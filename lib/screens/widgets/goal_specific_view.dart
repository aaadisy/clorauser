import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:flutter/material.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget.dart';

import '../../main.dart';

class GoalSpecificView extends StatefulWidget {
  final int goalIndex;
  final bool isDayClick;
  final int? cycleDay;
  final String? pregnancyImageUrl;
  final ValueChanged<int> onDaySelected;
  final Key viewKey;

  const GoalSpecificView({
    Key? key,
    required this.goalIndex,
    required this.isDayClick,
    required this.cycleDay,
    required this.pregnancyImageUrl,
    required this.onDaySelected,
    required this.viewKey,
  }) : super(key: key);

  @override
  State<GoalSpecificView> createState() => GoalSpecificViewState();
}

class GoalSpecificViewState extends State<GoalSpecificView> {
  @override
  Widget build(BuildContext context) {
    return widget.goalIndex == 0
        ? _buildMenstrualCycleView()
        : _buildPregnancyView();
  }

  Widget _buildMenstrualCycleView() {
    return MenstrualCyclePhaseView(
      key: widget.viewKey,
      size: 300,
      theme: MenstrualCycleTheme.arcs,
      phaseTextBoundaries: appStore.phaseText,
      isRemoveBackgroundPhaseColor: true,
      viewType: appStore.viewText,
      isAutoSetData: true,
      selectedDay: widget.cycleDay ?? 1,
      onDayClick: (selectedDay, selectedDate) {
        widget.onDaySelected(selectedDay);
      },
    ).center();
  }

  Widget _buildPregnancyView() {
    return PregnancyView(
      key: widget.viewKey,
      size: 300,
      imageUrl: widget.pregnancyImageUrl ?? "",
      messageTextSize: 12,
      titleTextSize: 30,
    ).center();
  }
}
