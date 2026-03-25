import 'package:clora_user/extensions/extension_util/context_extensions.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../components/user/story_page_component.dart';
import '../../extensions/custom_marquee.dart';
import '../../extensions/extensions.dart';
import '../../extensions/new_colors.dart';
import '../../main.dart';
import '../../model/user/category_models/category_data_response.dart';
import '../../model/user/category_models/category_list_response.dart';
import '../../network/rest_api.dart';
import '../../utils/utils.dart';
import '../screens.dart';

//ignore: must_be_immutable
class CategoryDetailsScreen extends StatefulWidget {
  static String tag = '/PosterDetailScreen';
  CategoryData? mCategoryData;

  CategoryDetailsScreen(
    this.mCategoryData,
  );

  @override
  CategoryDetailsScreenState createState() => CategoryDetailsScreenState();
}

class CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  List<ImageSection> mCategoryImage = [];
  List<CommonQueSectionData> mCommonQuestionAndAnswer = [];
  List<InfoSections> mInformation = [];
  List<SectionDataMainList> mSectionData = [];
  List<String> urls = [];
  ScrollController? _scrollController;
  String HeaderImage = '';

  @override
  void initState() {
    super.initState();
    getCategoryDetailApiCall();
    logScreenView("Category details screen");
  }

  bool validateYouTubeUrl(String? url) {
    if (url != null) {
      RegExp regExp = RegExp(
          r"(https?://)?(www\.)?(youtube\.com/watch\?v=|youtu\.be/)([a-zA-Z0-9_-]+)");
      return regExp.hasMatch(url);
    }
    return false;
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  ///api call
  Future<void> getCategoryDetailApiCall() async {
    appStore.setLoading(true);
    log("CAT_ID::: ${widget.mCategoryData!.id}");
    getCategoryDetailsApi(categoryId: widget.mCategoryData!.id).then((value) {
      appStore.setLoading(false);
      HeaderImage = value.categoryImage ?? "";
      mCategoryImage = value.imageSection ?? [];
      mCommonQuestionAndAnswer = value.commonQueSectionData ?? [];
      mInformation = value.infoSections ?? [];
      mSectionData = value.sectionDataMainList ?? [];
      setState(() {});
    }).catchError((e, s) {
      appStore.setLoading(false);
      setState(() {});
    });
  }

  ///type view
  Widget getTypeView(String title, String img) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: boxDecorationWithRoundedCorners(
          borderRadius: BorderRadius.circular(defaultRadius),
          backgroundColor: Colors.black38),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(img,
              height: 10, width: 10, color: Colors.white, fit: BoxFit.cover),
        ],
      ),
    );
  }

  ///title
  getHeaders(String title) {
    return Text(title,
        style: boldTextStyle(
          size: textFontSize_16,
          weight: FontWeight.w500,
          isHeader: true,
        )).paddingSymmetric(horizontal: 16);
  }

  @override
  Widget build(BuildContext context) {
    final double scaleFactor = MediaQuery.of(context).size.width / 360;
    final double kContainerHeight = 200 * scaleFactor;
    final double kContainerWidth = 120 * scaleFactor;

    return Scaffold(
      backgroundColor: bgColor,
      body: appStore.isLoading
          ? Loader().center()
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: mainColorLight,
                  pinned: true,
                  leading: IconButton(
                    icon: Icon(CupertinoIcons.back, color: mainColorText),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: LayoutBuilder(
                    builder: (context, constraints) {
                      final textPainter = TextPainter(
                        text: TextSpan(
                          text: widget.mCategoryData!.title.toString(),
                          style: boldTextStyle(
                            color: mainColorText,
                            size: 16,
                            weight: FontWeight.w500,
                          ),
                        ),
                        maxLines: 1,
                        textDirection: TextDirection.ltr,
                      )..layout(maxWidth: constraints.maxWidth - 100);

                      final isOverflowing = textPainter.didExceedMaxLines;
                      return isOverflowing
                          ? SizedBox(
                              height: 30,
                              child: CustomMarquee(
                                child: Text(
                                  widget.mCategoryData!.title.toString(),
                                  style: boldTextStyle(
                                    color: mainColorText,
                                    size: 16,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                                scrollDuration: Duration(seconds: 10),
                                blankSpace: 10.0,
                              ),
                            )
                          : Text(
                              widget.mCategoryData!.title.toString(),
                              style: boldTextStyle(
                                color: mainColorText,
                                size: 18,
                                weight: FontWeight.w500,
                              ),
                            );
                    },
                  ),
                  expandedHeight: 0,
                  elevation: 0,
                  surfaceTintColor: mainColorLight,
                  forceElevated: true,
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    // Header Image with overlay and HorizontalList
                    Stack(
                      children: [
                        cachedImage(
                          HeaderImage,
                          width: context.width(),
                          height: 350,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: SizedBox(
                            height: MediaQuery.of(context).size.width * 0.35,
                            child: HorizontalList(
                              itemCount: mCategoryImage.length,
                              padding: EdgeInsets.only(left: 16),
                              itemBuilder: (context, i) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        width: 2,
                                        color: Colors.white.withValues(alpha: 0.5)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  height:
                                      MediaQuery.of(context).size.width * 0.30,
                                  width: context.width() * 0.30,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: cachedImage(
                                      mCategoryImage[i]
                                          .imageSectionThumbnailImage,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ).onTap(() {
                                  BlogDetailScreen(
                                    article: mCategoryImage[i].article,
                                    onBookmarkUpdated: (updatedArticle) {
                                      setState(() {
                                        mCategoryImage[i].article =
                                            updatedArticle;
                                      });
                                    },
                                  ).launch(context);
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Transform.translate(
                      offset: Offset(0, -20),
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
                            // Information Horizontal List
                            HorizontalList(
                              itemCount: mInformation.length,
                              itemBuilder: (context, i) {
                                return SizedBox(
                                  width: context.width() * 0.45,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Stack(
                                          clipBehavior: Clip.hardEdge,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: [
                                                  Color(0xFFFED8E0),
                                                  Color(0xFFD9ECF5),
                                                  Color(0xFFE5DEF2),
                                                  Color(0xFFFAE8E9),
                                                  Color(0xFFFBEEC8),
                                                ][i % 5],
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (!mInformation[i]
                                                      .infoSectionImage!
                                                      .contains(ic_default))
                                                    cachedImage(
                                                      mInformation[i]
                                                          .infoSectionImage,
                                                      height: 35,
                                                      width: 35,
                                                    ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        mInformation[i]
                                                            .title
                                                            .toString(),
                                                        style: boldTextStyle(
                                                          size: textFontSize_14,
                                                          weight:
                                                              FontWeight.w500,
                                                          color: mainColorText,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      )
                                                          .paddingOnly(
                                                              top: 10,
                                                              bottom: 10)
                                                          .expand(),
                                                      Icon(
                                                          Icons
                                                              .arrow_forward_ios,
                                                          size: 12,
                                                          color: mainColorText),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ).onTap(() {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                        defaultRadius),
                                                    topRight: Radius.circular(
                                                        defaultRadius),
                                                  ),
                                                ),
                                                builder:
                                                    (BuildContext context) {
                                                  return IntrinsicHeight(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (!mInformation[i]
                                                            .infoSectionImage!
                                                            .contains(
                                                                ic_default))
                                                          cachedImage(
                                                            mInformation[i]
                                                                .infoSectionImage,
                                                            height: 40,
                                                            width: 40,
                                                          ),
                                                        16.height,
                                                        Text(
                                                          mInformation[i]
                                                              .title
                                                              .toString(),
                                                          style: boldTextStyle(
                                                              size: 14,
                                                              weight: FontWeight
                                                                  .bold,
                                                              color:
                                                                  mainColorText),
                                                        ),
                                                        16.height,
                                                        if (mInformation[i]
                                                                    .description !=
                                                                null &&
                                                            mInformation[i]
                                                                .description!
                                                                .isNotEmpty)
                                                          HtmlWidget(
                                                            mInformation[i]
                                                                .description
                                                                .toString(),
                                                          ),
                                                        20.height,
                                                      ],
                                                    ).paddingAll(16),
                                                  );
                                                },
                                              );
                                            }),
                                            Positioned(
                                              top: -4,
                                              right: 0,
                                              child: Image.asset(
                                                ic_leaf,
                                                height: 65,
                                                width: 65,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ).paddingOnly(left: 16, top: 26, bottom: 16),
                            if (mCommonQuestionAndAnswer.isNotEmpty) ...[
                              8.height,
                              getHeaders('Common Question Answer'),
                              8.height,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListView.builder(
                                    padding: EdgeInsets.zero,
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: mCommonQuestionAndAnswer.length,
                                    itemBuilder: (context, i) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.white.withValues(alpha: 0.5),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ExpansionTile(
                                          shape: Border(),
                                          tilePadding: EdgeInsets.symmetric(
                                              horizontal: 12),
                                          iconColor: primaryColor,
                                          collapsedIconColor: primaryColor,
                                          title: Text(
                                            mCommonQuestionAndAnswer[i]
                                                .question
                                                .toString(),
                                            style: primaryTextStyle(
                                                size: 16,
                                                weight: FontWeight.w400,
                                                color: mainColorText),
                                          ),
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
                                                        mCommonQuestionAndAnswer[
                                                                        i]
                                                                    .article
                                                                    ?.expertData!
                                                                    .name
                                                                    ?.isNotEmpty ??
                                                                false
                                                            ? mCommonQuestionAndAnswer[
                                                                    i]
                                                                .article!
                                                                .expertData!
                                                                .name!
                                                            : language
                                                                .Management,
                                                        style: boldTextStyle(
                                                            size:
                                                                textFontSize_14,
                                                            weight:
                                                                FontWeight.w500,
                                                            color:
                                                                mainColorText),
                                                      ),
                                                    ],
                                                  ),
                                                  10.height,
                                                  Text(
                                                    mCommonQuestionAndAnswer[i]
                                                        .answer
                                                        .toString(),
                                                    style: primaryTextStyle(
                                                      size: textFontSize_14,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                  10.height,
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ).paddingSymmetric(vertical: 4);
                                    },
                                  ),
                                ],
                              ).paddingSymmetric(horizontal: 16),
                              16.height,
                            ],
                            4.height,
                            // Section Data List
                            if (mSectionData.isNotEmpty)
                              ListView.builder(
                                padding: EdgeInsets.zero,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: mSectionData.length,
                                itemBuilder: (context, i) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      getHeaders(
                                          mSectionData[i].title.toString()),
                                      if (mSectionData[i].subSectionData !=
                                          null)
                                        HorizontalList(
                                          padding: EdgeInsets.only(
                                            left: 16,
                                            top: 8,
                                            right: 16,
                                            bottom: 20,
                                          ),
                                          itemCount: mSectionData[i]
                                              .subSectionData!
                                              .length,
                                          itemBuilder: (context, index) {
                                            final subSection = mSectionData[i]
                                                .subSectionData![index];
                                            return Container(
                                              height: kContainerHeight,
                                              width: kContainerWidth,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
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
                                                            fit: BoxFit.cover,
                                                            height:
                                                                kContainerHeight -
                                                                    30,
                                                            width:
                                                                kContainerWidth,
                                                          ).cornerRadiusWithClipRRect(
                                                              defaultRadius),
                                                          Align(
                                                            alignment: Alignment
                                                                .bottomRight,
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                getTypeView(
                                                                        "Story",
                                                                        ic_story)
                                                                    .visible(subSection
                                                                            .viewType ==
                                                                        STORY_VIEW),
                                                                getTypeView(
                                                                        "Video",
                                                                        ic_video)
                                                                    .visible(subSection
                                                                            .viewType ==
                                                                        VIDEO),
                                                                getTypeView(
                                                                        "Video Course",
                                                                        ic_video)
                                                                    .visible(subSection
                                                                            .viewType ==
                                                                        VIDEO_COURSE),
                                                                getTypeView(
                                                                        "Podcast",
                                                                        ic_podcast)
                                                                    .visible(subSection
                                                                            .viewType ==
                                                                        PODCAST),
                                                                getTypeView(
                                                                        "Blog",
                                                                        ic_blog)
                                                                    .visible(subSection
                                                                            .viewType ==
                                                                        BLOG),
                                                                getTypeView(
                                                                        "Blog Course",
                                                                        ic_blog)
                                                                    .visible(subSection
                                                                            .viewType ==
                                                                        BLOG_COURSE),
                                                              ],
                                                            ),
                                                          ).paddingSymmetric(
                                                              horizontal: 10,
                                                              vertical: 10),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  10.height,
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 4),
                                                    child: Text(
                                                      subSection.title ?? '',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                                        story.url.toString())
                                                    .toList();
                                                StoryPage(imageUrls: urls)
                                                    .launch(context);
                                              } else if (subSection.viewType ==
                                                  VIDEO) {
                                                final video = subSection
                                                    .sectionDataVideo!.first;
                                                if (video.fileUrl!.contains(
                                                        "youtube.com") &&
                                                    validateYouTubeUrl(
                                                        video.fileUrl)) {
                                                  YoutubeVideoScreen(
                                                          url: video.fileUrl)
                                                      .launch(context);
                                                } else {
                                                  VideoPlayerScreen(
                                                    thumbnail:
                                                        video.thumbnailImage,
                                                    url: video.fileUrl,
                                                  ).launch(context);
                                                }
                                              } else if (subSection.viewType ==
                                                  CATEGORIES) {
                                                CategoryDetailsScreen(
                                                        widget.mCategoryData)
                                                    .launch(context);
                                              } else if (subSection.viewType ==
                                                  VIDEO_COURSE) {
                                                VideoCourseScreen(
                                                  subSectionData: subSection,
                                                  sectionDataVideo: subSection
                                                      .sectionDataVideo,
                                                ).launch(context);
                                              } else if (subSection.viewType ==
                                                  BLOG_COURSE) {
                                                BlogCourseScreen(
                                                  article: subSection.article,
                                                  subSectionData: subSection,
                                                ).launch(context);
                                              } else if (subSection.viewType ==
                                                  PODCAST) {
                                                PodcastScreen(subSection)
                                                    .launch(context);
                                              } else if (subSection.viewType ==
                                                  BLOG) {
                                                BlogDetailScreen(
                                                  article:
                                                      subSection.article![0],
                                                  onBookmarkUpdated:
                                                      (updatedArticle) {
                                                    setState(() {
                                                      subSection.article![0] =
                                                          updatedArticle;
                                                    });
                                                  },
                                                ).launch(context);
                                              }
                                            });
                                          },
                                        ),
                                    ],
                                  );
                                },
                              )
                            else
                              NoDataWidget(),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
    );
  }
}
