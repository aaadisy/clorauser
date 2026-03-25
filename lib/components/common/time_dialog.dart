import 'package:clora_user/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extensions.dart';
import '../../utils/dynamic_theme.dart';

class TimeDialog extends StatefulWidget {
  final int? hrs;
  final int? mins;

  TimeDialog(this.hrs, this.mins);

  @override
  State<TimeDialog> createState() => _TimeDialogState();
}

class _TimeDialogState extends State<TimeDialog> {
  final List<String> TimeHourLength =
      List<String>.generate(25, (index) => index.toString().padLeft(2, '0'));
  final List<String> TimeMinuteLength =
      List<String>.generate(60, (index) => index.toString().padLeft(2, '0'));

  int selectedValue1 = 0;
  int selectedValue2 = 0;

  FixedExtentScrollController? _controller1;
  FixedExtentScrollController? _controller2;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedValue1 = (widget.hrs != null ? widget.hrs : 0) ?? 0;
    selectedValue2 = (widget.mins != null ? widget.mins : 0) ?? 0;
    _controller1 = FixedExtentScrollController(initialItem: selectedValue1);
    _controller2 = FixedExtentScrollController(initialItem: selectedValue2);
    setState(() {});
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
          Text("Time", style: primaryTextStyle(size: textFontSize_20)),
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
                      scrollController: _controller1,
                      onSelectedItemChanged: (selectedItem) {
                        selectedValue1 = selectedItem;
                      },
                      children: TimeHourLength.map((String item) {
                        return Text(
                          item.toString(),
                          style: primaryTextStyle(size: 16),
                        ).center();
                      }).toList(),
                    ).expand(),
                    Text(":"),
                    CupertinoPicker(
                      looping: true,
                      magnification: 1.4,
                      squeeze: 0.8,
                      useMagnifier: true,
                      selectionOverlay: SizedBox(),
                      itemExtent: 44.0,
                      scrollController: _controller2,
                      onSelectedItemChanged: (selectedItem) {
                        selectedValue2 = selectedItem;
                      },
                      children: TimeMinuteLength.map((String item) {
                        return Text(
                          item.toString(),
                          style: primaryTextStyle(size: 16),
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
                onTap: () {
                  finish(context, [selectedValue1, selectedValue2]);
                },
              ).expand(),
            ],
          ),
        ],
      ),
    );
  }
}
