import 'package:clora_user/extensions/animated_list/animated_list_view.dart';
import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/main.dart';
import 'package:clora_user/model/common/article_models/article_model.dart';
import 'package:clora_user/utils/app_common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import '../../extensions/new_colors.dart';
import '../../network/rest_api.dart';
import '../../utils/app_images.dart';
import 'blog_detail_screen.dart';

class BookmarkScreen extends StatefulWidget {
  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<Article>? bookmarks;
  bool isInitialLoading = true;

  Future<void> getBookmarkApiCall() async {
    appStore.setLoading(true);
    try {
      var value = await getBookmarkApi();
      if (mounted) {
        setState(() {
          bookmarks = value.data;
        });
      }
      appStore.setLoading(false);
    } catch (e) {
      appStore.setLoading(false);
    } finally {
      if (mounted) {
        setState(() {
          isInitialLoading = false;
        });
      }
    }
  }

  Future<void> updateBookmarkStatus(int index) async {
    if (bookmarks![index].id == null) {
      toast("Invalid article ID");
      return;
    }
    bool newBookmarkStatus = bookmarks![index].bookmark != 1;
    Map req = {
      "is_bookmark": newBookmarkStatus ? "1" : "0",
      "article_id": bookmarks![index].id.toString(),
    };
    appStore.setLoading(true);
    try {
      var value = await updateBookMarkStatus(req);
      if (mounted) {
        setState(() {
          if (newBookmarkStatus) {
            bookmarks![index].bookmark = 1;
          } else {
            bookmarks!.removeAt(index);
          }
        });
        toast(value.message);
      }
    } catch (e) {
      toast("Error updating bookmark");
    } finally {
      appStore.setLoading(false);
    }
  }

  @override
  void initState() {
    super.initState();
    getBookmarkApiCall();
    logScreenView("bookmark screen");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
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
                  language.Bookmarks,
                  style: boldTextStyle(
                    color: mainColorText,
                    size: 18,
                    weight: FontWeight.w500,
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
                            if (isInitialLoading) {
                              return SizedBox.shrink();
                            }
                            return bookmarks != null && bookmarks!.isNotEmpty
                                ? AnimatedListView(
                                    primary: false,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    itemCount: bookmarks!.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      final blog = bookmarks![index];
                                      return BlogItem(
                                        imageUrl: blog.articleImage!,
                                        title: blog.name!,
                                        article: blog,
                                        onBookmarkRemoved: () =>
                                            updateBookmarkStatus(index),
                                      ).onTap(() {
                                        BlogDetailScreen(
                                          article: bookmarks![index],
                                          onBookmarkUpdated: (updatedArticle) {
                                            setState(() {
                                              bookmarks![index] =
                                                  updatedArticle;
                                            });
                                          },
                                        ).launch(context);
                                      });
                                    },
                                  )
                                : SizedBox(
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
          // Loader
          Observer(
            builder: (context) => Loader().visible(appStore.isLoading).center(),
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
          cachedImage(article!.articleImage,
                  height: 100, width: 100, fit: BoxFit.cover)
              .cornerRadiusWithClipRRect(12),
          10.width,
          Column(
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
                    article!.expertData!.name.toString(),
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
