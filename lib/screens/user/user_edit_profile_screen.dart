import 'dart:convert';
import 'dart:io';
import 'package:clora_user/utils/app_constants.dart';
import 'package:clora_user/utils/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extensions.dart';
import '../../extensions/new_colors.dart';
import '../../main.dart';
import '../../model/user/user_models/user_model.dart';
import '../../network/network_utils.dart';
import '../../utils/app_common.dart';
import '../../utils/app_images.dart';
import '../widgets/register_bottom_sheet_container.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  int selectedIndex = -1;

  XFile? image;
  String? profileImg = '';
  String? selectedAge;
  List<String> ageOptions = [];
  bool isEnabled = false;

  TextEditingController mFNameCont = TextEditingController();
  TextEditingController mLNameCont = TextEditingController();
  TextEditingController mEmailCount = TextEditingController();
  TextEditingController mUserTypeCount = TextEditingController();
  TextEditingController mPassCount = TextEditingController();

  FocusNode mFNameFocus = FocusNode();
  FocusNode mLNameFocus = FocusNode();
  FocusNode mEmailFocus = FocusNode();
  FocusNode mUserTypeFocus = FocusNode();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();

  unFocusNodes() {
    mFNameFocus.unfocus();
    mLNameFocus.unfocus();
    mEmailFocus.unfocus();
    mUserTypeFocus.unfocus();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setControllers();
    });

    logScreenView("User Edit Profile screen");
  }

  void setControllers() {
    ageOptions = generateBirthYearOptions();

    final user = userStore.user;

    if (user == null) return;

    setState(() {
      mFNameCont.text = user.firstName ?? "";
      mLNameCont.text = user.lastName ?? "";
      mEmailCount.text = user.email ?? "";

      selectedAge = user.age != null
          ? getBirthYearFromAge(user.age!)
          : null;

      mPassCount.text = getStringAsync(PASSWORD);

      mUserTypeCount.text = (user.userType == ANONYMOUS)
          ? "Anonymous User"
          : "App User";

      isEnabled = user.userType == ANONYMOUS ? false : true;
    });
  }

  Future getImage() async {
    image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 100);
    setState(() {});
  }

  Future getImageFromCamera() async {
    image = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 100);
    if (image != null) {
      setState(() {});
    }
  }

  Widget profileImage() {
    if (image != null) {
      return Container(
        padding: EdgeInsets.all(1),
        decoration: boxDecorationWithRoundedCorners(
          boxShape: BoxShape.circle,
          border: Border.all(width: 2, color: primaryColor),
        ),
        child: Image.file(
          File(image!.path),
          height: 100,
          width: 100,
          fit: BoxFit.cover,
        ).cornerRadiusWithClipRRect(65),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(1),
        decoration: boxDecorationWithRoundedCorners(
          boxShape: BoxShape.circle,
          border: Border.all(width: 2, color: primaryColor),
        ),
        child: ClipOval(
          child: cachedImage(
            userStore.user?.profileImage ?? "",
            fit: BoxFit.cover,
            width: 120,
            height: 120,
          ),
        ),
      );
    }
  }


// ================= SIGNUP FUNCTION FIX =================
  void signUp() async {
    hideKeyboard(context);
    unFocusNodes();

    // ✅ FIX: validation issue solve
    if (formKey2.currentState != null) {
      if (!formKey2.currentState!.validate()) return;
    }

    // ✅ prevent empty submit
    if (mFNameCont.text.trim().isEmpty &&
        mLNameCont.text.trim().isEmpty &&
        mEmailCount.text.trim().isEmpty &&
        image == null) {
      toast("Please update something");
      return;
    }

    appStore.setLoading(true);

    MultipartRequest multipartRequest =
    await getMultiPartRequest('update-profile');

    multipartRequest.fields['id'] = userStore.user!.id.toString();
    multipartRequest.fields['first_name'] = mFNameCont.text.trim();
    multipartRequest.fields['last_name'] = mLNameCont.text.trim();
    multipartRequest.fields['email'] = mEmailCount.text.trim();

    multipartRequest.fields['age'] =
    selectedAge != null
        ? getCurrentAgeFromYear(int.parse(selectedAge!)).toString()
        : "0";

    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    multipartRequest.fields['conversion_date'] =
        formatter.format(DateTime.now().toUtc());

    if (mPassCount.text.trim().isNotEmpty) {
      multipartRequest.fields['password'] = mPassCount.text.trim();
    }

    multipartRequest.fields['user_type'] = APP_USER;

    // ✅ IMAGE UPLOAD FIX
    if (image != null) {
      multipartRequest.files.add(
        await MultipartFile.fromPath(
          'profile_image',
          image!.path,
        ),
      );
    }

    multipartRequest.headers.addAll(buildHeaderTokens());

    sendMultiPartRequest(
      multipartRequest,
      onSuccess: (data) async {
        print("API RESPONSE: $data"); // 🔥 DEBUG

        appStore.setLoading(false);

        Map<String, dynamic> decodedData = jsonDecode(data);

        bool status = decodedData['responseData']['status'];
        String message =
            decodedData['responseData']['message'] ?? "Profile updated";

        if (status == true) {
          UserModel value =
          UserModel.fromJson(decodedData['responseData']['data']);

          setValue(USER_TYPE, APP_USER);
          setValue(USER_ID, value.id);
          setValue(EMAIL, value.email);
          setValue(FIRSTNAME, value.firstName);
          setValue(LASTNAME, value.lastName);
          setValue(PASSWORD, mPassCount.text.trim());
          setValue(IS_LOGIN, true);

          userStore.setUserModelData(value);

          setLogInValue(isFromEducationScreen: true);

          setState(() {
            image = null;
            mUserTypeCount.text = "App User";
            isEnabled = true;
          });

          toast(message);
        } else {
          toast(message);
        }
      },
      onError: (error) {
        print("ERROR: $error");
        appStore.setLoading(false);
        toast(error.toString());
      },
    ).catchError((e) {
      print("CATCH ERROR: $e");
      appStore.setLoading(false);
      toast(e.toString());
    });
  }



  void _showAnimatedBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              top: 16, bottom: MediaQuery.of(context).viewInsets.bottom),
          child: RegisterBottomSheetContainer(
              emailController: mEmailCount,
              passwordController: mPassCount,
              fnameController: mFNameCont,
              lnameController: mLNameCont,
              onTap: () {
                signUp();
              },
              formKey: formKey2),
        );
      },
    );
  }

  // Helper function extracted for cleaner code
  String getAgeText(String? selectedAge, String? userType) {
    if (selectedAge != null) {
      return "${language.YouRe} ${getCurrentAgeFromYear(int.parse(selectedAge))} ${language.yearsOld}";
    }
    return userType == ANONYMOUS ? '' : language.SelectYourBirthYear;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF6F6F6),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// 🔹 Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.arrow_back).onTap(() {
                            pop();
                          }),
                          SizedBox(width: 10),
                          Text("Edit Profile",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text("Save",
                          style: TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold))
                          .onTap(() {
                        signUp();
                      })
                    ],
                  ),

                  SizedBox(height: 20),

                  /// 🔹 Profile Image
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          profileImage(),
                          Positioned(
                            bottom: -5,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.purple.shade100,
                              child: Icon(Icons.camera_alt, size: 16),
                            ),
                          )
                        ],
                      ).onTap(() {
                        openBottomSheet();
                      }),
                      SizedBox(height: 10),
                      Text("Change Photo",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ).center(),

                  SizedBox(height: 30),

                  /// 🔹 Personal Info
                  Text("Personal Info",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  SizedBox(height: 16),

                _field("FULL NAME", "${mFNameCont.text} ${mLNameCont.text}")
                    .onTap(() {
                  _showAnimatedBottomSheet(context);
                }),

                  _field("PHONE NUMBER",
                      userStore.user?.phone ?? ''),

                _field("EMAIL ADDRESS", mEmailCount.text)
                    .onTap(() {
                  _showAnimatedBottomSheet(context);
                }),

                  SizedBox(height: 30),

                  /// 🔹 Health Info
                  Text("Health Info",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  SizedBox(height: 16),

                  _dateField("LAST PERIOD DATE", "01/03/2026"),

                  _field("CYCLE LENGTH (DAYS)", "28"),

                  _field("PERIOD LENGTH (DAYS)", "5"),
                ],
              ),
            ),

            /// 🔹 Loader
            Center(child: Loader()).visible(appStore.isLoading),
          ],
        ),
      ),
    );
  }

  Widget _field(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value),
        ),
        SizedBox(height: 14),
      ],
    );
  }

  Widget _dateField(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value),
              Icon(Icons.calendar_today, size: 18)
            ],
          ),
        ),
        SizedBox(height: 14),
      ],
    );
  }

  openBottomSheet() {
    return showModalBottomSheet(
      context: context,
      backgroundColor: white,
      elevation: 10,
      shape: RoundedRectangleBorder(
          borderRadius: radiusOnly(topLeft: 12, topRight: 12)),
      builder: (BuildContext context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: Icon(Icons.close, size: 24).onTap(() {
                finish(context);
              }),
            ),
            10.height,
            Container(
              width: context.width(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Ionicons.camera_outline, color: primaryColor),
                  16.width,
                  Text(language.camera,
                      style: primaryTextStyle(size: 18, color: black)),
                ],
              ),
            ).onTap(() {
              getImageFromCamera();
              finish(context);
            }),
            10.height,
            Divider(),
            10.height,
            Container(
              width: context.width(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(AntDesign.picture, color: primaryColor),
                  16.width,
                  Text(language.chooseImage, style: primaryTextStyle(size: 18)),
                ],
              ),
            ).onTap(() {
              getImage();
              finish(context);
            }),
            10.height,
          ],
        ).paddingSymmetric(horizontal: 16, vertical: 16);
      },
    );
  }
}
