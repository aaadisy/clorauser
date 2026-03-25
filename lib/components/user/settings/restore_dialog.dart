import 'package:clora_user/main.dart';
import 'package:flutter/material.dart';
import '../../../extensions/extension_util/context_extensions.dart';
import '../../../extensions/extensions.dart';
import '../../../utils/dynamic_theme.dart';

class RestoreDialog extends StatefulWidget {
  const RestoreDialog({super.key});

  @override
  State<RestoreDialog> createState() => _RestoreDialogState();
}

class _RestoreDialogState extends State<RestoreDialog> {
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
          Text(language.warning, style: primaryTextStyle()),
          8.height,
          Text(
              language
                  .whenYouRestoreTheAppDataOnYourDeviceIsMergedWithTheLastBackedUpData,
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
          8.height,
          Align(
              alignment: Alignment.topRight,
              child: Text(language.forgotPassword,
                  style: secondaryTextStyle(color: ColorUtils.colorPrimary))),
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
                textColor: ColorUtils.colorPrimary,
                onTap: () {
                  finish(context);
                },
              ).expand(),
              8.width,
              AppButton(
                padding: EdgeInsets.zero,
                height: 40,
                text: language.restore,
                width: context.width(),
                elevation: 0,
                color: ColorUtils.colorPrimary,
                textColor: Colors.white,
                onTap: () {},
              ).expand(),
            ],
          ),
        ],
      ),
    );
  }
}
