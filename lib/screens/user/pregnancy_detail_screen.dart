import 'dart:math';

import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/main.dart';
import 'package:clora_user/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../model/user/user_models/pregnancy_detail_model.dart';

class PregnancyDetailScreen extends StatefulWidget {
  final List<PregnancyData> data;
  final int weekNumber;

  PregnancyDetailScreen(
      {super.key, required this.data, required this.weekNumber});

  @override
  State<PregnancyDetailScreen> createState() => _PregnancyDetailScreenState();
}

class _PregnancyDetailScreenState extends State<PregnancyDetailScreen> {
  int selectedWeek = 0; // Index-based selection
  List<PregnancyData> mPregnancyData = [];
  late ScrollController _weekScrollController;

  @override
  void initState() {
    super.initState();
    _weekScrollController = ScrollController();
    getPregnancyData();
    logScreenView("Pregnancy screen");
  }

  @override
  void dispose() {
    _weekScrollController.dispose();
    super.dispose();
  }

  Future<void> getPregnancyData() async {
    try {
      mPregnancyData = widget.data;
      if (mPregnancyData.isNotEmpty) {
        selectedWeek = max(widget.weekNumber - 1, 0);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToSelectedWeek();
        });
      }
    } catch (e) {}
  }

  void _scrollToSelectedWeek() {
    if (_weekScrollController.hasClients && mPregnancyData.isNotEmpty) {
      final double itemWidth = 100;
      final double screenWidth = MediaQuery.of(context).size.width;
      final double scrollOffset =
          (selectedWeek * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

      _weekScrollController.animateTo(
        max(0, scrollOffset),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Size getPregnancyImageSize(int week) {
    int baseSize = 100;
    int step = 5;
    int maxSize = 300; // Fixed size after week 42

    if (week < 1) week = 1;
    if (week > 42) return Size(maxSize.toDouble(), maxSize.toDouble());

    int size = baseSize + (week - 1) * step;
    return Size(size.toDouble(), size.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    String? selectedImageUrl = mPregnancyData.isNotEmpty
        ? mPregnancyData[selectedWeek].pregnancyDateImage
        : null;
    Size imageSize =
        getPregnancyImageSize(selectedWeek + 1); // Convert index to week

// Base top position
    double topPosition =
        (MediaQuery.of(context).size.height * 0.4) - (imageSize.height / 4);

// Slightly move the image up for later weeks
    if (selectedWeek >= 30) {
      topPosition -= 20; // Move up by 20 pixels for weeks 30+
    }
    if (selectedWeek >= 36) {
      topPosition -= 30; // Move up by 30 pixels for weeks 36+
    }
    if (selectedWeek >= 40) {
      topPosition -= 40; // Move up by 40 pixels for weeks 40+
    }

// Ensure it doesn't go too high
    if (topPosition < 50) topPosition = 50;
    return Scaffold(
      body: appStore.isLoading
          ? Loader().center()
          : Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.asset(
                    "assets/ic_bg.png",
                    fit: BoxFit.cover,
                  ),
                ),

                if (selectedImageUrl != null && selectedImageUrl.isNotEmpty)
                  Positioned(
                      top: topPosition,
                      left: 0,
                      right: 0,
                      child: Image.network(
                        selectedImageUrl,
                        height: imageSize.height,
                        width: imageSize.width,
                        fit: BoxFit.contain,
                      ).center()),

                Positioned(
                    top: 50,
                    left: 20,
                    child: Icon(Icons.close, color: Colors.white, size: 24)
                        .onTap(() {
                      finish(context);
                    })),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: MediaQuery.of(context).size.height * 0.22,
                  child: SizedBox(
                    height: 30,
                    child: ListView.builder(
                      controller: _weekScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: mPregnancyData.length,
                      itemBuilder: (context, index) {
                        bool isSelected = index == selectedWeek;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedWeek = index;
                            });
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                  mPregnancyData[index].pregnancyDate ??
                                      "${language.Week} ${index + 1}",
                                  style: boldTextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,
                                  )).center()),
                        );
                      },
                    ),
                  ),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.20,
                  minChildSize: 0.2,
                  maxChildSize: 0.9,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 5,
                                margin: const EdgeInsets.only(bottom: 10),
                                // Adds space below
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                mPregnancyData.isNotEmpty
                                    ? mPregnancyData[selectedWeek]
                                            .article
                                            ?.name ??
                                        language.noTitle
                                    : language.noTitle,
                                style: boldTextStyle(
                                    weight: FontWeight.bold,
                                    size: textFontSize_20),
                              ),
                            ),
                            10.height,
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(defaultRadius),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: cachedImage(
                                mPregnancyData.isNotEmpty
                                    ? mPregnancyData[selectedWeek]
                                            .article
                                            ?.articleImage ??
                                        ""
                                    : "",
                                width: context.width(),
                                fit: BoxFit.cover,
                              ),
                            ).paddingSymmetric(horizontal: 16),
                            16.height,
                            Row(
                              children: [
                                cachedImage(
                                  mPregnancyData.isNotEmpty
                                      ? mPregnancyData[selectedWeek]
                                              .article
                                              ?.expertData
                                              ?.healthExpertsImage ??
                                          ""
                                      : "",
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                ).cornerRadiusWithClipRRect(60),
                                16.width,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      language.reviewedBy,
                                      style: primaryTextStyle(
                                          size: textFontSize_12,
                                          letterSpacing: 0.2),
                                    ),
                                    Text(
                                      mPregnancyData.isNotEmpty
                                          ? mPregnancyData[selectedWeek]
                                                  .article
                                                  ?.expertData
                                                  ?.name ??
                                              language.Unknown
                                          : language.Unknown,
                                      style:
                                          boldTextStyle(size: textFontSize_16),
                                    ),
                                    Text(
                                      mPregnancyData.isNotEmpty
                                          ? mPregnancyData[selectedWeek]
                                                  .article
                                                  ?.expertData
                                                  ?.tagLine ??
                                              language.noTagline
                                          : language.noTagline,
                                      style: secondaryTextStyle(
                                          size: textFontSize_14),
                                      maxLines: 2,
                                    ),
                                  ],
                                ).expand(),
                              ],
                            ).paddingSymmetric(horizontal: 16),
                            16.height,
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                '${language.thisArticleWasPublishedOn} ' +
                                    (mPregnancyData.isNotEmpty
                                        ? parseDocumentDate(DateTime.parse(
                                            mPregnancyData[selectedWeek]
                                                    .article
                                                    ?.createdAt ??
                                                DateTime.now().toString()))
                                        : language.Unknown),
                                style: GoogleFonts.sansitaSwashed(
                                  textStyle:
                                      secondaryTextStyle(size: textFontSize_14),
                                ),
                              ),
                            ),
                            HtmlWidget(
                              mPregnancyData.isNotEmpty
                                  ? mPregnancyData[selectedWeek]
                                          .article
                                          ?.description ??
                                      language.noContentAvailable
                                  : language.noContentAvailable,
                            ).paddingSymmetric(horizontal: 10),
                            8.height,
                            if (mPregnancyData.isNotEmpty &&
                                mPregnancyData[selectedWeek]
                                        .article
                                        ?.articleReference !=
                                    null &&
                                mPregnancyData[selectedWeek]
                                    .article!
                                    .articleReference!
                                    .isNotEmpty)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius:
                                      BorderRadius.circular(defaultRadius),
                                ),
                                child: ExpansionTile(
                                  shape: Border(),
                                  maintainState: true,
                                  title: Text(
                                    language.references,
                                    style: boldTextStyle(size: textFontSize_16),
                                  ),
                                  children: [
                                    ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: mPregnancyData[selectedWeek]
                                          .article!
                                          .articleReference!
                                          .length,
                                      itemBuilder: (context, index) {
                                        return Text(mPregnancyData[selectedWeek]
                                                .article!
                                                .articleReference![index]
                                                .referenceName
                                                .toString())
                                            .paddingSymmetric(
                                                horizontal: 16, vertical: 8);
                                      },
                                    ),
                                  ],
                                ),
                              ).paddingSymmetric(horizontal: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
