import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/extensions/extension_util/string_extensions.dart';
import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:clora_user/main.dart';
import 'package:clora_user/model/user/calculator_model.dart';
import 'package:clora_user/screens/user/calculator/pragnancy_due_result.dart';
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
import '../../../extensions/text_styles.dart';
import '../../../utils/app_common.dart';
import '../../../utils/dynamic_theme.dart';
import '../blog_detail_screen.dart';

class PregnancyDueDataCalculator extends StatefulWidget {
  final CalculatorItem calculatorData;

  const PregnancyDueDataCalculator({super.key, required this.calculatorData});

  @override
  State<PregnancyDueDataCalculator> createState() =>
      _PregnancyDueDataCalculatorState();
}

class _PregnancyDueDataCalculatorState
    extends State<PregnancyDueDataCalculator> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    logScreenView("Pregnancy due date screen");
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
              language.pregnancyDueDateCalculator.capitalizeWords(),
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
                        8.height,
                        AppButton(
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          color: ColorUtils.colorPrimary,
                          width: context.width() * 0.4,
                          text: language.calculateDueDate,
                          elevation: 0,
                          onTap: () {
                            if (_selectedDate != null) {
                              DateTime dueDate =
                                  _selectedDate!.add(Duration(days: 280));
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
                                      action: 'pregnancy_calculation');
                                },
                                screen: PregnancyDueResult(
                                  dueDate: dueDate,
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
