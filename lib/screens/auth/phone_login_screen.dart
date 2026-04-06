import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:clora_user/service/firebase_auth_service.dart';
import '../../service/auth_flow_service.dart';
import 'otp_screen.dart';
import 'package:clora_user/utils/app_images.dart';
import 'package:clora_user/utils/app_common.dart'; // 🔥 for toast
import 'package:clora_user/utils/app_constants.dart';
import 'package:clora_user/store/userStore/user_store.dart';
import 'package:clora_user/network/rest_api.dart';
import 'package:clora_user/main.dart';
import 'package:clora_user/extensions/shared_pref.dart';

import 'dart:ui';

class PhoneLoginScreen extends StatefulWidget {
  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: _bgCircle(Colors.pink.shade200),
          ),
          Positioned(
            bottom: -120,
            right: -50,
            child: _bgCircle(Colors.pink.shade400),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios_new),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Image.asset(
                      ic_logo,
                      height: 140,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    "Enter your phone",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "We’ll send you a verification code",
                    style: TextStyle(color: Colors.black54),
                  ),

                  const SizedBox(height: 40),

                  /// 📱 PHONE FIELD
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text("+91",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: "Enter mobile number",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  /// 🚀 BUTTON
                  GestureDetector(
                    onTap: () async {
                      final phone = phoneController.text.trim();

                      if (phone.isEmpty || phone.length < 10) {
                        toast("Enter valid phone number");
                        return;
                      }

                      await _authService.sendOtp(
                        phone: phone,

                        /// 🔥 OTP SCREEN FLOW
                        onCodeSent: (verificationId) {
                          print("🔥 OTP SENT, ID: $verificationId");

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OtpScreen(
                                verificationId: verificationId,
                                phone: phone, // 🔥 pass phone
                              ),
                            ),
                          );
                        },

                        /// 🔥 AUTO LOGIN FLOW (IMPORTANT FIX)
                        onAutoLogin: (user) async {
                          print("⚡ AUTO LOGIN SUCCESS");

                          await handleFirebaseLogin(
                            context: context,
                            uid: user.uid,
                            phone: user.phoneNumber,
                            email: user.email,
                            name: user.displayName,
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.pink.shade500,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bgCircle(Color color) {
    return Container(
      height: 220,
      width: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.4),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: Container(),
      ),
    );
  }
}
