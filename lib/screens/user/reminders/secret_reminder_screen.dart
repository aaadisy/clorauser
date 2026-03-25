import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/extensions/extension_util/string_extensions.dart';
import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:clora_user/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../extensions/colors.dart';
import '../../../extensions/constants.dart';
import '../../../extensions/decorations.dart';
import '../../../extensions/new_colors.dart';
import '../../../extensions/text_styles.dart';
import '../../../utils/app_images.dart';

class SecretReminderScreen extends StatefulWidget {
  const SecretReminderScreen({super.key});

  @override
  State<SecretReminderScreen> createState() => _SecretReminderScreenState();
}

class _SecretReminderScreenState extends State<SecretReminderScreen> {
  int? currentIndex = 0;

  List<reminderModel> _reminderModel = [];

  ///getList
  getList() {
    _reminderModel
        .add(reminderModel(0, "${language.hiRxr}!", "${language.hiRxrText}"));
    _reminderModel.add(reminderModel(
        1, "${language.myCalender}", "${language.myCalenderText}"));
  }

  @override
  void initState() {
    super.initState();
    getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: mainColorLight,
            pinned: true,
            leading: IconButton(
              icon: Icon(CupertinoIcons.back, color: mainColorText),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              language.secretReminders,
              style: boldTextStyle(
                color: mainColorText,
                size: 18,
                weight: FontWeight.w500,
              ),
            ),
            expandedHeight: 0,
            elevation: 0,
            surfaceTintColor: mainColorLight,
            forceElevated: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Stack(
                  children: [
                    Container(
                      height: 40,
                      color: mainColorLight,
                    ),
                  ],
                ),
                Transform.translate(
                  offset: Offset(0, -60),
                  child: Container(
                    width: context.width(),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(language.chooseTheAppearance,
                            style: secondaryTextStyle()),
                        24.height,
                        ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: _reminderModel.length,
                            itemBuilder: (context, i) {
                              return Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    decoration: boxDecorationWithRoundedCorners(
                                        borderRadius: BorderRadius.circular(
                                            defaultRadius),
                                        border: Border.all(
                                            color: currentIndex == i
                                                ? primaryColor
                                                : grayColor)),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          _reminderModel[i].id == 0
                                              ? ic_app_logo
                                              : ic_logo_gray,
                                          height: _reminderModel[i].id == 0
                                              ? 40
                                              : 35,
                                          width: 40,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                _reminderModel[i]
                                                    .title
                                                    .validate(),
                                                style: boldTextStyle(
                                                    color: _reminderModel[i]
                                                                .id ==
                                                            1
                                                        ? textSecondaryColorGlobal
                                                        : textPrimaryColorGlobal)),
                                            Text(
                                              _reminderModel[i]
                                                  .subTitle
                                                  .validate(),
                                              style: secondaryTextStyle(),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ).expand(),
                                  12.width,
                                  Image.asset(
                                    currentIndex == i
                                        ? ic_radio_fill
                                        : ic_radio,
                                    height: 20,
                                    width: 20,
                                    color: primaryColor,
                                  )
                                ],
                              ).onTap(() {
                                setState(() {
                                  currentIndex = i;
                                });
                              }).paddingOnly(bottom: 16);
                            })
                      ],
                    ).paddingSymmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class reminderModel {
  int? id;
  String? title;
  String? subTitle;

  reminderModel(this.id, this.title, this.subTitle);
}
