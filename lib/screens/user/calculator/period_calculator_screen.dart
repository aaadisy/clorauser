import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/extensions/extension_util/string_extensions.dart';
import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:clora_user/model/user/calculator_model.dart';
import 'package:clora_user/screens/user/calculator/period_result.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';

import '../../../extensions/app_button.dart';
import '../../../extensions/colors.dart';
import '../../../extensions/common.dart';
import '../../../extensions/constants.dart';
import '../../../extensions/decorations.dart';
import '../../../extensions/new_colors.dart';
import '../../../extensions/system_utils.dart';
import '../../../extensions/text_styles.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/dynamic_theme.dart';
import '../blog_detail_screen.dart';

class PeriodCalculatorScreen extends StatefulWidget {
  final CalculatorItem calculatorData;

  const PeriodCalculatorScreen({super.key, required this.calculatorData});

  @override
  State<PeriodCalculatorScreen> createState() => _PeriodCalculatorScreenState();
}

class _PeriodCalculatorScreenState extends State<PeriodCalculatorScreen> {
  int? _selectedCycleLength;
  DateTime? _selectedDate;
  int? _selectedLastPeriodLength;
  int select = 0;

  bool predictableValue = false;
  bool ownValues = false;
  int? _selectedIndex;

  final List<int> phaseLength = List<int>.generate(17, (index) => index + 20);
  final List<int> lastdayslength = List<int>.generate(11, (index) => index + 0);

  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedCycleLength = 28;
    _selectedLastPeriodLength = 5;
    logScreenView("Period Calculator screen");
  }

  void _showPicker() {
    int tempSelectedIndex = _selectedIndex ?? 8;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.all(16),
          shape: dialogShape(),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(language.averageCycle,
                  style: boldTextStyle(size: textFontSize_20)),
              18.height,
              SizedBox(
                height: context.height() * 0.2,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CupertinoPicker(
                      magnification: 1.4,
                      squeeze: 0.8,
                      useMagnifier: true,
                      selectionOverlay: SizedBox(),
                      itemExtent: 32.0,
                      scrollController: FixedExtentScrollController(
                          initialItem: tempSelectedIndex),
                      onSelectedItemChanged: (selectedItem) {
                        tempSelectedIndex = selectedItem;
                      },
                      children: phaseLength.map((int item) {
                        return Text(
                          item == 0 ? 'Select' : item.toString(),
                          style: boldTextStyle(size: textFontSize_20),
                        ).center();
                      }).toList(),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            height: 2,
                            width: 100,
                            color: ColorUtils.colorPrimary),
                        45.height,
                        Container(
                            height: 2,
                            width: 100,
                            color: ColorUtils.colorPrimary),
                      ],
                    ),
                  ],
                ),
              ),
              18.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AppButton(
                    padding: EdgeInsets.zero,
                    height: 40,
                    text: language.cancel,
                    width: context.width(),
                    elevation: 0,
                    color: Colors.white,
                    textColor: ColorUtils.colorPrimary,
                    onTap: () {
                      finish(context);
                    },
                  ).expand(),
                  8.width,
                  AppButton(
                    padding: EdgeInsets.zero,
                    height: 40,
                    text: language.save,
                    width: context.width(),
                    elevation: 0,
                    color: ColorUtils.colorPrimary,
                    textColor: Colors.white,
                    onTap: () {
                      setState(() {
                        _selectedIndex = tempSelectedIndex;
                        _selectedCycleLength = phaseLength[tempSelectedIndex];
                      });
                      userStore.setLutealPhase(tempSelectedIndex);
                      Navigator.of(context).pop();
                    },
                  ).expand(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPickersecond() {
    int tempSelectedIndex = _selectedIndex ?? 6;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.all(16),
          shape: dialogShape(),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(language.lastDays,
                  style: boldTextStyle(size: textFontSize_20)),
              18.height,
              SizedBox(
                height: context.height() * 0.2,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CupertinoPicker(
                      magnification: 1.4,
                      squeeze: 0.8,
                      useMagnifier: true,
                      selectionOverlay: SizedBox(),
                      itemExtent: 32.0,
                      scrollController: FixedExtentScrollController(
                          initialItem: tempSelectedIndex),
                      onSelectedItemChanged: (selectedItem) {
                        tempSelectedIndex = selectedItem;
                      },
                      children: lastdayslength.map((int item) {
                        return Text(
                          item == 0 ? 'Select' : item.toString(),
                          style: boldTextStyle(size: textFontSize_20),
                        ).center();
                      }).toList(),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            height: 2,
                            width: 100,
                            color: ColorUtils.colorPrimary),
                        45.height,
                        Container(
                            height: 2,
                            width: 100,
                            color: ColorUtils.colorPrimary),
                      ],
                    ),
                  ],
                ),
              ),
              18.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AppButton(
                    padding: EdgeInsets.zero,
                    height: 40,
                    text: language.cancel,
                    width: context.width(),
                    elevation: 0,
                    color: Colors.white,
                    textColor: ColorUtils.colorPrimary,
                    onTap: () {
                      finish(context);
                    },
                  ).expand(),
                  8.width,
                  AppButton(
                    padding: EdgeInsets.zero,
                    height: 40,
                    text: language.save,
                    width: context.width(),
                    elevation: 0,
                    color: ColorUtils.colorPrimary,
                    textColor: Colors.white,
                    onTap: () {
                      setState(() {
                        _selectedIndex = tempSelectedIndex;
                        _selectedLastPeriodLength =
                            lastdayslength[tempSelectedIndex];
                      });
                      userStore.setLutealPhase(tempSelectedIndex);
                      Navigator.of(context).pop();
                    },
                  ).expand(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  DateTime? _calculateNextPeriodDate() {
    if (_selectedDate != null &&
        _selectedCycleLength != null &&
        _selectedLastPeriodLength != null) {
      // Add the average cycle length to the selected date
      DateTime nextPeriodDate =
          _selectedDate!.add(Duration(days: _selectedCycleLength!));
      // Add the length of the last period to get the actual next period date
      nextPeriodDate =
          nextPeriodDate.add(Duration(days: _selectedLastPeriodLength!));
      return nextPeriodDate;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: mainColorLight,
            pinned: true,
            leading: IconButton(
              icon: Icon(CupertinoIcons.back, color: mainColorText),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            actions: [
              IconButton(
                icon:
                    Icon(CupertinoIcons.question_diamond, color: Colors.black),
                onPressed: () {
                  BlogDetailScreen(
                    article: widget.calculatorData.article,
                    title: widget.calculatorData.article!.name!,
                    fromHome: false,
                    onBookmarkUpdated: (updatedArticle) {
                      setState(() {
                        widget.calculatorData.article = updatedArticle;
                      });
                    },
                  ).launch(context);
                },
              ),
            ],
            title: Text(
              language.periodCalculator.capitalizeWords(),
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
                  offset: Offset(0, -30),
                  child: Container(
                    width: context.width(),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        HtmlWidget(widget.calculatorData.description.toString())
                            .center()
                            .paddingOnly(left: 8, top: 16, bottom: 8),
                        Text(
                          language.selectTheFirstDayOfYourPeriod,
                          style: boldTextStyle(
                              weight: FontWeight.w400,
                              size: 14,
                              color: mainColorBodyText),
                          textAlign: TextAlign.center,
                        ).paddingOnly(left: 16, bottom: 8),
                        8.height,
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 16),
                          decoration: boxDecorationWithRoundedCorners(
                              backgroundColor: Colors.white,
                              borderRadius: radius(defaultRadius)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate != null
                                    ? DateFormat('MMMM d, y')
                                        .format(_selectedDate!)
                                    : language.selectDateRange,
                                style: primaryTextStyle(size: textFontSize_14),
                              ),
                              Icon(Icons.calendar_month),
                            ],
                          ),
                        )
                            .paddingOnly(left: 16, bottom: 8, right: 16)
                            .onTap(() async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          setState(() {
                            _selectedDate = pickedDate;
                          });
                        }),
                        16.height,
                        Text(
                          language.howLongIsYourAverageCycle,
                          style: boldTextStyle(
                              weight: FontWeight.w400,
                              size: 14,
                              color: mainColorBodyText),
                          textAlign: TextAlign.center,
                        ).paddingOnly(left: 16, bottom: 8),
                        8.height,
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 16),
                          decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: Colors.white,
                            borderRadius: radius(defaultRadius),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedCycleLength != null
                                    ? "$_selectedCycleLength ${language.days}"
                                    : language.selectAverageCycleDays,
                                style: primaryTextStyle(size: textFontSize_14),
                              ),
                              Icon(Icons.calendar_view_day),
                            ],
                          ),
                        ).paddingOnly(left: 16, bottom: 8, right: 16).onTap(() {
                          _showPicker();
                        }),
                        8.height,
                        Text(
                          language.howManyDaysDidItLast,
                          style: boldTextStyle(
                              weight: FontWeight.w400,
                              size: 14,
                              color: mainColorBodyText),
                          textAlign: TextAlign.center,
                        ).paddingOnly(left: 16, bottom: 8),
                        8.height,
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 16),
                          decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: bgColor,
                            borderRadius: radius(defaultRadius),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedLastPeriodLength != null
                                    ? "$_selectedLastPeriodLength ${language.days}"
                                    : language.selectAverageCycleDays,
                                style: primaryTextStyle(size: textFontSize_14),
                              ),
                              Icon(Icons.calendar_view_day),
                            ],
                          ),
                        ).paddingOnly(left: 16, bottom: 8, right: 16).onTap(() {
                          _showPickersecond();
                        }),
                        8.height,
                        AppButton(
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          color: ColorUtils.colorPrimary,
                          width: context.width() * 0.4,
                          text:
                              language.CalculateFertilityDays.capitalizeWords(),
                          elevation: 0,
                          onTap: () {
                            DateTime? nextPeriodDate =
                                _calculateNextPeriodDate();
                            if (nextPeriodDate != null) {
                              showAdBeforeNavigation(
                                context: context,
                                showAd: (appStore.adsConfig?.adsconfigAccess ??
                                        false) &&
                                    (appStore.showAdsBasedOnConfig
                                            ?.useCalculatorTools ??
                                        false),
                                postAction: () async {
                                  logAnalyticsEvent(
                                      category: 'calculator',
                                      action: 'period_calculation');
                                },
                                screen: PeriodResultScreen(
                                  nextPeriodDate: nextPeriodDate,
                                ),
                              );
                            }
                          },
                        ),
                        8.height,
                        noteCommon(),
                        8.height,
                      ],
                    ).paddingSymmetric(horizontal: 16),
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
