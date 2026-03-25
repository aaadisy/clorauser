import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:clora_user/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../extensions/app_button.dart';
import '../../../extensions/colors.dart';
import '../../../extensions/constants.dart';
import '../../../extensions/new_colors.dart';
import '../../../extensions/system_utils.dart';
import '../../../extensions/text_styles.dart';
import '../../../utils/app_common.dart';

class PregnancyDueResult extends StatefulWidget {
  final DateTime dueDate;
  const PregnancyDueResult({super.key, required this.dueDate});

  @override
  State<PregnancyDueResult> createState() => _PregnancyDueResultState();
}

class _PregnancyDueResultState extends State<PregnancyDueResult> {
  @override
  void initState() {
    super.initState();
    logScreenView("Pregnancy due result screen");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: Container(
        color: bgColor,
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppButton(
              color: primaryColor,
              width: context.width(),
              elevation: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(language.recalculate,
                      style: boldTextStyle(
                          size: textFontSize_14, color: Colors.white)),
                  8.width,
                  Icon(Icons.refresh_sharp, color: Colors.white, size: 18),
                ],
              ),
              onTap: () {
                finish(context);
              },
            ).paddingSymmetric(horizontal: 24),
          ],
        ),
      ),
      body: Column(
        children: [
          AppBar(
            backgroundColor: mainColorLight,
            leading: IconButton(
              icon: Icon(CupertinoIcons.back, color: mainColorText),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            title: Text(
              language.pregnancyDueDateResult,
              style: boldTextStyle(
                color: mainColorText,
                size: 18,
                weight: FontWeight.w500,
              ),
            ),
            elevation: 0,
            surfaceTintColor: mainColorLight,
          ),
          Stack(
            children: [
              Container(
                height: 40,
                color: mainColorLight,
              ),
            ],
          ),
          Transform.translate(
            offset: Offset(0, -30),
            child: Container(
              width: context.width(),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  8.height,
                  Text(
                    language.youWillMeetYourBabyOn,
                    style: boldTextStyle(size: textFontSize_14),
                    textAlign: TextAlign.center,
                  ).paddingSymmetric(horizontal: 16).center(),
                  16.height,
                  Container(
                    height: 150,
                    width: 300,
                    decoration: BoxDecoration(
                        color: OvulationColor,
                        borderRadius: BorderRadius.circular(defaultRadius)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('MMMM d, y').format(widget.dueDate),
                          style: TextStyle(
                              fontSize: textFontSize_24.toDouble(),
                              color: Colors.white),
                        ),
                        Text(
                          DateFormat('EEEE').format(widget.dueDate),
                          style: TextStyle(
                              fontSize: textFontSize_20.toDouble(),
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  16.height,
                ],
              ),
            ),
          ).expand()
        ],
      ),
    );
  }
}
