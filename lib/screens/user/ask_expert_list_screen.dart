import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/utils/dynamic_theme.dart';
import 'package:clora_user/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../extensions/new_colors.dart';
import '../../main.dart';
import '../../model/user/dashboard_response.dart';
import '../../network/rest_api.dart';
import '../../utils/custom_dialog.dart';
import '../common/ask_question_widget.dart';
import '../common/expandable_text.dart';
import 'ask_an_expert_screen.dart';

class AskExpertListScreen extends StatefulWidget {
  const AskExpertListScreen({super.key});

  @override
  State<AskExpertListScreen> createState() => _AskExpertListScreenState();
}

class _AskExpertListScreenState extends State<AskExpertListScreen> {
  List<AskExpertList>? expertData = [];

  @override
  void initState() {
    super.initState();
    getExpertQuestionListApi();
    logScreenView("Ask an expert list screen");
  }

  Future<void> deleteExpertData(AskExpertList singleData) async {
    pop();
    appStore.setLoading(true);
    try {
      await deleteAskDataApi(singleData.id).then(
        (value) {
          if (value.status == true) {
            expertData?.remove(singleData);
            toast(value.message);
          } else {
            toast(value.message);
          }
          appStore.setLoading(false);
          setState(() {});
        },
      ).onError(
        (error, stackTrace) {
          toast(error.toString());
          appStore.setLoading(false);
        },
      );
    } catch (e) {
      appStore.setLoading(false);
    }
  }

  getExpertQuestionListApi() async {
    appStore.setLoading(true);
    await getPendingQuestionToExpertApi().then(
      (value) {
        appStore.setLoading(false);
        setState(() {
          expertData = value.data;
        });
      },
    ).whenComplete(
      () {
        appStore.setLoading(false);
      },
    ).onError(
      (error, stackTrace) {
        toast(error.toString());
      },
    );
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
              language.myQuestions,
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
            delegate: SliverChildListDelegate(
              [
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        20.height,
                        Text(
                          language.getExpertAnswersToYourHealthQuestions,
                          style: primaryTextStyle(
                              weight: FontWeight.w400,
                              size: 16,
                              color: mainColorBodyText),
                        ),
                        20.height,
                        Observer(
                          builder: (context) {
                            if (appStore.isLoading) {
                              return SizedBox(
                                height: context.height() -
                                    kToolbarHeight -
                                    context.statusBarHeight -
                                    80,
                                child: Center(
                                  child: Loader(),
                                ),
                              );
                            } else if (expertData == null ||
                                expertData!.isEmpty) {
                              return SizedBox(
                                height: context.height() -
                                    kToolbarHeight -
                                    context.statusBarHeight -
                                    80,
                                // Adjust for SliverAppBar, status bar, and header
                                child: Center(
                                  child: emptyWidget(),
                                ),
                              );
                            } else {
                              return ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: expertData!.length,
                                itemBuilder: (context, index) {
                                  final singleData = expertData![index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(12)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize
                                          .min, // Ensures Column takes minimal space
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey[200],
                                                border: Border.all(
                                                  color: Colors.transparent,
                                                  width: 1,
                                                ),
                                              ),
                                              child: ClipOval(
                                                child: cachedImage(
                                                  userStore.user?.profileImage,
                                                  fit: BoxFit.cover,
                                                  width: 60,
                                                  height: 60,
                                                ),
                                              ),
                                            ),
                                            12.width,
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    singleData.title,
                                                    style: boldTextStyle(
                                                      color: mainColorText,
                                                      size: 14,
                                                      weight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  4.height,
                                                  Text(
                                                    "${language.askedOn} ${convertUtcToLocal2(singleData.createdAt.toString())}",
                                                    style: primaryTextStyle(
                                                      color: mainColorBodyText,
                                                      size: 12,
                                                      weight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                showDialog(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder: (context) =>
                                                      CustomDialog(
                                                    icon: ic_delete_ac,
                                                    iconColor: mainColorLight,
                                                    title:
                                                        language.deleteQuestion,
                                                    description: language
                                                        .areYouSureYouWantToDeleteThisQuestion,
                                                    buttons: [
                                                      DialogButton(
                                                        text: language.cancel,
                                                        color: Colors.black,
                                                        isTransparent: true,
                                                        onPressed: () {
                                                          pop();
                                                        },
                                                      ),
                                                      DialogButton(
                                                        text: language.delete,
                                                        color: mainColor,
                                                        onPressed: () {
                                                          deleteExpertData(
                                                              singleData);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              icon: Icon(
                                                CupertinoIcons.delete,
                                                color: errorColor,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                        8.height,
                                        Divider(
                                            color: mainColorStroke,
                                            thickness: 1),
                                        8.height,
                                        ExpandableText(
                                          text: singleData.description,
                                          style: boldTextStyle(
                                            color: mainColorText,
                                            size: 14,
                                            weight: FontWeight.w400,
                                          ),
                                        ),
                                        if (singleData
                                            .askexpertImage.isNotEmpty) ...[
                                          8.height,
                                          SizedBox(
                                            height: 70,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: singleData
                                                  .askexpertImage.length,
                                              itemBuilder: (context, index) {
                                                final image = singleData
                                                    .askexpertImage[index];
                                                return Container(
                                                  width: 80,
                                                  margin: const EdgeInsets.only(
                                                      right: 8),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child:
                                                      ScrollableNetworkImageRow(
                                                    imageFiles: [image],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                        if (singleData.expertAnswer !=
                                            null) ...[
                                          8.height,
                                          Row(
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.grey[200],
                                                  border: Border.all(
                                                    color: Colors.transparent,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: ClipOval(
                                                  child: cachedImage(
                                                    singleData.expert
                                                        ?.healthExpertsImage,
                                                    fit: BoxFit.cover,
                                                    width: 60,
                                                    height: 60,
                                                  ),
                                                ),
                                              ),
                                              12.width,
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      singleData.expert?.name ??
                                                          "Dr Foo Doo",
                                                      style: boldTextStyle(
                                                        color: mainColorText,
                                                        size: 14,
                                                        weight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    4.height,
                                                    Text(
                                                      "${language.answeredOn} ${convertUtcToLocal2(singleData.updatedAt.toString())}",
                                                      style: primaryTextStyle(
                                                        color:
                                                            mainColorBodyText,
                                                        size: 12,
                                                        weight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          8.height,
                                          Divider(
                                              color: mainColorStroke,
                                              thickness: 1),
                                          8.height,
                                          ExpandableText(
                                            text: singleData.expertAnswer ??
                                                "Foo Doo",
                                            style: boldTextStyle(
                                              color: mainColorText,
                                              size: 14,
                                              weight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AskAnExpertScreen().launch(context);
        },
        child: Icon(Icons.message, color: Colors.white),
        backgroundColor: ColorUtils.colorPrimary,
      ),
    );
  }
}
