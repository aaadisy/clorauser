import 'package:clora_user/extensions/colors.dart';
import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/extensions/extension_util/string_extensions.dart';
import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:clora_user/extensions/new_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../ads/facebook_ads_manager.dart';
import '../../main.dart';
import '../../model/common/article_models/article_model.dart';
import '../../utils/app_common.dart';
import '../../utils/app_constants.dart';
import '../all_article.dart';
import '../user/blog_detail_screen.dart';

class ArticlesRecommendationWidget extends StatelessWidget {
  final List<Article> articles;
  final String currentPhase;
  final String encData;
  final int cycleDay;
  final int trimester;
  final int week;
  final TextStyle boldTextStyle;
  final TextStyle primaryTextStyle;
  final double defaultRadius;
  final Function(Article, int) onArticleUpdated;
  final bool isLoading;

  const ArticlesRecommendationWidget({
    Key? key,
    required this.articles,
    required this.cycleDay,
    required this.encData,
    required this.trimester,
    required this.week,
    required this.boldTextStyle,
    required this.primaryTextStyle,
    required this.defaultRadius,
    required this.onArticleUpdated,
    required this.isLoading,
    required this.currentPhase,
  }) : super(key: key);

  String calculateReadingTime(String text, {int wordsPerMinute = 200}) {
    List<String> words = text.split(' ');
    int wordCount = words.length;
    double readingTimeMinutes = wordCount / wordsPerMinute;

    if (readingTimeMinutes < 1) {
      return '1 ${language.minRead}';
    } else if (readingTimeMinutes < 2) {
      return '1 ${language.minRead}';
    } else {
      int minutes = readingTimeMinutes.ceil();
      return '$minutes ${language.minRead}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || articles.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: mainWhite,
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          5.height,
          Text(
            currentPhase.isEmptyOrNull
                ? "Articles for you"
                : "${language.basedOnYour.capitalizeWords()} ${currentPhase}",
            style: boldTextStyle,
          ),
          10.height,
          _buildArticlesList(context),
        ],
      ),
    );
  }

  Widget _buildArticlesList(BuildContext context) {
    final double itemWidth = 120;
    final double itemHeight = 120;

    return SizedBox(
      height: itemHeight + 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount:
            articles.length == 10 ? articles.length + 1 : articles.length,
        itemBuilder: (context, index) {
          if (index == articles.length && articles.length == 10) {
            return _buildMoreContainer(context, itemWidth, itemHeight);
          }
          final article = articles[index];
          return _buildArticleItem(
              context, article, index, itemWidth, itemHeight);
        },
      ),
    );
  }

  Widget _buildArticleItem(
    BuildContext context,
    Article article,
    int index,
    double width,
    double height,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xfffcdce1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: cachedImage(
                article.articleImage,
                fit: BoxFit.cover,
                width: width,
                height: height,
              ),
            ),
          ),
          8.height,
          SizedBox(
            width: width,
            child: _buildArticleTitle(article.name ?? ""),
          ),
          8.height,
          SizedBox(
            width: width,
            child: Text(
              calculateReadingTime(article.description ?? ""),
              style: primaryTextStyle.copyWith(
                color: mainColorBodyText,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ).onTap(() {
        if (article.type == PAID) {
          if ((appStore.adsConfig?.adsconfigAccess ?? false) &&
              (appStore.showAdsBasedOnConfig?.viewPaidArticle ?? false)) {
            FacebookAdsManager.showRewardedVideoAd(
              onRewardedVideoCompleted: () {
                openArticleDetail(context, article, index);
              },
              onError: () {
                openArticleDetail(context, article, index);
              },
            );
          } else {
            openArticleDetail(context, article, index);
          }
        } else {
          BlogDetailScreen(
            article: article,
            onBookmarkUpdated: (updatedArticle) {
              onArticleUpdated(updatedArticle, index);
            },
          ).launch(context);
        }
      }),
    );
  }

  Widget _buildMoreContainer(
      BuildContext context, double width, double height) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xfffcdce1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 0.5),
            ),
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.forward,
                  size: 30,
                  color: primaryColor,
                ),
                Text(
                  language.ViewAll,
                  style:
                      boldTextStyle.copyWith(color: primaryColor, fontSize: 14),
                )
              ],
            )),
          ).onTap(() {
            printEraAppLogs("----enc$encData");
            AllArticlesScreen(
              encData: encData,
              cycleDay: cycleDay,
              trimester: trimester,
              week: week,
              boldTextStyle: boldTextStyle,
              primaryTextStyle: primaryTextStyle,
              onArticleUpdated: onArticleUpdated,
            ).launch(context);
          }),
          8.height,
          SizedBox(
            width: width,
            height: 36,
          ),
          8.height,
          SizedBox(
            width: width,
            height: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildArticleTitle(String title) {
    return Html(
      data: title,
      style: {
        "body": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          maxLines: 2,
          fontFamily: "poppins",
          textOverflow: TextOverflow.ellipsis,
          fontSize: FontSize(14),
          fontWeight: FontWeight.w500,
          lineHeight: LineHeight(1.2),
        ),
      },
    );
  }

  void openArticleDetail(BuildContext context, Article article, int index) {
    BlogDetailScreen(
      article: article,
      onBookmarkUpdated: (updatedArticle) =>
          onArticleUpdated(updatedArticle, index),
    ).launch(context);
  }
}
