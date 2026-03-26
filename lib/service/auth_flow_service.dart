import 'dart:convert';
import 'dart:developer';

import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:flutter/material.dart';
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

  if (res['status'] == true) {
    final apiToken = res['data']['api_token'];
    final profileCompleted = res['profile_completed'].toString();
    final userId = res['data']['id'];
    final userType = res['data']['user_type'];
    
    // 1. Store Session/Token and Login Status
    if (apiToken != null) {
      await setValue(TOKEN, apiToken);
    }
    await setValue(IS_LOGIN, true);
    
    if (userType != null) {
        await setValue(USER_TYPE, userType); // Save user type
    }

    // 2. Update UserStore (Ensuring UserStore is updated before navigation)
    if (userId != null) {
      await userStore.setUserID(userId);
    }
    if (apiToken != null) {
        await userStore.setToken(apiToken);
    }
    if (email != null) {
        await userStore.setUserEmail(email);
    }


    // 3. Check profile completion status from API response
    log('\u001B[35m[AUTH_FLOW] API Response Received: ${jsonEncode(res)}\u001B[39m'); // <-- ADDED LOG
    log('\u001B[35m[AUTH_FLOW] profileCompleted Value: $profileCompleted (Type: ${profileCompleted.runtimeType})\u001B[39m'); // <-- ADDED LOG
    log('\u001B[35m[AUTH_FLOW] profileCompleted == \'0\' is ${profileCompleted == '0'}\u001B[39m'); // <-- ADDED LOG
    
    if (profileCompleted == '0') {
      // 👉 NEW/INCOMPLETE USER: Redirect to AiOnboardingScreen for setup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AiOnboardingScreen(isFromLogin: true),
        ),
      );
    } else if (profileCompleted == '1') {
      // 👉 COMPLETED USER: Redirect to DashboardScreen
      DashboardScreen(currentIndex: 0).launch(context, isNewTask: true);
    } else {
      // 👉 UNKNOWN STATUS: Treat as incomplete to force setup, or navigate to sign-in for re-auth
      log('\u001B[31m[AUTH_FLOW_ISSUE] Profile status is neither \'0\' nor \'1\': $profileCompleted. Forcing onboarding.\u001B[39m'); // <-- ADDED LOG
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AiOnboardingScreen(isFromLogin: true),
        ),
      );
    }

  }
}