import 'package:clora_user/main.dart';
import 'package:flutter/material.dart';

import '../../extensions/constants.dart';
import '../../extensions/text_styles.dart';
import '../../utils/dynamic_theme.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLength;
  final TextStyle? style;
  final int maxLines;

  const ExpandableText({
    super.key,
    required this.text,
    this.maxLength = 100,
    this.style,
    this.maxLines = 3,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;
  bool hasOverflow = false;
  String? truncatedText;

  @override
  void initState() {
    debugPrint('Input text: ${widget.text}');
    super.initState();
  }

  String _computeTruncatedText(
      String text, int maxLines, double maxWidth, TextStyle? style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    if (!textPainter.didExceedMaxLines) {
      return text; // No truncation needed
    }
    int start = 0;
    int end = text.length;
    String lastValidText = text;

    while (start <= end) {
      int mid = (start + end) ~/ 2;
      String testText = text.substring(0, mid);
      final testPainter = TextPainter(
        text: TextSpan(text: testText, style: style),
        maxLines: maxLines,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxWidth);

      if (testPainter.didExceedMaxLines) {
        end = mid - 1;
      } else {
        lastValidText = testText;
        start = mid + 1;
      }
    }

    return lastValidText;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textStyle = widget.style ??
            primaryTextStyle(
              size: textFontSize_14,
              weight: FontWeight.normal,
              color: Colors.black54,
            );
        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: textStyle),
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        hasOverflow = textPainter.didExceedMaxLines ||
            widget.text.length > widget.maxLength;

        truncatedText = hasOverflow && !isExpanded
            ? _computeTruncatedText(
                widget.text, widget.maxLines, constraints.maxWidth, textStyle)
            : widget.text;

        if (!hasOverflow) {
          return Text(
            widget.text,
            style: textStyle,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              maxLines: isExpanded ? null : widget.maxLines,
              overflow:
                  isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              text: TextSpan(
                text: isExpanded ? widget.text : truncatedText,
                style: textStyle,
                children: [
                  if (!isExpanded)
                    const TextSpan(
                      text: '...',
                      style: TextStyle(color: Colors.black54),
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Text(
                isExpanded ? ' ${language.readLess}' : ' ${language.readMore}',
                style: primaryTextStyle(
                  size: textFontSize_14,
                  weight: FontWeight.bold,
                  color: ColorUtils.colorPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
