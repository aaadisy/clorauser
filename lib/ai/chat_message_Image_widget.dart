import 'package:clora_user/ai/questionModel.dart';
import 'package:clora_user/extensions/colors.dart';
import 'package:flutter/material.dart';
import '../extensions/extension_util/context_extensions.dart';
import '../extensions/extension_util/int_extensions.dart';
import '../extensions/extension_util/string_extensions.dart';
import '../extensions/extension_util/widget_extensions.dart';
import '../extensions/decorations.dart';
import '../extensions/text_styles.dart';
import '../utils/app_common.dart';

class ChatMessageWidget extends StatefulWidget {
  final String answer;
  final QuestionAnswerModel data;
  final bool isLoading;
  final String firstQuestion;

  ChatMessageWidget({
    required this.answer,
    required this.data,
    required this.isLoading,
    required this.firstQuestion,
  });

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          margin: EdgeInsets.only(top: 3.0, bottom: 3.0, left: 120),
          decoration: boxDecorationDefault(
            color: context.dividerColor.withValues(alpha: 0.4),
            boxShadow: defaultBoxShadow(
                blurRadius: 0, shadowColor: Colors.transparent),
            borderRadius: radiusOnly(bottomLeft: 16, topLeft: 16, topRight: 16),
          ),
          child: SelectableText(
            widget.data.smartCompose.validate().isNotEmpty
                ? ': ${widget.data.question.splitAfter('of ')}'
                : ' ${widget.data.question}',
            style: primaryTextStyle(size: 14, color: Colors.black54),
          ),
        ),
        if (widget.answer.isNotEmpty && !widget.isLoading)
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  margin: EdgeInsets.only(
                      top: 2,
                      bottom: 4.0,
                      left: 0,
                      right: (500 * 0.14).toDouble()),
                  decoration: boxDecorationDefault(
                    color: thistle.withValues(alpha: 0.5),
                    boxShadow: defaultBoxShadow(
                        blurRadius: 0, shadowColor: Colors.transparent),
                    borderRadius:
                        radiusOnly(topLeft: 16, bottomRight: 16, topRight: 16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText('${widget.answer}',
                          style: primaryTextStyle(
                              size: 14, color: Colors.black87)),
                      8.height,
                      Text(
                        "${widget.answer.calculateReadTime().toStringAsFixed(1).toDouble().ceil()} min read",
                        style:
                            secondaryTextStyle(color: Colors.black26, size: 12),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: boxDecorationWithRoundedCorners(),
                      child: Icon(Icons.copy, size: 16, color: Colors.black45),
                    ).onTap(() {
                      widget.answer.copyToClipboard();
                      toast('Copied'); // TODO
                    }),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
