import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart' as stream_video;

import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:clora_user/network/rest_api.dart';
import '../main.dart';
import '../screens/user/user_dashboard_screen.dart';
import '../screens/onboarding/fu_style_question_screen.dart';
import '../utils/app_constants.dart';
import '../utils/app_common.dart';
import '../extensions/shared_pref.dart';
import '../store/userStore/user_store.dart';

/// 🔥 MAIN LOGIN FUNCTION
Future<void> handleFirebaseLogin({
  required BuildContext context,
  required String uid,
  String? email,
  String? phone,
  String? name,
}) async {
  appStore.setLoading(true);

  var res = await firebaseLoginApi({
    "firebase_uid": uid,
    "email": email ?? "",
    "phone": phone ?? "",
    "name": name ?? "User",
  });

  final responseData = res['responseData'];

  if (responseData != null && responseData['status'] == true) {
    final userData = responseData['data'];

    final String? apiToken = userData['api_token'];
    final String? userIdStr = userData['id']?.toString();

    final String profileCompleted =
        responseData['profile_completed']?.toString() ?? "0";

    await setValue("PROFILE_COMPLETED", profileCompleted);

    if (userData['status'] == statusActive &&
        apiToken != null &&
        userIdStr != null) {
      /// ✅ SAVE TOKEN
      await setValue(TOKEN, apiToken);

      /// ✅ USER STORE
      userStore.setUserID(int.parse(userIdStr));
      userStore.setToken(apiToken);
      userStore.setLogin(true);

      await setValue(IS_LOGIN, true);

      /// 🔥 STREAM (NON-BLOCKING)
      connectStreamUserForce(userData);

      /// 🔥 NAVIGATION
      if (profileCompleted == "0") {
        AiOnboardingScreen().launch(context, isNewTask: true);
      } else {
        DashboardScreen(currentIndex: 0, token: apiToken)
            .launch(context, isNewTask: true);
      }
    } else {
      toast(userData['message'] ?? "Login failed");
    }
  } else {
    toast(res['message'] ?? "Firebase Login failed.");
  }

  appStore.setLoading(false);
}

/// 🔥 STREAM CONNECT (SAFE NON-BLOCKING)
Future<void> connectStreamUserForce(Map userData) async {
  print("🚀 STREAM CONNECT START");

  final token = userData['stream_token'];

  if (token == null || token.toString().isEmpty) {
    print("❌ STREAM TOKEN MISSING");
    return;
  }

  try {
    if (client.state.currentUser != null) return;

    await client.connectUser(
      User(
        id: userData['id'].toString(),
        name: userData['display_name'] ?? userData['first_name'] ?? "User",
        image: userData['profile_image'],
      ),
      token,
    );

    print("✅ STREAM CONNECTED");

    streamVideo = stream_video.StreamVideo(
      'krvywb83mwjv',
      user: stream_video.User.regular(
        userId: userData['id'].toString(),
        name: userData['display_name'] ?? userData['first_name'] ?? "User",
        image: userData['profile_image'],
      ),
      userToken: token,
    );
  } catch (e) {
    print("❌ STREAM ERROR: $e");
  }
}
