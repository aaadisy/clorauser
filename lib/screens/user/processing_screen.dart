
import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:clora_user/screens/screens.dart';
import 'package:clora_user/utils/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../extensions/shared_pref.dart';
import '../../main.dart';
import '../../model/user/question_model.dart';
import '../../network/rest_api.dart';
import '../../utils/app_common.dart';
import '../../utils/app_constants.dart';

class PleaseWaitScreen extends StatefulWidget {
  final int currentGoalType;

  const PleaseWaitScreen({super.key, required this.currentGoalType});

  @override
  State<PleaseWaitScreen> createState() => _PleaseWaitScreenState();
}

class _PleaseWaitScreenState extends State<PleaseWaitScreen> {
  QuestionsModel? questionsModelData;

  @override
  void initState() {
    super.initState();

    updateUserGoalStatus();
    logScreenView("GoalType process screen");
  }

  updateUserGoalStatus() async {
    if (getStringAsync(USER_TYPE) == ANONYMOUS) {
      Map<String, dynamic> map = getJSONAsync(KEY_QUESTION_DATA);
      questionsModelData = QuestionsModel.fromJson(map);
    } else {
      questionsModelData = QuestionsModel(
        step1: step1,
        step2: step2,
        step3: step3,
        step4: step4,
        step5: step5,
        step6: step6,
        step7: step7,
      );
    }
    Map req = {
      "id": userStore.userId,
      "goal_type": widget.currentGoalType,
    };
    await updateUserStatusApi(req).then(
      (value) {
        setValue(KEY_QUESTION_DATA, questionsModelData!.toJson());
        setValue(GOAL, widget.currentGoalType);
        userStore.setGoal(widget.currentGoalType);

        DashboardScreen(currentIndex: 0).launch(context, isNewTask: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
     canPop: false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [ColorUtils.colorPrimary, Color(0xFF6a1b9a)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Loading Indicator
                SpinKitFadingCircle(
                  color: Colors.white,
                  size: 80.0,
                ),
                30.height,
                // Text
                Text(
                  language.pleaseWait,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                10.height,
                Text(
                  language.weAreBuilding,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
