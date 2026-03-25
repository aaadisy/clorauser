import 'package:clora_user/extensions/new_colors.dart';
import 'package:flutter/material.dart';
import '../../extensions/colors.dart';
import '../../extensions/constants.dart';
import '../../extensions/text_styles.dart';

class RequiredValidationText extends StatefulWidget {
  final String? titleText;
  final bool required;

  RequiredValidationText({this.required = false, this.titleText});

  @override
  State<RequiredValidationText> createState() => _RequiredValidationTextState();
}

class _RequiredValidationTextState extends State<RequiredValidationText> {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: boldTextStyle(size: textFontSize_14, isHeader: true),
        children: <TextSpan>[
          TextSpan(
              text: widget.titleText,
              style: boldTextStyle(
                  size: textFontSize_16,
                  weight: FontWeight.w500,
                  color: mainColorText)),
          widget.required
              ? TextSpan(text: ' *', style: secondaryTextStyle(color: redColor))
              : TextSpan(),
        ],
      ),
    );
  }
}
