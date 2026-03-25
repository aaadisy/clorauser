import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/extensions/extension_util/string_extensions.dart';
import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:clora_user/extensions/new_colors.dart';
import 'package:clora_user/model/user/question_model.dart';
import 'package:clora_user/screens/user/about_screen.dart';
import 'package:clora_user/screens/user/inter_settings_screen.dart';
import 'package:clora_user/screens/user/period_prediction_screen.dart';
import 'package:clora_user/screens/user/processing_screen.dart';
import 'package:clora_user/screens/user/reminders/cycle_reminder_screen.dart';
import 'package:clora_user/screens/user/reminders/deafult_reminder_setting_screen.dart';
import 'package:clora_user/screens/user/reminders/secret_reminder_screen.dart';
import 'package:clora_user/screens/user/secret_chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:terminate_restart/terminate_restart.dart';

import '../../components/common/settings_components.dart';
import '../../extensions/colors.dart';
import '../../extensions/common.dart';
import '../../extensions/confirmation_dialog.dart';
import '../../extensions/constants.dart';
import '../../extensions/loader_widget.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../network/rest_api.dart';
import '../../service/reminder_service.dart';
import '../../utils/custom_dialog.dart';
import '../../utils/dynamic_theme.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/utils.dart';
import 'faq_screen.dart';
import 'home_screen.dart';
import 'user_edit_profile_screen.dart';
import 'ask_expert_list_screen.dart';
import 'bookmark_screen.dart';
import 'calculator/calculator_screen.dart';
import 'user_dashboard_screen.dart';
import 'graphs_reports_screen.dart';
import '../../model/reminder_model.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with SingleTickerProviderStateMixin {
  List<String> goalList = [
    language.trackCycle,
    language.trackPregnancy,
  ];

  String? userLastPeriodDate;

  int currentGoalIndex = 0;
  Set<int> selectList = Set<int>();
  QuestionsModel? questionsModelData;
  bool isRemindersEnabled = false;
  String? _periodReminderSubtitle;
  String? _ovulationReminderSubtitle;

  Future<void> _updateCycleReminderSubtitles() async {
    final periodReminder = await getReminderItem(index: REMINDER_PERIOD_INDEX);
    final ovulationReminder =
        await getReminderItem(index: REMINDER_OVULATION_INDEX);

    setState(() {
      _periodReminderSubtitle = periodReminder?.isReminderOn == true
          ? "${language.periodReminders}: ${formatTimeToAmPm(periodReminder!.hours!, periodReminder.minutes!)}"
          : null;

      _ovulationReminderSubtitle = ovulationReminder?.isReminderOn == true
          ? "${language.ovulationReminder}: ${formatTimeToAmPm(ovulationReminder!.hours!, ovulationReminder.minutes!)}"
          : null;
    });
  }

  String? _buildCycleReminderSubtitles() {
    final hasPeriod = _periodReminderSubtitle != null;
    final hasOvulation = _ovulationReminderSubtitle != null;

    if (hasPeriod && hasOvulation) {
      return '${_periodReminderSubtitle}, ${_ovulationReminderSubtitle}';
    }
    return _periodReminderSubtitle ?? _ovulationReminderSubtitle;
  }

  // List of all reminder indices
  final List<int> _reminderIndices = [
    REMINDER_MEDICINE_INDEX,
    REMINDER_MEDITATION_INDEX,
    REMINDER_DAILY_LOGGING_INDEX,
    REMINDER_TRACKING_INDEX,
    REMINDER_LOG_WEIGHT_INDEX,
    REMINDER_DRINK_WATER_INDEX,
    REMINDER_SLEEP_INDEX,
    REMINDER_BODY_TEMPRATURE_INDEX,
  ];

  final Map<int, String?> reminderSubtitles = {
    REMINDER_MEDICINE_INDEX: null,
    REMINDER_MEDITATION_INDEX: null,
    REMINDER_DAILY_LOGGING_INDEX: null,
    REMINDER_TRACKING_INDEX: null,
    REMINDER_LOG_WEIGHT_INDEX: null,
    REMINDER_DRINK_WATER_INDEX: null,
    REMINDER_SLEEP_INDEX: null,
    REMINDER_BODY_TEMPRATURE_INDEX: null,
  };

  @override
  void initState() {
    super.initState();
    getQuestionData();
    loadMainReminderState();
    setReminderSubtitleForActiveReminders();
    _updateCycleReminderSubtitles();
    logScreenView("UserSettings screen");
  }

  Future<void> setReminderSubtitleForActiveReminders() async {
    reminderSubtitles.updateAll((_, __) => null);

    await Future.wait(_reminderIndices.map((index) async {
      final reminder = await getReminderItem(index: index);

      if (reminder?.isReminderOn != true || reminder?.index == null) return;

      reminderSubtitles[index] =
          "${language.Your} ${_getReminderTypeName(reminder!.index!)} ${language.isSet} ${formatTimeToAmPm(reminder.hours!, reminder.minutes!)}";
    }));

    if (mounted) setState(() {});
  }

  Future<void> navigateToRemindersScreen({int? index}) async {
    await NavigationUtils.navigateWithPostPopAction(
      context: context,
      screen: DefaultReminderSettingScreen(index: index!),
      showRewardedAd: false,
      postPopAction: () async {
        setReminderSubtitleForActiveReminders();
      },
    );
  }

  String formatTimeToAmPm(int hours, int minutes) {
    hours = hours.clamp(0, 23);
    minutes = minutes.clamp(0, 59);

    final period = hours < 12 ? 'AM' : 'PM';
    final displayHours = hours % 12 == 0 ? 12 : hours % 12;

    // Format minutes with leading zero if needed
    final displayMinutes = minutes.toString().padLeft(2, '0');

    return '$displayHours:$displayMinutes $period';
  }

  String _getReminderTypeName(int type) {
    switch (type) {
      case REMINDER_MEDICINE_INDEX:
        return language.medicineReminders.toLowerCase();
      case REMINDER_MEDITATION_INDEX:
        return language.meditationReminders.toLowerCase();
      case REMINDER_DAILY_LOGGING_INDEX:
        return language.dailyLoggingReminders.toLowerCase();
      case REMINDER_TRACKING_INDEX:
        return language.trackingReminders.toLowerCase();
      case REMINDER_LOG_WEIGHT_INDEX:
        return language.waterDrinkingReminders.toLowerCase();
      case REMINDER_SLEEP_INDEX:
        return language.sleepReminders.toLowerCase();
      case REMINDER_BODY_TEMPRATURE_INDEX:
        return language.bodyTemperatureReminders.toLowerCase();
      default:
        return 'Reminder';
    }
  }

  String? get medicineReminderSubtitle =>
      reminderSubtitles[REMINDER_MEDICINE_INDEX];

  String? get meditationReminderSubtitle =>
      reminderSubtitles[REMINDER_MEDITATION_INDEX];

  String? get dailyLoggingReminderSubtitle =>
      reminderSubtitles[REMINDER_DAILY_LOGGING_INDEX];

  String? get trackingReminderSubtitle =>
      reminderSubtitles[REMINDER_TRACKING_INDEX];

  String? get logWeightReminderSubtitle =>
      reminderSubtitles[REMINDER_LOG_WEIGHT_INDEX];

  String? get drinkWaterReminderSubtitle =>
      reminderSubtitles[REMINDER_DRINK_WATER_INDEX];

  String? get sleepReminderSubtitle => reminderSubtitles[REMINDER_SLEEP_INDEX];

  String? get bodyTemperatureReminderSubtitle =>
      reminderSubtitles[REMINDER_BODY_TEMPRATURE_INDEX];

  // Load initial state of main reminder switch
  Future<void> loadMainReminderState() async {
    bool anyReminderEnabled = false;
    for (int index in _reminderIndices) {
      ReminderModel? reminder = await getReminderItem(index: index);
      if (reminder != null && reminder.isReminderOn == true) {
        anyReminderEnabled = true;
        break;
      }
    }
    setState(() {
      isRemindersEnabled = anyReminderEnabled;
    });
  }

  // Toggle all reminders
  Future<void> _toggleAllReminders(bool value) async {
    for (int index in _reminderIndices) {
      ReminderModel? reminder = await getReminderItem(index: index);
      if (value) {
        if (reminder != null &&
            reminder.hours != null &&
            reminder.minutes != null) {
          await updateReminder(
            index: index,
            weekDay: reminder.weekDay,
            hours: reminder.hours,
            minutes: reminder.minutes,
            year: reminder.year,
            month: reminder.month,
            day: reminder.day,
            isOn: reminder.isReminderOn ?? false,
          );
          await scheduleReminders(index: index);
        }
      } else {
        // Disable all reminders
        await cancelReminder(index: index);
        await clearReminder(index);
        await updateReminder(
          index: index,
          weekDay: reminder?.weekDay,
          hours: reminder?.hours,
          minutes: reminder?.minutes,
          year: reminder?.year,
          month: reminder?.month,
          day: reminder?.day,
          isOn: false,
        );
      }
    }
  }

  getQuestionData() async {
    try {
      var userType = getStringAsync(USER_TYPE);
      var goalType;
      if (GOAL.runtimeType is int) {
        goalType = getIntAsync(GOAL);
      } else {
        goalType = getIntAsync(GOAL);
      }
      if (userType == ANONYMOUS) {
        Map<String, dynamic> map = getJSONAsync(KEY_QUESTION_DATA);
        questionsModelData = QuestionsModel.fromJson(map);
      } else {
        questionsModelData = QuestionsModel(
          step1: step1,
          step2: step2,
          step3: step3,
          step4: step4,
          step5: step5,
          step6: step6,
          step7: step7,
        );
      }

      if (goalType is String) {
        questionsModelData!.step2.selectedOption = int.tryParse(goalType) ?? 0;
      } else if (goalType is int) {
        questionsModelData!.step2.selectedOption = goalType;
      } else {
        throw Exception("Unsupported goalType: $goalType");
      }

      await getUserLastPeriodDate();
    } catch (e) {}
  }

  Future deleteAccount(BuildContext context) async {
    appStore.setLoading(true);
    await deleteUserAccountApi().then((value) async {
      if (value.status == true) {
        await TerminateRestart.instance.restartApp(
          options: const TerminateRestartOptions(
            terminate: true,
          ),
        );
      }
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  Widget settingOption(String mTitle, Function onTapCall, IconData icon) {
    return SettingItemWidget(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      title: mTitle,
      onTap: () {
        onTapCall.call();
      },
      leading: Icon(icon),
      trailing: Icon(Icons.keyboard_arrow_right_sharp, size: 20),
      paddingAfterLeading: 8,
      paddingBeforeTrailing: 8,
    );
  }

  Widget mSettingOption(String mTitle, String mImg, Function onTapCall,
      {String? subtitle}) {
    return SettingItemWidget(
      onTap: () {
        onTapCall.call();
      },
      title: mTitle,
      subTitle: subtitle,
      subTitleTextStyle: GoogleFonts.roboto(fontSize: 12, color: Colors.red),
      leading: Image.asset(mImg, height: 20, width: 20, color: primaryColor),
      trailing: Icon(Icons.arrow_forward_ios_sharp, color: grayColor, size: 18),
      paddingAfterLeading: 10,
      paddingBeforeTrailing: 10,
    );
  }

  void showStep3UI() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: context.width() * 0.9,
          height: context.height() * 0.65,
          child: StatefulBuilder(
            builder: (context, stateSetter) {
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: context.width() * 0.75,
                        child: Text(
                          questionsModelData!.step3.title.toString(),
                          style: boldTextStyle(size: textFontSize_20),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ).paddingAll(10),
                      ),
                      8.height,
                      Text(
                        questionsModelData!.step3.desc.toString(),
                        style: primaryTextStyle(),
                      ).paddingAll(10),
                      30.height,
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(language.Close,
                              style: boldTextStyle(color: primaryColor)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showGoalSwitchConfirmation(BuildContext context, int newIndex) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => CustomDialog(
        iconData: Icons.swap_horizontal_circle,
        iconColor: mainColorLight,
        title: language.confirmation,
        description: language.areYouSureYouWantToSwitchYourGoalType,
        buttons: [
          DialogButton(
            text: language.no,
            color: Colors.black,
            isTransparent: true,
            onPressed: () {
              pop();
            },
          ),
          DialogButton(
            text: language.yes,
            color: mainColor,
            onPressed: () {
              Navigator.pop(context);
              _handleGoalSwitch(newIndex);
            },
          ),
        ],
      ),
    );
  }

  Future<void> getUserLastPeriodDate() async {
    userLastPeriodDate = await instance.getPreviousPeriodDay();
  }

  void _handleGoalSwitch(int newIndex) async {
    String title = "";
    if (userStore.goalIndex == 1) {
      title = "track_cycle";
    } else {
      title = "track_pregnancy";
    }
    logAnalyticsEvent(category: "goalType", action: "switched_to_${title}");
    if (userStore.goalIndex == 1) {
      questionsModelData!.step2.selectedOption = newIndex;
      currentGoalIndex = newIndex;
      PleaseWaitScreen(currentGoalType: currentGoalIndex)
          .launch(context, isNewTask: true);
    } else {
      if (questionsModelData!.step3.selectedLastPeriodDate != null) {
        questionsModelData!.step2.selectedOption = newIndex;
        currentGoalIndex = newIndex;
        PleaseWaitScreen(currentGoalType: currentGoalIndex)
            .launch(context, isNewTask: true);
      } else {
        showStep3UI();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: goalList.length,
      child: Observer(
        builder: (context) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: mainColorLight,
              statusBarIconBrightness: Brightness.dark,
            ),
            child: Scaffold(
              backgroundColor: bgColor,
              body: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 200,
                          color: mainColorLight,
                          child: Stack(
                            children: [
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: SafeArea(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          language.Account,
                                          style: boldTextStyle(
                                            color: Colors.black,
                                            size: 18,
                                            weight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 75,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Stack(
                                              alignment: Alignment.bottomRight,
                                              children: [
                                                Container(
                                                  width: 60,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: ClipOval(
                                                    child: cachedImage(
                                                      userStore
                                                          .user?.profileImage,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blueGrey,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.edit,
                                                    size: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            16.width,
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${userStore.user?.firstName ?? ''} ${userStore.user?.lastName ?? ''}"
                                                        .trim(),
                                                    style: boldTextStyle(
                                                      color: mainColorText,
                                                      size: 18,
                                                      weight: FontWeight.w500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  4.height,
                                                  Text(
                                                    userStore.user?.email ??
                                                        'no-email@example.com',
                                                    style: primaryTextStyle(
                                                      color: mainColorBodyText,
                                                      size: 12,
                                                      weight: FontWeight.w400,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(kCurveHeight),
                                    topRight: Radius.circular(kCurveHeight),
                                  ),
                                  child: Container(
                                    height: kCurveHeight * 1,
                                    color: bgColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).onTap(() {
                          EditProfileScreen().launch(context);
                        }),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: bgColor,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              16.height,
                              Text(
                                language.myGoal,
                                style: boldTextStyle(
                                    size: textFontSize_18,
                                    isHeader: true,
                                    color: scaffoldDarkColor),
                                textAlign: TextAlign.start,
                              ),
                              8.height,
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.all(4),
                                child: Row(
                                  children: () {
                                    final filteredGoals = userLastPeriodDate
                                            .isEmptyOrNull
                                        ? [goalList[0], ...goalList.sublist(2)]
                                        : goalList;

                                    return List.generate(filteredGoals.length,
                                        (i) {
                                      final isSelected = questionsModelData!
                                              .step2.selectedOption ==
                                          i;
                                      return Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            if (userLastPeriodDate
                                                .isEmptyOrNull) {
                                              return;
                                            }

                                            final isConnected =
                                                await isNetworkAvailable();
                                            if (!isConnected) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(language
                                                        .internetRequiredForThisAction),
                                                    backgroundColor:
                                                        ColorUtils.colorPrimary,
                                                  ),
                                                );
                                              }
                                              return null;
                                            } else {
                                              _showGoalSwitchConfirmation(
                                                  context, i);
                                            }
                                          },
                                          child: AnimatedContainer(
                                            duration:
                                                Duration(milliseconds: 200),
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 2),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? ColorUtils.colorPrimary
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12),
                                            child: Text(
                                              filteredGoals[i].validate(),
                                              textAlign: TextAlign.center,
                                              style: boldTextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black,
                                                size: textFontSize_14,
                                                weight: FontWeight.normal,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                                  }(),
                                ),
                              ),
                              18.height,
                              Column(
                                children: [
                                  mSettingOption(
                                      language.graphsAndReport, ic_chart, () {
                                    GraphsAndReportScreen(
                                            shouldShowBackButton: true)
                                        .launch(context);
                                  }),
                                  10.height,
                                  mSettingOption(
                                      language.periodPrediction, ic_graph, () {
                                    PeriodPredictionsScreen().launch(context);
                                  }),
                                  10.height,
                                  Column(
                                    children: [
                                      mSettingOption(
                                          language.addDummyData,
                                          ic_folder,
                                          appStore.isLoading
                                              ? () {}
                                              : () {
                                                  appStore.setLoading(true);
                                                  toast(language
                                                      .pleaseWaitWhileDataIsBeenAdded);
                                                  instance.addDummyData(
                                                      onSuccess: () {
                                                    toast(language
                                                        .dataHasBeenAdded);
                                                    appStore.setLoading(false);
                                                    DashboardScreen(
                                                            currentIndex: 0)
                                                        .launch(context,
                                                            isNewTask: true);
                                                  }, onError: () {
                                                    toast(
                                                        "Something went wrong");
                                                  });
                                                }),
                                      10.height,
                                    ],
                                  ).visible(appStore.dummyDataStatus == true)
                                ],
                              ).visible(userStore.goalIndex == 0),
                              mSettingOption(language.secretChat, ic_crown, () {
                                SecretChatScreen().launch(context);
                              }),
                              10.height,
                              Column(
                                children: [
                                  mSettingOption(
                                      language.askAnExpert, ic_expert, () {
                                    AskExpertListScreen().launch(context);
                                  }),
                                  10.height,
                                ],
                              ).visible(appStore.askExpertStatus == true),
                              mSettingOption(language.bookmark, ic_bookmark2,
                                  () {
                                BookmarkScreen().launch(context,
                                    shouldCheckForNetworkConnection: true);
                              }),
                              10.height,
                              mSettingOption(
                                  language.calculatorTools, ic_calculator, () {
                                CalculatorScreen(isFromDoctor: false).launch(
                                    context,
                                    shouldCheckForNetworkConnection: true);
                              }),
                              10.height,
                              // Reminders Container
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SettingItemWidget(
                                      title: language.reminders,
                                      leading: Image.asset(ic_alarm2),
                                      trailing: Transform.scale(
                                        scale: 0.8,
                                        child: CupertinoSwitch(
                                          value: isRemindersEnabled,
                                          activeTrackColor:
                                              ColorUtils.colorPrimary,
                                          onChanged: (value) async {
                                            setState(() {
                                              isRemindersEnabled = value;
                                            });
                                            await _toggleAllReminders(value);
                                          },
                                        ),
                                      ),
                                      paddingAfterLeading: 10,
                                      paddingBeforeTrailing: 10,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    AnimatedOpacity(
                                      duration: Duration(milliseconds: 800),
                                      opacity: isRemindersEnabled ? 1.0 : 0.0,
                                      child: Column(
                                        children: [
                                          Divider(
                                                  color: context.dividerColor,
                                                  height: 8)
                                              .visible(isRemindersEnabled),
                                          mSettingOption(
                                            language.cycleReminders,
                                            ic_cycle_reminder,
                                            () async {
                                              await NavigationUtils
                                                  .navigateWithPostPopAction(
                                                context: context,
                                                screen: CycleReminderScreen(),
                                                showRewardedAd: false,
                                                postPopAction: () async {
                                                  await _updateCycleReminderSubtitles();
                                                },
                                              );
                                            },
                                            subtitle:
                                                _buildCycleReminderSubtitles(),
                                          ).visible(userStore.goalIndex == 0),
                                          Divider(
                                                  color: context.dividerColor,
                                                  height: 8)
                                              .visible(
                                                  userStore.goalIndex == 0),
                                          mSettingOption(
                                              language.medicineReminders,
                                              subtitle:
                                                  medicineReminderSubtitle,
                                              ic_medicine_reminder, () {
                                            navigateToRemindersScreen(
                                                index: REMINDER_MEDICINE_INDEX);
                                          }),
                                          Divider(
                                              color: context.dividerColor,
                                              height: 8),
                                          mSettingOption(
                                              language.meditationReminders,
                                              subtitle:
                                                  meditationReminderSubtitle,
                                              ic_meditation_reminder, () {
                                            navigateToRemindersScreen(
                                                index:
                                                    REMINDER_MEDITATION_INDEX);
                                          }),
                                          Divider(
                                              color: context.dividerColor,
                                              height: 8),
                                          mSettingOption(
                                              language.dailyLoggingReminders,
                                              subtitle:
                                                  dailyLoggingReminderSubtitle,
                                              ic_logging_reminder, () {
                                            navigateToRemindersScreen(
                                                index:
                                                    REMINDER_DAILY_LOGGING_INDEX);
                                          }),
                                          Divider(
                                              color: context.dividerColor,
                                              height: 8),
                                          mSettingOption(
                                              language.waterDrinkingReminders,
                                              subtitle:
                                                  drinkWaterReminderSubtitle,
                                              ic_water_reminder, () {
                                            navigateToRemindersScreen(
                                                index:
                                                    REMINDER_DRINK_WATER_INDEX);
                                          }),
                                          Divider(
                                              color: context.dividerColor,
                                              height: 8),
                                          mSettingOption(
                                              language.weightLoggingReminders,
                                              subtitle:
                                                  logWeightReminderSubtitle,
                                              ic_weight_reminder, () {
                                            navigateToRemindersScreen(
                                                index:
                                                    REMINDER_LOG_WEIGHT_INDEX);
                                          }),
                                          Divider(
                                              color: context.dividerColor,
                                              height: 8),
                                          mSettingOption(
                                              language.sleepReminders,
                                              subtitle: sleepReminderSubtitle,
                                              ic_sleep_reminder, () {
                                            navigateToRemindersScreen(
                                                index: REMINDER_SLEEP_INDEX);
                                          }),
                                          Divider(
                                              color: context.dividerColor,
                                              height: 8),
                                          mSettingOption(
                                              language.bodyTemperatureReminders,
                                              subtitle:
                                                  bodyTemperatureReminderSubtitle,
                                              ic_temp_reminder, () {
                                            navigateToRemindersScreen(
                                                index:
                                                    REMINDER_BODY_TEMPRATURE_INDEX);
                                          }),
                                          Divider(
                                              color: context.dividerColor,
                                              height: 8),
                                          mSettingOption(
                                              language.trackingReminders,
                                              subtitle:
                                                  trackingReminderSubtitle,
                                              ic_tracing_reminder, () {
                                            navigateToRemindersScreen(
                                                index: REMINDER_TRACKING_INDEX);
                                          }),
                                          Divider(
                                              color: context.dividerColor,
                                              height: 8),
                                          // mSettingOption(
                                          //     language.secretReminders,
                                          //     ic_secret_reminder, () {
                                          //   SecretReminderScreen()
                                          //       .launch(context);
                                          // })
                                        ],
                                      ),
                                    ).visible(isRemindersEnabled),
                                  ],
                                ),
                              ),
                              10.height,
                              mSettingOption(language.settings, ic_settings2,
                                  () {
                                InterSettingsScreen().launch(context);
                              }),
                              10.height,
                              mSettingOption(language.faq, ic_question_mark,
                                  () {
                                FAQScreen().launch(context,
                                    shouldCheckForNetworkConnection: true);
                              }).visible(
                                  getStringAsync(USER_TYPE) == ANONYMOUS ||
                                      getStringAsync(USER_TYPE) == APP_USER),
                              10.height,
                              mSettingOption(language.about, ic_info, () {
                                AboutScreen().launch(context,
                                    shouldCheckForNetworkConnection: true);
                              }),
                              10.height,
                              mSettingOption(language.logout, ic_logout2, () {
                                showConfirmDialogCustom(
                                  image: ic_logout2,
                                  bgColor: context.cardColor,
                                  iconColor: ColorUtils.colorPrimary,
                                  context,
                                  negativeBg: context.cardColor,
                                  primaryColor: ColorUtils.colorPrimary,
                                  title: language.areYouSure,
                                  positiveText: language.logout,
                                  negativeText: language.cancel,
                                  height: 100,
                                  onAccept: (c) {
                                    logout(context: context);
                                  },
                                );
                              }),
                              10.height,
                              FutureBuilder<PackageInfo>(
                                future: PackageInfo.fromPlatform(),
                                builder: (_, snap) {
                                  return Text(
                                    snap.data != null
                                        ? 'v ${snap.data!.version.validate()}.${snap.data!.buildNumber.validate()}'
                                        : "",
                                    style: secondaryTextStyle(),
                                    textAlign: TextAlign.center,
                                  ).center();
                                },
                              ),
                              40.height,
                            ],
                          ),
                        ),
                        Center(
                          child: Loader(),
                        ).visible(appStore.isLoading),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
