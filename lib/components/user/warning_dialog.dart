import 'package:flutter/material.dart';

import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extensions.dart';
import '../../main.dart';
import '../../screens/user/sign_in_screen.dart';
import '../../screens/user/user_dashboard_screen.dart';
import '../../screens/user/policy_screen.dart';
import '../../screens/user/questions_list_screen.dart';
import '../../utils/app_config.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_images.dart';

class WarningDialog extends StatefulWidget {
  final Function()? onAccept;

  WarningDialog({super.key, this.onAccept});

  @override
  State<WarningDialog> createState() => _WarningDialogState();
}

class _WarningDialogState extends State<WarningDialog> {
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.all(16),
      shape: dialogShape(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Image.asset(ic_warning, height: 35, width: 35, fit: BoxFit.cover),
              Text(language.warning,
                  style: primaryTextStyle(size: textFontSize_18))
            ],
          ),
          4.width,
          Text("${APP_NAME} " + language.warningDisclaimer,
                  style: primaryTextStyle(size: textFontSize_12))
              .paddingOnly(top: 8),
          8.height,
          Row(
            children: [
              Icon(
                      isChecked
                          ? Icons.check_box_outline_blank
                          : Icons.check_box_outlined,
                      size: textFontSize_20.toDouble())
                  .onTap(() {
                setState(() {
                  isChecked = !isChecked;
                });
              }),
              6.width,
              Text(language.okayIUnderstand,
                  style: secondaryTextStyle(size: textFontSize_12))
            ],
          ),
          8.height,
          Row(
            children: [
              Icon(
                      getBoolAsync(IS_SHOW_WARNING_DIALOG)
                          ? Icons.check_box_outlined
                          : Icons.check_box_outline_blank,
                      size: 20)
                  .onTap(() {
                setState(() {
                  setValue(IS_SHOW_WARNING_DIALOG, true);
                });
              }),
              5.width,
              Text(language.doNotShowDialog,
                  style: secondaryTextStyle(size: textFontSize_12))
            ],
          ),
          18.height,
          AppButton(
            padding: EdgeInsets.zero,
            height: 40,
            text: language.continueText,
            width: context.width(),
            elevation: 0,
            color: primaryColor,
            textColor: Colors.white,
            onTap: () {
              setValue(IS_SHOW_WARNING_DIALOG, false);
              bool isFirstTime = getBoolAsync(IS_FIRST_TIME);
              if (!isFirstTime) {
                UserSignInScreen().launch(context, isNewTask: true);
              } else {
                bool login = getBoolAsync(IS_LOGIN);
                if (login) {
                  var userType = getStringAsync(USER_TYPE);
                  if (userType == APP_USER || USER_TYPE == ANONYMOUS) {
                    DashboardScreen(
                      currentIndex: 0,
                    ).launch(context);
                  } else if (userType == Doctor) {
                   //
                  }
                } else {
                  UserSignInScreen().launch(context, isNewTask: true);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
