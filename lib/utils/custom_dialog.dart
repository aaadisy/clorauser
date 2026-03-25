import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:clora_user/utils/dynamic_theme.dart';
import 'package:flutter/material.dart';

import '../extensions/colors.dart';
import '../extensions/new_colors.dart';
import '../extensions/text_styles.dart';

class CustomDialog extends StatelessWidget {
  final IconData? iconData;
  final String? icon;
  final Color iconColor;
  final String? title;
  final String description;
  final List<DialogButton> buttons;

  const CustomDialog({
    Key? key,
    this.icon,
    this.iconData,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.buttons,
  })  : assert(buttons.length == 1 || buttons.length == 2,
            'Buttons must be 1 or 2'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: mainColor.withValues(alpha:  0.1),
              child: icon != null
                  ? Image.asset(
                      icon!,
                      width: 30,
                      height: 30,
                    )
                  : Icon(
                      iconData,
                      size: 30,
                      color: ColorUtils.colorPrimary,
                    ),
            ).center(),
            if (icon != null || iconData != null) 16.height,
            Text(
              title ?? "",
              style: boldTextStyle(
                color: mainColorText,
                size: 18,
                weight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (title != null || title != "") 12.height,
            Text(
              description,
              style: boldTextStyle(
                color: mainColorText,
                size: 14,
                weight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            10.height,
            Divider(color: mainColorStroke, thickness: 2.5),
            20.height,
            buttons.length == 1
                ? SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: buttons[0].isTransparent
                        ? TextButton(
                            onPressed: buttons[0].onPressed ??
                                () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: mainColorText,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.black, width: 1),
                              ),
                            ),
                            child: Text(
                              buttons[0].text,
                              style: boldTextStyle(
                                size: 14,
                                weight: FontWeight.w500,
                                color: mainColorText,
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: buttons[0].onPressed ??
                                () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttons[0].color ?? mainColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              buttons[0].text,
                              style: boldTextStyle(
                                size: 14,
                                weight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  )
                : Row(
                    children: buttons.asMap().entries.map((entry) {
                      final index = entry.key;
                      final button = entry.value;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: index == 0 ? 0 : 8,
                              right: index == 1 ? 0 : 8),
                          child: SizedBox(
                            height: 40,
                            child: button.isTransparent
                                ? TextButton(
                                    onPressed: button.onPressed ??
                                        () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                      foregroundColor: mainColorText,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                            color: Colors.black, width: 1),
                                      ),
                                    ),
                                    child: Text(
                                      button.text,
                                      style: boldTextStyle(
                                        size: 12,
                                        weight: FontWeight.w500,
                                        color: mainColorText,
                                      ),
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: button.onPressed ??
                                        () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          button.color ?? mainColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      button.text,
                                      style: boldTextStyle(
                                        size: 12,
                                        weight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

class DialogButton {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isTransparent;

  DialogButton({
    required this.text,
    this.onPressed,
    this.color,
    this.isTransparent = false,
  });
}
