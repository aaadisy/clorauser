import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/screens/user/pass_code_screen.dart';
import 'package:clora_user/utils/app_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../extensions/extensions.dart';
import '../../extensions/new_colors.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/biometric_utils.dart';
import 'package:local_auth/local_auth.dart';

class SecureAccessOptionsScreen extends StatefulWidget {
  final bool isFromDoctor;

  const SecureAccessOptionsScreen({super.key, required this.isFromDoctor});

  @override
  State<SecureAccessOptionsScreen> createState() =>
      _SecureAccessOptionsScreenState();
}

class _SecureAccessOptionsScreenState extends State<SecureAccessOptionsScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool isFingerPrint = false;

  @override
  void initState() {
    super.initState();
    logScreenView("Secure Access screen");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: kPrimaryColor,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                color: kPrimaryColor,
                child: Column(
                  children: [
                    // 10.height,
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            CupertinoIcons.back,
                            color: mainColorText,
                          ),
                        ),
                        Text(
                          language.secureAccess,
                          style: boldTextStyle(
                            size: textFontSize_18,
                            weight: FontWeight.w500,
                            color: mainColorText,
                          ),
                        ),
                      ],
                    ),
                    10.height,
                  ],
                ),
              ),
              // Scrollable Content
              Expanded(
                child: Container(
                  width: context.width(),
                  decoration: const BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        reminderCommon(
                          language.pin,
                          language.chooseAPin,
                          Switch(
                            value: getBoolAsync(IS_PASS_LOCK_SET),
                            onChanged: (value) async {
                              if (value) {
                                PassCodeScreen(
                                  isVerifyPin: false,
                                ).launch(context).then((value) {
                                  bool res = value;
                                  if (res) {
                                    setState(() {
                                      setValue(IS_PASS_LOCK_SET, true);
                                    });
                                  }
                                });
                              } else {
                                setValue(IS_PASS_LOCK_SET, false);
                                setState(() {});
                              }
                            },
                          ),
                        ),
                        Divider(height: 0, color: grayColor),
                        reminderCommon(
                          language.fingerprintOrFaceRecognition,
                          language.fingerprintOrFaceRecognition,
                          Switch(
                            value: getBoolAsync(IS_FINGERPRINT_LOCK_SET),
                            onChanged: (value) {
                              if (value) {
                                if (!getBoolAsync(IS_PASS_LOCK_SET)) {
                                  toast(language
                                      .toSetFingerPrintAuthenticationFirstSetPinAuthentication);
                                } else {
                                  setFingerPrintAuthentication(value)
                                      .then((value) {
                                    setState(() {});
                                  });
                                }
                              } else {
                                setValue(IS_FINGERPRINT_LOCK_SET, false);
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
