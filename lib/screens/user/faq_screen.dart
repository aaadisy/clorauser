import 'dart:developer';
import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:clora_user/screens/user/blog_detail_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../extensions/animated_list/animated_list_view.dart';
import '../../extensions/colors.dart';
import '../../extensions/constants.dart';
import '../../extensions/loader_widget.dart';
import '../../extensions/new_colors.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../model/user/faq_model.dart';
import '../../network/rest_api.dart';
import '../../utils/app_common.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  Future<List<FaqData>>? _faqFuture;

  @override
  void initState() {
    super.initState();
    _faqFuture = _fetchFAQs();
    logScreenView("Faq screen");
  }

  /// Api call
  Future<List<FaqData>> _fetchFAQs() async {
    appStore.setLoading(true);
    try {
      final response = await fetchFAQListApi();
      if (response.data != null && response.data!.isNotEmpty) {
        return response.data!;
      }
      return [];
    } catch (e) {
      log("Error fetching FAQs: $e");
      return [];
    } finally {
      appStore.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: kPrimaryColor,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: kPrimaryColor,
                child: Column(
                  children: [
                    10.height,
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            CupertinoIcons.back,
                            color: mainColorText,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            language.faq,
                            style: boldTextStyle(
                              size: textFontSize_18,
                              weight: FontWeight.w500,
                              color: mainColorText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    10.height,
                  ],
                ),
              ),
              // Scrollable Content
              Expanded(
                child: Container(
                  width: context.width(),
                  decoration: const BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: FutureBuilder<List<FaqData>>(
                    future: _faqFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Loader().center();
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text(language.noFAQsFound));
                      } else {
                        final mFAQData = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              language.NoteTapOntoAnswer,
                              style: primaryTextStyle(
                                  size: textFontSize_10, color: Colors.red),
                            ).paddingSymmetric(horizontal: 16, vertical: 8),
                            Expanded(
                              child: AnimatedListView(
                                shrinkWrap: true,
                                itemCount: mFAQData.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: 0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ExpansionTile(
                                      shape: Border(),
                                      tilePadding:
                                          EdgeInsets.symmetric(horizontal: 12),
                                      iconColor: primaryColor,
                                      collapsedIconColor: primaryColor,
                                      title: HtmlWidget(
                                          mFAQData[index].question ?? ""),
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    CupertinoIcons
                                                        .check_mark_circled_solid,
                                                    color: Colors.green,
                                                    size: 14,
                                                  ),
                                                  Text(
                                                    ' ${language.AnsweredBy} ',
                                                    style: primaryTextStyle(
                                                      size: textFontSize_14,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Text(
                                                    language.Management,
                                                    style: boldTextStyle(
                                                        size: textFontSize_14,
                                                        weight: FontWeight.w500,
                                                        color: mainColorText),
                                                  ),
                                                ],
                                              ),
                                              10.height,
                                              HtmlWidget(
                                                mFAQData[index].answer ?? '',
                                              ),
                                              10.height,
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).paddingSymmetric(horizontal: 16).onTap(() {
                                    if (mFAQData[index].article != null) {
                                      BlogDetailScreen(
                                        article: mFAQData[index].article!,
                                        onBookmarkUpdated: (updatedArticle) {
                                          setState(() {
                                            mFAQData[index].article =
                                                updatedArticle;
                                          });
                                        },
                                      ).launch(context);
                                    }
                                  }).paddingSymmetric(vertical: 4);
                                  // return Column(
                                  //   children: [
                                  //     Container(
                                  //       decoration: boxDecorationWithRoundedCorners(
                                  //         backgroundColor: fifthColor,
                                  //         borderRadius: radius(defaultRadius),
                                  //       ),
                                  //       child: ExpansionTile(
                                  //         shape: const Border(),
                                  //         title: HtmlWidget(
                                  //             postContent: mFAQData[index].question),
                                  //         children: [
                                  //           Column(
                                  //             mainAxisAlignment:
                                  //             MainAxisAlignment.start,
                                  //             crossAxisAlignment:
                                  //             CrossAxisAlignment.start,
                                  //             children: [
                                  //               Row(
                                  //                 children: [
                                  //                   Icon(
                                  //                     CupertinoIcons
                                  //                         .check_mark_circled_solid,
                                  //                     color: Colors.green,
                                  //                     size: 16,
                                  //                   ),
                                  //                   5.width,
                                  //                   Text(
                                  //                     language.AnsweredBy,
                                  //                     style: primaryTextStyle(
                                  //                       size: textFontSize_14,
                                  //                       color: Colors.grey,
                                  //                     ),
                                  //                   ),
                                  //                   5.width,
                                  //                   Text(
                                  //                     "Management",
                                  //                     style: boldTextStyle(size: textFontSize_14,color: mainColorText,weight: FontWeight.w500)
                                  //                   ),
                                  //
                                  //                 ],
                                  //               ).paddingSymmetric(horizontal: 16),
                                  //               HtmlWidget(
                                  //                 postContent:
                                  //                 mFAQData[index].answer ?? '',
                                  //               ).paddingSymmetric(horizontal: 16),
                                  //             ],
                                  //           ).onTap(() {
                                  //             if (mFAQData[index].article != null) {
                                  //               BlogDetailScreen(
                                  //                 article: mFAQData[index].article!,
                                  //                 onBookmarkUpdated:
                                  //                     (updatedArticle) {
                                  //                   setState(() {
                                  //                     mFAQData[index].article =
                                  //                         updatedArticle;
                                  //                   });
                                  //                 },
                                  //               ).launch(context);
                                  //             }
                                  //           }),
                                  //         ],
                                  //       ),
                                  //     ).paddingSymmetric(horizontal: 16, vertical: 8),
                                  //   ],
                                  // );
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
