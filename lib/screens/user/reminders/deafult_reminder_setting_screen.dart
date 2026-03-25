import 'dart:core';
import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/main.dart';
import 'package:clora_user/model/reminder_model.dart';
import 'package:clora_user/utils/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../components/user/day_picker_dialog.dart';
import '../../../service/reminder_service.dart';
import '../../../utils/app_common.dart';
import '../../widgets/reminder_widget.dart';

//ignore: must_be_immutable
class DefaultReminderSettingScreen extends StatefulWidget {
  DefaultReminderSettingScreen({required this.index});

  int index;

  @override
  State<DefaultReminderSettingScreen> createState() =>
      _DefaultReminderSettingScreenState();
}

class _DefaultReminderSettingScreenState
    extends State<DefaultReminderSettingScreen> {
  TimeOfDay? timeOfDay;
  int selectedDayIndex = 0;
  String appbarTitle = "";
  String subtitle = "";
  String message = "";
  ReminderModel? data;
  TextEditingController msgCont = TextEditingController();

  List<int>? result = [];

  @override
  void initState() {
    super.initState();
    setAppbarTitle();
    init();
  }

  setAppbarTitle() {
    if (widget.index == REMINDER_MEDICINE_INDEX) {
      appbarTitle = language.medicineReminders;
      subtitle = language.medicineRemindersText;
      message = "${language.TimeToTakeYourMedicine} 💊";
    } else if (widget.index == REMINDER_MEDITATION_INDEX) {
      appbarTitle = language.meditationReminders;
      subtitle = language
          .PrioritizeMindfulnessAndRelaxationWithDailyMeditationReminders;
      message = "${language.TakeAMindfulBreak} 🧘‍♀️";
    } else if (widget.index == REMINDER_DAILY_LOGGING_INDEX) {
      appbarTitle = language.dailyLoggingReminders;
      subtitle = language.dailyLoggingRemindersText;
      message = "${language.ItTimeToLogYourDay} 📖";
    } else if (widget.index == REMINDER_TRACKING_INDEX) {
      appbarTitle = language.trackingReminders;
      subtitle = language.trackingRemindersText;
      message = language.TrackYourProgressToday;
    } else if (widget.index == REMINDER_LOG_WEIGHT_INDEX) {
      appbarTitle = language.weightReminders;
      subtitle = language.TrackYourWeightRegularly;
      message = "${language.DoNotForgetToLogYourWeightToday} ⚖️";
    } else if (widget.index == REMINDER_DRINK_WATER_INDEX) {
      appbarTitle = language.drinkWaterReminders;
      subtitle = language.StayHydratedThroughout;
      message = language.StayHydratedDrinkWater;
    } else if (widget.index == REMINDER_SLEEP_INDEX) {
      appbarTitle = language.sleepReminders;
      subtitle = language.WindDownAndGetEnoughRest;
      message = "${language.PrepareForAGood} 🌙";
    } else if (widget.index == REMINDER_BODY_TEMPRATURE_INDEX) {
      appbarTitle = language.bodyTemperatureReminders;
      subtitle = language.LogYourBasalBodyTemperature;
      message = "${language.TimeToRecordYourBodyTemperature} 🌡";
    }
  }

  init() async {
    setAppbarTitle();
    data = await getReminderItem(index: widget.index);
    if (data != null) {
      timeOfDay = TimeOfDay(hour: data?.hours ?? 0, minute: data?.minutes ?? 0);
      if (widget.index == REMINDER_TRACKING_INDEX) {
        selectedDayIndex = data!.weekDay != null ? data!.weekDay! - 1 : 0;
      }
    }
    String? savedMessage = await getReminderMessage(widget.index);
    if (savedMessage != null && savedMessage.isNotEmpty) {
      msgCont.text = savedMessage;
    } else {
      msgCont.text = message;
    }
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  void showDayPickerDialog() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => DayPickerDialog(() {}),
    );

    if (result != null) {
      selectedDayIndex = result;
      timeOfDay = await showTimePicker(
          context: context,
          initialTime:
              TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: 1))),
          builder: (BuildContext context, Widget? child) {
            return child!;
          });
      if (timeOfDay != null) {
        updateReminder(
            index: widget.index,
            weekDay: selectedDayIndex != -1 ? selectedDayIndex + 1 : null,
            hours: timeOfDay!.hour,
            minutes: timeOfDay!.minute,
            year: null,
            month: null,
            day: null,
            isOn: true);
        data = await getReminderItem(index: widget.index);

        setState(() {});
        scheduleReminders(index: widget.index);
      }
    }
  }

  String processReminderName(String appbarTitle) {
    String result =
        appbarTitle.replaceAll(RegExp('reminder', caseSensitive: false), '');
    return result.toLowerCase().trim();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: data != null
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
                            appbarTitle,
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
                  Transform.translate(
                    offset: Offset(0, -16),
                    child: Container(
                      width: context.width(),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          ReminderWidget(
                            titleText: appbarTitle,
                            descriptionText: subtitle,
                            reminderType:
                                data!.reminderType == REMINDER_TYPE_DAILY
                                    ? language.Daily
                                    : language.weekly,
                            reminderName: processReminderName(appbarTitle),
                            selectedDay: data!.reminderType ==
                                    REMINDER_TYPE_DAILY
                                ? formatReminderTime(data?.hours, data?.minutes)
                                : (getWeekdayName(selectedDayIndex)) +
                                    " at " +
                                    formatReminderTime(
                                        data?.hours, data?.minutes),
                            isReminderOn: data!.isReminderOn! &&
                                getReminderMessage(widget.index)
                                    .toString()
                                    .isNotEmpty,
                            onSwitchChanged: (value) {
                              setState(() {
                                data!.isReminderOn = value;
                              });
                              if (value == false) {
                                cancelReminder(index: widget.index);
                                clearReminder(widget.index);
                                msgCont.clear();
                              }
                              setState(() {});
                            },
                            messageController: msgCont,
                            onEditTimePressed: () async {
                              if (widget.index == REMINDER_TRACKING_INDEX) {
                                showDayPickerDialog();
                                return;
                              }
                              timeOfDay = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                    DateTime.now().add(Duration(minutes: 1)),
                                  ),
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return child!;
                                  });

                              if (timeOfDay != null) {
                                setState(() {
                                  data!.hours = timeOfDay!.hour;
                                  data!.minutes = timeOfDay!.minute;
                                });
                              }
                            },
                            onConfirmPressed: () async {
                              FocusScope.of(context).unfocus();
                              await Future.delayed(Duration(milliseconds: 100));
                              if (data!.isReminderOn!) {
                                setReminderMessage(widget.index, msgCont.text);
                                setReminderTitle(widget.index, appbarTitle);

                                if (timeOfDay == null ||
                                    timeOfDay!.hour == 00 &&
                                        timeOfDay!.minute == 00) {
                                  toast(language.pleaseSelectATime);
                                  return;
                                }

                                if (msgCont.text.isEmpty) {
                                  toast(language.PleaseEnterMessageForReminder);
                                  return;
                                }

                                updateReminder(
                                    index: widget.index,
                                    weekDay: null,
                                    hours: timeOfDay?.hour,
                                    minutes: timeOfDay?.minute,
                                    year: null,
                                    month: null,
                                    day: null,
                                    isOn: true);
                                scheduleReminders(index: widget.index);
                                toast(language.ReminderSetSuccessfully);
                                String screenTitle =
                                    processReminderName(appbarTitle);
                                logAnalyticsEvent(
                                    category: "${screenTitle}_reminder",
                                    action: "created");
                              }
                              setState(() {});
                            },
                            cancelButtonText: language.EditTime,
                            confirmButtonText: language.save,
                            primaryColor: ColorUtils.colorPrimary,
                            reminderDateTime: null,
                          ),
                        ],
                      ).paddingSymmetric(vertical: 16),
                    ),
                  ),
                ],
              )
            : Loader(),
      ),
    );
  }
}
