import 'package:clora_user/main.dart';
import 'package:flutter/material.dart';
import '../../../extensions/extension_util/context_extensions.dart';
import '../../../extensions/extensions.dart';

class ConfigureBackupDialog extends StatefulWidget {
  final Function()? onAccept;

  const ConfigureBackupDialog({super.key, this.onAccept});

  @override
  State<ConfigureBackupDialog> createState() => _ConfigureBackupDialogState();
}

class _ConfigureBackupDialogState extends State<ConfigureBackupDialog> {
  TextEditingController emailCount = TextEditingController();
  TextEditingController passCount = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.all(16),
      shape: dialogShape(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language.configureBackup, style: primaryTextStyle()),
          8.height,
          Text(
              language
                  .enterYourEmailAddressAndCreateAPasswordTheBackupWillBeConfiguredForTheAccountAssociatedWithThisEmail,
              style: secondaryTextStyle()),
          16.height,
          AppTextField(
            controller: emailCount,
            textFieldType: TextFieldType.NAME,
            isValidationRequired: true,
            focus: emailFocus,
            nextFocus: passFocus,
            decoration: defaultInputDecoration(context, label: language.email),
          ),
          16.height,
          AppTextField(
            controller: passCount,
            textFieldType: TextFieldType.PASSWORD,
            isValidationRequired: true,
            focus: passFocus,
            decoration:
                defaultInputDecoration(context, label: language.password),
          ),
          16.height,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(language.alreadyHaveAnAccount,
                      style: primaryTextStyle(size: textFontSize_14))
                  .expand(),
              4.width,
              Text(language.login,
                      style: primaryTextStyle(
                          color: primaryColor, size: textFontSize_14))
                  .onTap(() {})
            ],
          ),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AppButton(
                padding: EdgeInsets.zero,
                height: 40,
                text: language.cancel,
                width: context.width(),
                elevation: 0,
                color: Colors.white,
                textColor: primaryColor,
                onTap: () {
                  finish(context);
                },
              ).expand(),
              8.width,
              AppButton(
                padding: EdgeInsets.zero,
                height: 40,
                text: language.save,
                width: context.width(),
                elevation: 0,
                color: primaryColor,
                textColor: Colors.white,
                onTap: () {
                  widget.onAccept;
                },
              ).expand(),
            ],
          ),
        ],
      ),
    );
  }
}
