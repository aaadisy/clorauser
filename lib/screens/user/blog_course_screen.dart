import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/new_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import '../../extensions/extensions.dart';
import '../../main.dart';
import '../../model/common/article_models/article_model.dart';
import '../../model/user/category_models/category_list_response.dart';
import '../../network/rest_api.dart';
import '../../utils/app_common.dart';
import '../../utils/app_images.dart';
import '../screens.dart';

//ignore: must_be_immutable
class BlogCourseScreen extends StatefulWidget {
  List<Article>? article = [];
  SubSectionData? subSectionData;

  BlogCourseScreen({super.key, required this.article, this.subSectionData});

  @override
  State<BlogCourseScreen> createState() => _BlogCourseScreenState();
}

class _BlogCourseScreenState extends State<BlogCourseScreen> {
  ScrollController? _scrollController;
  bool lastStatus = true;
  double height = 200;
  bool isUpdatingBookmark = false;
  List<Article>? mArticleList = [];
  List<Article>? filteredArticleList = [];

  void _scrollListener() {
    if (_isShrink != lastStatus) {
      setState(() {
        lastStatus = _isShrink;
      });
    }
  }

  bool get _isShrink {
    return _scrollController != null &&
        _scrollController!.hasClients &&
        _scrollController!.offset > (height - kToolbarHeight);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    logScreenView("blog course screen");
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_scrollListener);
    _scrollController?.dispose();
    super.dispose();
  }

  Future<void> updateBookmarkStatusApiCall(int index) async {
    if (widget.article![index].id == null) {
      toast("Invalid article ID");
      return;
    }
    bool newBookmarkStatus = widget.article![index].bookmark != 1;
    Map req = {
      "is_bookmark": newBookmarkStatus ? "1" : "0",
      "article_id": widget.article![index].id.toString(),
    };
    // appStore.setLoading(true);
    setState(() {
      isUpdatingBookmark = true;
    });
    try {
      var value = await updateBookMarkStatus(req);
      if (mounted) {
        setState(() {
          widget.article![index].bookmark = newBookmarkStatus ? 1 : 0;
          int originalIndex = mArticleList!.indexWhere(
              (article) => article.id == filteredArticleList![index].id);
          if (originalIndex != -1) {
            mArticleList![originalIndex].bookmark = newBookmarkStatus ? 1 : 0;
          }
        });
        toast(value.message);
      }
    } catch (e) {
      toast("Error updating bookmark");
    } finally {
      setState(() {
        isUpdatingBookmark = false;
      });
      // appStore.setLoading(false);
    }
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 350.0,
              floating: false,
              pinned: true,
              backgroundColor: _isShrink ? Colors.white : Colors.transparent,
              shadowColor: _isShrink ? Colors.white : Colors.transparent,
              elevation: _isShrink ? 4.0 : 0.0,
              iconTheme: IconThemeData(
                color: _isShrink ? Colors.black : Colors.black,
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      children: [
                        if (_isShrink) SizedBox(width: kToolbarHeight - 16),
                        Expanded(
                          child: Text(
                            widget.subSectionData!.title.toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: boldTextStyle(
                              size: textFontSize_16,
                              color: _isShrink ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image with BoxFit.cover to fill the space without distortion
                    Positioned.fill(
                      child: cachedImage(
                        widget.subSectionData!.sectionDataImage.toString(),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    if (!_isShrink)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.4),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            children: [
              10.height,
              HtmlWidget(
                widget.subSectionData!.description ?? "",
              )
                  .paddingSymmetric(horizontal: 16)
                  .visible(widget.subSectionData!.description!.isNotEmpty),
              16.height.visible(widget.subSectionData!.description!.isNotEmpty),
              Divider(height: 0, color: context.dividerColor)
                  .visible(widget.subSectionData!.description!.isNotEmpty),
              ListView.builder(
                padding: EdgeInsets.all(16),
                physics: ScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.article!.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(defaultRadius)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            cachedImage(
                                    widget.article![index].articleImage
                                        .toString(),
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover)
                                .cornerRadiusWithClipRRect(12),
                            10.width,
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      widget.article![index].name.toString(),
                                      style: boldTextStyle(
                                        weight: FontWeight.w500,
                                        size: textFontSize_14,
                                        isHeader: true,
                                        color: mainColorText,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ).expand(),
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          color: kPrimaryColor,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Image.asset(
                                        widget.article![index].bookmark == 1
                                            ? ic_bookmark_filled
                                            : ic_bookmark2,
                                        width: 18,
                                        height: 18,
                                        fit: BoxFit.contain,
                                      ).center(),
                                    ).onTap(() async {
                                      await updateBookmarkStatusApiCall(index);
                                    }),
                                  ],
                                ),
                                10.height,
                                Row(
                                  children: [
                                    Image.asset(ic_user,
                                        width: 16,
                                        height: 16,
                                        color: mainColorText),
                                    4.width,
                                    Text(
                                      widget.article![index].expertData!.name
                                          .toString(),
                                      style: primaryTextStyle(
                                          color: mainColorText,
                                          size: textFontSize_12),
                                    ),
                                  ],
                                ),
                                10.height,
                                Row(
                                  children: [
                                    Image.asset(ic_clock2,
                                        width: 16,
                                        height: 16,
                                        color: mainColorText),
                                    4.width,
                                    Text(
                                      "${language.publishedDate} : ${formatDate(widget.article![index].createdAt.toString())}",
                                      style: primaryTextStyle(
                                          color: mainColorText,
                                          size: textFontSize_12),
                                    ),
                                  ],
                                ),
                              ],
                            ).expand(),
                          ],
                        ),
                      ).onTap(() {
                        BlogDetailScreen(
                          article: widget.article![index],
                          onBookmarkUpdated: (updatedArticle) {
                            setState(() {
                              widget.article![index] = updatedArticle;
                            });
                          },
                        ).launch(context);
                      }),
                      Divider(height: 1, color: Colors.grey[200])
                          .paddingSymmetric(vertical: 10)
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
