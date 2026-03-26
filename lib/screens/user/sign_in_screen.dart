import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/string_extensions.dart';
import 'package:clora_user/utils/app_images.dart';
import 'package:clora_user/utils/app_common.dart';
import 'package:clora_user/utils/app_constants.dart';
import 'package:clora_user/network/rest_api.dart';
import 'package:clora_user/main.dart';
import 'package:clora_user/service/firebase_auth_service.dart';
import 'package:clora_user/screens/auth/phone_login_screen.dart';
import '../onboarding/fu_style_question_screen.dart';
import '../user/user_dashboard_screen.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart' as stream_video;

class UserSignInScreen extends StatefulWidget {
  const UserSignInScreen({super.key});

  @override
  State<UserSignInScreen> createState() => _UserSignInScreenState();
}

class _UserSignInScreenState extends State<UserSignInScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    appStore.setLoading(false);
  }

  /// ================= LOGIN (UNCHANGED) =================
  Future<void> loginApi(
      {bool? isFormAutoValid, String? email, String? password}) async {

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

        if (value.data!.streamToken != null) {

          await client.connectUser(
            User(
              id: value.data!.id.toString(),
              name: value.data!.displayName ?? "",
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

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [

          /// 🔝 TOP (LESS EMPTY SPACE NOW)
          Expanded(
            flex: 65,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // 👈 pushes content down
                children: [

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Image.asset(
                      ic_logo,
                      width: double.infinity, // 👈 full width
                      height: 340,
                      fit: BoxFit.contain, // 👈 no stretch, clean scale
                    ),
                  ),

                  const SizedBox(height: 8),

                  Column(
                    children: [

                      /// 🔥 GRADIENT TITLE
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.black,
                            Colors.pink.shade400,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          "Welcome Back",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // required for shader
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// ✨ SUBTITLE
                      Text(
                        "Login to explore the journey of womanhood",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withOpacity(0.65),
                          height: 1.5,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // 👈 controlled spacing
                ],
              ),
            ),
          ),

          /// 🌸 BOTTOM (TIGHT + BALANCED)
          Expanded(
            flex: 45,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.pink.shade300,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      const SizedBox(height: 30),

                      _glassButton(
                        icon: Icons.phone_iphone,
                        text: "Login with Phone Number",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PhoneLoginScreen()),
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      _glassButton(
                        icon: Icons.g_mobiledata,
                        text: "Continue with Google",
                        onTap: () async {
                          if (appStore.isLoading) return;
                          appStore.setLoading(true);
                          try {
                            var user =
                            await _authService.signInWithGoogle();

                            if (user != null) {
                              String uid = user.uid;
                              String email = user.email ?? "";

                              var res = await firebaseLoginApi({
                                "firebase_uid": uid,
                                "email": email,
                              });

                              if (res['isNewUser'] == true) {
                                AiOnboardingScreen().launch(context);
                              } else {
                                DashboardScreen(currentIndex: 0)
                                    .launch(context);
                              }
                            }
                          } catch (e) {
                            toast("Google Sign-In Failed: ${e.toString()}");
                          } finally {
                            appStore.setLoading(false);
                          }
                        },
                      ),

                      const SizedBox(height: 14),

                      _glassButton(
                        icon: Icons.apple,
                        text: "Login via Apple ID",
                        onTap: () {},
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () {
                          AiOnboardingScreen().launch(context);
                        },
                        child: Text(
                          "Don't have an account? Sign Up",
                          style: boldTextStyle(
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Observer(
        builder: (_) =>
        appStore.isLoading ? Loader() : const SizedBox(),
      ),
    );
  }

  Widget _glassButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return _AnimatedGlassButton(
      icon: icon,
      text: text,
      onTap: onTap,
    );
  }






}

class _AnimatedGlassButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _AnimatedGlassButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  State<_AnimatedGlassButton> createState() => _AnimatedGlassButtonState();
}

class _AnimatedGlassButtonState extends State<_AnimatedGlassButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.96);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),

                /// 💎 GLASS LOOK
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.05),
                  ],
                ),

                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.2,
                ),
              ),

              child: Stack(
                alignment: Alignment.center,
                children: [

                  /// ✨ SHINE
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.icon, color: Colors.black),
                      const SizedBox(width: 12),
                      Text(
                        widget.text,
                        style: boldTextStyle(
                          size: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}