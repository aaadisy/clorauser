import 'dart:convert';
import 'package:clora_user/languageConfiguration/LanguageDataConstant.dart';
import 'package:clora_user/languageConfiguration/ServerLanguageResponse.dart';
import 'package:clora_user/model/user/user_models/user_model.dart';
import 'package:clora_user/screens/onboarding/fu_style_question_screen.dart';
import 'package:clora_user/screens/user/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menstrual_cycle_widget/utils/enumeration.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:store_checker/store_checker.dart';
import '../../../extensions/extension_util/context_extensions.dart';
import '../../../extensions/extension_util/string_extensions.dart';
import '../../components/user/warning_dialog.dart';
import '../../extensions/extensions.dart';
import '../../main.dart';
import '../../network/rest_api.dart';
import '../../utils/app_common.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_images.dart';
import '../../utils/biometric_utils.dart';
import '../user/questions_list_screen.dart';
import '../user/user_dashboard_screen.dart';

const BoxDecoration _kDarkGradientBackground = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1F1C2C),
      Color(0xFF928DAB),
    ],
  ),
);

class SplashScreen extends StatefulWidget {
  static const String tag = '/SplashScreen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  PackageInfo? _packageInfo;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    // Set Package Info
    await loadPackageInfo();

    // Get version number
    String versionNo = await getStringAsync(CURRENT_LAN_VERSION,
        defaultValue: LanguageVersion);

    // Handle language and theme configuration
    if (await isNetworkAvailable()) {
      await getLanguageList(versionNo).then((value) async {
        appStore.setLoading(false);
        CurrentAndroidVersion = value.details!.androidVersionCode!;
        CurrentIOSVersion = value.details!.iosVersion!;
        isAndroidForceUpdate = value.details!.androidForceUpdate!;
        isIOSForceUpdate = value.details!.iosForceUpdate!;
        androidLiveUrl = value.details!.playstoreUrl ?? "";
        iOSLiveUrl = value.details!.appstoreUrl ?? "";
        if (value.status == true) {
          setValue(CURRENT_LAN_VERSION, value.currentVersionNo.toString());
          if (value.data!.length > 0) {
            appStore.setThemeColor(value.themeColor!);
            appStore.updateTheme(hexToColor(value.themeColor!));
            setValue("themeColor", value.themeColor!);
            defaultServerLanguageData = value.data;
            performLanguageOperation(defaultServerLanguageData);
            setValue(LanguageJsonDataRes, value.toJson());
            bool isSetLanguage =
                getBoolAsync(IS_SELECTED_LANGUAGE_CHANGE, defaultValue: false);
            if (!isSetLanguage) {
              for (int i = 0; i < value.data!.length; i++) {
                if (value.data![i].isDefaultLanguage == 1) {
                  setValue(SELECTED_LANGUAGE_CODE, value.data![i].languageCode);
                  setValue(SELECTED_LANGUAGE_COUNTRY_CODE,
                      value.data![i].countryCode);
                  appStore.setLanguage(value.data![i].languageCode!,
                      context: context);
                }
              }
            }
          } else {
            defaultServerLanguageData = [];
            setValue(LanguageJsonDataRes, "");
          }
        } else {
          String jsonData =
              getStringAsync(LanguageJsonDataRes, defaultValue: "");
          if (jsonData.isNotEmpty) {
            ServerLanguageResponse languageSettings =
                ServerLanguageResponse.fromJson(json.decode(jsonData.trim()));
            if (languageSettings.data != null &&
                languageSettings.data!.isNotEmpty) {
              defaultServerLanguageData = languageSettings.data;
              performLanguageOperation(defaultServerLanguageData);
            }
          }
          String themeColor = getStringAsync("themeColor");
          if (themeColor.isNotEmpty) {
            appStore.setThemeColor(themeColor);
            appStore.updateTheme(hexToColor(themeColor));
          }
        }
        await setAppSettingData(value.appSettings);
      });
    } else {
      String jsonData = getStringAsync(LanguageJsonDataRes, defaultValue: "");
      if (jsonData.isNotEmpty) {
        ServerLanguageResponse languageSettings =
            ServerLanguageResponse.fromJson(json.decode(jsonData.trim()));
        if (languageSettings.data != null &&
            languageSettings.data!.isNotEmpty) {
          defaultServerLanguageData = languageSettings.data;
          performLanguageOperation(defaultServerLanguageData);
        }
      }
      String themeColor = getStringAsync("themeColor");
      if (themeColor.isNotEmpty) {
        appStore.setThemeColor(themeColor);
        appStore.updateTheme(hexToColor(themeColor));
      }
    }

    // Force English only
    instance.updateLanguageConfiguration(
      defaultLanguage: Languages.english,
    );

    // Check for Dialog or Navigate
    if (!_isNavigating) {
      _isNavigating = true;
      await navigateBasedOnUserState();
    }

  }

  Future<void> loadPackageInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
    setValue(APP_VERSION, _packageInfo!.buildNumber);
    String APPSOURCE = await updateStoreCheckerData();
    debugPrint("App Source - ${APPSOURCE}");
    setValue(APP_SOURCE, APPSOURCE);
  }

  Future<String> updateStoreCheckerData() async {
    Source installationSource;
    try {
      installationSource = await StoreChecker.getSource;
    } on PlatformException {
      installationSource = Source.UNKNOWN;
    }

    // Set source text state
    switch (installationSource) {
      case Source.IS_INSTALLED_FROM_PLAY_STORE:
        return PLAY_STORE;
      case Source.IS_INSTALLED_FROM_PLAY_PACKAGE_INSTALLER:
        return GOOGLE_PACKAGE_INSTALLER;
      case Source.IS_INSTALLED_FROM_RU_STORE:
        return RUSTORE;
      case Source.IS_INSTALLED_FROM_LOCAL_SOURCE:
        return LOCAL_SOURCE;
      case Source.IS_INSTALLED_FROM_AMAZON_APP_STORE:
        return AMAZON_STORE;
      case Source.IS_INSTALLED_FROM_HUAWEI_APP_GALLERY:
        return HUAWEI_APP_GALLERY;
      case Source.IS_INSTALLED_FROM_SAMSUNG_GALAXY_STORE:
        return SAMSUNG_GALAXY_STORE;
      case Source.IS_INSTALLED_FROM_SAMSUNG_SMART_SWITCH_MOBILE:
        return SAMSUNG_SMART_SWITCH_MOBILE;
      case Source.IS_INSTALLED_FROM_XIAOMI_GET_APPS:
        return XIAOMI_GET_APPS;
      case Source.IS_INSTALLED_FROM_OPPO_APP_MARKET:
        return OPPO_APP_MARKET;
      case Source.IS_INSTALLED_FROM_VIVO_APP_STORE:
        return VIVO_APP_STORE;
      case Source.IS_INSTALLED_FROM_OTHER_SOURCE:
        return OTHER_SOURCE;
      case Source.IS_INSTALLED_FROM_APP_STORE:
        return APP_STORE;
      case Source.IS_INSTALLED_FROM_TEST_FLIGHT:
        return TEST_FLIGHT;
      case Source.UNKNOWN:
        return UNKNOWN_SOURCE;
    }
  }

  void showWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WarningDialog(),
    );
  }

  Future<void> _clearOldQuestionnaireData() async {
    // Remove old state flags to prevent old flow from triggering
    await removeKey(KEY_QUESTION_DATA);
    await removeKey(IS_USER_COMPLETED_QUE); 
  }

  Future<void> navigateBasedOnUserState() async {
    final isLoggedIn = getBoolAsync(IS_LOGIN);

    if (isLoggedIn) {
      final isAuthenticated = await _authenticateUserIfRequired();
      if (!isAuthenticated) return;

      final userToken = getStringAsync(TOKEN);
      if (userToken.isEmptyOrNull) {
        // If token is missing despite IS_LOGIN being true, force sign in
        UserSignInScreen().launch(context, isNewTask: true);
        return;
      }

      // *** LOGIC: Check profile status via API ***
      var res = await firebaseLoginApi({
        "firebase_uid": userToken,
        "email": userStore.email.isEmpty ? getStringAsync(EMAIL) : userStore.email,
        "phone": userStore.email, // Placeholder: Verify actual parameter names expected by API
        "name": userStore.fName.isEmpty ? getStringAsync(FIRSTNAME) : userStore.fName, // Placeholder
      });

      if (res['status'] == true) {
        if (res['profile_completed'] == 0) {
          // Profile not completed -> Go to new onboarding flow
          await _clearOldQuestionnaireData();
          AiOnboardingScreen(isFromLogin: true).launch(context, isNewTask: true);
        } else {
          // Profile completed -> Go to Dashboard
          await _clearOldQuestionnaireData();
          UserModel? userData = await getUserFromLocalStorage();
          if (userData != null) {
            userStore.setUserModelData(userData);
          }
          DashboardScreen(currentIndex: 0).launch(context, isNewTask: true);
        }
      } else {
        // API call failed for existing user (e.g., token expired/invalid) -> Force sign in/re-auth
        setValue(IS_LOGIN, false);
        userStore.clearUserData();
        removeKey(TOKEN);
        UserSignInScreen().launch(context, isNewTask: true);
      }

    } else {
      UserSignInScreen()
          .launch(context, isNewTask: true);
    }
  }


  Future<bool> _authenticateUserIfRequired() async {
    if (getBoolAsync(IS_PASS_LOCK_SET) ||
        getBoolAsync(IS_FINGERPRINT_LOCK_SET)) {
      return await authenticateUser(context);
    }
    return true;
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white, // ✅ White background
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Image.asset(
            ic_app_logo,
            width: context.width() * 0.5,
            height: context.height() * 0.5,
          ),
        ),
      ),
    );
  }

}
