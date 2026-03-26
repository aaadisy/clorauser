import 'package:clora_user/main.dart';
import 'package:clora_user/screens/onboarding/fu_style_question_screen.dart';
import 'package:clora_user/utils/dynamic_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extensions.dart';
import '../../utils/utils.dart';

class PolicyScreen extends StatefulWidget {
  const PolicyScreen({super.key});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  List<PrivacyItem> list = [];
  Set<int> selectList = Set<int>();

  @override
  void initState() {
    super.initState();
    getList();
    logScreenView("Policy screen");
  }

  void getList() {
    list.add(PrivacyItem(0,
        "${language.iAgreeTo} Clora's ${language.termsAndConditions}.", false));
    list.add(PrivacyItem(
        1, "${language.iHaveRead} Clora's ${language.privacyAndPolicy}.", false));
    list.add(PrivacyItem(
      2,
      "${language.iAgreeTo} Clora ${language.processingHealthData}.",
      false,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(ic_logo, fit: BoxFit.fill, height: 100),
          28.height,
          Text("${language.youAndEra} Clora", style: boldTextStyle(size: 24)),
          14.height,
          Text(
            "${language.policyDeclaration}.",
            style: secondaryTextStyle(size: 14),
            textAlign: TextAlign.center,
          ),
          18.height,
          ListView.builder(
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (context, i) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    selectList.contains(i)
                        ? Icons.check_box_outlined
                        : Icons.check_box_outline_blank,
                    size: 25,
                  ),
                  15.width,
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: primaryTextStyle(),
                        children: _getStyledText(list[i].title),
                      ),
                    ),
                  ),
                ],
              ).onTap(() {
                setState(() {
                  if (selectList.contains(i)) {
                    selectList.remove(i);
                  } else {
                    selectList.add(i);
                  }
                });
              }).paddingOnly(bottom: 16);
            },
          ),
          18.height.expand(),
          AppButton(
            disabledColor: ColorUtils.colorPrimary,
            text: language.next,
            width: context.width(),
            color: selectList.isNotEmpty
                ? primaryColor
                : primaryLightColor.withValues(alpha: 0.5),
            elevation: 0,
            onTap: selectList.length > 2
                ? () {
                    setValue(IS_FIRST_TIME, true);
                    AiOnboardingScreen().launch(context);
                  }
                : () {},
          ),
        ],
      ).paddingOnly(
          left: 16, right: 16, top: context.statusBarHeight + 40, bottom: 20),
    );
  }

  List<TextSpan> _getStyledText(String text) {
    List<TextSpan> spans = [];
    RegExp regExp =
        RegExp('${language.termsAndConditions}|${language.privacyAndPolicy}');

    text.splitMapJoin(
      regExp,
      onMatch: (match) {
        spans.add(
          TextSpan(
            text: match.group(0),
            style: TextStyle(
                color: ColorUtils.colorPrimary, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (match.group(0) == language.termsAndConditions) {
                  launchUrls("$APP_BASE_URL/termofservice");
                } else if (match.group(0) == language.privacyAndPolicy) {
                  launchUrls("$APP_BASE_URL/privacypolicy");
                }
              },
          ),
        );
        return '';
      },
      onNonMatch: (nonMatch) {
        spans.add(TextSpan(text: nonMatch));
        return '';
      },
    );

    return spans;
  }
}

class PrivacyItem {
  final int id;
  final String title;
  bool isSelected;

  PrivacyItem(this.id, this.title, this.isSelected);
}
