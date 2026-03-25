import 'package:clora_user/components/common/required_validation.dart';
import 'package:clora_user/extensions/new_colors.dart';
import 'package:clora_user/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../extensions/extensions.dart';
import '../../screens/doctor/html_edit_screen.dart';

class HtmlFieldWidget extends StatelessWidget {
  final String title;
  final String content;
  final Function(String) onUpdate;
  final BuildContext context;

  HtmlFieldWidget({
    required this.title,
    required this.content,
    required this.onUpdate,
    required this.context,
  });

  void navigateToEditScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HtmlEditScreen(
          field: title,
          content: content,
          onUpdate: onUpdate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RequiredValidationText(
              required: false,
              titleText: title,
            ),
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: primaryColor,
              ),
              onPressed: navigateToEditScreen,
            ),
          ],
        ),
        4.height,
        Container(
          width: double.infinity,
          height: content.isEmpty ? 60.0 : 60.0,
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: content.isEmpty
              ? Text(language.addDescription,
                      style: boldTextStyle(
                          size: textFontSize_16,
                          weight: FontWeight.w500,
                          color: mainColorBodyText))
                  .paddingOnly(top: 15, left: 15)
              : HtmlWidget(
                  content,
                ),
        ).onTap(() {
          navigateToEditScreen();
        }),
      ],
    );
  }
}
