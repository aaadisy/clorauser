import 'package:clora_user/model/user/dashboard_response.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget.dart';
import 'package:mobx/mobx.dart';

import '../extensions/colors.dart';
import '../extensions/constants.dart';
import '../extensions/decorations.dart';
import '../extensions/shared_pref.dart';
import '../languageConfiguration/AppLocalizations.dart';
import '../languageConfiguration/LanguageDataConstant.dart';
import '../main.dart';
import '../model/user/question_model.dart';
import '../utils/app_config.dart';
import '../utils/app_constants.dart';
import '../utils/dynamic_theme.dart';

part 'app_store.g.dart';

class AppStore = AppStoreBase with _$AppStore;

abstract class AppStoreBase with Store {
  @observable
  bool isLoading = false;

  @observable
  String selectedLanguage = '';

  @observable
  QuestionsModel? questionModel;

  @observable
  bool isHomeScreenUpdated = false;

  @observable
  String themeColor = '0xff00000';

  @observable
  String supportEmail = '';

  @observable
  String supportUrl = '';

  @observable
  String supportContact = '';

  @observable
  String siteDescription = "";

  @observable
  String facebookURL = "";

  @observable
  String instagramURL = "";

  @observable
  String twitterURL = "";

  @observable
  String linkedinURL = "";

  @observable
  String privacyPolicy = "";

  @observable
  String termsCondition = '';

  @observable
  String currencySymbol = '';

  @observable
  String currencyCode = '';

  @observable
  String currencyPosition = '';

  @observable
  String oneSignalAppID = '';

  @observable
  String onesignalRestApiKey = '';

  @observable
  String admobBannerId = '';

  @observable
  String admobInterstitialId = '';

  @observable
  String admobBannerIdIos = '';

  @observable
  String admobInterstitialIdIos = '';

  @observable
  String chatGptApiKey = '';

  @observable
  bool subscriptionStatus = false;

  @observable
  bool askExpertStatus = false;

  @observable
  bool dummyDataStatus = false;

  @observable
  AdsConfiguration? adsConfig = null;

  @observable
  ShowAdsBasedOnConfig? showAdsBasedOnConfig = null;

  @action
  Future<void> setShowAdsBasedOnConfig(ShowAdsBasedOnConfig configuration,
      {bool isInitialization = false}) async {
    showAdsBasedOnConfig = configuration;
  }

  @action
  Future<void> setFacebookAdsConfiguration(AdsConfiguration newAdsConfig,
      {bool isInitialization = false}) async {
    adsConfig = newAdsConfig;
  }

  @action
  Future<void> setTermsCondition(String val,
      {bool isInitialization = false}) async {
    termsCondition = val;
    if (!isInitialization) await setValue(TermsCondition, val);
  }

  @action
  Future<void> setCurrencyCodeID(String val,
      {bool isInitialization = false}) async {
    currencySymbol = val;
    if (!isInitialization) await setValue(CurrencySymbol, val);
  }

  @action
  Future<void> setCurrencyCode(String val,
      {bool isInitialization = false}) async {
    currencyCode = val;
    if (!isInitialization) await setValue(CurrencyCode, val);
  }

  @action
  Future<void> setCurrencyPositionID(String val,
      {bool isInitialization = false}) async {
    currencyPosition = val;
    if (!isInitialization) await setValue(CurrencyPosition, val);
  }

  @action
  Future<void> setOneSignalAppID(String val,
      {bool isInitialization = false}) async {
    oneSignalAppID = val;
    if (!isInitialization) await setValue(mOneSignalAppId, val);
  }

  @action
  Future<void> setOnesignalRestApiKey(String val,
      {bool isInitialization = false}) async {
    onesignalRestApiKey = val;
    if (!isInitialization) await setValue(mOneSignalRestKey, val);
  }

  @action
  Future<void> setSubscriptionStatus(bool val,
      {bool isInitialization = false}) async {
    subscriptionStatus = val;
  }

  @action
  Future<void> setAskExpertStatus(bool val,
      {bool isInitialization = false}) async {
    askExpertStatus = val;
  }

  @action
  Future<void> setDummyDataStatusStatus(bool val,
      {bool isInitialization = false}) async {
    dummyDataStatus = val;
  }

  @action
  Future<void> setAdmobBannerId(String val,
      {bool isInitialization = false}) async {
    admobBannerId = val;
    if (!isInitialization) await setValue(AdmobBannerId, val);
  }

  @action
  Future<void> setAdmobInterstitialId(String val,
      {bool isInitialization = false}) async {
    admobInterstitialId = val;
    if (!isInitialization) await setValue(AdmobInterstitialId, val);
  }

  @action
  Future<void> setAdmobBannerIdIos(String val,
      {bool isInitialization = false}) async {
    admobBannerIdIos = val;
    if (!isInitialization) await setValue(AdmobBannerIdIos, val);
  }

  @action
  Future<void> setAdmobInterstitialIdIos(String val,
      {bool isInitialization = false}) async {
    admobInterstitialIdIos = val;
    if (!isInitialization) await setValue(AdmobInterstitialIdIos, val);
  }

  @action
  Future<void> setChatGptApiKey(String val,
      {bool isInitialization = false}) async {
    chatGptApiKey = val;
    if (!isInitialization) await setValue(ChatGptApiKey, val);
  }

  @action
  void setHomeScreenUpdated(bool value) {
    isHomeScreenUpdated = value;
  }

  @observable
  MenstrualCycleTheme cycleTheme = MenstrualCycleTheme.arcs;

  @action
  Future<void> setMenstrualCycleTheme(MenstrualCycleTheme value) async {
    cycleTheme = value;
    await setValue(MENSTRUAL_CYCLE_THEME, value.toString().split('.').last);
  }

  @observable
  PhaseTextBoundaries phaseText = PhaseTextBoundaries.outside;

  @action
  Future<void> setPhaseTextBoundaries(PhaseTextBoundaries value) async {
    phaseText = value;
    await setValue(PHASE_TEXT_BOUNDARIES, value.toString().split('.').last);
  }

  @observable
  MenstrualCycleViewType viewText = MenstrualCycleViewType.text;

  @action
  Future<void> setMenstrualCycleViewType(MenstrualCycleViewType value) async {
    viewText = value;
    await setValue(PHASE_TEXT_BOUNDARIES, value.toString().split('.').last);
  }

  @action
  void setLoading(bool val) => isLoading = val;

  @action
  Future<void> setSupportEmail(String email,
      {bool isInitialization = false}) async {
    supportEmail = email;
    if (!isInitialization) await setValue(CONTACT_EMAIL, supportEmail);
  }

  @action
  Future<void> setSupportUrl(String url,
      {bool isInitialization = false}) async {
    supportUrl = url;
    if (!isInitialization) await setValue(HELP_SUPPORT, supportUrl);
  }

  @action
  Future<void> setSupportContact(String contact,
      {bool isInitialization = false}) async {
    supportContact = contact;
    if (!isInitialization) await setValue(CONTACT_NUMBER, supportContact);
  }

  @action
  Future<void> setSiteDescription(String desc,
      {bool isInitialization = false}) async {
    siteDescription = desc;
    if (!isInitialization) await setValue(SITE_DESCRIPTION, siteDescription);
  }

  @action
  Future<void> setFacebookURL(String url,
      {bool isInitialization = false}) async {
    facebookURL = url;
    if (!isInitialization) await setValue(FACEBOOK_URL, facebookURL);
  }

  @action
  Future<void> setInstagramURL(String url,
      {bool isInitialization = false}) async {
    instagramURL = url;
    if (!isInitialization) await setValue(INSTAGRAM_URL, instagramURL);
  }

  @action
  Future<void> setTwitterURL(String url,
      {bool isInitialization = false}) async {
    twitterURL = url;
    if (!isInitialization) await setValue(TWITTER_URL, twitterURL);
  }

  @action
  Future<void> setLinkedInURL(String url,
      {bool isInitialization = false}) async {
    linkedinURL = url;
    if (!isInitialization) await setValue(LINKED_URL, linkedinURL);
  }

  @action
  Future<void> setPrivacyPolicy(String val,
      {bool isInitialization = false}) async {
    privacyPolicy = val;
    if (!isInitialization) await setValue(PrivacyPolicy, val);
  }

  @action
  Future<void> setLanguage(String aCode, {BuildContext? context}) async {
    setDefaultLocate();
    selectedLanguage = aCode;
    language = (await AppLocalizations().load(Locale(selectedLanguage)));
    if (context != null) {
      (context as Element).markNeedsBuild();
    }
  }

  @action
  Future<void> setQuestionModel(QuestionsModel questionsModel) async {
    questionModel = questionsModel;
  }

  @action
  Future<void> setThemeColor(String val) async {
    themeColor = val;
  }

  @observable
  ThemeData lightTheme = ThemeData(
    primarySwatch: createMaterialColor(ColorUtils.colorPrimary),
    primaryColor: ColorUtils.colorPrimary,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: GoogleFonts.poppins().fontFamily,
    iconTheme: IconThemeData(color: Colors.black),
    unselectedWidgetColor: Colors.grey,
    dividerColor: dividerColor,
    cardColor: Colors.white,
    tabBarTheme: TabBarThemeData(labelColor: Colors.black),
    dialogTheme: DialogThemeData(shape: dialogShape()),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),
    colorScheme: ColorScheme.light(
      primary: ColorUtils.colorPrimary,
    ),
  ).copyWith(
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  @observable
  ThemeData darkTheme = ThemeData(
    primarySwatch: createMaterialColor(ColorUtils.colorPrimary),
    primaryColor: ColorUtils.colorPrimary,
    scaffoldBackgroundColor: ColorUtils.scaffoldColorDark,
    fontFamily: GoogleFonts.lato().fontFamily,
    iconTheme: IconThemeData(color: Colors.white),
    unselectedWidgetColor: Colors.white60,
    dividerColor: Colors.white12,
    cardColor: ColorUtils.scaffoldSecondaryDark,
    tabBarTheme: TabBarThemeData(labelColor: Colors.white),
    dialogTheme: DialogThemeData(shape: dialogShape()),
    snackBarTheme:
        SnackBarThemeData(backgroundColor: ColorUtils.appButtonColorDark),
    bottomSheetTheme:
        BottomSheetThemeData(backgroundColor: ColorUtils.appButtonColorDark),
    colorScheme: ColorScheme.dark(
      primary: ColorUtils.colorPrimary,
    ),
  ).copyWith(
      pageTransitionsTheme: PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
      TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ));

  @action
  void updateTheme(Color newColor) {
    ColorUtils.updateColors(appStore.themeColor);
    lightTheme = ThemeData(
        useMaterial3: false,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        scaffoldBackgroundColor: whiteColor,
        primaryColor: ColorUtils.colorPrimary,
        iconTheme: IconThemeData(color: Colors.black),
        dividerColor: viewLineColor,
        colorScheme: ColorScheme(
          primary: ColorUtils.colorPrimary,
          secondary: ColorUtils.colorPrimary,
          surface: Colors.white,
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black,
          onError: Colors.redAccent,
          brightness: Brightness.light,
        ),
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(
              borderRadius: radius(20),
              side: BorderSide(width: 1, color: ColorUtils.colorPrimary)),
          checkColor: WidgetStateProperty.all(Colors.white),
          fillColor: WidgetStateProperty.all(ColorUtils.colorPrimary),
          materialTapTargetSize: MaterialTapTargetSize.padded,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ));

    darkTheme = ThemeData(
      primarySwatch: createMaterialColor(newColor),
      primaryColor: newColor,
      scaffoldBackgroundColor: ColorUtils.scaffoldColorDark,
      fontFamily: GoogleFonts.lato().fontFamily,
      iconTheme: IconThemeData(color: Colors.white),
      unselectedWidgetColor: Colors.white60,
      dividerColor: Colors.white12,
      cardColor: ColorUtils.scaffoldSecondaryDark,
      tabBarTheme: TabBarThemeData(labelColor: Colors.white),
      dialogTheme: DialogThemeData(shape: dialogShape()),
      snackBarTheme:
          SnackBarThemeData(backgroundColor: ColorUtils.appButtonColorDark),
      bottomSheetTheme:
          BottomSheetThemeData(backgroundColor: ColorUtils.appButtonColorDark),
      colorScheme: ColorScheme.dark(
        primary: newColor,
      ),
    ).copyWith(
        pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ));
  }
}
