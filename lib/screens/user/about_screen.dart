import 'package:clora_user/extensions/colors.dart';
import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/common/settings_components.dart';
import '../../extensions/common.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/app_config.dart';
import '../../utils/app_images.dart';
import 'about_us_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  void initState() {
    super.initState();
    logScreenView("About Screen");
  }

  Widget mSettingOption(String mTitle, String mImg, Function onTapCall) {
    return SettingItemWidget(
      onTap: () {
        onTapCall.call();
      },
      title: mTitle,
      leading: Image.asset(mImg, height: 20, width: 20, color: primaryColor),
      trailing: Icon(Icons.arrow_forward_ios_sharp, color: grayColor, size: 18),
      paddingAfterLeading: 10,
      paddingBeforeTrailing: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          backgroundColor: bgColor,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: kToolbarHeight + MediaQuery.of(context).padding.top,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                  ),
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            pop();
                          },
                          icon: Icon(CupertinoIcons.back)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          language.about,
                          style: boldTextStyle(
                            color: Colors.black,
                            size: 20,
                            weight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  color: kPrimaryColor,
                ),
                Transform.translate(
                  offset: Offset(0, -25),
                  child: Container(
                      width: context.width(),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          20.height,
                          mSettingOption(language.about, ic_info, () {
                            AboutUsScreen(isFromDoctor: false).launch(context);
                          }),
                          10.height,
                          mSettingOption(language.privacyAndPolicy, ic_secure,
                              () {
                            launchUrls("$APP_BASE_URL/privacypolicy");
                          }),
                          10.height,
                          mSettingOption(language.termsAndConditions, ic_docs,
                              () {
                            launchUrls("$APP_BASE_URL/termofservice");
                          }),
                          10.height,
                          mSettingOption(language.rate, ic_star, () {
                            launchAppStore();
                          }),
                          10.height,
                          mSettingOption(language.share, ic_share, () {
                            shareApp(context);
                          }),
                          10.height,
                        ],
                      ).paddingSymmetric(horizontal: 16)),
                )
              ],
            ),
          )),
    );
  }
}
