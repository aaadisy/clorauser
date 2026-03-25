import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/new_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:story_view/controller/story_controller.dart';

import '../../components/user/story_page_component.dart';
import '../../extensions/extensions.dart';
import '../../main.dart';
import '../../model/user/category_models/category_list_response.dart';
import '../../network/rest_api.dart';
import '../../utils/app_common.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_images.dart';
import '../screens.dart';

class InsightsScreen extends StatefulWidget {
  static String tag = '/InsightsScreen';

  @override
  InsightsScreenState createState() => InsightsScreenState();
}

class InsightsScreenState extends State<InsightsScreen> {
  final storyController = StoryController();

  List<CategoryData> mCategoryData = [];
  List<SectionData> mSectionData = [];
  List<String> urls = [];

  @override
  void initState() {
    super.initState();
    getCategoryListApiCall();
    logScreenView("Insights screen");
  }

  bool validateYouTubeUrl(String? url) {
    if (url != null) {
      RegExp regExp = RegExp(
          r"(https?://)?(www\.)?(youtube\.com/watch\?v=|youtu\.be/)([a-zA-Z0-9_-]+)");
      return regExp.hasMatch(url);
    }
    return false;
  }

  ///title
  Widget getHeaderTitle(String title) {
    return Text(
      title,
      style: boldTextStyle(
          size: textFontSize_16, color: mainColorText, weight: FontWeight.w600),
    ).paddingSymmetric(horizontal: 16);
  }

  ///type view
  Widget getTypeView(String title, String img) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: boxDecorationWithRoundedCorners(
          borderRadius: BorderRadius.circular(defaultRadius),
          backgroundColor: Colors.black26),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(img, height: 14, width: 14, fit: BoxFit.cover),
        ],
      ),
    );
  }

  ///api call
  Future<void> getCategoryListApiCall() async {
    try {
      appStore.setLoading(true);
      setState(() {});
      try {
        final value = await getCategoryListApi(id: userStore.goalIndex);

        mCategoryData = value.categoryData!;
        mSectionData = value.sectionData!;
        appStore.setLoading(false);
        setState(() {});
      } catch (e) {
        appStore.setLoading(false);
      }
    } catch (e, s) {
      log("Insight Error ======>> ${e}, ${s}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double baseWidth = 360;
    final double maxScale = 1.2;

    final double scaleFactor =
        (MediaQuery.of(context).size.width / baseWidth).clamp(1.0, maxScale);

    final double kContainerHeight = 200 * scaleFactor;
    final double kContainerWidth = 120 * scaleFactor;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: mainColorLight,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  Stack(
                    children: [
                      mCategoryData.isNotEmpty
                          ? Container(
                              height: 190,
                              decoration: BoxDecoration(
                                color: mainColorLight,
                              ),
                              padding: EdgeInsets.all(12),
                              child: HorizontalList(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  itemCount: mCategoryData.length,
                                  itemBuilder: (context, i) {
                                    return Container(
                                      height: 130,
                                      width: 107,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            defaultRadius),
                                        color: mainWhite,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          10.height,
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                defaultRadius),
                                            child: cachedImage(
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              mCategoryData[i]
                                                  .categoryThumbnailImage
                                                  .toString(),
                                            ),
                                          ),
                                          10.height,
                                          Container(
                                            width: 100,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4),
                                            child: Text(
                                              mCategoryData[i].title.toString(),
                                              style: primaryTextStyle(
                                                  size: textFontSize_12,
                                                  weight: FontWeight.w500,
                                                  color: mainColorText),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          10.height,
                                        ],
                                      ),
                                    ).onTap(() {
                                      CategoryDetailsScreen(mCategoryData[i])
                                          .launch(context);
                                    });
                                  }),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                  mSectionData.isNotEmpty
                      ? Transform.translate(
                          offset: Offset(0, -30),
                          child: Container(
                            width: context.width(),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            child: Column(
                              children: [
                                Center(
                                  child: Container(
                                    width: 46,
                                    height: 4,
                                    margin: const EdgeInsets.only(
                                        top: 10, bottom: 10),
                                    decoration: BoxDecoration(
                                      color: mainColorStroke,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                ListView.builder(
                                    physics: ScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: mSectionData.length,
                                    itemBuilder: (context, i) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          getHeaderTitle(
                                              mSectionData[i].title.toString()),
                                          10.height,
                                          mSectionData[i].subSectionData != null
                                              ? HorizontalList(
                                                  padding: EdgeInsets.only(
                                                      left: 16,
                                                      top: 0,
                                                      bottom: 10),
                                                  itemCount: mSectionData[i]
                                                      .subSectionData!
                                                      .length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final subSection =
                                                        mSectionData[i]
                                                                .subSectionData![
                                                            index];
                                                    return Container(
                                                      height: kContainerHeight,
                                                      width: kContainerWidth,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Expanded(
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            defaultRadius),
                                                              ),
                                                              child: Stack(
                                                                clipBehavior:
                                                                    Clip.hardEdge,
                                                                children: [
                                                                  cachedImage(
                                                                    subSection
                                                                        .sectionDataImage
                                                                        .toString(),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    height:
                                                                        kContainerHeight -
                                                                            30,
                                                                    width:
                                                                        kContainerWidth,
                                                                  ).cornerRadiusWithClipRRect(
                                                                      defaultRadius),
                                                                  Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomRight,
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        getTypeView("Story",
                                                                                ic_story)
                                                                            .visible(subSection.viewType ==
                                                                                STORY_VIEW),
                                                                        getTypeView("Video",
                                                                                ic_video)
                                                                            .visible(subSection.viewType ==
                                                                                VIDEO),
                                                                        getTypeView("Video Course",
                                                                                ic_video)
                                                                            .visible(subSection.viewType ==
                                                                                VIDEO_COURSE),
                                                                        getTypeView("Podcast",
                                                                                ic_podcast)
                                                                            .visible(subSection.viewType ==
                                                                                PODCAST),
                                                                        getTypeView("Blog",
                                                                                ic_blog)
                                                                            .visible(subSection.viewType ==
                                                                                BLOG),
                                                                        getTypeView("Blog Course",
                                                                                ic_blog)
                                                                            .visible(subSection.viewType ==
                                                                                BLOG_COURSE),
                                                                      ],
                                                                    ),
                                                                  ).paddingSymmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          10),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          // Added text with max 2 lines and ellipsis
                                                          8.height,
                                                          // Space between image and text
                                                          Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        4),
                                                            child: Text(
                                                              subSection
                                                                      .title ??
                                                                  '',
                                                              style: primaryTextStyle(
                                                                  size:
                                                                      textFontSize_12,
                                                                  weight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color:
                                                                      mainColorText),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ).onTap(() {
                                                      if (subSection.viewType ==
                                                          STORY_VIEW) {
                                                        urls = subSection
                                                            .sectionDataStoryImage!
                                                            .map((story) =>
                                                                story.url
                                                                    .toString())
                                                            .toList();
                                                        StoryPage(
                                                                imageUrls: urls)
                                                            .launch(context);
                                                      } else if (subSection
                                                              .viewType ==
                                                          VIDEO) {
                                                        final video = subSection
                                                            .sectionDataVideo!
                                                            .first;
                                                        if (video.fileUrl!.contains(
                                                                "youtube.com") &&
                                                            validateYouTubeUrl(
                                                                video
                                                                    .fileUrl)) {
                                                          YoutubeVideoScreen(
                                                                  url: video
                                                                      .fileUrl)
                                                              .launch(context);
                                                        } else {
                                                          VideoPlayerScreen(
                                                                  thumbnail: video
                                                                      .thumbnailImage,
                                                                  url: video
                                                                      .fileUrl)
                                                              .launch(context);
                                                        }
                                                      } else if (subSection
                                                              .viewType ==
                                                          CATEGORIES) {
                                                        CategoryData cat =
                                                            CategoryData(
                                                                id: subSection
                                                                    .categoryId,
                                                                title: subSection
                                                                    .categoryName);
                                                        CategoryDetailsScreen(
                                                                cat)
                                                            .launch(context);
                                                      } else if (subSection
                                                              .viewType ==
                                                          VIDEO_COURSE) {
                                                        VideoCourseScreen(
                                                          subSectionData:
                                                              subSection,
                                                          sectionDataVideo:
                                                              subSection
                                                                  .sectionDataVideo,
                                                        ).launch(context);
                                                      } else if (subSection
                                                              .viewType ==
                                                          BLOG_COURSE) {
                                                        BlogCourseScreen(
                                                          article: subSection
                                                              .article,
                                                          subSectionData:
                                                              subSection,
                                                        ).launch(context);
                                                      } else if (subSection
                                                              .viewType ==
                                                          PODCAST) {
                                                        PodcastScreen(
                                                                subSection)
                                                            .launch(context);
                                                      } else if (subSection
                                                              .viewType ==
                                                          BLOG) {
                                                        if (subSection
                                                                    .article ==
                                                                null ||
                                                            subSection.article!
                                                                .isEmpty) {
                                                          return;
                                                        } else {
                                                          BlogDetailScreen(
                                                            article: subSection
                                                                .article!.first,
                                                            onBookmarkUpdated:
                                                                (updatedArticle) {
                                                              setState(() {
                                                                subSection
                                                                        .article!
                                                                        .first =
                                                                    updatedArticle;
                                                              });
                                                            },
                                                          ).launch(context);
                                                        }
                                                      }
                                                    });
                                                  },
                                                )
                                              : SizedBox(),
                                        ],
                                      ).paddingOnly(bottom: 8);
                                    }).paddingOnly(top: 8),
                              ],
                            ),
                          ),
                        )
                      : NoDataWidget(),
                ],
              ),
            ),
            Loader().visible(appStore.isLoading)
          ],
        ),
      ),
    );
  }
}
