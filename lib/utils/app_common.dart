import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clora_user/extensions/extension_util/device_extensions.dart';
import 'package:clora_user/extensions/new_colors.dart';
import 'package:clora_user/utils/app_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../extensions/extension_util/string_extensions.dart';
import '../extensions/extensions.dart';
import '../languageConfiguration/LanguageDataConstant.dart';
import '../languageConfiguration/ServerLanguageResponse.dart';
import '../main.dart';
import '../model/common/app_setting_model.dart';
import '../model/user/user_models/user_model.dart';
import '../network/rest_api.dart';
import '../screens/user/explore_detail_screen.dart';
import 'app_constants.dart';
import 'app_images.dart';
import 'dynamic_theme.dart';

/// Print logs to console
printEraAppLogs(String message) {
  if (kDebugMode) {
    //printEraAppLogs("Era App Logs: $message");
  }
}

class DiagonalPathClipperTwo extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0.0, size.height)
      ..lineTo(size.width, size.height - 50)
      ..lineTo(size.width, 0.0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

Widget outlineIconButton(BuildContext context,
    {required String text, String? icon, Function()? onTap, Color? textColor}) {
  return OutlinedButton(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          ImageIcon(AssetImage(icon), color: ColorUtils.colorPrimary, size: 24),
        if (icon != null) 8.width,
        Text(text, style: primaryTextStyle(color: textColor ?? null, size: 14)),
      ],
    ),
    onPressed: onTap ?? () {},
    style: OutlinedButton.styleFrom(
      side: BorderSide(
          color: textColor ?? ColorUtils.colorPrimary,
          style: BorderStyle.solid),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}

// Call when we view screen
void logScreenView(String screenName) async {
  try {
    final user = userStore.user;
    if (user == null) {
      return;
    }

    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    await analytics.logEvent(
      name: 'screen_view',
      parameters: {
        'screen_name': screenName,
        'user_id': user.uid ?? '',
        'screen_class': screenName,
      },
    );
  } catch (e, stack) {
    log('Failed to log screen view: $e');
    log('$stack');
  }
}

Future<void> logAnalyticsEvent({
  required String category,
  required String action,
  String? label,
}) async {
  try {
    final user = userStore.user;
    if (user == null) return;

    await FirebaseAnalytics.instance.logEvent(
      name: '${category}', // e.g., Sleep_reminder
      parameters: {
        'category': category, // e.g sleep_reminder
        'action': action, // created
        if (label != null) 'label': label,
        'user_id': user.id!.toInt(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  } catch (e, stack) {
    log('Analytics error: ${stack}');
  }
}

Widget cachedImage(String? url,
    {double? height,
    Color? color,
    double? width,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    bool usePlaceholderIfUrlEmpty = true,
    double? radius}) {
  if (url.validate().isEmpty) {
    return placeHolderWidget(
        height: height,
        width: width,
        fit: fit,
        alignment: alignment,
        radius: radius);
  } else if (url.validate().startsWith('http')) {
    // log("I AM http ${url}");
    return CachedNetworkImage(
      imageUrl: url!,
      height: height,
      width: width,
      fit: fit,
      color: color,
      alignment: alignment as Alignment? ?? Alignment.center,
      placeholder: (context, url) => placeHolderWidget(
          height: height,
          width: width,
          fit: fit,
          alignment: alignment,
          radius: radius),
      errorWidget: (_, s, d) {
        return placeHolderWidget(
            height: height,
            width: width,
            fit: fit,
            alignment: alignment,
            radius: radius);
      },
    );
  } else {
    return Image.asset(ic_placeholder,
            height: height,
            width: width,
            fit: fit,
            alignment: alignment ?? Alignment.center)
        .cornerRadiusWithClipRRect(radius ?? defaultRadius);
  }
}

Widget placeHolderWidget(
    {double? height,
    double? width,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    double? radius}) {
  return Image.asset(ic_placeholder,
          height: height,
          width: width,
          fit: fit ?? BoxFit.fill,
          alignment: alignment ?? Alignment.center)
      .cornerRadiusWithClipRRect(radius ?? defaultRadius);
}

toast(String? value,
    {ToastGravity? gravity,
    length = Toast.LENGTH_SHORT,
    Color? bgColor,
    Color? textColor}) {
  Fluttertoast.showToast(
    msg: value.validate(),
    toastLength: length,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: bgColor,
    textColor: textColor,
    fontSize: 16.0,
  );
}

String parseDocumentDate(DateTime dateTime, [bool includeTime = false]) {
  if (includeTime) {
    return DateFormat('dd MMM, yyyy hh:mm a').format(dateTime);
  } else {
    // return DateFormat('dd MMM').format(dateTime);
    return DateFormat('dd MMM, yyyy').format(dateTime);
  }
}

Future<void> getUSerDetail(BuildContext context, int? id) async {
  await getUserDetailsApi(id: id).then((value) async {
    appStore.setLoading(false);
  }).catchError((e) {
    appStore.setLoading(false);
  });
}

Future<void> getDoctorDetail(BuildContext context) async {
  await getDoctorDetailsApi().then((value) async {
    userStore.setDrExpertise(value.data!.areaExpertise.toString());
    userStore.setDrName(value.data!.name.validate());
    userStore.setUserDrEmail(value.data!.email.validate());
    userStore.setDrTagline(value.data!.tagLine.validate());
    userStore.setDRprofileImage(value.data!.healthExpertsImage.validate());
    userStore.setDrDesc(value.data!.shortDescription.validate());
    userStore.setDrCareer(value.data!.career.validate());
    userStore.setDrEducation(value.data!.education.validate());
    userStore.setDrAwards(value.data!.awardsAchievements.validate());
  }).catchError((e) {});
}

Future<void> setAppSettingData(AppSettings? value) async {
  setValue(SITE_NAME, value!.appSetting!.siteName.validate());
  setValue(SITE_DESCRIPTION, value.appSetting!.siteDescription.validate());
  setValue(SITE_COPYRIGHT, value.appSetting!.siteCopyright.validate());
  setValue(FACEBOOK_URL, value.appSetting!.facebookUrl.validate());
  setValue(INSTAGRAM_URL, value.appSetting!.instagramUrl.validate());
  setValue(TWITTER_URL, value.appSetting!.twitterUrl.validate());
  setValue(LINKED_URL, value.appSetting!.linkedinUrl.validate());
  setValue(CONTACT_EMAIL, value.appSetting!.contactEmail.validate());
  setValue(CONTACT_NUMBER, value.appSetting!.contactNumber.validate());
  setValue(HELP_SUPPORT, value.appSetting!.helpSupportUrl.validate());
  setValue(PrivacyPolicy, value.appSetting!.helpSupportUrl.validate());
}

bool isFeatureLocked({
  required bool? features,
  required bool? isUserSubscribed,
}) {
  if (features == null || isUserSubscribed == null) {
    return false;
  }

  // Check if the feature is enabled and the user is not subscribed
  return features == true && !isUserSubscribed;
}

setLogInValue({required bool isFromEducationScreen}) {
  userStore.setLogin(getBoolAsync(IS_LOGIN));
  if (userStore.isLoggedIn) {
    userStore.setToken(getStringAsync(TOKEN));
    userStore.setUserID(getIntAsync(USER_ID));
    userStore.setUserEmail(getStringAsync(EMAIL));
    userStore.setFirstName(getStringAsync(FIRSTNAME));
    userStore.setLastName(getStringAsync(LASTNAME));
    userStore.setUserPassword(getStringAsync(PASSWORD));
    userStore.setUserImage(getStringAsync(USER_PROFILE_IMG));
    isFromEducationScreen
        ? userStore.setLoginUsertype(APP_USER)
        : userStore.setLoginUsertype(ANONYMOUS);
  }
}

Widget mSuffixTextFieldIconWidget(String? img, Color? color) {
  return Image.asset(img.validate(),
          height: 20, width: 20, color: color != null ? color : Colors.grey)
      .paddingAll(14);
}

Future<void> launchUrls(String url, {bool forceWebView = false}) async {
  log(url);
  if (!await launchUrl(
    Uri.parse(url),
    // mode: LaunchMode.inAppWebView,
    // webViewConfiguration: const WebViewConfiguration(enableDomStorage: false),
  )) {
    throw 'Could not launch $url';
  }
  // await launchUrl(Uri.parse(url),mode: LaunchMode.inAppWebView,webViewConfiguration: WebViewConfiguration()).catchError((e) {
  //   log(e);
  //   toast('Invalid URL: $url');
  // });
}

Future<void> commonLaunchUrl(String url, {bool forceWebView = false}) async {
  log(url);
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)
      .then((value) {})
      .catchError((e) {
    toast("Individual " + ' $url');
  });
}

Future<void> oneSignalData() async {
  if (isMobile) {
    PermissionStatus status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.Debug.setAlertLevel(OSLogLevel.none);
  OneSignal.consentRequired(false);
  OneSignal.initialize(mOneSignalAppId);
  OneSignal.Notifications.requestPermission(true);
  OneSignal.User.pushSubscription.addObserver((state) async {
    //  await setValue(playerId, OneSignal.User.pushSubscription.id);
    if (!OneSignal.User.pushSubscription.id.isEmptyOrNull)
      await setValue(PLAYER_ID, OneSignal.User.pushSubscription.id.validate());
  });
  OneSignal.Notifications.addPermissionObserver((state) {});

  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    event.preventDefault();
    event.notification.display();
  });

  appStore.setLoading(false);
  OneSignal.Notifications.addClickListener((event) async {
    var data = event.notification.additionalData;
    print("CLICK LISTENER DATA: $data");

    if (data != null) {
      var type = data["type"];
      var postId = data["id"];

      if (type == "secret_chat_comment" && postId != null) {
        int? id = int.tryParse(postId.toString());
        if (id != null) {
          String? description = data["description"]?.toString();
          String? backgroundImage = data["background_image"]?.toString();
          ExploreDetailScreen(
            postId: id,
            postTitle: description ?? "",
            postImageUrl: backgroundImage ?? "",
          ).launch(getContext);
        }
      }
    }
  });
}

Widget reminderCommon(String title, String subtitle, Widget? trailing,
    {Color? color, double? borderRadius = 0}) {
  return Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius!),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: boldTextStyle(
                    color: mainColorText, size: 16, weight: FontWeight.w500)),
            8.height,
            Text(subtitle,
                    style: boldTextStyle(
                        color: mainColorBodyText,
                        size: 12,
                        weight: FontWeight.w400))
                .visible(subtitle.isNotEmpty),
          ],
        ).expand(),
        trailing ?? SizedBox(),
      ],
    ).paddingSymmetric(horizontal: 16, vertical: 16),
  );
}

Widget predictionCommon(String title, String subtitle, Widget? trailing) {
  return Container(
    // color: Colors.blue,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: primaryTextStyle()),
            8.height,
            Text(subtitle, style: primaryTextStyle(size: 12))
                .visible(subtitle.isNotEmpty)
          ],
        ).expand(),
        trailing ?? SizedBox(),
      ],
    ).paddingSymmetric(horizontal: 16, vertical: 8),
  );
}

dividerCommon(context) {
  return Divider(
    color: viewLineColor,
    height: 8,
    thickness: 1,
  );
}

noteCommon() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    decoration: boxDecorationWithRoundedCorners(
      backgroundColor: Colors.white,
      borderRadius: radius(defaultRadius),
    ),
    child: Text(
      "NOTE: we don't collect, process, or store any of the data that you enter while using this tool. All calculation are done exclusively in your locally, and we don't have access to the results. All data will be permanently erased after leaving or close the screen.",
      style: boldTextStyle(size: 8, color: Colors.grey),
    ),
  ).paddingSymmetric(horizontal: 16);
}

List<String> setSearchParam(String caseNumber) {
  List<String> caseSearchList = [];
  String temp = "";
  for (int i = 0; i < caseNumber.length; i++) {
    temp = temp + caseNumber[i];
    caseSearchList.add(temp.toLowerCase());
  }
  return caseSearchList;
}

Widget noProfileImageFound(
    {double? height, double? width, bool isNoRadius = true}) {
  return Image.asset(
    ic_profile,
    height: height,
    width: width,
    fit: BoxFit.cover,
    // color: iconColor,
  ).cornerRadiusWithClipRRect(isNoRadius ? 0 : height! / 2);
}

UserModel sender = UserModel(
  firstName: getStringAsync(FIRSTNAME),
  profileImage: getStringAsync(USER_PROFILE_IMG),
  uid: getStringAsync(UID),
  playerId: getStringAsync(PLAYER_ID),
);

String timeAgoSinceDate(Timestamp dateString) {
  Duration difference = DateTime.now().difference(dateString.toDate());

  if (difference.inSeconds < 60) {
    return '${difference.inSeconds} seconds ago';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} minutes ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else if ((difference.inDays / 7).floor() < 4) {
    return '${(difference.inDays / 7).floor()} weeks ago';
  } else if ((difference.inDays / 30).floor() < 12) {
    return '${(difference.inDays / 30).floor()} months ago';
  } else {
    return '${(difference.inDays / 365).floor()} years ago';
  }
}

List<String> getCycleLengthList() {
  List<String> cycleLengthList = ["Select"];
  for (int i = 21; i <= 45; i++) {
    cycleLengthList.add(i.toString());
  }
  return cycleLengthList;
}

List<String> getPeriodLengthList() {
  List<String> periodLengthList = ["Select"];
  for (int i = 1; i <= 12; i++) {
    periodLengthList.add(i.toString());
  }
  return periodLengthList;
}

List<Object> getLutealLengthList() {
  List<Object> lutealLengthList = ["Select"];
  for (int i = 8; i <= 17; i++) {
    lutealLengthList.add(i.toString());
  }
  return lutealLengthList;
}

// Generate dynamic color
List<Color> generateColorVariations(Color baseColor, int numberOfColors) {
  List<Color> colorList = [];
  HSLColor hslBase = HSLColor.fromColor(baseColor);

  for (int i = 0; i < numberOfColors; i++) {
    double hue = (hslBase.hue + (i * 30) % 360).clamp(0.0, 360.0);
    double saturation = (hslBase.saturation + 0.1 * (i % 3)).clamp(0.0, 1.0);
    double lightness =
        (hslBase.lightness + 0.05 * (i % 3) - 0.05).clamp(0.0, 1.0);
    HSLColor hslColor = HSLColor.fromAHSL(1.0, hue, saturation, lightness);
    colorList.add(hslColor.toColor());
  }
  return colorList;
}

// Format date to Word Format
// e.g 12-12-24 -> 12th Dec 2024
String formatDateToWordFormat(String dateString) {
  try {
    // Parse the input date
    DateTime date = DateFormat("yyyy-MM-dd").parse(dateString);

    String day = DateFormat("d").format(date);
    String month = DateFormat("MMM").format(date);
    String year = DateFormat("y").format(date);

    // Add ordinal suffix
    String suffix = getDaySuffix(int.parse(day));

    return "$day$suffix $month $year";
  } catch (e) {
    return "Invalid Date";
  }
}

String getDaySuffix(int day) {
  if (day >= 11 && day <= 13) {
    return "th";
  }
  switch (day % 10) {
    case 1:
      return "st";
    case 2:
      return "nd";
    case 3:
      return "rd";
    default:
      return "th";
  }
}

Widget emptyWidget() {
  return Center(child: Lottie.asset('assets/no_data.json', width: 150));
}

DateTime getNextSameDay(int dayIndex, TimeOfDay? timeOfDay) {
  DateTime now = DateTime.now();
  final dateTimeToday =
      DateTime(now.year, now.month, now.day, timeOfDay!.hour, timeOfDay.minute);
  if (dayIndex == now.weekday && dateTimeToday.isAfter(now)) {
    return dateTimeToday;
  } else {
    double daysToAdd = (dayIndex - now.weekday + 7) % 7;
    DateTime nextDay = dateTimeToday.add(Duration(days: daysToAdd.toInt()));

    return nextDay;
  }
}

Color hexToColor(String hexString) {
  // Remove the leading '#' if present
  hexString = hexString.replaceFirst('#', '');

  // If the string is 6 characters long, add 'FF' for full opacity
  if (hexString.length == 6) {
    hexString = 'FF$hexString';
  }

  // Parse the string and return the Color object
  return Color(int.parse(hexString, radix: 16));
}

/** progress screen **/
final List<String> birdNames = [
  "Sparrow",
  "Robin",
  "Eagle",
  "Hawk",
  "Falcon",
  "Owl",
  "Crow",
  "Raven",
  "Blue Jay",
  "Cardinal",
  "Hummingbird",
  "Pelican",
  "Seagull",
  "Woodpecker",
  "Swan",
  "Duck",
  "Goose",
  "Pigeon",
  "Parrot",
  "Peacock",
  "Albatross",
  "Heron",
  "Flamingo",
  "Kingfisher",
  "Toucan",
  "Wren",
  "Warbler",
  "Magpie",
  "Sparrowhawk",
  "Kookaburra",
  "Nightingale",
  "Osprey",
  "Ostrich",
  "Penguin",
  "Puffin",
  "Quail",
  "Rail",
  "Rook",
  "Starling",
  "Stork",
  "Swallow",
  "Swift",
  "Tern",
  "Turkey",
  "Vulture",
  "Waxwing",
  "Weka",
  "Whimbrel",
  "Willow Warbler",
  "Yellowhammer",
  "Zebra Finch",
  "Anhinga",
  "Bittern",
  "Bobolink",
  "Bunting",
  "Cuckoo",
  "Curlew",
  "Dodo",
  "Dotterel",
  "Egret",
  "Finch",
  "Grosbeak",
  "Grouse",
  "Harrier",
  "Ibis",
  "Jacana",
  "Junco",
  "Kakapo",
  "Lapwing",
  "Loon",
  "Lyrebird",
  "Martin",
  "Meadowlark",
  "Nighthawk",
  "Nuthatch",
  "Oriole",
  "Osprey",
  "Ouzel",
  "Parakeet",
  "Partridge",
  "Petrel",
  "Pipit",
  "Ptarmigan",
  "Razorbill",
  "Redpoll",
  "Sandpiper",
  "Shrike",
  "Snipe",
  "Spoonbill",
  "Sunbird",
  "Tanager",
  "Teal",
  "Tern",
  "Thrasher",
  "Thrush",
  "Titmouse",
  "Towhee",
  "Treecreeper",
  "Tropicbird",
  "Veery",
];

String generateRandomBirdPassword() {
  Random random = Random();
  String randomBird = birdNames[random.nextInt(birdNames.length)];
  String randomSuffix = generateRandomString(4);
  return '$randomBird$randomSuffix';
}

String generateDateTimeString() {
  DateTime now = DateTime.now();
  return DateFormat('yyyyMMddHHmmss').format(now);
}

String generateRandomString(int length) {
  const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
  Random random = Random();
  return String.fromCharCodes(Iterable.generate(
    length,
    (_) => characters.codeUnitAt(random.nextInt(characters.length)),
  ));
}

// Update App Language Configuration

Future<void> updateAppLanguageConfiguration(
    {LanguageJsonData? data, BuildContext? context}) async {
  await setValue(SELECTED_LANGUAGE_CODE, data!.languageCode);
  await setValue(SELECTED_LANGUAGE_COUNTRY_CODE, data.countryCode);
  selectedServerLanguageData = data;
  await setValue(IS_SELECTED_LANGUAGE_CHANGE, true);
  appStore.setLanguage(data.languageCode!, context: context);
}
