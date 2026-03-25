import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/extensions/new_colors.dart';
import 'package:clora_user/screens/user/user_dashboard_screen.dart';
import 'package:clora_user/utils/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget.dart';
import '../../../components/common/time_dialog.dart';
import '../../../main.dart';
import '../../../model/reminder_model.dart';
import '../../../service/reminder_service.dart';
import '../../../utils/app_common.dart';
import '../../widgets/reminder_widget.dart';
import '../home_screen.dart';

class CycleReminderScreen extends StatefulWidget {
  const CycleReminderScreen({super.key});

  @override
  State<CycleReminderScreen> createState() => _CycleReminderScreenState();
}

class _CycleReminderScreenState extends State<CycleReminderScreen> {
  int selectedOption = -1;
  ReminderModel? dataPeriod;
  ReminderModel? dataOvulation;
  DateTime nextPeriodDate = DateTime(2025, 03, 07);
  DateTime nextOvulation = DateTime(2025, 03, 07);
  bool _isInitCompleted = false;
  bool _showNoDataView = false;
  TextEditingController periodMsgCont = TextEditingController(
      text: "${language.YourPeriodIsExpectedSoon} 🌸"); // Default message
  TextEditingController ovulationMsgCont =
      TextEditingController(text: "${language.YouAreEntering} ✨");
  List<int>? result = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    String predictedPeriodDate = await instance.getNextPredictedPeriodDate();
    String predictedOvulationDate = await instance.getNextOvulationDate();

    try {
      nextPeriodDate = DateTime.parse(predictedPeriodDate);
      nextOvulation = DateTime.parse(predictedOvulationDate);
    } catch (e) {
      printEraAppLogs("Error parsing dates: $e");
      // toast("Invalid date format: ${e.toString()}");
    }

    if (nextPeriodDate.isBefore(DateTime.now()) &&
        nextOvulation.isBefore(DateTime.now())) {
      setState(() {
        _showNoDataView = true;
        _isInitCompleted = true;
      });
      return;
    }

    String? periodMessage = await getReminderMessage(REMINDER_PERIOD_INDEX);
    if (periodMessage != null) {
      periodMsgCont.text = periodMessage;
      FocusScope.of(context).unfocus();
    }
    String? ovulationMessage =
        await getReminderMessage(REMINDER_OVULATION_INDEX);
    if (ovulationMessage != null) {
      ovulationMsgCont.text = ovulationMessage;
      FocusScope.of(context).unfocus();
    }

    await getPeriodReminder();
    await getOvulationReminder();
    await Future.delayed(Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isInitCompleted = true;
      });
    }
  }

  Future<void> getPeriodReminder() async {
    dataPeriod = await getReminderItem(index: REMINDER_PERIOD_INDEX);
  }

  Future<void> getOvulationReminder() async {
    dataOvulation = await getReminderItem(index: REMINDER_OVULATION_INDEX);
  }

  Widget _buildNoDataView() {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              kToolbarHeight -
              160,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image.asset(
                  //   ic_woman_with_flower,
                  //   width: 100,
                  //   height: 100,
                  //   fit: BoxFit.contain,
                  // ),
                  // 16.height,
                  Text(
                    language.NoDataAvailableToGenerateYourCycleReminder,
                    textAlign: TextAlign.center,
                    style: boldTextStyle(
                      weight: FontWeight.w500,
                      size: textFontSize_14,
                    ),
                  ),
                  16.height,
                  CustomListTile(
                    icon: Icons.check,
                    normalText1:
                        language.PleaseLogYourDataToGenerateCycleReminder,
                    boldText: "",
                    normalText2: "",
                  ),
                  16.height,
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: ColorUtils.colorPrimary,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          language.logPreviousCycle,
                          style: boldTextStyle(
                            color: Colors.white,
                            isHeader: true,
                          ),
                        ),
                      ],
                    ),
                  ).center().onTap(() {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MenstrualCycleMonthlyCalenderView(
                          themeColor: Colors.black,
                          isShowCloseIcon: true,
                          onDataChanged: (value) {
                            if (value) {
                              setState(() {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DashboardScreen(currentIndex: 0),
                                  ),
                                );
                              });
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: _isInitCompleted
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: kToolbarHeight + MediaQuery.of(context).padding.top,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                    ),
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top),
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              pop();
                            },
                            icon: Icon(CupertinoIcons.back)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            language.cycleReminders,
                            style: boldTextStyle(
                              color: Colors.black,
                              size: 20,
                              weight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    color: kPrimaryColor,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Transform.translate(
                            offset: Offset(0, -25),
                            child: Container(
                              width: context.width(),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              child: _showNoDataView
                                  ? _buildNoDataView().center()
                                  : Column(
                                      children: [
                                        20.height,
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: kPrimaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      language.nextPeriod,
                                                      style: boldTextStyle(
                                                        color: mainColor,
                                                        size: 12,
                                                        weight: FontWeight.w400,
                                                      ),
                                                    ).paddingOnly(
                                                        top: 10, left: 10),
                                                    8.height,
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          DateFormat(
                                                                  'd MMMM, y')
                                                              .format(DateTime(
                                                                  nextPeriodDate
                                                                      .year,
                                                                  nextPeriodDate
                                                                      .month,
                                                                  nextPeriodDate
                                                                      .day)),
                                                          style: boldTextStyle(
                                                            color:
                                                                mainColorText,
                                                            size: 14,
                                                            weight:
                                                                FontWeight.w500,
                                                          ),
                                                        ).paddingOnly(
                                                            left: 10,
                                                            bottom: 10),
                                                        Spacer(),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            8.width,
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: backgroundYellow,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      language.nextOvulation,
                                                      style: boldTextStyle(
                                                        color: warningColor,
                                                        size: 12,
                                                        weight: FontWeight.w400,
                                                      ),
                                                    ).paddingOnly(
                                                        top: 10, left: 10),
                                                    8.height,
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          DateFormat(
                                                                  'd MMMM, y')
                                                              .format(DateTime(
                                                                  nextOvulation
                                                                      .year,
                                                                  nextOvulation
                                                                      .month,
                                                                  nextOvulation
                                                                      .day)),
                                                          style: boldTextStyle(
                                                            color:
                                                                mainColorText,
                                                            size: 14,
                                                            weight:
                                                                FontWeight.w500,
                                                          ),
                                                        ).paddingOnly(
                                                            left: 10,
                                                            bottom: 10),
                                                        Spacer(),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ).paddingSymmetric(horizontal: 16),
                                        8.height,
                                        ReminderWidget(
                                          titleText: language.periodReminders,
                                          descriptionText:
                                              language.GetTimelyAlerts,
                                          isReminderOn:
                                              dataPeriod?.isReminderOn ?? false,
                                          onSwitchChanged: (value) async {
                                            setState(() => dataPeriod!
                                                .isReminderOn = value);
                                            await updateReminder(
                                              index: REMINDER_PERIOD_INDEX,
                                              isOn: value,
                                              hours: dataPeriod!.hours ?? 8,
                                              minutes: dataPeriod!.minutes ?? 0,
                                              month: nextPeriodDate.month,
                                              year: nextPeriodDate.year,
                                              day: nextPeriodDate.day,
                                              weekDay: nextPeriodDate.weekday,
                                            );
                                            if (!value)
                                              await cancelReminder(
                                                  index: REMINDER_PERIOD_INDEX);
                                            dataPeriod = await getReminderItem(
                                                index: REMINDER_PERIOD_INDEX);
                                            if (mounted) setState(() {});
                                          },
                                          messageController: periodMsgCont,
                                          onEditTimePressed: () async {
                                            result =
                                                await showDialog<List<int>>(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (context) => TimeDialog(
                                                  dataPeriod!.hours,
                                                  dataPeriod!.minutes!),
                                            );
                                            if (result != null &&
                                                result!.isNotEmpty) {
                                              setState(() {
                                                dataPeriod!.hours = result![0];
                                                dataPeriod!.minutes =
                                                    result![1];
                                              });
                                            }
                                          },
                                          onConfirmPressed: () async {
                                            setReminderMessage(
                                                dataPeriod!.index!,
                                                periodMsgCont.text);
                                            setReminderTitle(
                                                dataOvulation!.index!,
                                                language.periodReminders);
                                            FocusScope.of(context).unfocus();
                                            await Future.delayed(
                                                Duration(milliseconds: 100));
                                            if (periodMsgCont.text.isNotEmpty) {
                                              if (dataPeriod!.isReminderOn!) {
                                                if (result != null &&
                                                    result?.length == 2) {
                                                  updateReminder(
                                                    index:
                                                        REMINDER_PERIOD_INDEX,
                                                    weekDay: null,
                                                    month: nextPeriodDate.month,
                                                    year: nextPeriodDate.year,
                                                    hours: result![0],
                                                    minutes: result![1],
                                                    day: nextPeriodDate.day,
                                                    isOn: true,
                                                  ).whenComplete(() {
                                                    scheduleReminders(
                                                        index:
                                                            REMINDER_PERIOD_INDEX);
                                                    toast(language
                                                        .ReminderSetSuccessfully);
                                                  });
                                                  dataPeriod =
                                                      await getReminderItem(
                                                          index:
                                                              REMINDER_PERIOD_INDEX);
                                                  setState(() {});
                                                } else {
                                                  toast(language
                                                      .pleaseSelectATime);
                                                }
                                              } else {
                                                setState(() {
                                                  dataPeriod?.hours = 0;
                                                  dataPeriod?.minutes = 0;
                                                });
                                                cancelReminder(
                                                    index:
                                                        REMINDER_PERIOD_INDEX);
                                              }
                                            } else {
                                              toast(language
                                                  .PleaseEnterMessageForReminder);
                                            }
                                            setState(() {});
                                          },
                                          cancelButtonText: language.EditTime,
                                          confirmButtonText: language.save,
                                          primaryColor: ColorUtils.colorPrimary,
                                          reminderDateTime: DateTime(
                                            nextPeriodDate.year,
                                            nextPeriodDate.month,
                                            nextPeriodDate.day,
                                            dataPeriod?.hours ?? 0,
                                            dataPeriod?.minutes ?? 0,
                                          ),
                                        ),
                                        8.height,
                                        ReminderWidget(
                                          titleText: language.ovulationReminder,
                                          descriptionText:
                                              language.StayInformedAbout,
                                          isReminderOn:
                                              dataOvulation?.isReminderOn ??
                                                  false,
                                          onSwitchChanged: (value) async {
                                            setState(() => dataOvulation!
                                                .isReminderOn = value);
                                            await updateReminder(
                                              index: REMINDER_OVULATION_INDEX,
                                              isOn: value,
                                              hours: dataOvulation!.hours ?? 8,
                                              minutes:
                                                  dataOvulation!.minutes ?? 0,
                                              month: nextOvulation.month,
                                              year: nextOvulation.year,
                                              day: nextOvulation.day,
                                              weekDay: nextOvulation.weekday,
                                            );
                                            if (!value)
                                              await cancelReminder(
                                                  index:
                                                      REMINDER_OVULATION_INDEX);
                                            dataOvulation = await getReminderItem(
                                                index:
                                                    REMINDER_OVULATION_INDEX);
                                            if (mounted) setState(() {});
                                          },
                                          messageController: ovulationMsgCont,
                                          onEditTimePressed: () async {
                                            result =
                                                await showDialog<List<int>>(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (context) => TimeDialog(
                                                  dataOvulation!.hours,
                                                  dataOvulation!.minutes!),
                                            );
                                            if (result != null &&
                                                result!.isNotEmpty) {
                                              setState(() {
                                                dataOvulation!.hours =
                                                    result![0];
                                                dataOvulation!.minutes =
                                                    result![1];
                                              });
                                            }
                                          },
                                          onConfirmPressed: () async {
                                            FocusScope.of(context).unfocus();
                                            await Future.delayed(
                                                Duration(milliseconds: 100));
                                            if (ovulationMsgCont
                                                .text.isNotEmpty) {
                                              if (dataOvulation!
                                                  .isReminderOn!) {
                                                setReminderMessage(
                                                    dataOvulation!.index!,
                                                    ovulationMsgCont.text);
                                                setReminderTitle(
                                                    dataOvulation!.index!,
                                                    language.ovulationReminder);
                                                if (result != null &&
                                                    result!.length == 2) {
                                                  updateReminder(
                                                    index:
                                                        REMINDER_OVULATION_INDEX,
                                                    weekDay: null,
                                                    month: nextOvulation.month,
                                                    year: nextOvulation.year,
                                                    hours: result![0],
                                                    minutes: result![1],
                                                    day: nextOvulation.day,
                                                    isOn: true,
                                                  ).whenComplete(() {
                                                    scheduleReminders(
                                                        index:
                                                            REMINDER_OVULATION_INDEX);
                                                    toast(language
                                                        .ReminderSetSuccessfully);
                                                  });
                                                  dataOvulation =
                                                      await getReminderItem(
                                                          index:
                                                              REMINDER_OVULATION_INDEX);
                                                  setState(() {});
                                                } else {
                                                  toast(language
                                                      .pleaseSelectATime);
                                                }
                                              }
                                            } else {
                                              toast(language
                                                  .PleaseEnterMessageForReminder);
                                            }
                                            FocusScope.of(context).unfocus();
                                            setState(() {});
                                          },
                                          cancelButtonText: language.EditTime,
                                          confirmButtonText: language.save,
                                          primaryColor: ColorUtils.colorPrimary,
                                          reminderDateTime: DateTime(
                                            nextOvulation.year,
                                            nextOvulation.month,
                                            nextOvulation.day,
                                            dataOvulation?.hours ?? 0,
                                            dataOvulation?.minutes ?? 0,
                                          ),
                                        ),
                                        4.height,
                                      ],
                                    ).paddingSymmetric(vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Loader().center(),
      ),
    );
  }
}

void scheduleReminderOnGoalChanged() {
  List<int> reminderIndexes = [
    REMINDER_MEDICINE_INDEX,
    REMINDER_MEDITATION_INDEX,
    REMINDER_DAILY_LOGGING_INDEX,
    REMINDER_TRACKING_INDEX,
    REMINDER_PERIOD_INDEX,
    REMINDER_FERTILITY_INDEX,
    REMINDER_OVULATION_INDEX,
    REMINDER_SLEEP_INDEX,
    REMINDER_DRINK_WATER_INDEX,
    REMINDER_BODY_TEMPRATURE_INDEX,
    REMINDER_LOG_WEIGHT_INDEX,
  ];

  for (int index in reminderIndexes) {
    scheduleReminders(index: index);
  }
}
