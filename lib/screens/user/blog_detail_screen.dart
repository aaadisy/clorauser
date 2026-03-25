import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/string_extensions.dart';
import 'package:clora_user/utils/app_images.dart';
import 'package:clora_user/utils/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../extensions/custom_marquee.dart';
import '../../extensions/extensions.dart';
import '../../extensions/new_colors.dart';
import '../../main.dart';
import '../../model/common/article_models/article_model.dart';
import '../../network/rest_api.dart';
import '../../utils/app_common.dart';
import '../all_article.dart';

class BlogDetailScreen extends StatefulWidget {
  final Article? article;
  final bool fromHome;
  final String? title;
  final Function(Article) onBookmarkUpdated;

  BlogDetailScreen({
    this.article,
    this.fromHome = true,
    this.title = "",
    required this.onBookmarkUpdated,
  });

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen>
    with SingleTickerProviderStateMixin {
  bool isBookMarked = false;
  late AnimationController _controller;
  late Animation<double> shakeAnimation;

  String extractBeforeColon(String text) {
    return text.split(':').first.trim();
  }

  @override
  void initState() {
    super.initState();
    logScreenView("Blog details screen");
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);

    shakeAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    checkBookmark();
  }

  checkBookmark() {
    if (widget.article?.bookmark == 1) {
      isBookMarked = true;
    } else {
      isBookMarked = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String formatArticleDate(String? createdAt) {
    try {
      if (createdAt == null) {
        return DateFormat('MMMM d, yyyy').format(DateTime.now());
      }
      final date = DateTime.parse(createdAt);
      return DateFormat('MMMM d, yyyy').format(date);
    } catch (e) {
      return DateFormat('MMMM d, yyyy').format(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: mainColorLight,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Scrollable content
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      height:
                          kToolbarHeight + MediaQuery.of(context).padding.top),
                  Stack(
                    children: [
                      SizedBox(
                        height: 350,
                        width: context.width(),
                        child: cachedImage(
                          widget.article!.articleImage,
                          width: context.width(),
                          fit: BoxFit.cover,
                        ),
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
                    ],
                  ),
                  Transform.translate(
                    offset: Offset(0, -18),
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
                          16.height,
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, bottom: 16.0, right: 24),
                            child: Text(
                              "${widget.article!.name.capitalizeFirstLetter()}",
                              style: boldTextStyle(
                                  weight: FontWeight.normal,
                                  size: textFontSize_20),
                            ),
                          ).visible(widget.fromHome),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24)),
                            ),
                            child: Row(
                              children: [
                                cachedImage(
                                        widget.article!.expertData!
                                            .healthExpertsImage,
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover)
                                    .cornerRadiusWithClipRRect(60),
                                16.width,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.article!.expertData != null)
                                      Text(
                                        language.reviewedBy,
                                        style: primaryTextStyle(
                                            size: textFontSize_14,
                                            weight: FontWeight.normal,
                                            color: Colors.black54,
                                            letterSpacing: 0.2),
                                      ),
                                    Text(
                                      widget.article!.expertData!.name
                                          .toString(),
                                      style:
                                          boldTextStyle(size: textFontSize_16),
                                    ),
                                    if (widget.article!.expertData != null &&
                                        widget.article!.expertData!.tagLine !=
                                            null)
                                      Text(widget.article!.expertData!.tagLine!,
                                          style: primaryTextStyle(
                                              size: textFontSize_14,
                                              weight: FontWeight.normal,
                                              color: Colors.black54,
                                              letterSpacing: 0.2),
                                          maxLines: 2),
                                  ],
                                ).expand(),
                              ],
                            ),
                          ).paddingSymmetric(horizontal: 16),
                          16.height,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '${language.thisArticleWasPublishedOn} ${formatArticleDate(widget.article?.createdAt)}',
                              style: GoogleFonts.sansitaSwashed(
                                textStyle: secondaryTextStyle(size: 14),
                              ),
                            ),
                          ),
                          8.height,
                          Divider().paddingSymmetric(horizontal: 16),
                          HtmlWidget(
                            enableCaching: true,
                            buildAsync: false,
                            widget.article!.description ?? '',
                          ).paddingSymmetric(horizontal: 10),
                          8.height,
                          if (widget.article!.tags != null &&
                              widget.article!.tags!.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: widget.article!.tags!.map((tag) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: primaryColor),
                                    ),
                                    child: Text(tag.name.toString(),
                                        style: boldTextStyle(
                                            size: textFontSize_12,
                                            color: textPrimaryColor,
                                            weight: FontWeight.w500)),
                                  ).onTap(() {
                                    AllArticlesScreen(
                                      tagsId: tag.id,
                                      tagName: tag.name,
                                      boldTextStyle: boldTextStyle(),
                                      primaryTextStyle: primaryTextStyle(),
                                      onArticleUpdated: (updatedArticle, _) {
                                        if (updatedArticle.id ==
                                            widget.article!.id) {
                                          widget.onBookmarkUpdated(
                                              updatedArticle);
                                        }
                                      },
                                    ).launch(context);
                                  });
                                }).toList(),
                              ),
                            ),
                          16.height,
                          8.height,
                          widget.article!.articleReference != null ||
                                  widget.article!.articleReference!.length > 0
                              ? Container(
                                      decoration: boxDecorationWithRoundedCorners(
                                        backgroundColor: Colors.grey.shade200,
                                        borderRadius: radius(defaultRadius),
                                      ),
                                      child: ExpansionTile(
                                        shape: Border(),
                                        maintainState: true,
                                        title: Text(
                                          language.references,
                                          style: boldTextStyle(
                                              size: textFontSize_16),
                                        ),
                                        children: [
                                          ListView.builder(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: widget.article!
                                                  .articleReference!.length,
                                              itemBuilder: (context, index) {
                                                return Text(widget
                                                        .article!
                                                        .articleReference![
                                                            index]
                                                        .referenceName
                                                        .toString())
                                                    .paddingSymmetric(
                                                        horizontal: 16,
                                                        vertical: 8);
                                              })
                                        ],
                                      ))
                                  .visible(widget
                                      .article!.articleReference!.isNotEmpty)
                                  .paddingSymmetric(horizontal: 16)
                              : SizedBox.shrink(),
                          16.height,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Fixed header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: kToolbarHeight + MediaQuery.of(context).padding.top,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                ),
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          pop();
                        },
                        icon: Icon(CupertinoIcons.back)),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final textPainter = TextPainter(
                            text: TextSpan(
                              text: widget.fromHome
                                  ? language.selfCare
                                  : extractBeforeColon(
                                      widget.title?.capitalizeFirstLetter() ??
                                          ""),
                              style: boldTextStyle(
                                color: mainColorText,
                                size: 16,
                                weight: FontWeight.w500,
                              ),
                            ),
                            maxLines: 1,
                            textDirection: Directionality.of(context),
                          )..layout(maxWidth: constraints.maxWidth - 100);

                          final isOverflowing = textPainter.didExceedMaxLines;
                          return isOverflowing
                              ? SizedBox(
                                  height: 30,
                                  child: CustomMarquee(
                                    child: Text(
                                      widget.fromHome
                                          ? language.selfCare
                                          : extractBeforeColon(widget.title
                                                  ?.capitalizeFirstLetter() ??
                                              ""),
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
                                  widget.fromHome
                                      ? language.selfCare
                                      : extractBeforeColon(widget.title
                                              ?.capitalizeFirstLetter() ??
                                          ""),
                                  style: boldTextStyle(
                                    color: mainColorText,
                                    size: 16,
                                    weight: FontWeight.w500,
                                  ),
                                );
                        },
                      ),
                    ),
                    // 10.width,
                    Image.asset(
                      isBookMarked ? ic_bookmark_filled : ic_bookmark2,
                      width: 24,
                      height: 24,
                      color: ColorUtils.colorPrimary,
                    ).onTap(() async {
                      setState(() {
                        isBookMarked = !isBookMarked;
                      });
                      Map req = {
                        "is_bookmark": isBookMarked ? "1" : "0",
                        "article_id": widget.article?.id.toString() ?? "",
                      };
                      updateBookMarkStatus(req).then(
                        (value) {
                          toast(value.message);
                          Article updatedArticle = Article(
                            id: widget.article?.id,
                            name: widget.article?.name,
                            articleImage: widget.article?.articleImage,
                            articleReference: widget.article?.articleReference,
                            bookmark: isBookMarked ? 1 : 0,
                            createdAt: widget.article?.createdAt,
                            description: widget.article?.description,
                            expertData: widget.article?.expertData,
                            goalType: widget.article?.goalType,
                            goalTypeName: widget.article?.goalTypeName,
                            tags: widget.article?.tags,
                            updatedAt: widget.article?.updatedAt,
                          );
                          widget.onBookmarkUpdated(updatedArticle);
                        },
                      );
                    }),
                    20.width,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
