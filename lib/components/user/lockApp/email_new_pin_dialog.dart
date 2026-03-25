import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/string_extensions.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../network/rest_api.dart';
import '../../../utils/app_common.dart';
import '../../../utils/app_constants.dart';
import 'existing_password_dialog.dart';

class EmailNewPinRequestDialog extends StatefulWidget {
  const EmailNewPinRequestDialog({super.key});

  @override
  State<EmailNewPinRequestDialog> createState() =>
      _EmailNewPinRequestDialogState();
}

class _EmailNewPinRequestDialogState extends State<EmailNewPinRequestDialog> {
  TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String newPin = generateRandom4DigitNumber();

  getNewPinApiCall() async {
    setState(() {});
    await setValue(NEWLY_GENERATED_PIN, newPin);
    Map<String, dynamic> req = {
      "email": emailController.text.trim(),
      "new_pin": newPin,
    };

    await resetPinApi(req).then((value) async {
      hideKeyboard(context);
      appStore.setLoading(false);
      if (value.status == true) {
        toast(value.message);
        // Close current dialog first
        Navigator.of(context).pop();
        // Use a slight delay and ensure we're using a valid context
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return ExistingPasswordDialog(
                isResetPinFromEmail: true,
                resetPin: value.code.toInt(),
                email: emailController.text,
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
  void initState() {
    super.initState();
    appStore.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: dialogShape(),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language.didYouForgetYourPin, style: boldTextStyle()),
                  Icon(Icons.close).paddingOnly(left: 16, right: 6).onTap(() {
                    pop();
                  }),
                ],
              ),
              10.height,
              Text(language.enterEmailAddressToReceiveNewPin,
                  style: secondaryTextStyle()),
              28.height,
              Form(
                key: formKey,
                child: AppTextField(
                  textFieldType: TextFieldType.OTHER,
                  maxLines: 1,
                  controller: emailController,
                  isValidationRequired: true,
                  errorInvalidEmail: language.invalidEmailAddress,
                  decoration: defaultInputDecoration(
                    context,
                    label: language.email,
                  ),
                ),
              ),
              16.height,
              SizedBox(
                height: 50,
                child: appStore.isLoading
                    ? SizedBox(width: context.width(), child: Loader().center())
                    : AppButton(
                        padding: EdgeInsets.zero,
                        height: 40,
                        text: language.recover,
                        width: context.width(),
                        elevation: 0,
                        color: primaryColor,
                        textColor: Colors.white,
                        onTap: () async {
                          appStore.setLoading(true);
                          if (emailController.text.isNotEmpty &&
                              !emailController.text.validateEmail()) {
                            toast(language.emailValid);
                          } else {
                            getNewPinApiCall();
                          }
                        },
                      ),
              ),
              8.height,
            ],
          ),
        );
      },
    );
  }
}
