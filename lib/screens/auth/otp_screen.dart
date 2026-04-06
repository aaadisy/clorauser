import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:clora_user/service/firebase_auth_service.dart';
import '../../service/auth_flow_service.dart';

import 'package:clora_user/utils/app_images.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phone; // 🔥 ADD THIS

  OtpScreen({required this.verificationId, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with CodeAutoFill {
  final FirebaseAuthService _authService = FirebaseAuthService();

  List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());

  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  String otpCode = "";
  int seconds = 30;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    listenForCode();
    startTimer();
  }

  @override
  void dispose() {
    cancel();
    timer?.cancel();
    super.dispose();
  }

  /// 🔥 AUTO FILL
  @override
  void codeUpdated() {
    if (code != null && code!.length == 6) {
      setOtp(code!);
    }
  }

  void setOtp(String code) {
    for (int i = 0; i < 6; i++) {
      controllers[i].text = code[i];
    }
    otpCode = code;
  }

  /// ⏳ TIMER
  void startTimer() {
    seconds = 30;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (seconds == 0) {
        timer.cancel();
      } else {
        setState(() => seconds--);
      }
    });
  }

  /// 🔢 GET OTP
  String getOtp() {
    return controllers.map((e) => e.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// BACK
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back_ios_new),
                ),
              ),

              const SizedBox(height: 20),

              /// LOGO
              Image.asset(
                ic_logo,
                height: 120,
              ),

              const SizedBox(height: 30),

              Text(
                "Verify OTP",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Enter the 6-digit code",
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 40),

              /// 🔥 OTP BOXES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    child: TextField(
                      controller: controllers[index],
                      focusNode: focusNodes[index],
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      /// 🔥 AUTO MOVE
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              /// ⏳ RESEND
              seconds == 0
                  ? GestureDetector(
                      onTap: () async {
                        startTimer();
                        // TODO: call resend OTP
                      },
                      child: Text(
                        "Resend OTP",
                        style: TextStyle(
                          color: Colors.pink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Text("Resend in 00:$seconds"),

              const Spacer(),

              /// VERIFY BUTTON
              GestureDetector(
                onTap: () async {
                  String otp = getOtp();

                  if (otp.length < 6) {
                    print("❌ Invalid OTP");
                    return;
                  }

                  var user = await _authService.verifyOtp(
                    verificationId: widget.verificationId,
                    otp: otp,
                  );

                  if (user == null) {
                    print("❌ Firebase user null");
                    return;
                  }

                  /// 🔥 FINAL FIX (IMPORTANT)
                  await handleFirebaseLogin(
                    context: context,
                    uid: user.uid,
                    phone: user.phoneNumber,
                    email: user.email ?? "",
                    name: user.displayName ?? "User",
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
                      "Verify & Continue",
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
    );
  }
}
