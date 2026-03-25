import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/main.dart';
import 'package:clora_user/utils/app_common.dart';
import 'package:clora_user/utils/biometric_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../components/user/lockApp/existing_password_dialog.dart';
import '../../network/rest_api.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_images.dart';
import '../user/user_dashboard_screen.dart';

class PassCodeScreen extends StatefulWidget {
  static const String tag = '/PassCodeScreen';
  final bool isVerifyPin;
  final bool isResetPinFromEmail;

  PassCodeScreen({
    super.key,
    this.isVerifyPin = false,
    this.isResetPinFromEmail = false,
  });

  @override
  State<PassCodeScreen> createState() => _PassCodeScreenState();
}

class _PassCodeScreenState extends State<PassCodeScreen> {
  @override
  void initState() {
    super.initState();
    logScreenView("Passcode screen");
  }

  String enteredPin = '';
  String reEnteredPin = '';
  bool isPinVisible = true;
  bool isReEnterPin = false;

  void _handleNumberTap(int number) {
    setState(() {
      if (!isReEnterPin) {
        if (enteredPin.length < DEFAULT_PIN_LENGTH) {
          enteredPin += number.toString();
        }
        if (enteredPin.length == DEFAULT_PIN_LENGTH) {
          if (!getBoolAsync(IS_PASS_LOCK_SET) || !widget.isVerifyPin) {
            isReEnterPin = true;
          } else if (widget.isVerifyPin) {
            if (enteredPin.trim() == getStringAsync(USER_SECURITY_PIN)) {
              _navigateToNextScreen();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(language.pinDoesNotMatch),
                  duration: Duration(seconds: 1),
                ),
              );
              setState(() {
                enteredPin = "";
                reEnteredPin = "";
              });
              return;
            }
          }
        }
      } else {
        if (reEnteredPin.length < DEFAULT_PIN_LENGTH) {
          reEnteredPin += number.toString();
        }
        if (reEnteredPin.length == DEFAULT_PIN_LENGTH) {
          if (reEnteredPin == enteredPin) {
            _showConfirmDialog();
          } else {
            toast(language.passwordsDoNotMatch);
            reEnteredPin = '';
          }
        }
      }
    });
  }

  void _navigateToNextScreen() {
    final destination = getStringAsync(USER_TYPE) == Doctor
        ? DashboardScreen(currentIndex: 1)
        : DashboardScreen(currentIndex: 0);
    destination.launch(context);
  }

  void _showConfirmDialog() {
    showConfirmDialogCustom(
      context,
      image: ic_right,
      bgColor: context.cardColor,
      iconColor: primaryColor,
      title: language.confirmThisPassword,
      positiveText: language.yes,
      negativeText: language.no,
      height: 100,
      onCancel: (_) => setState(() => reEnteredPin = ''),
      onAccept: (_) async {
        toast(language.pinSavedSuccessfully);
        await setValue(IS_PASS_LOCK_SET, true);
        await setValue(USER_SECURITY_PIN, enteredPin);
        widget.isResetPinFromEmail
            ? _navigateToNextScreen()
            : finish(context, true);
      },
    );
  }

  Widget _numButton(int number) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: () => _handleNumberTap(number),
      child: Container(
        width: 60,
        height: 60,
        decoration:
            boxDecorationDefault(borderRadius: BorderRadius.circular(40)),
        child: Text(
          number.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ).center(),
      ),
    ).paddingAll(10);
  }

  Widget _pinBox(int index) {
    final pin = isReEnterPin ? reEnteredPin : enteredPin;
    final isFilled = index < pin.length;
    return Container(
      margin: const EdgeInsets.all(6),
      width: 50,
      height: 50,
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: BorderRadius.circular(6),
        backgroundColor: isFilled
            ? primaryLightColor.withValues(alpha: 0.1)
            : grayColor.withValues(alpha: 0.2),
      ),
      child: isFilled
          ? isPinVisible
              ? Text(pin[index], style: boldTextStyle(color: primaryColor))
                  .center()
              : Container(
                  margin: const EdgeInsets.all(20),
                  decoration: boxDecorationWithRoundedCorners(
                    borderRadius: BorderRadius.circular(20),
                    backgroundColor: primaryColor,
                  ),
                )
          : const SizedBox(),
    );
  }

  getNewPinApiCall() async {
    appStore.setLoading(true);
    String newPin = generateRandom4DigitNumber();

    await setValue(NEWLY_GENERATED_PIN, newPin);
    Map<String, dynamic> req = {
      "email": getStringAsync(EMAIL),
      "new_pin": newPin,
    };
    toast("We would send a verification code to your registered email");
    await resetPinApi(req).then((value) async {
      hideKeyboard(context);
      appStore.setLoading(false);
      if (value.status == true) {
        toast(value.message);
        // Use a slight delay and ensure we're using a valid context
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return ExistingPasswordDialog(
                isResetPinFromEmail: true,
                resetPin: int.parse(value.code),
                email: getStringAsync(EMAIL),
              );
            },
          );
        });
      } else {
        toast(value.message);
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool, dynamic) {
        if (widget.isVerifyPin) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBarWidget(
          widget.isVerifyPin ? "" : language.setPin,
          context1: context,
          color: Colors.white,
          textColor: Colors.black,
          elevation: 0,
          showBack: !widget.isVerifyPin,
        ),
        body: Observer(
          builder: (context) {
            return SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100),
                      Text(
                        isReEnterPin
                            ? language.reenterYour4digitPIN
                            : language.enterDigitPIN,
                        style: primaryTextStyle(size: textFontSize_26),
                      ).center(),
                      const SizedBox(height: 26),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(DEFAULT_PIN_LENGTH, _pinBox),
                      ),
                      const SizedBox(height: 26),
                      for (var i = 0; i < 3; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                                3, (index) => _numButton(1 + 3 * i + index)),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                  isPinVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 24),
                              onPressed: () =>
                                  setState(() => isPinVisible = !isPinVisible),
                            ),
                            _numButton(0),
                            IconButton(
                              icon: const Icon(Icons.backspace, size: 24),
                              onPressed: () => setState(() {
                                if (!isReEnterPin && enteredPin.isNotEmpty) {
                                  enteredPin = enteredPin.substring(
                                      0, enteredPin.length - 1);
                                } else if (isReEnterPin &&
                                    reEnteredPin.isNotEmpty) {
                                  reEnteredPin = reEnteredPin.substring(
                                      0, reEnteredPin.length - 1);
                                }
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 60),
                            if (getBoolAsync(IS_FINGERPRINT_LOCK_SET))
                              InkWell(
                                borderRadius: BorderRadius.circular(40),
                                onTap: () => authenticateUser(context)
                                    .then((_) => _navigateToNextScreen()),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: boxDecorationDefault(
                                      borderRadius: BorderRadius.circular(40)),
                                  child: const Icon(Icons.fingerprint),
                                ),
                              ),
                            TextButton(
                              onPressed: () async {
                                await getNewPinApiCall();
                                // final result = await showDialog<bool>(
                                //   context: context,
                                //   barrierDismissible: false,
                                //   builder: (_) => EmailNewPinRequestDialog(),
                                // );
                              },
                              child: Text(language.reset,
                                      style: TextStyle(fontSize: 20))
                                  .visible(widget.isVerifyPin),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (appStore.isLoading)
                    Positioned.fill(
                      child: Center(
                        child: Loader(),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
