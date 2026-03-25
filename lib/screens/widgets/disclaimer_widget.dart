// disclaimer_widget.dart

import 'package:clora_user/extensions/constants.dart';
import 'package:clora_user/extensions/new_colors.dart';
import 'package:clora_user/utils/app_constants.dart';
import 'package:flutter/material.dart';

import '../../extensions/shared_pref.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';

Widget buildDisclaimerWidget({EdgeInsets? padding}) {
  return Container(
    padding: EdgeInsets.symmetric(
      vertical: padding?.vertical ?? 8,
      horizontal: padding?.horizontal ?? 8,
    ),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      "👉 ${getStringAsync(SITE_NAME)} ${language.isNotADiagnosticTool}",
      style: primaryTextStyle(
        color: mainColorBodyText,
        weight: FontWeight.w400,
        size: textFontSize_10,
      ),
    ),
  );
}
