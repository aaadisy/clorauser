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

  if (res['status'] == true) {
    // Extracted data from firebaseLoginApi response will be used as context,
    // but primary navigation logic now relies on logInAsUserApi response ('value').
    final String? firebaseUserEmail = email; // Keep email for UserStore/Stream setup if needed later
    final String? firebaseUserId = uid; // Keep UID for Stream setup if needed later
    final userType = res['data']['user_type'];

    await setValue(IS_LOGIN, true); // Tentatively set login status true after firebase auth succeeded

    if (userType != null) {
        await setValue(USER_TYPE, userType); // Save user type
    }

    appStore.setLoading(true);
    log('\u001B[32m[AUTH_FLOW] Calling logInAsUserApi after successful Firebase auth...\u001B[39m'); // <-- ADDED LOG

    // Replicating logic from loginApi (sign_in_screen.dart) after successful Firebase auth
    await logInAsUserApi({
      "firebase_uid": uid,
      "email": email,
      "phone": phone,
      "name": name,
    }).then((value) async {

      if (value.status == false) {
        toast(value.message);
        appStore.setLoading(false);
        return;
      }

      if (value.data!.status == statusActive) {

        setValue(TOKEN, value.data!.apiToken);
        userStore.setLogin(true);
        userStore.setUserID(value.data!.id!);
        userStore.setToken(value.data!.apiToken!);
        await setValue(IS_LOGIN, true);

        // *** STREAM CHAT/VIDEO SETUP OMITTED ***
        // This part requires 'client', 'streamVideo', and 'User' imports 
        // which are not visible in auth_flow_service.dart imports.

        DashboardScreen(currentIndex: 0).launch(context, isNewTask: true);
      }

      appStore.setLoading(false);

    }).catchError((e) {
      appStore.setLoading(false);
    });

    // The original profile completion logic is now replaced by the above block.
  }
}