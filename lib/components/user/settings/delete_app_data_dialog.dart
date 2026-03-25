import 'package:clora_user/main.dart';
import 'package:flutter/material.dart';
import '../../../extensions/extension_util/context_extensions.dart';
import '../../../extensions/extensions.dart';
import '../../../utils/dynamic_theme.dart';

class DeleteAppDataDialog extends StatefulWidget {
  const DeleteAppDataDialog({super.key});

  @override
  State<DeleteAppDataDialog> createState() => _DeleteAppDataDialogState();
}

class _DeleteAppDataDialogState extends State<DeleteAppDataDialog> {
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
          16.height,
          Text(language.allTheSavedDataWillBeDeleted,
              style: secondaryTextStyle()),
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
                text: language.delete,
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
