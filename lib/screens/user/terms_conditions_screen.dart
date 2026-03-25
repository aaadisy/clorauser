import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../extensions/extensions.dart';
import '../../extensions/new_colors.dart';
import '../../main.dart';
import '../../utils/app_common.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  @override
  void initState() {
    super.initState();
    logScreenView("TnC screen");
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: kPrimaryColor,
                child: Column(
                  children: [
                    10.height,
                    Row(
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            language.termsAndConditions,
                            style: boldTextStyle(
                              size: textFontSize_18,
                              weight: FontWeight.w500,
                              color: mainColorText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    10.height,
                  ],
                ),
              ),
              // Scrollable Content
              Expanded(
                child: Container(
                  width: context.width(),
                  decoration: const BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: HtmlWidget(appStore.termsCondition),
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
