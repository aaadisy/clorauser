import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/screens/screens.dart';
import 'package:clora_user/screens/user/pass_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/app_constants.dart';
import 'email_new_pin_dialog.dart';

@immutable
class ExistingPasswordDialog extends StatefulWidget {
  int resetPin;
  bool isResetPinFromEmail;
  String email;

  ExistingPasswordDialog(
      {required this.resetPin,
      this.isResetPinFromEmail = false,
      this.email = ""});

  @override
  State<ExistingPasswordDialog> createState() => _ExistingPasswordDialogState();
}

class _ExistingPasswordDialogState extends State<ExistingPasswordDialog> {
  bool isPinVisible = true;
  List<String> enteredPin = ['', '', '', ''];
  List<TextEditingController> controllers =
      List.generate(DEFAULT_PIN_LENGTH, (index) => TextEditingController());
  List<FocusNode> focusNodes =
      List.generate(DEFAULT_PIN_LENGTH, (index) => FocusNode());

  bool verifySecurityPin(
      List<TextEditingController> controllers, String storedPin) {
    String enteredPin = '';
    for (var controller in controllers) {
      enteredPin += controller.text;
    }
    return enteredPin == storedPin;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace) {
          for (int i = 0; i < DEFAULT_PIN_LENGTH; i++) {
            if (focusNodes[i].hasFocus) {
              if (controllers[i].text.isEmpty && i > 0) {
                FocusScope.of(context).requestFocus(focusNodes[i - 1]);
                setState(() {
                  controllers[i - 1].clear();
                  enteredPin[i - 1] = '';
                });
              } else if (controllers[i].text.isNotEmpty) {
                setState(() {
                  controllers[i].clear();
                  enteredPin[i] = '';
                });
              }
              break;
            }
          }
        }
      },
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: dialogShape(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400, // max width for tablets and larger
              minWidth: 300, // min width
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(language.enterYourPin, style: primaryTextStyle()),
                6.height,
                Text("${language.receivedAt} ${widget.email}",
                        style: secondaryTextStyle())
                    .visible(widget.isResetPinFromEmail),
                16.height,
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(
                    DEFAULT_PIN_LENGTH,
                    (index) {
                      return SizedBox(
                        width: 50,
                        height: 50,
                        child: DecoratedBox(
                          decoration: boxDecorationWithRoundedCorners(
                            borderRadius: BorderRadius.circular(6),
                            backgroundColor: index < enteredPin.length
                                ? primaryLightColor.withValues(alpha: 0.1)
                                : grayColor.withValues(alpha: 0.2),
                          ),
                          child: TextFormField(
                            controller: controllers[index],
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1)
                            ],
                            textAlignVertical: TextAlignVertical.center,
                            keyboardType: TextInputType.numberWithOptions(),
                            focusNode: focusNodes[index],
                            obscureText: true,
                            obscuringCharacter: "*",
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  enteredPin[index] = value;
                                });
                                if (index < DEFAULT_PIN_LENGTH - 1) {
                                  FocusScope.of(context).nextFocus();
                                }
                              }
                            },
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                            style: TextStyle(color: primaryColor, fontSize: 26),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                8.height,
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(language.forgotPin, style: secondaryTextStyle())
                      .paddingAll(10)
                      .onTap(() async {
                    pop();
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => EmailNewPinRequestDialog(),
                    );
                  }),
                ),
                8.height,
                Row(
                  children: [
                    AppButton(
                      padding: EdgeInsets.zero,
                      height: 40,
                      text: language.cancel,
                      elevation: 0,
                      color: Colors.white,
                      textColor: primaryColor,
                      onTap: () {
                        pop(false);
                      },
                    ).expand(),
                    8.width,
                    AppButton(
                      padding: EdgeInsets.zero,
                      height: 40,
                      text: "Verify",
                      elevation: 0,
                      color: primaryColor,
                      textColor: Colors.white,
                      onTap: () async {
                        bool isCorrectPin = await verifySecurityPin(
                            controllers, widget.resetPin.toString());
                        if (isCorrectPin) {
                          removeKey(NEWLY_GENERATED_PIN);
                          widget.resetPin = 0;
                          PassCodeScreen(
                            isVerifyPin: false,
                          ).launch(context).then((value) {
                            bool res = value;
                            if (res) {
                              setState(() {
                                setValue(IS_PASS_LOCK_SET, true);
                              });
                            }
                            DashboardScreen(currentIndex: 0)
                                .launch(context, isNewTask: true);
                          });
                        } else {
                          toast(
                              "Code does not match. Please verify the code we sent to ${widget.email}");
                          return;
                        }
                      },
                    ).expand(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
