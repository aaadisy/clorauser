// import 'package:clora_user/utils/app_constants.dart';
// import 'package:timezone/browser.dart';
// import 'package:timezone/browser.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import '../../service/reminders_service.dart';
//
// class ReminderModel {
//   int? index;
//   String? title;
//   String? subTitle;
//   bool? isReminderOn;
//   int? reminderType;
//   int? hours;
//   int? minutes;
//   tz.TZDateTime? scheduledDateTime;
//   ReminderModel({required this.index, required this.title, this.subTitle = "", this.isReminderOn = false, this.reminderType = REMINDER_TYPE_DAILY, this.hours, this.minutes, this.scheduledDateTime});
//   factory ReminderModel.fromJson(Map<String, dynamic> json) {
//     return ReminderModel(
//       index: json['index'],
//       title: json['title'],
//       subTitle: json['subTitle'],
//       isReminderOn: json['isReminderOn'],
//       reminderType: json['reminderType'],
//       hours: json['hours'],
//       minutes: json['minutes'],
//       scheduledDateTime: json['scheduledDateTime'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['index'] = this.index;
//     data['title'] = this.title;
//     data['subTitle'] = this.subTitle;
//     data['isReminderOn'] = this.isReminderOn;
//     data['reminderType'] = this.reminderType;
//     data['hours'] = this.hours;
//     data['minutes'] = this.minutes;
//     data['scheduledDateTime'] = this.scheduledDateTime;
//     return data;
//   }
// }
