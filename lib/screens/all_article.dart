import 'package:clora_user/extensions/animated_list/animated_list_view.dart';
import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/string_extensions.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/main.dart';
import 'package:clora_user/model/common/article_models/article_model.dart';
import 'package:clora_user/screens/user/blog_detail_screen.dart';
import 'package:clora_user/utils/app_common.dart';
import 'package:clora_user/utils/app_images.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';

import '../../extensions/new_colors.dart';
import '../../network/rest_api.dart';

class AllArticlesScreen extends StatefulWidget {
  final int? cycleDay;
  final int? trimester;
  final int? week;
  final String? encData;
  final int? tagsId;
  final String? tagName;
  final TextStyle boldTextStyle;
  final TextStyle primaryTextStyle;
  final Function(Article, int) onArticleUpdated;

  const AllArticlesScreen({
    Key? key,
    this.cycleDay,
    this.trimester,
    this.week,
    this.encData,
    this.tagsId,
    this.tagName,
    required this.boldTextStyle,
    required this.primaryTextStyle,
    required this.onArticleUpdated,
  }) : super(key: key);

  @override
  _AllArticlesScreenState createState() => _AllArticlesScreenState();
}

class _AllArticlesScreenState extends State<AllArticlesScreen> {
  List<Article> articles = [];
  bool isInitialLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;
  int currentPage = 2;
  bool hasMorePages = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    currentPage = widget.tagsId != null ? 1 : 2;
    fetchArticles();
    _scrollController.addListener(_onScroll);
    logScreenView("All article screen");
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasMorePages) {
      fetchArticles(page: currentPage + 1);
    }
  }

  Future<void> fetchArticles({int? page}) async {
    page ??= widget.tagsId != null ? 1 : 2;
    printEraAppLogs(
        'Fetching articles for page $page, tagsId: ${widget.tagsId}, cycleDay: ${widget.cycleDay}');
    if (page == (widget.tagsId != null ? 1 : 2)) {
      setState(() {
        isInitialLoading = true;
        errorMessage = null;
        articles.clear();
      });
    } else {
      setState(() {
        isLoadingMore = true;
      });
    }
    appStore.setLoading(true);

    try {
      final request = widget.tagsId != null
          ? {
              'tag_id': widget.tagsId.toString(),
            }
          : {
              'cycle_day': widget.cycleDay ?? 0,
              'encData': widget.encData,
              'week': widget.week ?? 0,
            };

      final response = widget.tagsId != null
          ? await TagArticleList(
              request,
              page: page,
            ).timeout(Duration(seconds: 10), onTimeout: () {
              throw 'Request timed out';
            })
          : await DashboardArticleList(
              request,
              page: page,
            ).timeout(Duration(seconds: 10), onTimeout: () {
              throw 'Request timed out';
            });

      if (response.status == 'true' && response.data != null) {
        setState(() {
          if (page == (widget.tagsId != null ? 1 : 2)) {
            articles = response.data!;
          } else {
            articles.addAll(response.data!);
          }
          currentPage = page!;
          hasMorePages = response.data!.isNotEmpty;
          printEraAppLogs(
              'Loaded ${response.data!.length} articles, hasMorePages: $hasMorePages');
        });
      } else {
        setState(() {
          errorMessage = 'No articles found.';
          hasMorePages = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load articles: $e';
        hasMorePages = false;
      });
      throw e;
    } finally {
      setState(() {
        isInitialLoading = false;
        isLoadingMore = false;
      });
      appStore.setLoading(false);
    }
  }

  Future<void> updateBookmarkStatus(int index) async {
    if (articles[index].id == null) {
      toast("Invalid article ID");
      return;
    }
    bool newBookmarkStatus = articles[index].bookmark != 1;
    Map req = {
      "is_bookmark": newBookmarkStatus ? "1" : "0",
      "article_id": articles[index].id.toString(),
    };
    appStore.setLoading(true);
    try {
      var value = await updateBookMarkStatus(req);
      if (mounted) {
        setState(() {
          articles[index].bookmark = newBookmarkStatus ? 1 : 0;
        });
        widget.onArticleUpdated(articles[index], index);
        toast(value.message);
      }
    } catch (e) {
      toast("Error updating bookmark");
      throw e;
    } finally {
      appStore.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => fetchArticles(page: widget.tagsId != null ? 1 : 2),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  backgroundColor: mainColorLight,
                  pinned: true,
                  leading: IconButton(
                    icon: Icon(CupertinoIcons.back, color: mainColorText),
                    onPressed: () => Navigator.pop(context),
                  ),
                  titleSpacing: 0,
                  title: Text(
                    widget.tagsId != null
                        ? 'Articles based on ${widget.tagName?.capitalizeFirstLetter() ?? 'Tag'}'
                        : 'All Articles',
                    style: widget.boldTextStyle.copyWith(
                      color: mainColorText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                        offset: Offset(0, -40),
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
                              if (appStore.isLoading && isInitialLoading) {
                                return SizedBox(
                                  height: context.height() -
                                      kToolbarHeight -
                                      context.statusBarHeight,
                                  child: Center(
                                    child: Loader(),
                                  ),
                                );
                              }
                              if (articles.isNotEmpty) {
                                return Column(
                                  children: [
                                    AnimatedListView(
                                      primary: false,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      itemCount: articles.length,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final article = articles[index];
                                        return BlogItem(
                                          imageUrl: article.articleImage ?? '',
                                          title: article.name ?? '',
                                          article: article,
                                          onBookmarkRemoved: () =>
                                              updateBookmarkStatus(index),
                                        ).onTap(() {
                                          BlogDetailScreen(
                                            article: article,
                                            onBookmarkUpdated:
                                                (updatedArticle) {
                                              setState(() {
                                                articles[index] =
                                                    updatedArticle;
                                              });
                                              widget.onArticleUpdated(
                                                  updatedArticle, index);
                                            },
                                          ).launch(context);
                                        });
                                      },
                                    ),
                                    if (isLoadingMore)
                                      Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Loader(),
                                      ),
                                  ],
                                );
                              }
                              return SizedBox(
                                height: context.height() -
                                    kToolbarHeight -
                                    context.statusBarHeight,
                                child: Center(
                                  child: emptyWidget(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BlogItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final Article? article;
  final VoidCallback? onBookmarkRemoved;

  BlogItem({
    required this.imageUrl,
    required this.title,
    this.article,
    this.onBookmarkRemoved,
  });

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cachedImage(
            article!.articleImage ?? 'assets/images/placeholder.png',
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          ).cornerRadiusWithClipRRect(12),
          10.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    article!.name.toString(),
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
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset(
                      article!.bookmark == 1
                          ? ic_bookmark_filled
                          : ic_bookmark2,
                      width: 18,
                      height: 18,
                      fit: BoxFit.contain,
                    ).center(),
                  ).onTap(() {
                    onBookmarkRemoved?.call();
                  }),
                ],
              ),
              10.height,
              Row(
                children: [
                  Image.asset(ic_user,
                      width: 16, height: 16, color: mainColorText),
                  4.width,
                  Text(
                    article!.expertData?.name.toString() ?? 'Unknown',
                    style: primaryTextStyle(
                        color: mainColorText, size: textFontSize_12),
                  ),
                ],
              ),
              10.height,
              Row(
                children: [
                  Image.asset(ic_clock2,
                      width: 16, height: 16, color: mainColorText),
                  4.width,
                  Text(
                    "${language.publishedDate} : ${formatDate(article!.createdAt.toString())}",
                    style: primaryTextStyle(
                        color: mainColorText, size: textFontSize_12),
                  ),
                ],
              ),
            ],
          ).expand(),
        ],
      ),
    ).paddingSymmetric(vertical: 10);
  }
}
