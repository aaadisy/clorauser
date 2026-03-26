import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/string_extensions.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/main.dart';
import 'package:clora_user/screens/onboarding/fu_style_question_screen.dart';
import 'package:clora_user/screens/user/sign_in_screen.dart';
import 'package:clora_user/utils/app_common.dart';
import 'package:clora_user/utils/app_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../../extensions/new_colors.dart';
import '../../model/user/question_model.dart';
import '../../utils/dynamic_theme.dart';
import '../../utils/app_images.dart';

class QuestionsListScreen extends StatefulWidget {
  @override
  State<QuestionsListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionsListScreen> {
  
  @override
  void initState() {
    super.initState();
    log("QuestionsListScreen: Inert. If navigated here, flow should resume from Splash.");
  }

  @override
  Widget build(BuildContext context) {
    // Return an inert container to prevent further navigation, allowing splash screen logic to take over.
    return Container(
      color: Colors.transparent,
    );
  }
}