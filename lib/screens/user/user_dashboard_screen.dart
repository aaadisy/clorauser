import 'dart:io';

import 'package:clora_user/ai/chat_screen.dart';
import 'package:clora_user/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:menstrual_cycle_widget/database_helper/menstrual_cycle_db_helper.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget.dart';
import 'package:menstrual_cycle_widget/ui/menstrual_log_period_view.dart';
import 'package:menstrual_cycle_widget/ui/model/display_symptoms_data.dart';
import '../../extensions/extensions.dart';
import '../../main.dart';
import '../../model/user/dashboard_response.dart';
import '../../network/rest_api.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import '../../utils/app_common.dart';
import '../../utils/app_constants.dart';
import '../../utils/dynamic_theme.dart';
import '../../utils/navigation_utils.dart';
import '../screens.dart';
import '../shop_webview_screen.dart';
import '../consult/consult_now_screen.dart' as consult;
import '../../store/userStore/user_store.dart';


class DashboardScreen extends StatefulWidget {
  static String tag = '/DashboardScreen';

  int currentIndex;
  final String? token;

  DashboardScreen({required this.currentIndex, this.token});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  List<SymptomsCategory> mSymptomsCategory = [];
  bool isSuccess = false;
  bool _isDataLoaded = false;

  onSuccess() {
    appStore.setHomeScreenUpdated(true);
  }

  onError() {
    log("onError");
  }

  final List<Widget> tab = [
    HomeScreen(),
    consult.ConsultNowScreen(), // 👈 yaha add karo
    ShopWebViewScreen(),
    SettingScreen(),
  ];


  @override
  void initState() {
    super.initState();
    // Wait for userStore to confirm login before attempting API calls
    _checkLoginAndLoadData();
  }

  void _checkLoginAndLoadData() async {
    // Polling mechanism to wait for userStore login confirmation after immediate navigation
    if (!userStore.isLoggedIn) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        _checkLoginAndLoadData(); // Recurse
      }
    } else if (!_isDataLoaded) {
      // Only call if not already loaded and widget is mounted
      await AddSymptomsApiCall();
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  Future<bool> onWillPop() async {
    return await showDialog(
      context: context, // <-- FIXED: Added missing context argument
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(language.confirmExit),
          content: Text(language.AreYouSureYouWantToExit),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(language.cancel),
            ),
            TextButton(
              onPressed: () {
                pop();
                exit(0);
              },
              child: Text(language.exit),
            ),
          ],
        );
      },
    ) ??
        false;
  }

  Future<void> AddSymptomsApiCall() async {
    final isConnected = await isNetworkAvailable();
    if (!isConnected) {
      return null;
    } else {
      // Pass the token received during login to the API call
      List<Symptoms> SymptomsList = await AddSubSymptoms(token: widget.token);
      for (int i = 0; i < SymptomsList.length; i++) {
        List<SymptomsData> c = [];
        for (int index = 0;
        index < SymptomsList[i].subSymptoms!.length;
        index++) {
          c.add(SymptomsData(
              isSelected: false,
              symptomId: SymptomsList[i].subSymptoms![index].id,
              symptomName: SymptomsList[i].subSymptoms![index].title));
        }
        mSymptomsCategory.add(SymptomsCategory(
            categoryColor: SymptomsList[i].bgColor,
            categoryId: SymptomsList[i].id,
            categoryName: SymptomsList[i].title,
            isVisibleCategory: SymptomsList[i].subSymptoms != null &&
                SymptomsList[i].subSymptoms!.isNotEmpty
                ? 1
                : 0,
            symptomsData: c));
      }
    }
  }

  updateConfiguration() async {
    final String? prevPeriodDay = instance.getPreviousPeriodDay();
    final DateTime? prevPeriodDt = prevPeriodDay != null && prevPeriodDay != ""
        ? DateTime.parse(prevPeriodDay)
        : null;
    final DateTime? lastPeriodDate = (prevPeriodDt == null ||
        prevPeriodDt.isAtSameMomentAs(DateTime(1971, 1, 1)))
        ? null
        : prevPeriodDt;
    int cycleLength = getIntAsync(CYCLE_LENGTH);
    int periodLength = getIntAsync(PERIOD_LENGTH);

    if (cycleLength == 0) {
      cycleLength = DEFAULT_CYCLE_LENGTH;
      setValue(CYCLE_LENGTH, cycleLength);
    }

    if (periodLength == 0) {
      periodLength = DEFAULT_PERIOD_LENGTH;
      setValue(PERIOD_LENGTH, periodLength);
    }

    instance.updateConfiguration(
      cycleLength: cycleLength,
      periodDuration: periodLength,
      customerId: userStore.userId.toString(),
      lastPeriodDate: lastPeriodDate,
    );

    updateMenstrualWidgetLanguage();
  }

  Future<void> navigateToMenstrualLogPeriodView(bool isConnected) async {
    await NavigationUtils.navigateWithPostPopAction(
      context: context,
      screen: MenstrualLogPeriodView(
        displaySymptomsData: DisplaySymptomsData(),
        isShowCustomSymptomsOnly: true,
        customSymptomsList: mSymptomsCategory,
        onError: onError,
        onSuccess: (int id) {
          logAnalyticsEvent(category: "daily_symptoms", action: "logged");
          setState(() {
            isSuccess = true;
          });
        },
        symptomsLogDate: DateTime.now(),
      ),
      postPopAction: () async {
        if (isSuccess) {
          onSuccess();
          updateConfiguration();
        }
      },
      showRewardedAd: (appStore.adsConfig?.adsconfigAccess ?? false) &&
          (appStore.showAdsBasedOnConfig?.saveDailyLogs ?? false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) onWillPop();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        resizeToAvoidBottomInset: false,
        body: _getBody(widget.currentIndex),
        // Render the appropriate body based on currentIndex
        floatingActionButton: Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF6FB5),
                Color(0xFFFF3D8E),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () {
                AiChatScreen().launch(context);
              },
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.6),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/home/clo_avatar.png",
                      height: 38,
                      width: 38,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: StylishBottomBar(
          backgroundColor: kPrimaryColor,
          hasNotch: true,
          notchStyle: NotchStyle.circle,
          elevation: 1,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          option: AnimatedBarOptions(iconStyle: IconStyle.Default),
          currentIndex: widget.currentIndex,
          fabLocation: StylishBarFabLocation.center,
          onTap: (index) async {

            if (index == 1) {
              bool isConnected = await isNetworkAvailable();
              if (!isConnected) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(language.noInternetConnectionCannotAccessThisPage),
                    backgroundColor: ColorUtils.colorPrimary,
                  ),
                );
                return;
              }
            }

            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShopWebViewScreen(),
                ),
              );
              return;
            }

            setState(() {
              widget.currentIndex = index;
            });
          },


          items: [
            BottomBarItem(
              icon: const Icon(
                Icons.home_outlined,
                size: 26,
                color: Colors.black,
              ),
              selectedIcon: Icon(
                Icons.home_rounded,
                size: 26,
                color: ColorUtils.colorPrimary,
              ),
              title: Text(
                'Home',
                style: boldTextStyle(
                  size: textFontSize_12,
                  color: widget.currentIndex == 0
                      ? ColorUtils.colorPrimary
                      : Colors.black,
                ),
              ),
            ),

            BottomBarItem(
              icon: const Icon(
                Icons.medical_services_outlined,
                size: 26,
                color: Colors.black,
              ),
              selectedIcon: Icon(
                Icons.medical_services,
                size: 26,
                color: ColorUtils.colorPrimary,
              ),
              title: Text(
                'Consult',
                style: boldTextStyle(
                  size: textFontSize_12,
                  color: widget.currentIndex == 1
                      ? ColorUtils.colorPrimary
                      : Colors.black,
                ),
              ),
            ),

            BottomBarItem(
              icon: const Icon(
                Icons.shopping_bag_outlined,
                size: 26,
                color: Colors.black,
              ),
              selectedIcon: Icon(
                Icons.shopping_bag,
                size: 26,
                color: ColorUtils.colorPrimary,
              ),
              title: Text(
                'Shop',
                style: boldTextStyle(
                  size: textFontSize_12,
                  color: widget.currentIndex == 2
                      ? ColorUtils.colorPrimary
                      : Colors.black,
                ),
              ),
            ),

            BottomBarItem(
              icon: const Icon(
                Icons.person_outline,
                size: 26,
                color: Colors.black,
              ),
              selectedIcon: Icon(
                Icons.person,
                size: 26,
                color: ColorUtils.colorPrimary,
              ),
              title: Text(
                'Profile',
                style: boldTextStyle(
                  size: textFontSize_12,
                  color: widget.currentIndex == 3
                      ? ColorUtils.colorPrimary
                      : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Helper method to return the appropriate body based on the currentIndex
  Widget _getBody(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return tab[0];
      case 1:
        return tab[1];
      case 2:
        return tab[2];
      case 3:
        return tab[3];
      default:
        return tab[0];
    }
  }
}