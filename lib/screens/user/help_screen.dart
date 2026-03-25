import 'package:clora_user/main.dart';
import 'package:flutter/material.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extensions.dart';
import '../../utils/app_common.dart';
import '../../utils/dynamic_theme.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class HelpScreen extends StatefulWidget {
  final bool isFromDoctor;

  const HelpScreen({super.key, required this.isFromDoctor});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  void initState() {
    super.initState();
    logScreenView("Help screen");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(language.helpAndSupport,
          context1: context,
          elevation: 1,
          titleTextStyle: boldTextStyle(
              size: textFontSize_18, isHeader: true, color: Colors.white),
          textColor: widget.isFromDoctor ? Colors.white : Colors.black,
          color: widget.isFromDoctor ? ColorUtils.colorPrimary : null),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: boxDecorationWithRoundedCorners(boxShadow: [
              BoxShadow(
                  color: shadowColorGlobal,
                  offset: Offset(0, 0.5),
                  spreadRadius: 1,
                  blurRadius: 8,
                  blurStyle: BlurStyle.outer)
            ], borderRadius: radius(defaultRadius)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingItemWidget(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  title: language.privacyAndPolicy,
                  onTap: () {
                    PrivacyPolicyScreen().launch(context);
                  },
                  leading: Icon(Feather.refresh_ccw, size: 18),
                  trailing: Icon(Icons.keyboard_arrow_right_sharp),
                  paddingAfterLeading: 16,
                  paddingBeforeTrailing: 0,
                ),
                Divider(color: context.dividerColor, height: 8),
                SettingItemWidget(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  title: language.termsAndConditions,
                  onTap: () {
                    TermsConditionsScreen().launch(context);
                  },
                  leading: Icon(Feather.refresh_ccw, size: 18),
                  trailing: Icon(Icons.keyboard_arrow_right_sharp),
                  paddingAfterLeading: 16,
                  paddingBeforeTrailing: 0,
                ),
              ],
            ),
          ).paddingSymmetric(horizontal: 16, vertical: 16),
        ],
      ),
    );
  }
}
