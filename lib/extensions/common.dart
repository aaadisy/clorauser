import 'dart:io';
import 'dart:math';
import 'package:clora_user/extensions/shared_pref.dart';
import 'package:clora_user/extensions/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:menstrual_cycle_widget/utils/enumeration.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/text_styles.dart';
import '../../extensions/widgets.dart';
import '../main.dart';
import '../screens/user/app_update_dialog.dart';
import '../utils/app_constants.dart';
import '../utils/navigation_utils.dart';
import 'confirmation_dialog.dart';
import 'constants.dart';
import 'decorations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Make any variable nullable
T? makeNullable<T>(T? value) => value;

/// Enum for page route
enum PageRouteAnimation { Fade, Scale, Rotate, Slide, SlideBottomTop }

/// has match return bool for pattern matching
bool hasMatch(String? s, String p) {
  return (s == null) ? false : RegExp(p).hasMatch(s);
}

/// Returns the full language name for a given ISO 639-1 language code.
///
/// [languageCode] must be a 2-letter code (case-insensitive).
/// Returns "Unknown" for unsupported codes.
String getLanguageName(String languageCode) {
  // Validation
  if (languageCode.length != 2) {
    throw ArgumentError('Language code must be 2 characters');
  }

  // Normalize to lowercase
  final code = languageCode.toLowerCase();

  // Complete ISO 639-1 language map
  const languageMap = {
    'aa': 'Afar',
    'ab': 'Abkhazian',
    'ae': 'Avestan',
    'af': 'Afrikaans',
    'ak': 'Akan',
    'am': 'Amharic',
    'an': 'Aragonese',
    'ar': 'Arabic',
    'as': 'Assamese',
    'av': 'Avaric',
    'ay': 'Aymara',
    'az': 'Azerbaijani',
    'ba': 'Bashkir',
    'be': 'Belarusian',
    'bg': 'Bulgarian',
    'bh': 'Bihari',
    'bi': 'Bislama',
    'bm': 'Bambara',
    'bn': 'Bengali',
    'bo': 'Tibetan',
    'br': 'Breton',
    'bs': 'Bosnian',
    'ca': 'Catalan',
    'ce': 'Chechen',
    'ch': 'Chamorro',
    'co': 'Corsican',
    'cr': 'Cree',
    'cs': 'Czech',
    'cu': 'Church Slavic',
    'cv': 'Chuvash',
    'cy': 'Welsh',
    'da': 'Danish',
    'de': 'German',
    'dv': 'Divehi',
    'dz': 'Dzongkha',
    'ee': 'Ewe',
    'el': 'Greek',
    'en': 'English',
    'eo': 'Esperanto',
    'es': 'Spanish',
    'et': 'Estonian',
    'eu': 'Basque',
    'fa': 'Persian',
    'ff': 'Fulah',
    'fi': 'Finnish',
    'fj': 'Fijian',
    'fo': 'Faroese',
    'fr': 'French',
    'fy': 'Western Frisian',
    'ga': 'Irish',
    'gd': 'Scottish Gaelic',
    'gl': 'Galician',
    'gn': 'Guarani',
    'gu': 'Gujarati',
    'gv': 'Manx',
    'ha': 'Hausa',
    'he': 'Hebrew',
    'hi': 'Hindi',
    'ho': 'Hiri Motu',
    'hr': 'Croatian',
    'ht': 'Haitian Creole',
    'hu': 'Hungarian',
    'hy': 'Armenian',
    'hz': 'Herero',
    'ia': 'Interlingua',
    'id': 'Indonesian',
    'ie': 'Interlingue',
    'ig': 'Igbo',
    'ii': 'Sichuan Yi',
    'ik': 'Inupiaq',
    'io': 'Ido',
    'is': 'Icelandic',
    'it': 'Italian',
    'iu': 'Inuktitut',
    'ja': 'Japanese',
    'jv': 'Javanese',
    'ka': 'Georgian',
    'kg': 'Kongo',
    'ki': 'Kikuyu',
    'kj': 'Kuanyama',
    'kk': 'Kazakh',
    'kl': 'Kalaallisut',
    'km': 'Khmer',
    'kn': 'Kannada',
    'ko': 'Korean',
    'kr': 'Kanuri',
    'ks': 'Kashmiri',
    'ku': 'Kurdish',
    'kv': 'Komi',
    'kw': 'Cornish',
    'ky': 'Kirghiz',
    'la': 'Latin',
    'lb': 'Luxembourgish',
    'lg': 'Ganda',
    'li': 'Limburgan',
    'ln': 'Lingala',
    'lo': 'Lao',
    'lt': 'Lithuanian',
    'lu': 'Luba-Katanga',
    'lv': 'Latvian',
    'mg': 'Malagasy',
    'mh': 'Marshallese',
    'mi': 'Maori',
    'mk': 'Macedonian',
    'ml': 'Malayalam',
    'mn': 'Mongolian',
    'mr': 'Marathi',
    'ms': 'Malay',
    'mt': 'Maltese',
    'my': 'Burmese',
    'na': 'Nauru',
    'nb': 'Norwegian Bokmål',
    'nd': 'North Ndebele',
    'ne': 'Nepali',
    'ng': 'Ndonga',
    'nl': 'Dutch',
    'nn': 'Norwegian Nynorsk',
    'no': 'Norwegian',
    'nr': 'South Ndebele',
    'nv': 'Navajo',
    'ny': 'Chichewa',
    'oc': 'Occitan',
    'oj': 'Ojibwa',
    'om': 'Oromo',
    'or': 'Oriya',
    'os': 'Ossetian',
    'pa': 'Punjabi',
    'pi': 'Pali',
    'pl': 'Polish',
    'ps': 'Pashto',
    'pt': 'Portuguese',
    'qu': 'Quechua',
    'rm': 'Romansh',
    'rn': 'Rundi',
    'ro': 'Romanian',
    'ru': 'Russian',
    'rw': 'Kinyarwanda',
    'sa': 'Sanskrit',
    'sc': 'Sardinian',
    'sd': 'Sindhi',
    'se': 'Northern Sami',
    'sg': 'Sango',
    'si': 'Sinhala',
    'sk': 'Slovak',
    'sl': 'Slovenian',
    'sm': 'Samoan',
    'sn': 'Shona',
    'so': 'Somali',
    'sq': 'Albanian',
    'sr': 'Serbian',
    'ss': 'Swati',
    'st': 'Southern Sotho',
    'su': 'Sundanese',
    'sv': 'Swedish',
    'sw': 'Swahili',
    'ta': 'Tamil',
    'te': 'Telugu',
    'tg': 'Tajik',
    'th': 'Thai',
    'ti': 'Tigrinya',
    'tk': 'Turkmen',
    'tl': 'Tagalog',
    'tn': 'Tswana',
    'to': 'Tonga',
    'tr': 'Turkish',
    'ts': 'Tsonga',
    'tt': 'Tatar',
    'tw': 'Twi',
    'ty': 'Tahitian',
    'ug': 'Uighur',
    'uk': 'Ukrainian',
    'ur': 'Urdu',
    'uz': 'Uzbek',
    've': 'Venda',
    'vi': 'Vietnamese',
    'vo': 'Volapük',
    'wa': 'Walloon',
    'wo': 'Wolof',
    'xh': 'Xhosa',
    'yi': 'Yiddish',
    'yo': 'Yoruba',
    'za': 'Zhuang',
    'zh': 'Chinese',
    'zu': 'Zulu',
  };

  return languageMap[code] ?? 'Unknown';
}

/// Show SnackBar
void snackBar(
  BuildContext context, {
  String title = '',
  Widget? content,
  SnackBarAction? snackBarAction,
  Function? onVisible,
  Color? textColor,
  Color? backgroundColor,
  EdgeInsets? margin,
  EdgeInsets? padding,
  Animation<double>? animation,
  double? width,
  ShapeBorder? shape,
  Duration? duration,
  SnackBarBehavior? behavior,
  double? elevation,
}) {
  if (title.isEmpty && content == null) {
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        action: snackBarAction,
        margin: margin,
        animation: animation,
        width: width,
        shape: shape,
        duration: duration ?? 4.seconds,
        behavior: margin != null ? SnackBarBehavior.floating : behavior,
        elevation: elevation,
        onVisible: onVisible?.call(),
        content: content ??
            Padding(
              padding: padding ?? EdgeInsets.symmetric(vertical: 4),
              child: Text(
                title,
                style: primaryTextStyle(color: textColor ?? Colors.white),
              ),
            ),
      ),
    );
  }
}

/// Get Package Name
Future<String> getPackageName() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.packageName;
}

/// Launch Playstore
Future<void> launchAppStore() async {
  final String? url = Platform.isAndroid
      ? androidLiveUrl
      : Platform.isIOS
          ? iOSLiveUrl
          : null;

  if (url == null || url.isEmpty) {
    throw 'No valid store URL available for this platform.';
  }

  final Uri storeUri = Uri.parse(url);

  if (await canLaunchUrl(storeUri)) {
    await launchUrl(storeUri);
  } else {
    throw 'Could not launch $storeUri';
  }
}

/// Share App
Future<void> shareApp(BuildContext context) async {
  // Generate the store URL based on the platform
  final String storeUrl = Theme.of(context).platform == TargetPlatform.iOS
      ? iOSLiveUrl!
      : androidLiveUrl!;

  // Share the app link
  final String shareText = 'Check out this awesome app!\n$storeUrl';

  await Share.share(shareText);
}

/// Check if app is uptdate
void checkIfAppIsUpdate(BuildContext context) {
  final currentBuildNumber = int.tryParse(getStringAsync(APP_VERSION)) ?? 0;

  late int latestVersion;
  late bool isForceUpdate;

  if (Platform.isAndroid) {
    latestVersion = CurrentAndroidVersion;
    isForceUpdate = isAndroidForceUpdate;
  } else if (Platform.isIOS) {
    latestVersion = CurrentIOSVersion;
    isForceUpdate = isIOSForceUpdate;
  } else {
    return; // Not a supported platform
  }

  if (currentBuildNumber < latestVersion) {
    if (isForceUpdate) {
      setValue(IS_UPDATE_POP_DISMISSED, false);
    }

    final isUpdatePopupDismissed = getBoolAsync(IS_UPDATE_POP_DISMISSED);
    if (!isUpdatePopupDismissed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showUpdateDialog(context);
      });
    }
  }
}

String formattedDateToDayFirst(String expectedDueDate) {
  DateTime myDate = DateFormat("dd-MM-yyyy").parse(expectedDueDate);
  String formattedDate = DateFormat("d MMM, yyyy").format(myDate);
  return formattedDate;
}

String formatDateTime(DateTime dateTime) {
  // Format the date without the day
  final dateFormat = DateFormat('MMM, yyyy h:mm a');
  final formattedDate = dateFormat.format(dateTime);

  // Get the day with ordinal suffix
  final day = dateTime.day;
  final ordinal = _getOrdinalSuffix(day);

  // Combine day with ordinal and formatted date
  return '${day}$ordinal $formattedDate';
}

String _getOrdinalSuffix(int day) {
  if (day >= 11 && day <= 13) {
    return 'th';
  }
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

/// Update App Dialog
void showUpdateDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async {
          bool shouldPop = onWillPopScopeInvoked();
          return shouldPop;
        },
        child: ShakingUpdateDialog(), // Your custom dialog widget
      );
    },
  );
}

/// OnWillPopScope for update app
bool onWillPopScopeInvoked() {
  final String buildStr = getStringAsync(APP_VERSION);
  try {
    final int currentBuild = int.parse(buildStr);
    if (Platform.isAndroid && isAndroidForceUpdate) {
      return currentBuild >= CurrentAndroidVersion;
    } else if (Platform.isIOS && isIOSForceUpdate) {
      return currentBuild >= CurrentIOSVersion;
    }
  } catch (e) {
    return true;
  }
  return true;
}

bool isCurrentPlatformForceUpdate() {
  if (Platform.isAndroid) {
    return isAndroidForceUpdate;
  } else if (Platform.isIOS) {
    return isIOSForceUpdate;
  }
  return false;
}

void updateMenstrualWidgetLanguage() {
  var language;
  if (selectedServerLanguageData != null) {
    if (selectedServerLanguageData!.languageCode == "en") {
      language = Languages.english;
    } else if (selectedServerLanguageData!.languageCode == "hi") {
      language = Languages.hindi;
    } else if (selectedServerLanguageData!.languageCode == "ar") {
      language = Languages.arabic;
    }
  }
  if(language!=null) {
    language = Languages.english;
    instance.updateLanguageConfiguration(defaultLanguage: language);
  }
}

/// Hide soft keyboard
void hideKeyboard(context) => FocusScope.of(context).requestFocus(FocusNode());

/// Returns a string from Clipboard
Future<String> paste() async {
  ClipboardData? data = await Clipboard.getData('text/plain');
  return data?.text?.toString() ?? "";
}

/// Returns a string from Clipboard
Future<dynamic> pasteObject() async {
  ClipboardData? data = await Clipboard.getData('text/plain');
  return data;
}

/// Enum for Link Provider
enum LinkProvider {
  PLAY_STORE,
  APPSTORE,
  FACEBOOK,
  INSTAGRAM,
  LINKEDIN,
  TWITTER,
  YOUTUBE,
  REDDIT,
  TELEGRAM,
  WHATSAPP,
  FB_MESSENGER,
  GOOGLE_DRIVE
}

/// Use getSocialMediaLink function to build social media links
String getSocialMediaLink(LinkProvider linkProvider, {String url = ''}) {
  switch (linkProvider) {
    case LinkProvider.PLAY_STORE:
      return "$playStoreBaseURL$url";
    case LinkProvider.APPSTORE:
      return "$appStoreBaseURL$url";
    case LinkProvider.FACEBOOK:
      return "$facebookBaseURL$url";
    case LinkProvider.INSTAGRAM:
      return "$instagramBaseURL$url";
    case LinkProvider.LINKEDIN:
      return "$linkedinBaseURL$url";
    case LinkProvider.TWITTER:
      return "$twitterBaseURL$url";
    case LinkProvider.YOUTUBE:
      return "$youtubeBaseURL$url";
    case LinkProvider.REDDIT:
      return "$redditBaseURL$url";
    case LinkProvider.TELEGRAM:
      return "$telegramBaseURL$url";
    case LinkProvider.FB_MESSENGER:
      return "$facebookMessengerURL$url";
    case LinkProvider.WHATSAPP:
      return "$whatsappURL$url";
    case LinkProvider.GOOGLE_DRIVE:
      return "$googleDriveURL$url";
  }
}

const double degrees2Radians = pi / 180.0;

double radians(double degrees) => degrees * degrees2Radians;

void afterBuildCreated(Function()? onCreated) {
  makeNullable(SchedulerBinding.instance)!
      .addPostFrameCallback((_) => onCreated?.call());
}

Widget dialogAnimatedWrapperWidget({
  required Animation<double> animation,
  required Widget child,
  required DialogAnimation dialogAnimation,
  required Curve curve,
}) {
  switch (dialogAnimation) {
    case DialogAnimation.ROTATE:
      return Transform.rotate(
        angle: radians(animation.value * 360),
        child: Opacity(
          opacity: animation.value,
          child: FadeTransition(opacity: animation, child: child),
        ),
      );

    case DialogAnimation.SLIDE_TOP_BOTTOM:
      final curvedValue = curve.transform(animation.value) - 1.0;

      return Transform(
        transform: Matrix4.translationValues(0.0, curvedValue * 300, 0.0),
        child: Opacity(
          opacity: animation.value,
          child: FadeTransition(opacity: animation, child: child),
        ),
      );

    case DialogAnimation.SCALE:
      return Transform.scale(
        scale: animation.value,
        child: FadeTransition(opacity: animation, child: child),
      );

    case DialogAnimation.SLIDE_BOTTOM_TOP:
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset.zero)
            .chain(CurveTween(curve: curve))
            .animate(animation),
        child: Opacity(
          opacity: animation.value,
          child: FadeTransition(opacity: animation, child: child),
        ),
      );

    case DialogAnimation.SLIDE_LEFT_RIGHT:
      return SlideTransition(
        position: Tween(begin: Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: curve))
            .animate(animation),
        child: Opacity(
          opacity: animation.value,
          child: FadeTransition(opacity: animation, child: child),
        ),
      );

    case DialogAnimation.SLIDE_RIGHT_LEFT:
      return SlideTransition(
        position: Tween(begin: Offset(-1, 0), end: Offset.zero)
            .chain(CurveTween(curve: curve))
            .animate(animation),
        child: Opacity(
          opacity: animation.value,
          child: FadeTransition(opacity: animation, child: child),
        ),
      );

    case DialogAnimation.DEFAULT:
      return FadeTransition(opacity: animation, child: child);
  }
}

Route<T> buildPageRoute<T>(
    Widget child, PageRouteAnimation? pageRouteAnimation, Duration? duration,
    {RouteSettings? settings}) {
  if (pageRouteAnimation != null) {
    if (pageRouteAnimation == PageRouteAnimation.Fade) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child,
        transitionsBuilder: (c, anim, a2, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: duration ?? pageRouteTransitionDurationGlobal,
      );
    } else if (pageRouteAnimation == PageRouteAnimation.Rotate) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child,
        transitionsBuilder: (c, anim, a2, child) {
          return RotationTransition(
              child: child, turns: ReverseAnimation(anim));
        },
        transitionDuration: duration ?? pageRouteTransitionDurationGlobal,
      );
    } else if (pageRouteAnimation == PageRouteAnimation.Scale) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child,
        transitionsBuilder: (c, anim, a2, child) {
          return ScaleTransition(child: child, scale: anim);
        },
        transitionDuration: duration ?? pageRouteTransitionDurationGlobal,
      );
    } else if (pageRouteAnimation == PageRouteAnimation.Slide) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child,
        transitionsBuilder: (c, anim, a2, child) {
          return SlideTransition(
            child: child,
            position: Tween(
              begin: Offset(1.0, 0.0),
              end: Offset(0.0, 0.0),
            ).animate(anim),
          );
        },
        transitionDuration: duration ?? pageRouteTransitionDurationGlobal,
      );
    } else if (pageRouteAnimation == PageRouteAnimation.SlideBottomTop) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child,
        transitionsBuilder: (c, anim, a2, child) {
          return SlideTransition(
            child: child,
            position: Tween(
              begin: Offset(0.0, 1.0),
              end: Offset(0.0, 0.0),
            ).animate(anim),
          );
        },
        transitionDuration: duration ?? pageRouteTransitionDurationGlobal,
      );
    }
  }
  return MaterialPageRoute<T>(
    builder: (_) => child,
    settings: settings,
  );
}

EdgeInsets dynamicAppButtonPadding(BuildContext context) {
  if (context.isDesktop()) {
    return EdgeInsets.symmetric(vertical: 20, horizontal: 20);
  } else if (context.isTablet()) {
    return EdgeInsets.symmetric(vertical: 16, horizontal: 16);
  } else {
    return EdgeInsets.symmetric(vertical: 12, horizontal: 16);
  }
}

enum BottomSheetDialog { Dialog, BottomSheet }

Future<dynamic> showBottomSheetOrDialog({
  required BuildContext context,
  required Widget child,
  BottomSheetDialog bottomSheetDialog = BottomSheetDialog.Dialog,
}) {
  if (bottomSheetDialog == BottomSheetDialog.BottomSheet) {
    return showModalBottomSheet(context: context, builder: (_) => child);
  } else {
    return showInDialog(context, builder: (_) => child);
  }
}

/// mailto: function to open native email app
Uri mailTo({
  required List<String> to,
  String subject = '',
  String body = '',
  List<String> cc = const [],
  List<String> bcc = const [],
}) {
  String _subject = '';
  if (subject.isNotEmpty) _subject = '&subject=$subject';

  String _body = '';
  if (body.isNotEmpty) _body = '&body=$body';

  String _cc = '';
  if (cc.isNotEmpty) _cc = '&cc=${cc.join(',')}';

  String _bcc = '';
  if (bcc.isNotEmpty) _bcc = '&bcc=${bcc.join(',')}';

  return Uri(
    scheme: 'mailto',
    query: 'to=${to.join(',')}$_subject$_body$_cc$_bcc',
  );
}

Widget dotIndicator(list, i, {bool isPersonal = false}) {
  return SizedBox(
    height: 16,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        list.length,
        (ind) {
          return Container(
            height: 4,
            width: i == ind ? 30 : 12,
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: i == ind ? Colors.white : Colors.grey.withOpacity(0.5),
                borderRadius: radius(4)),
          );
        },
      ),
    ),
  );
}

/// returns true if network is available (Commented by John. Return true even if there is no internet connection)
// Future<bool> isNetworkAvailable() async {
//   var connectivityResult = await Connectivity().checkConnectivity();
//   return connectivityResult != ConnectivityResult.none;
// }

Future<bool> isNetworkAvailable() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult != ConnectivityResult.none) {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  return false;
}

get getContext => navigatorKey.currentState?.overlay?.context;

Future<T?> push<T>(
  Widget widget, {
  bool isNewTask = false,
  PageRouteAnimation? pageRouteAnimation,
  Duration? duration,
}) async {
  if (isNewTask) {
    return await Navigator.of(getContext).pushAndRemoveUntil(
      buildPageRoute(widget, pageRouteAnimation, duration),
      (route) => false,
    );
  } else {
    return await Navigator.of(getContext).push(
      buildPageRoute(widget, pageRouteAnimation, duration),
    );
  }
}

//// Helper function to disable floating action button if async operation is ongoing
void Function()? getAsyncOnPressedCallback({
  required bool isLoading,
  required Future<bool> Function() asyncAction,
  required BuildContext context,
}) {
  if (isLoading) {
    return null;
  }
  return () async {
    bool success = await asyncAction();
    if (success) {
      finish(context, true);
    }
  };
}

/// Convert Date to a specific timezone
String formatDateToTimezone({required String dateString}) {
  tz.initializeTimeZones();
  DateTime parsedDate = DateTime.parse(dateString);
  DateTime utcDate = parsedDate.toUtc();
  tz.Location location = tz.local; // What does this do?
  tz.TZDateTime localDate = tz.TZDateTime.from(utcDate, location);
  DateFormat formatter = DateFormat('MMMM d, y - hh:mm a');
  String formattedDate = formatter.format(localDate);
  return '$formattedDate';
}

/// Dispose current screen or close current dialog
void pop([Object? object]) {
  if (Navigator.canPop(getContext)) Navigator.pop(getContext, object);
}

// List<String> generateAgeOptions({
//   int minAge = 10,
//   int maxAge = 60,
//   int? currentYear,
// }) {
//   final year = currentYear ?? DateTime.now().year;
//   final lastOptionYear = year - minAge;
//
//   return List<int>.generate(
//     maxAge - minAge + 1,  // Calculate total options
//         (index) => lastOptionYear - index,
//   ).map((birthYear) => (year - birthYear).toString()).toList();
// }

List<String> generateBirthYearOptions({
  int minAge = 10,
  int maxAge = 60,
  int? currentYear,
}) {
  final year = currentYear ?? DateTime.now().year;
  final youngestYear = year - minAge;
  final oldestYear = year - maxAge;

  return List<int>.generate(
    maxAge - minAge + 1,
    (index) => youngestYear - index,
  ).map((birthYear) => birthYear.toString()).toList();
}

int getCurrentAgeFromYear(int birthYear, {int? currentYear}) {
  assert(birthYear > 1900, 'Birth year must be after 1900');

  final year = currentYear ?? DateTime.now().year;
  return (year - birthYear).clamp(0, 120);
}

String getBirthYearFromAge(int age, {int? currentYear}) {
  final year = currentYear ?? DateTime.now().year;
  final birthYear = year - age;

  if (birthYear < 1900) {
    debugPrint('Warning: Birth year $birthYear may be invalid');
    return '1900';
  }
  return birthYear.toString();
}

Color getRandomColor() {
  int randomNumber = Random().nextInt(5) + 1;

  switch (randomNumber) {
    case 1:
      return Color(0xFFFED8E0);
    case 2:
      return Color(0xFFD9ECF5);
    case 3:
      return Color(0xFFE5DEF2);
    case 4:
      return Color(0xFFFAE8E9);
    case 5:
      return Color(0xFFFBEEC8);
    default:
      return Color(0xFFFED8E0);
  }
}

Widget randomPosition(String imagePath) {
  final bool placeOnRight = Random().nextBool();

  return Positioned(
    top: 0,
    right: placeOnRight ? 0 : null,
    left: !placeOnRight ? 0 : null,
    child: Transform(
      alignment: Alignment.center,
      transform: !placeOnRight ? Matrix4.rotationY(pi) : Matrix4.identity(),
      child: Image.asset(imagePath),
    ),
  );
}

Future<void> showAdBeforeNavigation({
  required BuildContext context,
  required Widget screen,
  required bool showAd,
  required Future<void> Function() postAction,
}) async {
  await NavigationUtils.navigateWithPostPopAction(
    context: context,
    screen: screen,
    showRewardedAd: showAd,
    postPopAction: postAction,
  );
}

String generateRandom4DigitNumber() {
  Random random = Random();
  int number = random.nextInt(9000) + 1000;
  return number.toString();
}
