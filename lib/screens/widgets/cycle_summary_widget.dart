import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:clora_user/extensions/new_colors.dart';
import 'package:flutter/material.dart';
import 'package:menstrual_cycle_widget/ui/menstrual_monthly_calender_view.dart';

import '../../main.dart';
import '../../model/user/menstrual_cycle_summary_model.dart';
import 'disclaimer_widget.dart';

class CycleSummaryWidget extends StatelessWidget {
  final MenstrualCycleSummaryData? summaryData;
  final TextStyle boldTextStyle;
  final TextStyle primaryTextStyle;
  final double defaultRadius;
  final bool isVisible;
  final String Function(String) formatDateToWordFormat;
  final VoidCallback onEditCompleted;

  const CycleSummaryWidget({
    Key? key,
    required this.summaryData,
    required this.boldTextStyle,
    required this.primaryTextStyle,
    required this.defaultRadius,
    required this.isVisible,
    required this.formatDateToWordFormat,
    required this.onEditCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible ||
        summaryData == null ||
        summaryData!.keyMatrix!.prevCycleLength! <= 0 ||
        summaryData!.keyMatrix!.prevPeriodDuration! <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      width: context.width(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 15),
                child: Text(
                  language.myCycle,
                  style: boldTextStyle,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MenstrualCycleMonthlyCalenderView(
                        themeColor: Colors.black,
                        isShowCloseIcon: true,
                        onDataChanged: (value) {
                          if (value) {
                            onEditCompleted.call();
                          }
                        },
                      ),
                    ),
                  );
                },
                child: Text(language.edit),
              )
            ],
          ),
          Divider(color: mainColorStroke).paddingSymmetric(horizontal: 13),
          14.height,
          _buildCycleLengthSection(),
          _buildPeriodLengthSection(),
          _buildNextPeriodSection(),
          _buildOvulationSection(),
          8.height,
          buildDisclaimerWidget(),
        ],
      ),
    );
  }

  Widget _buildCycleLengthSection() {
    return Column(
      children: [
        _buildMetricRow(
          label: language.previousCycleLength,
          value: "${summaryData!.keyMatrix!.prevCycleLength!} ${language.days}",
          status: summaryData!.keyMatrix!.cycleRegularityScoreStatus!,
          isRegular: summaryData!.keyMatrix!.cycleRegularityScoreStatus!
                  .toLowerCase() ==
              "regular",
        ),
        12.height,
        const Divider(color: mainColorStroke).paddingSymmetric(horizontal: 16),
        4.height,
      ],
    );
  }

  Widget _buildPeriodLengthSection() {
    return Column(
      children: [
        _buildMetricRow(
          label: language.previousPeriodLength,
          value:
              "${summaryData!.keyMatrix!.prevPeriodDuration!} ${language.days}",
          status: summaryData!.keyMatrix!.periodRegularityScoreStatus!,
          isRegular: true, // Always green check for period
        ),
        12.height,
        const Divider(color: mainColorStroke).paddingSymmetric(horizontal: 16),
        4.height,
      ],
    );
  }

  Widget _buildNextPeriodSection() {
    return Column(
      children: [
        _buildSimpleMetricRow(
          label: language.nextPeriodDate,
          value: formatDateToWordFormat(
              summaryData!.predictionMatrix!.nextPeriodDay!),
        ),
        const Divider(color: mainColorStroke).paddingSymmetric(horizontal: 16),
        12.height,
      ],
    );
  }

  Widget _buildOvulationSection() {
    return FutureBuilder<String?>(
      future: instance.getNextOvulationDate(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Text(language.couldNotLoadOvulationDate);
        }
        final ovulationDate = snapshot.data!;
        return Column(
          children: [
            _buildSimpleMetricRow(
              label: language.nextOvulationDate,
              value: formatDateToWordFormat(
                  ovulationDate.toString().split(' ')[0]),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildMetricRow({
    required String label,
    required String value,
    required String status,
    required bool isRegular,
  }) {
    return Column(
      children: [
        _buildLabelRow(label),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                value,
                style: boldTextStyle,
              ),
            ),
            Text(
              status,
              style: primaryTextStyle.copyWith(
                  fontSize: 14, color: isRegular ? Colors.green : Colors.red),
            ).paddingSymmetric(horizontal: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleMetricRow({
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelRow(label),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: boldTextStyle.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildLabelRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: primaryTextStyle.copyWith(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
