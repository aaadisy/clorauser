import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
// ASSUMING NECESSARY IMPORTS FOR STREAM & MOBX ARE HERE OR GLOBALLY ACCESSIBLE
// import 'package:stream_chat_flutter/stream_chat_flutter.dart';
// import 'package:stream_video_flutter/stream_video_flutter.dart' as stream_video;

import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:clora_user/network/rest_api.dart';
import '../main.dart';
import '../screens/user/user_dashboard_screen.dart';
import '../screens/onboarding/fu_style_question_screen.dart';
import '../model/user/question_model.dart';
import '../utils/app_constants.dart';
import '../utils/app_common.dart';
import '../extensions/shared_pref.dart'; // Explicitly import shared_pref for setValue
import '../store/userStore/user_store.dart'; // Explicitly import userStore


Future<void> handleFirebaseLogin({
  required BuildContext context,
  required String uid,
  String? email,
  String? phone,
  String? name,
}) async {

  var res = await firebaseLoginApi({
    "firebase_uid": uid,
    "email": email,
    "phone": phone,
    "name": name,
  });

  /// 🔥 IMPORTANT: Correct response parsing
  final responseData = res['responseData'];

  if (responseData != null && responseData['status'] == true) {

    final userData = responseData['data'];
    final userType = userData['user_type'];

    if (userType != null) {
      await setValue(USER_TYPE, userType);
    }

    appStore.setLoading(true);
    log("🟢 [AUTH_FLOW] Processing firebase login response");

    final String? apiToken = userData['api_token'];
    final String? userIdStr = userData['id']?.toString();

    /// 🔥 FIXED: correct path
    final String profileCompleted =
        responseData['profile_completed']?.toString() ?? "0";

    log("🟡 Profile Completed: $profileCompleted");

    if (userData['status'] == statusActive &&
        apiToken != null &&
        userIdStr != null) {

      /// ✅ SAVE TOKEN PROPERLY
      await setValue(TOKEN, apiToken);
      userStore.setLogin(true);
      userStore.setUserID(int.parse(userIdStr));
      userStore.setToken(apiToken);

      /// ⚠️ IMPORTANT: set login AFTER validation
      await setValue(IS_LOGIN, true);

      await Future.delayed(const Duration(milliseconds: 200));

      /// 🔥 NAVIGATION LOGIC
      if (profileCompleted == "0") {
        log("➡️ Navigating to OnBoardingScreen");

        AiOnboardingScreen().launch(context, isNewTask: true);
      } else {
        log("➡️ Navigating to Dashboard");

        DashboardScreen(currentIndex: 0, token: apiToken)
            .launch(context, isNewTask: true);
      }

    } else {
      toast(userData['message'] ??
          "Login failed with status: ${userData['status']}");
    }

    appStore.setLoading(false);

  } else {
    toast(res['message'] ?? "Firebase Login failed.");
    appStore.setLoading(false);
  }
}