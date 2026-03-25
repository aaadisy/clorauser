import 'dart:async';
import 'package:clora_user/extensions/extension_util/widget_extensions.dart';
import 'package:flutter/material.dart';
import '../../extensions/shared_pref.dart';
import '../../widgets/animated_marble_background.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_common.dart';
import '../user/sign_up_screen.dart';
import 'fu_questions.dart';
import 'fu_question_model.dart';

class FuStyleQuestionScreen extends StatefulWidget {
  @override
  State<FuStyleQuestionScreen> createState() =>
      _FuStyleQuestionScreenState();
}

class _FuStyleQuestionScreenState extends State<FuStyleQuestionScreen> {
  int index = 0;

  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  Map<String, dynamic> answers = {};
  Set<String> multiSelectTemp = {};

  bool canProceed = false;
  bool isTyping = true;
  String typedText = "";
  double sliderValue = 5;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    typedText = "";
    isTyping = true;
    canProceed = false;
    controller.clear();
    multiSelectTemp.clear();

    final text = fuQuestions[index].question;
    int i = 0;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 22), (timer) {
      if (i < text.length) {
        setState(() {
          typedText += text[i];
          i++;
        });
      } else {
        timer.cancel();
        setState(() => isTyping = false);
      }
    });
  }

  void goNext(dynamic value) async {

    final currentKey = fuQuestions[index].key;

    /// STEP 1 — show preview instantly
    setState(() {
      answers[currentKey] = value;
      canProceed = false;
    });

    /// STEP 2 — small premium delay (chat feel)
    await Future.delayed(const Duration(milliseconds: 700));

    /// STEP 3 — move to next question
    if (index < fuQuestions.length - 1) {
      setState(() {
        index++;
      });

      _startTyping();
    } else {
      /// LAST STEP → CALL SIGNUP
      setValue(KEY_QUESTION_DATA, answers);

      await Future.delayed(const Duration(milliseconds: 500));

      SignUpScreen().launch(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    final q = fuQuestions[index];
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: AnimatedMarbleBackground(
        child: SafeArea(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.only(bottom: keyboardHeight),
            child: Column(
              children: [

                const SizedBox(height: 40),

                Text(
                  "Clo ✨",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 30),

                /// QUESTION CARD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _glassCard(
                    height: 170,
                    child: Center(
                      child: Text(
                        typedText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// ANSWER PREVIEW
                if (answers.containsKey(q.key))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC44D72),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          answers[q.key].toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                /// INPUT AREA
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: buildInput(q),
                  ),
                ),

                /// BUTTONS
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [

                      Expanded(
                        child: ElevatedButton(
                          onPressed: index == 0
                              ? null
                              : () {
                            setState(() => index--);
                            _startTyping();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: index == 0
                                ? Colors.white.withOpacity(0.3)
                                : const Color(0xFFAD6C86),
                            padding:
                            const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text("Previous"),
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: (!canProceed || isTyping)
                              ? null
                              : () {

                            dynamic value;

                            if (q.type == InputType.slider) {
                              value = sliderValue.toInt();
                            } else if (q.type == InputType.multiSelect) {
                              value = multiSelectTemp.toList();
                            } else {
                              value = controller.text.trim();
                            }

                            goNext(value);
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: canProceed
                                ? const Color(0xFFC44D72)
                                : Colors.white.withOpacity(0.3),
                            padding:
                            const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            index == fuQuestions.length - 1
                                ? "Submit"
                                : "Next",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInput(FuQuestion q) {

    /// TEXT / NUMBER / MOBILE / EMAIL / PASSWORD
    if (q.type == InputType.text ||
        q.type == InputType.number) {

      return _glassCard(
        height: 60,
        child: TextField(
          focusNode: focusNode,
          controller: controller,
          keyboardType: q.key == "mobile"
              ? TextInputType.phone
              : q.keyboardType ??
              (q.type == InputType.number
                  ? TextInputType.number
                  : TextInputType.text),
          obscureText: q.key == "password",
          onChanged: (v) {
            setState(() {
              if (q.key == "mobile") {
                canProceed = v.length >= 8;
              } else {
                canProceed = v.trim().isNotEmpty;
              }
            });
          },
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding:
            EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
      );
    }

    /// SINGLE SELECT
    if (q.type == InputType.singleSelect) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: q.options!
            .map((e) => GestureDetector(
          onTap: () {
            controller.text = e;
            setState(() => canProceed = true);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFC44D72),
              borderRadius:
              BorderRadius.circular(20),
            ),
            child: Text(e,
                style: const TextStyle(
                    color: Colors.white)),
          ),
        ))
            .toList(),
      );
    }

    /// MULTI SELECT
    if (q.type == InputType.multiSelect) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: q.options!
            .map((e) => GestureDetector(
          onTap: () {
            setState(() {
              multiSelectTemp.contains(e)
                  ? multiSelectTemp.remove(e)
                  : multiSelectTemp.add(e);
              canProceed =
                  multiSelectTemp.isNotEmpty;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: multiSelectTemp.contains(e)
                  ? const Color(0xFFC44D72)
                  : Colors.white.withOpacity(0.3),
              borderRadius:
              BorderRadius.circular(20),
            ),
            child: Text(e,
                style: const TextStyle(
                    color: Colors.white)),
          ),
        ))
            .toList(),
      );
    }

    /// SLIDER
    if (q.type == InputType.slider) {
      return _glassCard(
        height: 120,
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Slider(
              value: sliderValue,
              min: 1,
              max: 10,
              divisions: 9,
              activeColor:
              const Color(0xFFC44D72),
              onChanged: (v) {
                setState(() {
                  sliderValue = v;
                  canProceed = true;
                });
              },
            ),
            Text(
              sliderValue.toInt().toString(),
              style: const TextStyle(
                  color: Colors.white),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  Widget _glassCard({
    required double height,
    required Widget child,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color:
        const Color(0xFFC44D72).withOpacity(0.35),
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}