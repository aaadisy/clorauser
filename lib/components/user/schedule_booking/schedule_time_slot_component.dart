import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:flutter/material.dart';

import '../../../extensions/colors.dart';
import '../../../extensions/constants.dart';
import '../../../extensions/decorations.dart';
import '../../../extensions/text_styles.dart';

class ScheduleTimeSlotWidget extends StatefulWidget {
  ScheduleTimeSlotWidget();

  @override
  State<ScheduleTimeSlotWidget> createState() => _ScheduleTimeSlotWidgetState();
}

class _ScheduleTimeSlotWidgetState extends State<ScheduleTimeSlotWidget> {
  int selectedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select TimeSlots",
          style: boldTextStyle(),
        ),
        8.height,
        Container(
          width: context.width(),
          height: 60,
          child: ListView.builder(
              itemCount: 15,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                    width: 60,
                    height: 100,
                    decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: selectedIndex == index
                            ? primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: viewLineColor, width: 1)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("11 : 30",
                            style: secondaryTextStyle(
                                size: textFontSize_12,
                                color: selectedIndex == index
                                    ? white
                                    : primaryColor)),
                      ],
                    )).paddingRight(8).onTap(() {
                  setState(() {
                    selectedIndex = index;
                  });
                });
              }),
        ),
      ],
    );
  }
}
