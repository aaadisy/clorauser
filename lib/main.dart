import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:clora_user/extensions/extension_util/string_extensions.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/newsplash.dart'; 
import 'package:clora_user/service/notification_service.dart';
import 'package:clora_user/service/reminder_service.dart';
import 'package:clora_user/store/app_store.dart';
import 'package:clora_user/store/userStore/user_store.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terminate_restart/terminate_restart.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as chat;
import 'package:stream_video_flutter/stream_video_flutter.dart' as video;


import '../../utils/app_config.dart';
import '../../utils/app_constants.dart';
import 'languageConfiguration/AppLocalizations.dart';
import 'languageConfiguration/BaseLanguage.dart';
import 'languageConfiguration/LanguageDataConstant.dart';
import 'languageConfiguration/LanguageDefaultJson.dart';
import 'languageConfiguration/ServerLanguageResponse.dart';
import 'utils/app_common.dart';
import '../../utils/dynamic_theme.dart'; 

final navigatorKey = GlobalKey<NavigatorState>();
AppStore appStore = AppStore();
UserStore userStore = UserStore();
const MethodChannel platform =
    const MethodChannel('dexterx.dev/flutter_local_notifications_example');
MenstrualCycleWidget instance = MenstrualCycleWidget.instance!;
const String portName = 'notification_send_port';
late SharedPreferences sharedPreferences;
late BaseLanguage language;

LanguageJsonData? selectedServerLanguageData;
List<LanguageJsonData>? defaultServerLanguageData = [];
List<String> backgroundEvents = [];
List<String> scheduleRemindersData = [];
NotificationService notificationService = NotificationService();
final List<String> days = [MON, TUE, WED, THU, FRI, SAT, SUN];
bool mIsEnterKey = false;
int CurrentAndroidVersion = 1;
int CurrentIOSVersion = 1;
bool isAndroidForceUpdate = false;
bool isIOSForceUpdate = false;
String? androidLiveUrl = "";
String? iOSLiveUrl = "";
String? chatgptKey;

// Stream Chat Client Initialization
final client = chat.StreamChatClient(
  'krvywb83mwjv', 
  logLevel: chat.Level.WARNING,
);
video.StreamVideo? streamVideo;

/// This "Headless Task" is run when app is terminated.
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  var taskId = task.taskId;
  var timeout = task.timeout;
  if (timeout) {
    BackgroundFetch.finish(taskId);
    return;
  }

  var timestamp = DateTime.now();

  var prefs = await SharedPreferences.getInstance();

  var events = <String>[];

  var json = prefs.getString(EVENTS_KEY);
  if (json != null) {
    events = jsonDecode(json).cast<String>();
  }

  events.insert(0, "$taskId@$timestamp [Headless]");
  prefs.setString(EVENTS_KEY, jsonEncode(events));
  rescheduleRemindersIfMissed();
  if (taskId == 'flutter_background-fetch') {
    BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.transistorsoft.customtask",
        delay: 5000,
        periodic: false,
        forceAlarmManager: false,
        stopOnTerminate: false,
        enableHeadless: true));
  }
  BackgroundFetch.finish(taskId);
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 
  HttpOverrides.global = MyHttpOverrides();
  TerminateRestart.instance.initialize();
  MenstrualCycleWidget.init(
      secretKey: "a9c4f1b5e7d83a1c8b5c6d9f8a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8",
      ivKey: "9f1c3a5e7b2d4f6a8c0e1b3d5f7a9c");
  sharedPreferences = await SharedPreferences.getInstance();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
  ));

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Request Permissions for Android/iOS
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Handle Token Refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    if (client.state.currentUser != null) {
       client.addDevice(
        newToken,
        chat.PushProvider.firebase, // 👈 FIX
      );
    }
  });

  appStore.setLanguage(DEFAULT_LANGUAGE);
  setLogInValue(isFromEducationScreen: false);
  defaultAppButtonShapeBorder =
      RoundedRectangleBorder(borderRadius: radius(defaultAppButtonRadius));
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Basic Notification Channel',
        defaultColor: primaryColor,
        playSound: true,
        importance: NotificationImportance.High,
        locked: true,
        enableVibration: true,
      ),
      NotificationChannel(
        channelKey: 'scheduled_channel',
        channelName: 'Scheduled Notifications',
        channelDescription: 'Scheduled Notification Channel',
        defaultColor: primaryColor,
        locked: true,
        importance: NotificationImportance.High,
        playSound: true,
        enableVibration: true,
      ),
    ],
  );
  initJsonFile();
  oneSignalData();
  getRemindersList();
  await Alarm.init();

  runApp(MyApp());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatefulWidget {
  static String tag = '/MyApp';

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static StreamSubscription<AlarmSettings>? subscription;
  bool isCurrentlyOnNoInternet = false;
  final pinLockMillis = 2000;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    init();
  }

  void init() async {
    initPlatformState();
    
    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
       // If message has notification data, you can show it manually or use Stream UI
       if (message.notification != null) {
          // You could use AwesomeNotifications or similar to show it if Stream isn't already
       }
    });
  }

  Future<void> initPlatformState() async {
    var prefs = await SharedPreferences.getInstance();
    var json = prefs.getString(EVENTS_KEY);
    if (json != null) {
      setState(() {
        backgroundEvents = jsonDecode(json).cast<String>();
      });
    }
    var json1 = prefs.getString(CHECK_SCHEDULE_DATA);
    if (json1 != null) {
      setState(() {
        scheduleRemindersData = jsonDecode(json1).cast<String>();
      });
    }
    try {
      BackgroundFetch.scheduleTask(TaskConfig(
          taskId: "com.transistorsoft.customtask",
          delay: 10000,
          periodic: false,
          forceAlarmManager: true,
          stopOnTerminate: false,
          enableHeadless: true));
    } on Exception {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    subscription?.cancel();
    super.dispose();
  }

  Future pausedState() async {
    setValue(
        KEY_LAST_KNOWN_APP_LIFECYCLE_STATE, AppLifecycleState.paused.index);
  }

  Future<void> inActiveState() async {
    final prevState = getIntAsync(KEY_LAST_KNOWN_APP_LIFECYCLE_STATE);
    final prevStateIsNotPaused =
        AppLifecycleState.values[prevState] != AppLifecycleState.paused;

    if (prevStateIsNotPaused) {
      setValue(KEY_APP_BACKGROUND_TIME, DateTime.now().millisecondsSinceEpoch);
    }

    setValue(
        KEY_LAST_KNOWN_APP_LIFECYCLE_STATE, AppLifecycleState.inactive.index);
  }

  Future<void> _resumed() async {
    removeKey(KEY_APP_BACKGROUND_TIME);
    setValue(
        KEY_LAST_KNOWN_APP_LIFECYCLE_STATE, AppLifecycleState.resumed.index);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        pausedState();
        break;
      case AppLifecycleState.resumed:
        _resumed();
        break;
      case AppLifecycleState.inactive:
        inActiveState();
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Container(
        decoration: BoxDecoration(
          gradient: ColorUtils.ROOT_BACKGROUND_GRADIENT,
        ),
        child: MaterialApp(
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
          title: APP_NAME,
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          scrollBehavior: SBehavior(),
          theme: ThemeData.from(
            colorScheme: ColorScheme.fromSeed(
              seedColor: ColorUtils.colorPrimary,
              background: Colors.transparent,
              onBackground: Colors.black.withOpacity(0.7),
              primary: ColorUtils.colorPrimary,
              secondary: ColorUtils.PRIMARY_CREAM,
            )
            ,
            useMaterial3: true,
          ).copyWith(
            cardTheme: CardThemeData(
              elevation: 0, 
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)), 
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorUtils.colorPrimary, 
                foregroundColor: Colors.white,
                elevation: 0, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.0), 
                ),
                shadowColor: Colors.transparent,
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              iconTheme: IconThemeData(color: ColorUtils.colorPrimary),
            ),
          ),
          builder: (context, child) {
            return chat.StreamChat(
              client: client,
              child: child!,
            );
          },
          home: NewSplashScreen(), 
          supportedLocales: getSupportedLocales(),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            CountryLocalizations.delegate,
            AppLocalizations(),
          ],
          localeResolutionCallback: (locale, supportedLocales) => locale,
          locale: Locale(
              appStore.selectedLanguage.validate(value: defaultLanguageCode)),
        ),
      );
    });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
