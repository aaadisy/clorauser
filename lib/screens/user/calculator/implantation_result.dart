import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../extensions/new_colors.dart';
import '../../../utils/app_common.dart';

class ImplantationResult extends StatefulWidget {
  final DateTime ovulationDay;
  final DateTime implantationStart;
  final DateTime implantationEnd;
  const ImplantationResult(
      {super.key,
      required this.ovulationDay,
      required this.implantationStart,
      required this.implantationEnd});

  @override
  State<ImplantationResult> createState() => _ImplantationResultState();
}

class _ImplantationResultState extends State<ImplantationResult> {
  @override
  void initState() {
    super.initState();
    logScreenView("Implantation Calculator Result screen");
  }

  @override
  Widget build(BuildContext context) {
    bool showTwoMonthNames =
        widget.implantationStart.month != widget.implantationEnd.month;
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
              language.implantationResult,
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
                  Text(
                    language.yourImplantationRangeIsBetween,
                    style: boldTextStyle(
                      size: 16,
                    ),
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
                          '${DateFormat('d').format(widget.implantationStart)}-${DateFormat('d').format(widget.implantationEnd)}',
                          textAlign: TextAlign.center,
                          style: boldTextStyle(
                              size: textFontSize_65, color: Colors.white),
                        ),
                        if (showTwoMonthNames)
                          Text(
                            '${DateFormat(' MMMM').format(widget.implantationStart)} - ${DateFormat(' MMMM').format(widget.implantationEnd)}',
                            textAlign: TextAlign.center,
                            style: boldTextStyle(
                                size: textFontSize_14, color: Colors.white),
                          )
                        else
                          Text(
                            '${DateFormat(' MMMM').format(widget.implantationStart)}',
                            textAlign: TextAlign.center,
                            style: boldTextStyle(
                                size: textFontSize_14, color: Colors.white),
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
