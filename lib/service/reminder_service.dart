import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:clora_user/utils/app_common.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../model/reminder_model.dart';
import '../utils/app_constants.dart';

const REMINDER_MEDICINE_INDEX = 1;
const REMINDER_MEDITATION_INDEX = 2;
const REMINDER_DAILY_LOGGING_INDEX = 3;
const REMINDER_TRACKING_INDEX = 4;
const REMINDER_PERIOD_INDEX = 5;
const REMINDER_FERTILITY_INDEX = 6;
const REMINDER_OVULATION_INDEX = 7;
const REMINDER_SLEEP_INDEX = 8;
const REMINDER_DRINK_WATER_INDEX = 9;
const REMINDER_BODY_TEMPRATURE_INDEX = 10;
const REMINDER_LOG_WEIGHT_INDEX = 11;

const REMINDER_TYPE_DAILY = 1;
const REMINDER_TYPE_WEEKLY = 2;
const REMINDER_TYPE_MONTHLY = 3;

/// Helper function to get reminder title
Future<String> getReminderBody(ReminderModel reminder) async {
  String? savedMessage = await getReminderMessage(reminder.index!);
  if (savedMessage != null) {
    return savedMessage;
  }
  return "";
}

Future<String> getReminderTitleHeader(ReminderModel reminder) async {
  String? savedMessage = await getReminderTitle(reminder.index!);
  if (savedMessage != null) {
    return savedMessage;
  }
  return "";
}

//Helper function to schedule reminder for given index
Future<void> scheduleReminders({required int index}) async {
  List<ReminderModel> items =
      await getRemindersList(); // Wait for reminders to load

  // Find the reminder with the matching index
  ReminderModel? reminder = items.firstWhere(
    (item) => item.index == index,
    orElse: () => throw "no reminder found", // If not found, return null
  );

  // Cancel existing notification for this index before scheduling a new one
  await AwesomeNotifications().cancel(reminder.index!);

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: reminder.index!,
      channelKey: 'basic_channel',
      title: await getReminderTitleHeader(reminder),
      body: await getReminderBody(reminder),
      notificationLayout: NotificationLayout.Default,
    ),
    schedule: NotificationCalendar(
      hour: reminder.hours,
      minute: reminder.minutes,
      second: 0,
      month: reminder.month,
      year: reminder.year,
      day: reminder.day != null ? reminder.day : null,
      weekday: reminder.weekDay != null ? reminder.weekDay : null,
      repeats: true, // This makes it repeat automatically
    ),
  );
  printCurrentlyScheduledReminders();
}

// to check currently active reminders that will ring at given time
printCurrentlyScheduledReminders() async {
  List<NotificationModel> scheduledNotifications =
      await AwesomeNotifications().listScheduledNotifications();

  for (var notification in scheduledNotifications) {
    String? title = notification.content?.title;
    NotificationSchedule? schedule = notification.schedule;

    if (schedule is NotificationCalendar) {
      ('Line 86 Scheduled Notification: $title - Time: ${schedule.year}-${schedule.month}-${schedule.day} ${schedule.hour}:${schedule.minute}:${schedule.second}');
    } else {
      printEraAppLogs(
          'Line 88 Scheduled Notification: $title - No valid time found');
    }
  }
}

//return day name based on index
String getWeekdayName(int day) {
  return [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ][day];
}

// get list of reminders if not set intially will fetch all by default.
Future<List<ReminderModel>> getRemindersList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Check if reminders already exist
  if (prefs.containsKey(KEY_REMINDER_DATA)) {
    String? remindersJson = prefs.getString(KEY_REMINDER_DATA);
    List<dynamic> jsonData = jsonDecode(remindersJson!);
    return jsonData.map((e) => ReminderModel.fromJson(e)).toList();
  }

  // If no data exists, use default list
  List<ReminderModel> reminderList = [
    ReminderModel(
        index: REMINDER_MEDITATION_INDEX,
        title: language.meditationReminders,
        subTitle: language.meditationRemindersText,
        isReminderOn: false,
        reminderType: REMINDER_TYPE_DAILY,
        hours: 0,
        minutes: 0,
        weekDay: null,
        day: null),
    ReminderModel(
        index: REMINDER_MEDICINE_INDEX,
        title: language.medicineReminders,
        subTitle: language.meditationRemindersText,
        isReminderOn: false,
        reminderType: REMINDER_TYPE_DAILY,
        hours: 0,
        minutes: 0,
        weekDay: null,
        day: null),
    ReminderModel(
        index: REMINDER_DAILY_LOGGING_INDEX,
        title: language.dailyLoggingReminders,
        subTitle: language.dailyLoggingRemindersText,
        isReminderOn: false,
        reminderType: REMINDER_TYPE_DAILY,
        hours: 00,
        minutes: null,
        weekDay: null),
    ReminderModel(
        index: REMINDER_TRACKING_INDEX,
        title: language.trackingReminders,
        subTitle: language.trackingRemindersText,
        isReminderOn: false,
        reminderType: REMINDER_TYPE_WEEKLY,
        hours: 00,
        minutes: 00,
        weekDay: null,
        day: null),
    new ReminderModel(
        index: REMINDER_PERIOD_INDEX,
        title: language.periodReminders,
        subTitle: language.periodRemindersText,
        isReminderOn: false,
        reminderType: REMINDER_TYPE_MONTHLY,
        hours: 00,
        minutes: 00,
        weekDay: null,
        day: null),
    ReminderModel(
        index: REMINDER_FERTILITY_INDEX,
        title: language.fertilityReminder,
        subTitle: language.fertilityReminderText,
        isReminderOn: false,
        reminderType: REMINDER_TYPE_MONTHLY,
        hours: 00,
        minutes: 00,
        weekDay: null,
        day: null),
    ReminderModel(
        index: REMINDER_OVULATION_INDEX,
        title: language.ovulationReminder,
        subTitle: language.ovulationReminderText,
        isReminderOn: false,
        reminderType: REMINDER_TYPE_MONTHLY,
        hours: 00,
        minutes: 00,
        weekDay: null,
        day: null),
    //todo add keys
    ReminderModel(
        index: REMINDER_SLEEP_INDEX,
        title: "Sleep Reminders",
        subTitle: "Track your sleep reminders",
        isReminderOn: false,
        reminderType: REMINDER_TYPE_DAILY,
        hours: 0,
        minutes: 0,
        weekDay: null,
        day: null),
    ReminderModel(
        index: REMINDER_DRINK_WATER_INDEX,
        title: "Drink water Reminders",
        subTitle: "Track your water intake",
        isReminderOn: false,
        reminderType: REMINDER_TYPE_DAILY,
        hours: 0,
        minutes: 0,
        weekDay: null,
        day: null),
    ReminderModel(
        index: REMINDER_LOG_WEIGHT_INDEX,
        title: "weight Reminders",
        subTitle: "Track your weight",
        isReminderOn: false,
        reminderType: REMINDER_TYPE_DAILY,
        hours: 0,
        minutes: 0,
        weekDay: null,
        day: null),
    ReminderModel(
        index: REMINDER_BODY_TEMPRATURE_INDEX,
        title: "Body temperature Reminders",
        subTitle: "Track your sleep reminders",
        isReminderOn: false,
        reminderType: REMINDER_TYPE_DAILY,
        hours: 0,
        minutes: 0,
        weekDay: null,
        day: null),
  ];

  // Save default reminders to SharedPreferences
  await prefs.setString(KEY_REMINDER_DATA,
      jsonEncode(reminderList.map((e) => e.toJson()).toList()));

  return reminderList;
}

// to update reminder date time and other data
Future<void> updateReminder({
  required int index,
  required int? day,
  required int? weekDay,
  required int? hours,
  required int? month,
  required int? year,
  required int? minutes,
  required bool isOn,
}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? remindersJson = prefs.getString(KEY_REMINDER_DATA);

  // Initialize reminders list
  List<ReminderModel> reminders = [];

  // If remindersJson is not null, decode it into a list of ReminderModel objects
  List<dynamic> jsonData = jsonDecode(remindersJson!);
  reminders = jsonData.map((e) => ReminderModel.fromJson(e)).toList();

  // Find the reminder with the specified index
  ReminderModel? foundReminder;
  for (var reminder in reminders) {
    if (reminder.index == index) {
      foundReminder = reminder;
      break;
    }
  }

  // If the reminder does not exist, create a new one
  if (foundReminder == null) {
    foundReminder = ReminderModel(
      index: index,
      day: day,
      weekDay: weekDay,
      hours: hours,
      minutes: minutes,
      month: month,
      year: year,
      isReminderOn: isOn,
      title: '',
    );
    reminders.add(foundReminder);
  } else {
    // If the reminder exists, update its properties
    foundReminder.day = day;
    foundReminder.weekDay = weekDay;
    foundReminder.hours = hours;
    foundReminder.minutes = minutes;
    foundReminder.month = month;
    foundReminder.year = year;
    foundReminder.isReminderOn = isOn;
  }

  // Save the updated list back to SharedPreferences
  await prefs.setString(
    KEY_REMINDER_DATA,
    jsonEncode(reminders.map((e) => e.toJson()).toList()),
  );
}

//get model object of particualr reminder for given index
Future<ReminderModel?> getReminderItem({required int? index}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? remindersJson = prefs.getString(KEY_REMINDER_DATA);

  List<dynamic> jsonData = jsonDecode(remindersJson!);
  List<ReminderModel> reminders =
      jsonData.map((e) => ReminderModel.fromJson(e)).toList();

  ReminderModel? foundReminder;

  for (var reminder in reminders) {
    if (reminder.index == index) {
      foundReminder = reminder; // Store the found reminder
      break; // Stop looping once found
    }
  }

  return foundReminder; // Return the found reminder or null if not found
}

//cancel awasome notification and update reminders to null as default value
Future<void> cancelReminder({required int index}) async {
  await AwesomeNotifications().cancel(index);
  //reset reminders to default null
  updateReminder(
      index: index,
      day: null,
      weekDay: null,
      hours: null,
      month: null,
      year: null,
      minutes: null,
      isOn: false);
}

//called from background fetch to reset reminders if set at given time but doesnt ring.
void rescheduleRemindersIfMissed() async {
//  Get list of currently scheduled notifications
  List<NotificationModel> scheduledNotifications =
      await AwesomeNotifications().listScheduledNotifications();

//  Extract IDs of already scheduled reminders
  Set<int> scheduledIds = scheduledNotifications
      .map((notification) => notification.content?.id)
      .whereType<int>()
      .toSet();

//  Fetch reminders list
  List<ReminderModel> reminderList = await getRemindersList();

  for (var reminder in reminderList) {
    if (!reminder.isReminderOn!) continue; // Skip if reminder is off

    int reminderId = reminder.index!; // Use index as unique ID

//  Check if this reminder is already scheduled
    if (scheduledIds.contains(reminderId)) {
      continue;
    }
//if not schedule then schedule it with same as normal process
    scheduleReminders(index: reminder.index!);
  }
}

//hrs & minutes to display in 2 digit format
String formatReminderTime(int? hours, int? minutes) {
  // Ensure hours and minutes are not null, otherwise default to 0
  hours ??= 0;
  minutes ??= 0;

  // Format hours and minutes to always have two digits
  String formattedHours = hours < 10 ? '0$hours' : '$hours';
  String formattedMinutes = minutes < 10 ? '0$minutes' : '$minutes';

  return '$formattedHours:$formattedMinutes';
}

//on user account logout or account deletion reset all pref value of remidners to null && cancel awasome notification
resetAllReminders() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? remindersJson = prefs.getString(KEY_REMINDER_DATA);

  List<dynamic> jsonData = jsonDecode(remindersJson!);
  List<ReminderModel> reminderList =
      jsonData.map((e) => ReminderModel.fromJson(e)).toList();
  for (var reminder in reminderList) {
    cancelReminder(index: reminder.index!);
    //reset value to null if its not from goal type if its from goal type ==1 only cancel reminder no need to clear data

    reminder.isReminderOn = false;
    reminder.reminderType = null;
    reminder.hours = null;
    reminder.minutes = null;
    reminder.weekDay = null;
    reminder.day = null;
    clearReminder(reminder.index!);
    //  Save updated list back to SharedPreferences
    String updatedJson =
        jsonEncode(reminderList.map((e) => e.toJson()).toList());
    await prefs.setString(KEY_REMINDER_DATA, updatedJson);
  }
}

//update reminder when date changes
updateRemindersForDateChange() async {
  updatePeriodReminderDate();
  updateOvualtionDateRemidner();
}

updateOvualtionDateRemidner() async {
  String predictedOvulationDate = await instance.getNextOvulationDate();
  DateTime nextOvulation = DateTime.parse(predictedOvulationDate);
  //ovulation reminder
  ReminderModel? ovulationReminder =
      await getReminderItem(index: REMINDER_OVULATION_INDEX);
  if (ovulationReminder != null) {
    if (ovulationReminder.hours != null && ovulationReminder.minutes != null) {
      int hrs = ovulationReminder.hours!;
      int min = ovulationReminder.minutes!;
      DateTime givenDate = DateTime(
          nextOvulation.year, nextOvulation.month, nextOvulation.day, hrs, min);
      if (isDatePassed(givenDate)) {
        if (ovulationReminder.isReminderOn != null &&
            ovulationReminder.isReminderOn!) {
          toast("Sorry this date is passed! reminder is skipped");
          cancelReminder(index: REMINDER_OVULATION_INDEX);
        } else {}
      } else {
        if (ovulationReminder.isReminderOn != null &&
            ovulationReminder.isReminderOn!) {
          updateReminder(
            index: REMINDER_OVULATION_INDEX,
            weekDay: null,
            month: nextOvulation.month,
            year: nextOvulation.year,
            hours: hrs,
            minutes: min,
            day: nextOvulation.day,
            isOn: true,
          ).whenComplete(() {
            scheduleReminders(index: REMINDER_OVULATION_INDEX);
          });
        }
      }
    }
  }
}

updatePeriodReminderDate() async {
  String predictedPeriodDate = await instance.getNextPredictedPeriodDate();
  DateTime nextPeriodDate = DateTime.parse(predictedPeriodDate);
  //period index reset
  ReminderModel? reminderItem =
      await getReminderItem(index: REMINDER_PERIOD_INDEX);
  if (reminderItem != null) {
    if (reminderItem.hours != null && reminderItem.minutes != null) {
      int hrs = reminderItem.hours!;
      int min = reminderItem.minutes!;
      DateTime givenDate = DateTime(nextPeriodDate.year, nextPeriodDate.month,
          nextPeriodDate.day, hrs, min);
      if (isDatePassed(givenDate)) {
        if (reminderItem.isReminderOn != null && reminderItem.isReminderOn!) {
          toast("Sorry this date is passed! you can not set reminder for this");
          cancelReminder(index: REMINDER_PERIOD_INDEX);
        } else {}
      } else {
        if (reminderItem.isReminderOn != null && reminderItem.isReminderOn!) {
          updateReminder(
            index: REMINDER_PERIOD_INDEX,
            weekDay: null,
            month: nextPeriodDate.month,
            year: nextPeriodDate.year,
            hours: hrs,
            // Keeping the same hours
            minutes: min,
            // Keeping the same minutes
            day: nextPeriodDate.day,
            isOn: true,
          ).whenComplete(() {
            scheduleReminders(index: REMINDER_PERIOD_INDEX);
          });
        }
      }
    }
  }
}

bool isDatePassed(DateTime date) {
  DateTime now = DateTime.now().add(Duration(minutes: 5));
  return date.isBefore(now);
}

Future<void> setReminderMessage(int index, String message) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('reminder_msg_$index', message);
}

Future<void> setReminderTitle(int index, String title) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('reminder_msg_title_$index', title);
}

Future<String?> getReminderMessage(int index) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('reminder_msg_$index');
}

Future<String?> getReminderTitle(int index) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('reminder_msg_title_$index');
}

Future<void> clearReminder(int index) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('reminder_msg_$index');
}
