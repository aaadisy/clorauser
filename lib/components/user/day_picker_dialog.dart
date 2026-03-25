import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extensions.dart';
import '../../main.dart';
import '../../utils/dynamic_theme.dart';

class DayPickerDialog extends StatefulWidget {
  final Function()? onSave;

  DayPickerDialog(this.onSave);

  @override
  State<DayPickerDialog> createState() => _DayPickerDialogState();
}

class _DayPickerDialogState extends State<DayPickerDialog> {
  int selectedDay = 0;

  final FixedExtentScrollController _controllerDay =
      FixedExtentScrollController();

  void _submit() {
    finish(context, selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.all(16),
      shape: dialogShape(),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(language.day, style: primaryTextStyle(size: textFontSize_20)),
          18.height,
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 150,
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CupertinoPicker(
                      looping: true,
                      magnification: 1.4,
                      squeeze: 0.8,
                      useMagnifier: true,
                      selectionOverlay: SizedBox(),
                      itemExtent: 44.0,
                      scrollController: _controllerDay,
                      onSelectedItemChanged: (selectedItem) {
                        selectedDay = selectedItem;
                      },
                      children: days.map((String item) {
                        return Text(
                          item.toString(),
                          style: primaryTextStyle(size: textFontSize_16),
                        ).center();
                      }).toList(),
                    ).expand(),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 40,
                    width: 120,
                    color: Colors.grey.withValues(alpha: 0.2),
                  ).cornerRadiusWithClipRRect(5)
                ],
              ),
            ],
          ).center(),
          18.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AppButton(
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: textSecondaryColor)),
                padding: EdgeInsets.zero,
                height: 40,
                text: language.cancel,
                width: context.width(),
                elevation: 0,
                color: Colors.white,
                textColor: Colors.black,
                onTap: () {
                  finish(context);
                },
              ).expand(),
              8.width,
              AppButton(
                padding: EdgeInsets.zero,
                height: 40,
                text: language.save,
                width: context.width(),
                elevation: 0,
                color: ColorUtils.colorPrimary,
                textColor: Colors.white,
                onTap: () => _submit(),
              ).expand(),
            ],
          ),
        ],
      ),
    );
  }
}
