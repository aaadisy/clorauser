import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'package:clora_user/widgets/animated_marble_background.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/string_extensions.dart';
import 'package:clora_user/utils/app_images.dart';
import 'package:clora_user/utils/app_common.dart';
import 'package:clora_user/utils/app_constants.dart';
import 'package:clora_user/network/rest_api.dart';
import 'package:clora_user/main.dart';

import '../onboarding/fu_style_question_screen.dart';
import 'forgot_password_screen.dart';
import '../user/user_dashboard_screen.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart' as stream_video;
class UserSignInScreen extends StatefulWidget {
  const UserSignInScreen({super.key});

  @override
  State<UserSignInScreen> createState() => _UserSignInScreenState();
}

class _UserSignInScreenState extends State<UserSignInScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode passFocus = FocusNode();

  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    appStore.setLoading(false);
    logScreenView("SignIn screen");
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passFocus.dispose();
    super.dispose();
  }

  Future<void> loginApi(
      {bool? isFormAutoValid, String? email, String? password}) async {

    hideKeyboard(context);
    passFocus.unfocus();
    emailFocus.unfocus();

    bool isValid = isFormAutoValid ?? formKey.currentState!.validate();
    if (!isValid) return;

    Map<String, dynamic> req = {
      'email': email,
      'user_type': "app_user",
      'password': password,
    };

    appStore.setLoading(true);

    await logInAsUserApi(req).then((value) async {

      if (value.status == false) {
        toast(value.message);
        appStore.setLoading(false);
        return;
      }

      if (value.data!.status == statusActive) {

        setValue(TOKEN, value.data!.apiToken);
        userStore.setLogin(true);
        userStore.setUserID(value.data!.id!);
        userStore.setToken(value.data!.apiToken.validate());
        await setValue(IS_LOGIN, true);

        // 🔥 CONNECT STREAM CHAT HERE
        if (value.data!.streamToken != null) {

          await client.connectUser(
            User(
              id: value.data!.id.toString(),
              name: value.data!.displayName ??
                  "${value.data!.firstName ?? ""} ${value.data!.lastName ?? ""}".trim(),
              image: value.data!.profileImage,
            ),
            value.data!.streamToken!,
          );

          streamVideo = stream_video.StreamVideo(
            'krvywb83mwjv',
            user: stream_video.User.regular(
              userId: value.data!.id.toString(),
              name: value.data!.displayName ?? "",
              image: value.data!.profileImage,
            ),
            userToken: value.data!.streamToken!,
          );




        }



        DashboardScreen(currentIndex: 0).launch(context);
      }


      appStore.setLoading(false);

    }).catchError((e) {
      appStore.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedMarbleBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
                  child: Container(
                    width: 350,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.30),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.25),
                          blurRadius: 50,
                          offset: const Offset(0, 25),
                        ),
                      ],
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          Image.asset(ic_logo, height: 70),

                          const SizedBox(height: 20),

                          Text(
                            language.welcomeBack,
                            style: boldTextStyle(
                              size: 24,
                              color: Colors.pink.shade700,
                            ),
                          ),

                          const SizedBox(height: 35),

                          _glassInput(
                            controller: emailController,
                            hint: language.email,
                          ),

                          const SizedBox(height: 22),

                          _glassInput(
                            controller: passwordController,
                            hint: language.password,
                            isPassword: true,
                          ),

                          const SizedBox(height: 35),

                          /// 💗 LOGIN BUTTON (Bright Pink)
                          GestureDetector(
                            onTap: () {
                              loginApi(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              );
                            },
                            child: Container(
                              height: 56,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF5DA2),
                                    Color(0xFFFF2E8A),
                                  ],
                                ),
                                borderRadius:
                                BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pink.withOpacity(0.5),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  language.login,
                                  style: boldTextStyle(
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      FuStyleQuestionScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Don't have an account? Sign Up",
                              style: boldTextStyle(
                                color: Colors.pink.shade700,
                                size: 14,
                              ),
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              language.forgotPassword,
                              style: primaryTextStyle(
                                color: Colors.pink.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Observer(
        builder: (_) =>
        appStore.isLoading ? Loader() : const SizedBox(),
      ),
    );
  }

  Widget _glassInput({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword && !_passwordVisible,
            style: TextStyle(
              color: Colors.pink.shade800,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.pink.shade400,
              ),
              border: InputBorder.none,
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  _passwordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.pink.shade600,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible =
                    !_passwordVisible;
                  });
                },
              )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
