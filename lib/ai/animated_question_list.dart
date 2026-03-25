import 'package:clora_user/ai/InfoCard.dart';
import 'package:clora_user/ai/chat_screen.dart';
import 'package:clora_user/ai/questionModel.dart';
import 'package:clora_user/extensions/colors.dart';
import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:clora_user/extensions/text_styles.dart';
import 'package:clora_user/utils/app_images.dart';
import 'package:flutter/material.dart';

import '../extensions/new_colors.dart';

class AnimatedQuestionList extends StatefulWidget {
  final List<Questionmodel> questions;

  AnimatedQuestionList({super.key, required this.questions});

  @override
  State<AnimatedQuestionList> createState() => _AnimatedQuestionListState();
}

class _AnimatedQuestionListState extends State<AnimatedQuestionList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  TextEditingController sendMsg = TextEditingController();
  Questionmodel? data;
  String? askQuestion;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Are you trying to ask...?',
                    textAlign: TextAlign.start,
                    style: boldTextStyle(
                      size: 18,
                      weight: FontWeight.w500,
                      color: mainColorText,
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_drop_down_circle,
                          size: 35, color: Colors.black12))
                ],
              ),
              15.height,
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.questions.length,
                  itemBuilder: (context, index) {
                    return InfoCard(
                      description: widget.questions[index].text ,
                      index: 0,
                      onClick: (dds) {
                        sendMsg.text = widget.questions[index].text ;
                        askQuestion = widget.questions[index].askAi;
                      },
                    ).paddingOnly(bottom: 10);
                  },
                ),
              ),
              15.height,
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: sendMsg,
                          readOnly: true,
                          showCursor: false,
                          maxLines: null,
                          enableInteractiveSelection: false,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'What would you like to ask',
                            hintStyle:
                                primaryTextStyle(color: Colors.grey, size: 14),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (askQuestion != null && sendMsg.text.isNotEmpty) {
                            Navigator.pop(context);
                            AiChatScreen(
                              questionAsk: askQuestion ,
                              question: sendMsg.text ,
                            ).launch(context);
                          }
                        },
                        child: Image.asset(
                          sendbtn,
                          width: 28,
                          height: 28,
                          color: Colors.grey,
                        ),
                      ),
                    ],
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
