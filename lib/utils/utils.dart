import 'package:intl/intl.dart';

export 'app_common.dart';
export 'app_config.dart';
export 'app_constants.dart';
export 'app_images.dart';

String convertUtcToLocal(String utcTimeString) {
  final DateFormat inputFormatter = DateFormat('MMMM dd, yyyy - hh:mm a');

  DateTime utcTime = inputFormatter.parse(utcTimeString, true).toUtc();

  DateTime localTime = utcTime.toLocal();

  final DateFormat outputFormatter = DateFormat('MMMM dd, yyyy - hh:mm a');

  String formattedLocalTime = outputFormatter.format(localTime);

  return formattedLocalTime;
}

String convertUtcToLocal2(String utcTimeString) {
  // First parse the input string which is in format "yyyy-MM-dd HH:mm:ss"
  final DateFormat inputFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  DateTime utcTime = inputFormatter.parse(utcTimeString, true).toUtc();

  // Convert to local time
  DateTime localTime = utcTime.toLocal();

  // Format for output
  final DateFormat outputFormatter = DateFormat('MMMM dd, yyyy - hh:mm a');
  String formattedLocalTime = outputFormatter.format(localTime);

  return formattedLocalTime;
}
