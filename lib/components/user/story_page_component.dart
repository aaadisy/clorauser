import 'dart:io' show Platform;

import 'package:clora_user/extensions/extension_util/string_extensions.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/main.dart';
import 'package:clora_user/utils/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import '../../extensions/new_colors.dart';
import '../../model/common/article_models/article_model.dart';
import '../../model/user/dashboard_response.dart';
import '../../screens/user/blog_detail_screen.dart';
import '../../utils/app_common.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_images.dart';

class StoryPage extends StatefulWidget {
  final bool isAIPowered;
  final List<String>? imageUrls;
  final List<InsightData>? insightData;
  final List<CycleDateData>? challengeData;
  final String? cycleDay;
  Article? article;

  StoryPage({
    this.imageUrls,
    this.insightData,
    this.challengeData,
    this.cycleDay,
    this.article,
    this.isAIPowered = false,
  });

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  List<StoryItem> storyItems = [];
  late StoryController controller;
  String? cycleDay;

  bool _isImage(String url) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  bool _isVideo(String url) {
    final videoExtensions = ['mp4', 'mkv', 'avi', 'mov', 'flv', 'wmv'];
    return videoExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  List<StoryItem> buildChallengeStories(List<CycleDateData> data) {
    return data.asMap().entries.map((entry) {
      var day = entry.value;

      return StoryItem(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            40.height.visible(cycleDay != null && cycleDay!.isNotEmpty),
            cycleDay != null && cycleDay!.isNotEmpty
                ? Text(
                    cycleDay!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  )
                : SizedBox.shrink(),
            20.height,
            Align(
              alignment: Alignment.center,
              child: Text(
                day.title ?? "",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            16.height,
            day.slideType == 1
                ? Column(
                    children: day.questionAndAnswer!.map((e) {
                      return ChallengeCard(
                        title: e.question!,
                        description: e.answer!,
                        imageURL: e.image ?? "",
                      );
                    }).toList(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      8.height,
                      Text(
                        day.message ?? '',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        textAlign: TextAlign.start,
                      ),
                      8.height,
                      if (!day.cycleDateDataTextMessageImage.isEmptyOrNull &&
                          !day.cycleDateDataTextMessageImage!
                              .contains(ic_default))
                        cachedImage(day.cycleDateDataTextMessageImage,
                                fit: BoxFit.cover)
                            .paddingAll(50),
                    ],
                  ),
          ],
        ).paddingAll(16),
        duration: Duration(seconds: INSIGHT_STORY_IMAGE_DURATION),
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    controller = StoryController();

    if (widget.cycleDay.isEmptyOrNull || widget.cycleDay!.toInt() == 0) {
      cycleDay = "";
    } else {
      cycleDay =
          "${DateFormat("MMMM d").format(DateTime.now())} • Cycle day ${widget.cycleDay ?? ''}";
    }

    if (widget.imageUrls != null && widget.imageUrls!.isNotEmpty) {
      storyItems.addAll(widget.imageUrls!.map((url) {
        if (_isImage(url)) {
          return StoryItem.pageImage(
            duration: Duration(seconds: INSIGHT_STORY_IMAGE_DURATION),
            url: url,
            imageFit: Platform.isIOS ? BoxFit.contain : BoxFit.cover,
            controller: controller,
          );
        } else if (_isVideo(url)) {
          return StoryItem.pageVideo(
            url,
            controller: controller,
            duration: Duration(seconds: INSIGHT_STORY_IMAGE_DURATION),
          );
        } else {
          return StoryItem.text(
            duration: Duration(seconds: INSIGHT_STORY_IMAGE_DURATION),
            title: "Unsupported media type",
            backgroundColor: Colors.red,
          );
        }
      }));
    }

    if (widget.insightData != null && widget.insightData!.isNotEmpty) {
      storyItems.addAll(widget.insightData!.map((insight) {
        Color bgColor = insight.bgColor != null
            ? Color(int.parse(insight.bgColor!.replaceFirst('#', '0xff')))
            : ColorUtils.colorPrimary;

        Color textColor = insight.textColor != null
            ? Color(int.parse(insight.textColor!.replaceFirst('#', '0xff')))
            : Colors.white;

        return StoryItem(
          Container(
            color: bgColor,
            padding: const EdgeInsets.all(24),
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    if (insight.titleName != null)
                      TextSpan(
                        text: '${insight.titleName}\n\n',
                        style: boldTextStyle(
                          size: 24,
                          weight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    if (insight.description != null)
                      TextSpan(
                        text: insight.description,
                        style: primaryTextStyle(
                          size: 20,
                          weight: FontWeight.normal,
                          color: textColor,
                          height: 1.4,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          duration: Duration(seconds: INSIGHT_STORY_IMAGE_DURATION),
        );
      }));
    }

    if (widget.challengeData != null && widget.challengeData!.isNotEmpty) {
      storyItems.addAll(buildChallengeStories(widget.challengeData!));
    }

    if (storyItems.isEmpty) {
      storyItems.add(
        StoryItem.text(
          title: "No stories available",
          backgroundColor: Colors.grey,
          duration: Duration(seconds: INSIGHT_STORY_IMAGE_DURATION),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: mainColorLight,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            toolbarHeight: 0,
            elevation: 0,
          ),
          body: Stack(
            children: [
              StoryView(
                indicatorHeight: IndicatorHeight.small,
                indicatorColor:
                    widget.challengeData != null ? Colors.grey : null,
                onComplete: () {
                  finish(context);
                },
                controller: controller,
                storyItems: storyItems,
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorUtils.colorPrimary,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                      ),
                      onPressed: () {
                        BlogDetailScreen(
                          article: widget.article!,
                          onBookmarkUpdated: (updatedArticle) {
                            setState(() {
                              widget.article = updatedArticle;
                            });
                          },
                        ).launch(context);
                      },
                      icon: Icon(
                        CupertinoIcons.hand_point_right,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        language.clickToReadMore,
                        style: boldTextStyle(
                            size: 16, letterSpacing: 1.2, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ).visible(widget.article?.id != null),
            ],
          ),
        ),
      ),
    );
  }
}

class ChallengeCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageURL;

  ChallengeCard({
    required this.title,
    required this.description,
    required this.imageURL,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 5,
              spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorUtils.colorPrimary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (!imageURL.contains(ic_default))
                  cachedImage(imageURL, height: 30, width: 30),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              description,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
