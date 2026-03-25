import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extensions.dart';
import '../../extensions/new_colors.dart';
import '../../main.dart';
import '../../utils/dynamic_theme.dart';
import '../../utils/utils.dart';

class AboutUsScreen extends StatefulWidget {
  final bool isFromDoctor;

  const AboutUsScreen({super.key, required this.isFromDoctor});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    logScreenView("About Us Screen");
  }

  Widget mSocialOption(var value, String key, {var color}) {
    String url = getStringAsync(key);
    if (url.isEmpty) return const SizedBox.shrink();
    return Image.asset(value, height: 30, width: 30, color: color)
        .paddingAll(8)
        .onTap(() => launchUrls(url));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: kPrimaryColor,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Container(
                color: kPrimaryColor,
                child: Column(
                  children: [
                    10.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            CupertinoIcons.back,
                            color: mainColorText,
                          ),
                        ),
                        Text(
                          language.about,
                          style: boldTextStyle(
                            size: textFontSize_18,
                            weight: FontWeight.w500,
                            color: mainColorText,
                          ),
                        ),
                      ],
                    ),
                    10.height,
                  ],
                ),
              ),
              // Scrollable Content and Fixed Bottom Container
              Expanded(
                child: Container(
                  width: context.width(),
                  decoration: const BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 150),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            4.height,
                            Text(
                              getStringAsync(SITE_NAME),
                              style: boldTextStyle(
                                color: ColorUtils.colorPrimary,
                                size: textFontSize_18,
                              ),
                            ),
                            10.height,
                            Text(
                              getStringAsync(SITE_DESCRIPTION,
                                  defaultValue:
                                      language.noDescriptionAvailable),
                              style: primaryTextStyle(),
                            ),
                            16.height,
                            Row(
                              children: [
                                Icon(
                                  MaterialIcons.mail_outline,
                                  color: textSecondaryColorGlobal,
                                ),
                                8.width,
                                Text(
                                  getStringAsync(CONTACT_EMAIL,
                                      defaultValue: language.noEmailAvailable),
                                  style: secondaryTextStyle(),
                                ).onTap(() {
                                  commonLaunchUrl(
                                      "mailto:${getStringAsync(CONTACT_EMAIL)}");
                                }),
                              ],
                            ),
                            16.height,
                            Row(
                              children: [
                                Icon(
                                  MaterialIcons.support_agent,
                                  color: textSecondaryColorGlobal,
                                ),
                                8.width,
                                TextButton(
                                  onPressed: () {
                                    commonLaunchUrl(getStringAsync(HELP_SUPPORT,
                                        defaultValue: ''));
                                  },
                                  child: Text(
                                    language.contactSupport,
                                    style:
                                        secondaryTextStyle(color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                            16.height,
                            Row(
                              children: [
                                Icon(
                                  Ionicons.md_call_outline,
                                  color: textSecondaryColorGlobal,
                                ),
                                8.width,
                                Text(
                                  getStringAsync(CONTACT_NUMBER,
                                      defaultValue: language.noNumberAvailable),
                                  style: secondaryTextStyle(),
                                ),
                              ],
                            ),
                            16.height,
                          ],
                        ).paddingSymmetric(horizontal: 16, vertical: 8),
                      ),
                      // Fixed Bottom Container
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Center(
                          child: Container(
                            width: context.width() * 0.9,
                            height: 130,
                            child: Column(
                              children: [
                                FutureBuilder<PackageInfo>(
                                  future: PackageInfo.fromPlatform(),
                                  builder: (_, snap) {
                                    if (snap.hasData) {
                                      return Text(
                                        'V ${snap.data!.version.validate()}.${snap.data!.buildNumber.validate()}',
                                        style: primaryTextStyle(),
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                ),
                                16.height,
                                Text(
                                  language.followUs,
                                  style:
                                      primaryTextStyle(size: textFontSize_14),
                                ),
                                2.height,
                                SizedBox(
                                  height: 50,
                                  child: ListView(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          mSocialOption(
                                                  ic_facebook, FACEBOOK_URL)
                                              .paddingOnly(left: 16, right: 16),
                                          mSocialOption(
                                                  ic_instagram, INSTAGRAM_URL)
                                              .paddingRight(16),
                                          mSocialOption(ic_twitter, TWITTER_URL)
                                              .paddingRight(16),
                                          mSocialOption(ic_linkedin, LINKED_URL)
                                              .paddingRight(16),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                2.height,
                                Text(
                                  getStringAsync(SITE_COPYRIGHT),
                                  style:
                                      secondaryTextStyle(size: textFontSize_12),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
