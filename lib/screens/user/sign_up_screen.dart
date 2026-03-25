import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream_chat_flutter;

import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/date_time_extensions.dart';
import '../../extensions/extensions.dart';
import '../../main.dart';
import '../../model/user/question_model.dart';
import '../../network/rest_api.dart';
import '../../utils/app_common.dart';
import '../../utils/app_constants.dart';
import '../screens.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await proceedToRegisterApiCall();
  }

  // ================= STREAM CHAT CONNECTION HELPER (APPLIED USER LOGIC) =================
  Future<void> connectUserToStreamChat(int userId, String userName) async {
    final userIdString = userId.toString();
    final streamChatClient = client; // Use global Stream Chat client

    // Only attempt to connect if a valid ID is present
    if (userStore.isLoggedIn && userId != 0) {
      try {
        final token = streamChatClient.devToken(userIdString).rawValue; // Using .rawValue as requested
        
        await streamChatClient.connectUser(
          stream_chat_flutter.User( // Use StreamChat's User class
            id: userIdString,
            name: userName,
            extraData: {
              'image': userStore.user?.profileImage,
            },
          ),
          token,
        );
        log("Stream Chat user connected successfully: $userId");
      } catch (e) {
        log("Stream connect failed: $e");
        // Logging the error, as chat failure shouldn't block user login
      }
    }
  }

  Future<void> proceedToRegisterApiCall() async {
    try {
      appStore.setLoading(true);
      final Map<String, dynamic> answers = getJSONAsync(KEY_QUESTION_DATA);

      final String email = answers['email'] ?? "";
      final String password = answers['password'] ?? "";
      final String name = answers['name'] ?? "";
      final String ageStr = answers['age'] ?? "0";
      final int age = int.tryParse(ageStr.toString()) ?? 0;

      final String goal = answers['goal'] ?? "";
      final int cycleLength = int.tryParse(answers['cycle_length']?.toString() ?? "28") ?? 28;
      final int painLevel = answers['pain_level'] ?? 5;

      // Map names to first and last name
      List<String> nameParts = name.split(" ");
      String firstName = nameParts.isNotEmpty ? nameParts[0] : "User";
      String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "Clora";
      String displayName = "$firstName $lastName";

      final req = {
        "first_name": firstName,
        "last_name": lastName,
        "age": age,
        "email": email,
        "password": password,
        "goal_type": goal,
        "user_type": "app_user",
        "period_start_date": getDateTimeString(DateTime.now()),
        "cycle_length": cycleLength,
        "period_length": 5, // Default or extracted from symptoms
        "luteal_phase": 14, // Default
      };

      final registerResult = await registerApi(req);

      registerResult.fold(
        (errorResponse) {
          toast(errorResponse.message ?? "Registration failed");
          finish(context); // Go back to onboarding if failed
        },
        (userModel) async {
          userStore
            ..setLogin(true)
            ..setUserModelData(userModel)
            ..setUserID(userModel.id!)
            ..setUserPassword(password)
            ..setLoginUsertype(APP_USER)
            ..setToken(userModel.apiToken!);

          saveUserToLocalStorage(userModel);
          setValue(TOKEN, userModel.apiToken);
          setValue(PASSWORD, password);
          setValue(IS_LOGIN, true);

          // --- NEW STREAM CHAT CONNECTION ---
          if (userModel.id != null) {
            await connectUserToStreamChat(userModel.id!, displayName);
          }

          DashboardScreen(currentIndex: 0).launch(context, isNewTask: true);
        },
      );
    } catch (e) {
      toast(e.toString());
      finish(context);
    } finally {
      appStore.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (context) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (appStore.isLoading) ...[
                  Loader(),
                  16.height,
                  Text("Creating your account...", style: boldTextStyle()),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
