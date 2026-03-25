import 'package:flutter/material.dart';
import 'package:menstrual_cycle_widget/ui/model/symptoms_count.dart';

import '../../main.dart';

class PredictedSymptomsWidget extends StatelessWidget {
  final List<SymptomsCount> symptoms;
  final TextStyle boldTextStyle;
  final TextStyle primaryTextStyle;
  final double defaultRadius;
  final bool isFeatureLocked;
  final bool isVisible;
  final VoidCallback onSubscribePressed;

  // Pre-generate color variations to avoid rebuilding
  static final List<Color> _colorVariations = _generateStaticColorVariations();

  const PredictedSymptomsWidget({
    Key? key,
    required this.symptoms,
    required this.boldTextStyle,
    required this.primaryTextStyle,
    required this.defaultRadius,
    required this.isFeatureLocked,
    required this.isVisible,
    required this.onSubscribePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible || symptoms.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                language.todayPredictedSymptoms,
                style: boldTextStyle.copyWith(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),
            _buildSymptomsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsList(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: symptoms.take(8).map((symptom) {
                  final index = symptoms.indexOf(symptom);
                  return _buildSymptomChip(context, symptom, index);
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomChip(
      BuildContext context, SymptomsCount symptom, int index) {
    final chipColor = _colorVariations[index % _colorVariations.length];
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      margin: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: chipColor.withAlpha(50),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              symptom.name ?? 'Unknown',
              style: boldTextStyle.copyWith(color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Frequency: ${symptom.accuracy}%",
            style: primaryTextStyle.copyWith(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  static List<Color> _generateStaticColorVariations() {
    const baseColor = Colors.purple;
    return [
      baseColor,
      baseColor.withRed(150),
      baseColor.withBlue(200),
      baseColor.withGreen(100),
      baseColor.withAlpha(180),
      baseColor.withRed(200).withBlue(150),
      baseColor.withGreen(150).withBlue(200),
      baseColor.withRed(180).withGreen(180),
    ];
  }
}
