import 'dart:convert';

import 'package:clora_user/extensions/new_colors.dart';
import 'package:clora_user/model/user/question_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget_base.dart';

import '../../extensions/LiveStream.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extensions.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/app_constants.dart';
import '../../utils/dynamic_theme.dart';

class PeriodPredictionsScreen extends StatefulWidget {
  @override
  PeriodPredictionsScreenState createState() => PeriodPredictionsScreenState();
}

class PeriodPredictionsScreenState extends State<PeriodPredictionsScreen> {
  int? index = -1;
  int? value = 0;
  int? selectedItem = -1;
  QuestionsModel? questionsModelData;

  // Helper lists
  List<String> getCycleLengthList() =>
      List.generate(30, (i) => (i + 21).toString());

  List<String> getPeriodLengthList() =>
      List.generate(15, (i) => (i + 2).toString());

  List<Object> getLutealLengthList() => List.generate(14, (i) => i + 7);

  // Initialize GoalTypeModel options
  final goalOptions = [
    GoalTypeModel(
      img: "",
      title: "Track Cycle",
      desc: "Stay prepared for your next period.",
    ),
    GoalTypeModel(
      img: "",
      title: "Track Pregnancy",
      desc: "Monitor changes in your body.",
    ),
  ];

  QuestionsModel getInitializedQuestionsModel() {
    return QuestionsModel(
      step1: Step1(
        title: "Are you using Era for yourself?",
        options: [
          "Yes, for tracking my cycle.",
          "Yes, as a doctor.",
          "No, I have partner code."
        ],
        selectedOption: -1,
        isSkip: false,
        isConfirm: false,
      ),
      step2: Step2(
        title: "What is your goal?",
        desc: "All features will be available",
        options: goalOptions,
        selectedOption: 0,
        isSkip: false,
        isConfirm: true,
      ),
      step3: Step3(
        title: "When was your last period?",
        desc: "Provide this information for accurate predictions",
        selectedLastPeriodDate: "",
        isSkip: true,
        isConfirm: true,
      ),
      step4: Step4(
        title: "What is your cycle length?",
        cycleLengthList: getCycleLengthList(),
        selectedOption: userStore.user!.cycleLength ?? 28,
        isSkip: true,
        isConfirm: true,
      ),
      step5: Step5(
        title: "What is your period duration?",
        desc: "How many days does your period typically last",
        periodLengthList: getPeriodLengthList(),
        selectedOption: userStore.user!.periodLength ?? 5,
        isSkip: true,
        isConfirm: true,
      ),
      step6: Step6(
        title: "What is Luteal Phase?",
        desc: "Duration between ovulation and start of period",
        lutealLengthList: getLutealLengthList(),
        selectedOption: userStore.user!.lutealPhase ?? 14,
        isSkip: true,
        isConfirm: true,
      ),
      step7: Step7(
        title: "Complete Your Profile",
        desc:
            "Help us personalize your experience by providing some basic information",
        question1: "What is your full name?",
        question2: "What is your age?",
        answerToQuestion1: "",
        // Will be filled by user input
        answerToQuestion2: "",
        // Will be filled by user input
        confirm: true,
        // Shows confirm button
        skip: true, // Allows skipping this step
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    logScreenView("Period prediction screen");
    final storedData = getStringAsync(KEY_QUESTION_DATA);
    if (storedData.isNotEmpty) {
      questionsModelData = QuestionsModel.fromJson(jsonDecode(storedData));
      if (userStore.cycleLength == 0) {
        userStore.setCycleLength(
            questionsModelData?.step4.selectedOption ?? DEFAULT_CYCLE_LENGTH);
      }
      if (userStore.periodsLength == 0) {
        userStore.setPeriodsLength(
            questionsModelData?.step5.selectedOption ?? DEFAULT_PERIOD_LENGTH);
      }
    } else {
      questionsModelData = getInitializedQuestionsModel();
      userStore.setCycleLength(
          questionsModelData?.step4.selectedOption ?? DEFAULT_CYCLE_LENGTH);
      userStore.setPeriodsLength(
          questionsModelData?.step5.selectedOption ?? DEFAULT_PERIOD_LENGTH);
    }
    updateConfiguration();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _showPicker(String title, int index, int value) async {
    List<Object> targetList = [];
    int initialIndex = 0;

    if (index == 0) {
      targetList = getCycleLengthList().cast<Object>();
      initialIndex =
          targetList.indexWhere((item) => item.toString() == value.toString());
      if (initialIndex == -1) {
        initialIndex = targetList.indexWhere(
            (item) => item.toString() == DEFAULT_CYCLE_LENGTH.toString());
        if (initialIndex == -1) initialIndex = 0;
      }
    } else if (index == 1) {
      targetList = getPeriodLengthList().cast<Object>();
      initialIndex =
          targetList.indexWhere((item) => item.toString() == value.toString());
      if (initialIndex == -1) {
        initialIndex = targetList.indexWhere(
            (item) => item.toString() == DEFAULT_PERIOD_LENGTH.toString());
        if (initialIndex == -1) initialIndex = 0;
      }
    } else if (index == 2) {
      targetList = getLutealLengthList();
      initialIndex = targetList.indexWhere((item) => item == value);
      if (initialIndex == -1) {
        initialIndex = targetList.indexWhere((item) => item == 14);
        if (initialIndex == -1) initialIndex = 0;
      }
    } else {
      targetList = getCycleLengthList().cast<Object>();
      initialIndex = 0;
    }

    int selectedItem = initialIndex;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.all(16),
            shape: dialogShape(),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: boldTextStyle(size: textFontSize_20)),
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
                          initialItem: initialIndex,
                        ),
                        onSelectedItemChanged: (int newIndex) {
                          setState(() {
                            selectedItem = newIndex;
                          });
                        },
                        children: targetList.map((Object item) {
                          return Text(
                            item.toString(),
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
                            color: ColorUtils.colorPrimary,
                          ),
                          45.height,
                          Container(
                            height: 2,
                            width: 100,
                            color: ColorUtils.colorPrimary,
                          ),
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
                      disabledColor: ColorUtils.colorPrimary,
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
                      disabledColor: ColorUtils.colorPrimary,
                      padding: EdgeInsets.zero,
                      height: 40,
                      text: language.save,
                      width: context.width(),
                      elevation: 0,
                      color: ColorUtils.colorPrimary,
                      textColor: Colors.white,
                      onTap: () {
                        setState(() {
                          if (index == 0) {
                            final selectedValue =
                                int.parse(targetList[selectedItem].toString());
                            questionsModelData!.step4.selectedOption =
                                selectedValue;
                            userStore.setCycleLength(selectedValue);
                            setValue(KEY_QUESTION_DATA,
                                jsonEncode(questionsModelData!.toJson()));
                            updateConfiguration();
                          } else if (index == 1) {
                            final selectedValue =
                                int.parse(targetList[selectedItem].toString());
                            questionsModelData!.step5.selectedOption =
                                selectedValue;
                            userStore.setPeriodsLength(selectedValue);
                            setValue(KEY_QUESTION_DATA,
                                jsonEncode(questionsModelData!.toJson()));
                            updateConfiguration();
                          } else if (index == 2) {
                            final selectedValue =
                                targetList[selectedItem] as int;
                            questionsModelData!.step6.selectedOption =
                                selectedValue;
                            userStore.setLutealPhase(selectedValue);
                            setValue(KEY_QUESTION_DATA,
                                jsonEncode(questionsModelData!.toJson()));
                            updateConfiguration();
                          }
                          LiveStream().emit("predictionDataUpdate");
                        });
                        Navigator.of(context).pop();
                      },
                    ).expand(),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  updateConfiguration() async {
    final instance = MenstrualCycleWidget.instance!;
    DateTime? lastPeriodDate;
    String previousPeriodDay = await instance.getPreviousPeriodDay();
    lastPeriodDate = DateTime.parse(previousPeriodDay);
    lastPeriodDate = (lastPeriodDate.isAtSameMomentAs(DateTime(1971, 1, 1)))
        ? null
        : lastPeriodDate;
    instance.updateConfiguration(
        cycleLength: userStore.cycleLength,
        periodDuration: userStore.periodsLength,
        customerId: userStore.userId.toString(),
        lastPeriodDate: lastPeriodDate);

    updateMenstrualWidgetLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
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
                      onPressed: () => pop(),
                      icon: Icon(CupertinoIcons.back, color: mainColorText),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        language.periodPrediction,
                        style: boldTextStyle(
                          color: mainColorText,
                          size: 18,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Pink background extension
              Container(
                height: 20,
                width: context.width(),
                color: kPrimaryColor,
              ),

              // Main content area
              Transform.translate(
                offset: Offset(0, -20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        (kToolbarHeight +
                            MediaQuery.of(context).padding.top +
                            20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        24.height,
                        InfoCard(
                          title: language.cycleLength,
                          unit: "Days",
                          value: (userStore.cycleLength != 0
                                  ? userStore.cycleLength
                                  : questionsModelData?.step4.selectedOption ??
                                      DEFAULT_CYCLE_LENGTH)
                              .toString(),
                          isText: false,
                          onEdit: () {
                            _showPicker(
                              language.cycleLength,
                              0,
                              userStore.cycleLength
                            );
                          },
                        ),
                        24.height,
                        InfoCard(
                          title: language.periodLength,
                          unit: "Days",
                          value: (userStore.periodsLength != 0
                                  ? userStore.periodsLength
                                  : questionsModelData?.step5.selectedOption ??
                                      DEFAULT_PERIOD_LENGTH)
                              .toString(),
                          isText: true,
                          onEdit: () {
                            _showPicker(
                              language.periodLength,
                              1,
                              userStore.periodsLength
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final bool isText;
  final VoidCallback? onEdit;

  const InfoCard({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.isText,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: boldTextStyle(
                      size: 18,
                      weight: FontWeight.w500,
                      color: mainColorText,
                    ),
                  ),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: FaIcon(FontAwesomeIcons.pen,
                          size: 24, color: mainColor),
                      onPressed: onEdit,
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            Divider(height: 1, color: mainColorStroke),
            // Value display
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Row(
                children: [
                  Text(
                    value,
                    style: boldTextStyle(
                        size: textFontSize_22,
                        weight: FontWeight.w500,
                        color: mainColor),
                  ),
                  4.width,
                  Text(
                    unit,
                    style: boldTextStyle(
                        size: textFontSize_22,
                        weight: FontWeight.w500,
                        color: mainColor),
                  ),
                ],
              ),
            ),
            Text(
              language.periodLengthText,
              style: primaryTextStyle(),
            ).paddingSymmetric(horizontal: 16).visible(isText),
            8.height,
          ],
        ),
      ),
    );
  }
}
