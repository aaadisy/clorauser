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
    setControllers();
    logScreenView("User Edit Profile screen");
  }

  setControllers() {
    ageOptions = generateBirthYearOptions();
    setState(() {
      mFNameCont.text = userStore.user!.firstName!;
      mLNameCont.text = userStore.user!.lastName!;
      mEmailCount.text = userStore.user!.email!;
      selectedAge = userStore.user!.age != null
          ? getBirthYearFromAge(userStore.user!.age!)
          : null;
      mPassCount.text = getStringAsync(PASSWORD);
      mUserTypeCount.text = (userStore.user!.userType == ANONYMOUS)
          ? "Anonymous User"
          : "App User";

      isEnabled = userStore.user!.userType == ANONYMOUS ? false : true;
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
            border: Border.all(width: 2, color: primaryColor)),
        child: Image.file(File(image!.path),
                height: 100, width: 100, fit: BoxFit.cover)
            .cornerRadiusWithClipRRect(65),
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
            userStore.user!.profileImage,
            fit: BoxFit.cover,
            width: 120,
            height: 120,
          ),
        ),
      );
    }
  }

  void signUp() async {
    hideKeyboard(context);
    unFocusNodes();
    if (formKey2.currentState?.validate() ??
        formKey.currentState?.validate() ??
        false) {
      if (userStore.user!.userType! != APP_USER) {
        pop();
      }
      appStore.setLoading(true);
      MultipartRequest multipartRequest =
          await getMultiPartRequest('update-profile');
      multipartRequest.fields['id'] = userStore.user!.id.toString();
      multipartRequest.fields['first_name'] = mFNameCont.text;
      multipartRequest.fields['last_name'] = mLNameCont.text;
      multipartRequest.fields['email'] = mEmailCount.text.trim();
      multipartRequest.fields['age'] =
          getCurrentAgeFromYear(int.parse(selectedAge!)).toString() ;
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      multipartRequest.fields['conversion_date'] =
          formatter.format(DateTime.now().toUtc());
      if (mPassCount.text.trim().isNotEmpty)
        multipartRequest.fields['password'] = mPassCount.text.trim();
      multipartRequest.fields['user_type'] = APP_USER;
      if (image != null)
        multipartRequest.files.add(
          await MultipartFile.fromPath(
            'profile_image',
            image!.path,
          ),
        );
      multipartRequest.headers.addAll(buildHeaderTokens());
      sendMultiPartRequest(
        multipartRequest,
        onSuccess: (data) async {
          appStore.setLoading(false);
          String rawData = data;
          Map<String, dynamic> decodedData = jsonDecode(rawData);
          bool status = decodedData['responseData']['status'];
          String message = decodedData['responseData']['message'];

          if (status == true) {
            UserModel value =
                UserModel.fromJson(decodedData['responseData']['data']);
            if (status == true) {
              setValue(USER_TYPE, APP_USER);
              setValue(USER_ID, value.id);
              setValue(EMAIL, value.email);
              setValue(FIRSTNAME, value.firstName);
              setValue(LASTNAME, value.lastName);
              setValue(PASSWORD, mPassCount.text.trim());
              setValue(IS_LOGIN, true);
              userStore.setUserModelData(value);
              setLogInValue(isFromEducationScreen: true);
              appStore.setLoading(false);
              mUserTypeCount.text = "App User";
              isEnabled = true;
              setState(() {});
              toast(message);
            }
          }
        },
        onError: (error) {
          log("Multipart Request " + multipartRequest.fields.length.toString());
          toast(error.toString());
          appStore.setLoading(false);
        },
      ).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    }
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: mainColorLight,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(body: Observer(
        builder: (context) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                              height: context.height() * 0.4,
                              color: mainColorLight),
                          Icon(CupertinoIcons.back, color: Colors.black)
                              .onTap(() {
                            pop();
                          }).paddingOnly(
                                  top: context.statusBarHeight + 16, left: 16),
                          Container(
                            margin:
                                EdgeInsets.only(top: context.height() * 0.2),
                            height: context.height() * 0.8,
                            decoration: boxDecorationWithRoundedCorners(
                              backgroundColor: Colors.white,
                              borderRadius: radiusOnly(
                                  topRight: defaultRadius,
                                  topLeft: defaultRadius),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: context.height() * 0.1,
                                right: 16,
                                left: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                16.height,
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    profileImage(),
                                  ],
                                ).onTap(() {
                                  if (context.mounted) {
                                    if (userStore.user!.userType == ANONYMOUS) {
                                      toast(language
                                          .anonymousUsersCannotChangeTheProfileImage);
                                    } else {
                                      openBottomSheet();
                                    }
                                  }
                                }).center(),
                                18.height,
                                Text(language.firstName,
                                    style: primaryTextStyle()),
                                8.height,
                                AppTextField(
                                  controller: mFNameCont,
                                  readOnly:
                                      getStringAsync(USER_TYPE) == APP_USER
                                          ? false
                                          : true,
                                  textFieldType: TextFieldType.NAME,
                                  isValidationRequired: true,
                                  focus: mFNameFocus,
                                  nextFocus: mLNameFocus,
                                  suffix: mSuffixTextFieldIconWidget(
                                      ic_user, Colors.black),
                                  decoration: defaultInputDecoration(context,
                                      label: language.pleaseEnterFirstName),
                                ),
                                8.height,
                                Text(language.lastName,
                                    style: primaryTextStyle()),
                                8.height,
                                AppTextField(
                                  controller: mLNameCont,
                                  readOnly:
                                      getStringAsync(USER_TYPE) == APP_USER
                                          ? false
                                          : true,
                                  textFieldType: TextFieldType.NAME,
                                  isValidationRequired: true,
                                  focus: mLNameFocus,
                                  nextFocus: mEmailFocus,
                                  suffix: mSuffixTextFieldIconWidget(
                                      ic_user, Colors.black),
                                  decoration: defaultInputDecoration(context,
                                      label: language.pleaseEnterLastName),
                                ),
                                8.height,
                                Text(language.WhatYearWereYouBorn,
                                    style: primaryTextStyle()),
                                8.height,
                                DropdownButtonFormField<String>(
                                  value: selectedAge,
                                  hint: Text(language.SelectYourBirthYear),
                                  items: ageOptions.map((age) {
                                    return DropdownMenuItem<String>(
                                      value: age,
                                      child: Text(age),
                                    );
                                  }).toList(),
                                  onChanged: isEnabled
                                      ? (value) {
                                          setState(() => selectedAge = value);
                                        }
                                      : null,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                ),
                                2.height,
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    getAgeText(
                                        selectedAge, userStore.user?.userType),
                                    style: boldTextStyle(size: 12),
                                  ),
                                ),
                                8.height,
                                Text(language.email, style: primaryTextStyle()),
                                8.height,
                                AppTextField(
                                  controller: mEmailCount,
                                  readOnly: true,
                                  textFieldType: TextFieldType.NAME,
                                  isValidationRequired: true,
                                  focus: mEmailFocus,
                                  nextFocus: mUserTypeFocus,
                                  suffix: mSuffixTextFieldIconWidget(
                                      ic_mail, Colors.black),
                                  decoration: defaultInputDecoration(context,
                                      label: language.pleaseEnterEmail),
                                ),
                                8.height,
                                Text(language.userType,
                                    style: primaryTextStyle()),
                                8.height,
                                AppTextField(
                                  controller: mUserTypeCount,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  textFieldType: TextFieldType.NAME,
                                  isValidationRequired: true,
                                  focus: mUserTypeFocus,
                                  nextFocus: null,
                                  readOnly: true,
                                  suffix: Icon(
                                      getStringAsync(USER_TYPE) == APP_USER
                                          ? Icons.verified_user
                                          : Icons.no_accounts,
                                      color: Colors.black),
                                  decoration: defaultInputDecoration(context,
                                      label: language.userType),
                                ),
                                16.height,
                                // 28.height,
                                userStore.user!.userType == APP_USER
                                    ? AppButton(
                                        color: mainColor,
                                        disabledColor: mainColor,
                                        width: context.width(),
                                        elevation: 0,
                                        text: language.updateProfile,
                                        onTap: signUp,
                                      )
                                    : AppButton(
                                        color: mainColor,
                                        disabledColor: mainColor,
                                        width: context.width(),
                                        elevation: 0,
                                        text: language.joinAsAnAppUser,
                                        onTap: () async {
                                          final isConnected =
                                              await isNetworkAvailable();
                                          if (!isConnected) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(language
                                                      .internetRequiredForThisAction),
                                                  backgroundColor:
                                                      ColorUtils.colorPrimary,
                                                ),
                                              );
                                            }
                                            return null;
                                          } else {
                                            _showAnimatedBottomSheet(context);
                                          }
                                        },
                                      )
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Center(
                child: Loader(), // Ensure the loader is centered
              ).visible(appStore.isLoading),
            ],
          );
        },
      )),
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
