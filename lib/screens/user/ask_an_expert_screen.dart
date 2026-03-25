import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/extensions/new_colors.dart';
import 'package:clora_user/main.dart';
import 'package:clora_user/utils/app_common.dart';
import 'package:clora_user/utils/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart' show MultipartFile, MultipartRequest;
import 'package:image_picker/image_picker.dart';

import '../../network/network_utils.dart';
import 'ask_expert_list_screen.dart';

class AskAnExpertScreen extends StatefulWidget {
  const AskAnExpertScreen({super.key});

  @override
  State<AskAnExpertScreen> createState() => _AskAnExpertScreenState();
}

class _AskAnExpertScreenState extends State<AskAnExpertScreen> {
  @override
  void initState() {
    super.initState();
    logScreenView("Ask an expert screen");
  }

  TextEditingController questionTitleCont = TextEditingController();
  TextEditingController questionContentCont = TextEditingController();
  List<File> imageFiles = [];

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Function to pick image
  Future<void> pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFiles.add(File(pickedFile.path));
      });
    }
  }

  void saveExpertQuestion() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    appStore.setLoading(true);

    MultipartRequest multipartRequest =
        await getMultiPartRequest('askexpert-save');
    multipartRequest.fields['title'] = questionTitleCont.text;
    multipartRequest.fields['description'] = questionContentCont.text;

    if (imageFiles.isNotEmpty) {
      for (var imageFile in imageFiles) {
        multipartRequest.files.add(
          await MultipartFile.fromPath(
            'askexpert_image[]',
            imageFile.path,
          ),
        );
      }
    }

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
          appStore.setLoading(false);
          toast(message);
          pop();
          AskExpertListScreen().launch(context, shouldReplace: true);
        }
      },
      onError: (error) {
        log(multipartRequest.toString());
        toast(error.toString());
        appStore.setLoading(false);
      },
    ).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: mainColorLight,
            pinned: true,
            leading: IconButton(
              icon: Icon(CupertinoIcons.back, color: mainColorText),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              language.askAnExpert,
              style: boldTextStyle(
                color: mainColorText,
                size: 18,
                weight: FontWeight.w500,
              ),
            ),
            titleSpacing: 0,
            expandedHeight: 0,
            elevation: 0,
            surfaceTintColor: mainColorLight,
            forceElevated: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Stack(
                children: [
                  Container(
                    height: 40,
                    color: mainColorLight,
                  ),
                ],
              ),
              Transform.translate(
                offset: Offset(0, -30),
                child: Container(
                  width: context.width(),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Observer(
                    builder: (context) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Form(
                                  key: formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppTextField(
                                        controller: questionTitleCont,
                                        textFieldType: TextFieldType.NAME,
                                        errorThisFieldRequired:
                                            language.pleaseEnterTitle,
                                        readOnly:
                                            appStore.isLoading ? true : false,
                                        decoration: InputDecoration(
                                          labelText: language.questionTitle,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                            borderSide: BorderSide(
                                                color: Colors.black12,
                                                width: 5),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                            borderSide: BorderSide(
                                                color: Colors.black12,
                                                width: 1),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                            borderSide: BorderSide(
                                                color: mainColor, width: 0.5),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                            borderSide: BorderSide(
                                                color: errorColor, width: 0.5),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                            borderSide: BorderSide(
                                                color: errorColor,
                                                width:
                                                    0.5), // Border when error and focused
                                          ),
                                        ),
                                      ),
                                      16.height,
                                      AppTextField(
                                        textFieldType: TextFieldType.MULTILINE,
                                        controller: questionContentCont,
                                        maxLines: 8,
                                        errorThisFieldRequired:
                                            language.pleaseEnterQuestion,
                                        readOnly:
                                            appStore.isLoading ? true : false,
                                        decoration: InputDecoration(
                                          alignLabelWithHint: true,
                                          labelText: language.askYourQuestion,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                            borderSide: BorderSide(
                                                color: Colors.black12,
                                                width: 1),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                            borderSide: BorderSide(
                                                color: Colors.black12,
                                                width: 1),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                            borderSide: BorderSide(
                                                color: mainColor, width: 0.5),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                            borderSide: BorderSide(
                                                color: errorColor, width: 0.5),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                            borderSide: BorderSide(
                                                color: errorColor, width: 0.5),
                                          ),
                                        ),
                                      ),
                                      16.height.visible(imageFiles.isNotEmpty),
                                      SizedBox(
                                        height: 80,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: imageFiles.length,
                                          itemBuilder: (context, index) {
                                            return Stack(
                                              children: [
                                                Container(
                                                  width: 80,
                                                  margin: const EdgeInsets.only(
                                                      right: 8),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: mainColorStroke),
                                                    image: DecorationImage(
                                                      image: FileImage(
                                                          imageFiles[index]),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 4,
                                                  right: 4,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        imageFiles.removeAt(
                                                            index); // Remove the image from imageFiles
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.8),
                                                        // Semi-transparent background
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.close,
                                                        color: errorColor,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ).visible(imageFiles.isNotEmpty),
                                      16.height,
                                      DottedBorder(
                                        borderType: BorderType.RRect,
                                        radius: Radius.circular(12),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12)),
                                          child: Container(
                                            height: 60,
                                            width: double.infinity,
                                            color: Colors.white,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                // "+" Icon
                                                Icon(
                                                  Icons.add,
                                                  color: mainColor,
                                                  size: 24,
                                                ),
                                                8.width,
                                                // Spacing between elements
                                                // Text
                                                Text(
                                                  language.addAnImage,
                                                  style: boldTextStyle(
                                                    color: mainColorText,
                                                    size: 14,
                                                    weight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ).onTap(() {
                                            pickImage();
                                          }),
                                        ),
                                      ),
                                      32.height,
                                      Center(
                                        child: GestureDetector(
                                          onTap: appStore.isLoading
                                              ? null
                                              : saveExpertQuestion,
                                          // Disable tap when loading
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            transitionBuilder: (Widget child,
                                                Animation<double> animation) {
                                              return ScaleTransition(
                                                scale: animation,
                                                child: child,
                                              );
                                            },
                                            child: appStore.isLoading
                                                ? Loader(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            ColorUtils
                                                                .colorPrimary),
                                                  )
                                                : Transform.scale(
                                                    scale: 1.0,
                                                    child: AnimatedContainer(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    300),
                                                        width: 120,
                                                        height: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: ColorUtils
                                                              .colorPrimary,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(25),
                                                        ),
                                                        child: Text(
                                                          language.save,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ).center()),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ).paddingSymmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )
            ]),
          )
        ],
      ),
    );
  }
}
