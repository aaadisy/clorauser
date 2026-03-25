import 'package:flutter/material.dart';
import '../../../extensions/extension_util/context_extensions.dart';
import '../../../extensions/extensions.dart';
import '../../../main.dart';
import '../../../utils/dynamic_theme.dart';

class NameDialog extends StatefulWidget {
  const NameDialog({super.key});

  @override
  State<NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<NameDialog> {
  TextEditingController nameController = TextEditingController();

  FocusNode firstNameFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: dialogShape(),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(language.tellUsWhatToCallYou, style: primaryTextStyle()),
          16.height,
          AppTextField(
            controller: nameController,
            textFieldType: TextFieldType.NAME,
            isValidationRequired: true,
            focus: firstNameFocus,
            autoFocus: true,
            // nextFocus: emailFocus,
            decoration: defaultInputDecoration(context,
                label: language.firstName, mPrefix: Icon(Icons.person)),
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
                textColor: ColorUtils.colorPrimary,
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
                color: ColorUtils.colorPrimary,
                textColor: Colors.white,
                onTap: () {
                  setState(() {
                    finish(context,
                        userStore.setCycleLength(userStore.periodsLength));
                  });
                },
              ).expand(),
            ],
          ),
        ],
      ),
    );
  }
}
