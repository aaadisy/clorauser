import '../service/reminder_service.dart';

class ReminderModel {
  int? index;
  String? title;
  String? subTitle;
  bool? isReminderOn;
  int? reminderType;
  int? hours;
  int? minutes;
  int? month;
  int? year;
  int? day;
  int? weekDay;

  ReminderModel(
      {required this.index,
      required this.title,
      this.subTitle = "",
      this.isReminderOn = false,
      this.reminderType = REMINDER_TYPE_DAILY,
      this.hours,
      this.minutes,
      this.weekDay,
      this.day,
      this.month,
      this.year});

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      index: json['index'],
      title: json['title'],
      subTitle: json['subTitle'],
      isReminderOn: json['isReminderOn'],
      reminderType: json['reminderType'],
      hours: json['hours'],
      month: json['month'],
      year: json['year'],
      minutes: json['minutes'],
      weekDay: json['weekDay'],
      day: json['day'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['index'] = this.index;
    data['title'] = this.title;
    data['subTitle'] = this.subTitle;
    data['isReminderOn'] = this.isReminderOn;
    data['reminderType'] = this.reminderType;
    data['hours'] = this.hours;
    data['month'] = this.month;
    data['year'] = this.year;
    data['minutes'] = this.minutes;
    data['weekDay'] = this.weekDay;
    data['day'] = this.day;
    return data;
  }
}
