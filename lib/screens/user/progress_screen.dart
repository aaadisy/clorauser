import 'dart:async';

import 'package:clora_user/extensions/extension_util/date_time_extensions.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/screens/common/no_internet_screen.dart';
import 'package:flutter/material.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/new_colors.dart';
import '../../main.dart';
import '../../model/user/question_model.dart';
import '../../network/rest_api.dart';
import '../../utils/dynamic_theme.dart';
import '../../utils/utils.dart';
import 'user_dashboard_screen.dart';

class ProgressScreen extends StatefulWidget {
  static String tag = '/NameFillupScreen';

  @override
  ProgressScreenState createState() => ProgressScreenState();
}

class ProgressScreenState extends State<ProgressScreen> {
  double _percent = 0.0;

  @override
  void initState() {
    super.initState();
    initializeApp();
    logScreenView("Progress screen");
  }

  Future<void> initializeApp() async {
    final isConnected = await isNetworkAvailable();
    if (!isConnected) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => NoInternetScreen()),
          );
        });
      }
      return;
    }

    _startAnimation();
    await registerApiCall();
  }

  /// Start the progress update and API call together
  void _startAnimation() {
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        _percent += 0.01;
        if (_percent >= 1.0) {
          _percent = 1.0;
          timer.cancel();
        }
      });
    });
  }

  /// Update MenstrualCycleWidget Config
  updateConfiguration() {
    try {
      Map<String, dynamic> map = getJSONAsync(KEY_QUESTION_DATA);
      QuestionsModel questionsModelData = QuestionsModel.fromJson(map);
      final instance = MenstrualCycleWidget.instance!;
      DateTime? lastPeriodDate;
      if (questionsModelData.step3.selectedLastPeriodDate!.isNotEmpty) {
        lastPeriodDate =
            DateTime.parse(questionsModelData.step3.selectedLastPeriodDate!);
      } else {
        lastPeriodDate = null;
      }
      instance.updateConfiguration(
          cycleLength: questionsModelData.step4.selectedOption,
          periodDuration: questionsModelData.step5.selectedOption,
          customerId: userStore.userId.toString(),
          lastPeriodDate: lastPeriodDate);

      updateMenstrualWidgetLanguage();
    } catch (e) {
      log("instance.updateConfiguration    ${e}");
      throw e;
    }
  }

  /**
   * api call for registration
   */
  Future<void> registerApiCall() async {
    String dateTimeString = generateDateTimeString();
    String randomLastName = generateRandomBirdPassword();
    String randomEmail =
        '${randomLastName.trim().replaceAll(" ", "")}$dateTimeString@nomail.com';
    String randomPassword = generateRandomString(8);
    Map<String, dynamic> map = getJSONAsync(KEY_QUESTION_DATA);
    final String fullName =
        questionsModel.step7.answerToQuestion1 ?? "Anonymous";
    final List<String> nameParts = fullName.trim().split(' ');
    final String firstName =
        nameParts.isNotEmpty ? nameParts.first : "Anonymous";
    final String lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : randomLastName;
    final int age = questionsModel.step7.answerToQuestion2?.isNotEmpty == true
        ? getCurrentAgeFromYear(
            int.tryParse(questionsModel.step7.answerToQuestion2!)!)
        : 0;

    QuestionsModel questionsModelData = QuestionsModel.fromJson(map);
    Map<String, dynamic> req;
    req = {
      "first_name": firstName,
      "last_name": lastName,
      "age": age,
      "email": randomEmail,
      "password": randomPassword,
      "goal_type": questionsModelData.step1.selectedOption == -1
          ? 0
          : questionsModelData.step1.selectedOption,
      "user_type": "anonymous_user",
      "period_start_date":
          questionsModelData.step3.selectedLastPeriodDate.isEmptyOrNull
              ? getDateTimeString(DateTime.now())
              : questionsModelData.step3.selectedLastPeriodDate.toString(),
      "cycle_length": questionsModelData.step4.selectedOption,
      "period_length": questionsModelData.step5.selectedOption,
      "luteal_phase": questionsModelData.step6.selectedOption != -1
          ? questionsModelData.step6.selectedOption
          : 0
    };

    final registerResult = await registerApi(req);

    registerResult.fold(
      (errorResponse) {},
      (userModel) async {
        userStore
          ..setLogin(true)
          ..setUserID(userModel.id!)
          ..setUserPassword(randomPassword)
          ..setLoginUsertype(ANONYMOUS)
          ..setUserModelData(userModel)
          ..setToken(userModel.apiToken.validate());

        // Save data to local storage
        saveUserToLocalStorage(userModel);
        setValue(TOKEN, userModel.apiToken.validate());
        setValue(LASTNAME, userModel.lastName);
        setValue(PASSWORD, randomPassword);
        setValue(IS_USER_SIGNED_UP, true);

        updateConfiguration();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: mainColorLight,
            pinned: true,
            title: null,
            expandedHeight: 0,
            elevation: 0,
            surfaceTintColor: mainColorLight,
            forceElevated: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Transform.translate(
                  offset: Offset(0, -30),
                  child: Container(
                    width: context.width(),
                    height: context.height() * 0.8,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('${language.progressScreenMainText}.',
                                    style: boldTextStyle(
                                        size: 16, weight: FontWeight.w400),
                                    textAlign: TextAlign.start)
                                .paddingOnly(top: 30),
                            SizedBox(height: context.height() * 0.13),
                            Center(
                              child: CircularPercentIndicator(
                                radius: 70,
                                lineWidth: 12,
                                animation: false,
                                percent: _percent,
                                backgroundColor: Colors.grey,
                                animationDuration: 10,
                                progressColor: primaryColor,
                                circularStrokeCap: CircularStrokeCap.round,
                                center: Text(
                                  "${(_percent * 100).toInt()}%",
                                  style: boldTextStyle(
                                      size: 18,
                                      weight: FontWeight.w500,
                                      color: mainColorText),
                                ),
                                footer: Text(
                                        '${language.personalizeYourExperience}...',
                                        style: boldTextStyle(
                                            size: 16,
                                            weight: FontWeight.w400,
                                            color: mainColorText))
                                    .paddingOnly(top: 48),
                              ),
                            ),
                            16.height,
                          ],
                        ).paddingAll(16),
                        Spacer(),
                        if (_percent >= 1.0)
                          SizedBox(
                            width: context.width(),
                            child: AppButton(
                              elevation: 0,
                              disabledColor: ColorUtils.colorPrimary,
                              color: mainColor,
                              width: context.width() * 0.4,
                              text: language.continueText,
                              onTap: () async {
                                try {
                                  await setValue(USER_TYPE, ANONYMOUS);
                                  userStore.setLoginUsertype(ANONYMOUS);
                                  await setValue(IS_LOGIN, true);
                                  DashboardScreen(
                                    currentIndex: 0,
                                  ).launch(context, isNewTask: true);
                                } catch (e) {
                                  log("Error::: ${e}");
                                }
                              },
                            ),
                          ).paddingSymmetric(horizontal: 16),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
