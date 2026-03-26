import 'package:clora_user/ai/InfoCard.dart';
import 'package:clora_user/ai/animated_question_list.dart';
import 'package:clora_user/ai/questionModel.dart';
import 'package:clora_user/extensions/colors.dart';
import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/extensions/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../extensions/new_colors.dart';
import '../main.dart' as MenstrualCycleWidget;
import '../utils/app_constants.dart';

class AiDashboardScreen extends StatefulWidget {
  @override
  _AiDashboardScreenState createState() => _AiDashboardScreenState();
}

class _AiDashboardScreenState extends State<AiDashboardScreen> {
  List<Questionmodel> questionFirst = [];
  List<Questionmodel> questionSecond = [];
  List<Questionmodel> questionThree = [];
  List<Questionmodel> questionFour = [];

  String? LAST_DATE_OF_PERIODS;
  String? AVERAGE_PERIOD_LENGTH;
  String? PHASE_NAME;

  @override
  void initState() {
    super.initState();
    ints();
  }

  ints() async {
    await getSetInfo();
    init();
  }

  Future<void> getSetInfo() async {
    final instance = MenstrualCycleWidget.instance;
    LAST_DATE_OF_PERIODS = await instance.getPreviousPeriodDay();
    final avgPeriodLength = await instance.getAvgCycleLength();
    AVERAGE_PERIOD_LENGTH = avgPeriodLength.toString();
    PHASE_NAME = await instance.getCurrentPhaseName();
  }

  init() async {
    // Check if userStore is initialized and has user data before formatting strings
    final user = MenstrualCycleWidget.userStore.user;
    final lastPeriod = LAST_DATE_OF_PERIODS ?? 'unknown';
    final avgCycle = AVERAGE_PERIOD_LENGTH ?? 'unknown';
    final phase = PHASE_NAME ?? 'current';

    questionFirst = [
      Questionmodel(
          text: 'When is my next period likely to start?',
          askAi:
              'Given that my last period started on ${lastPeriod} and my average cycle length is ${avgCycle} days. When is my next period likely to start?'),
      Questionmodel(
          text: 'Can you predict my ovulation window?',
          askAi:
              'Given that my last period started on ${lastPeriod} and my average cycle length is ${avgCycle} days. Can you predict my ovulation window?'),
      Questionmodel(
          text: 'Is my cycle irregular, and if so, what could be the cause?',
          askAi:
              'Given that  My last period\'s avg length is #LAST_4_5_CYCLE LENGTH. Is my cycle irregular, and if so, what could be the cause?'),
      Questionmodel(
          text: 'What are the common causes of missed or delayed periods?',
          askAi: 'What are the common causes of missed or delayed periods?'),
      Questionmodel(
          text: 'What are the signs and symptoms of ovulation?',
          askAi:
              'Given that my last period started on ${lastPeriod} and my average cycle length is ${avgCycle} days. What are the signs and symptoms of ovulation?'),
      Questionmodel(
          text: 'How do I read an ovulation test result?',
          askAi: 'How do I read an ovulation test result?'),
      Questionmodel(
          text:
              'What foods should I eat to reduce bloating during my period? (only)',
          askAi:
              'What foods should I eat to reduce bloating during my period?'),
      Questionmodel(
          text: 'Can you suggest exercises for relieving menstrual pain?',
          askAi: 'Can you suggest exercises for relieving menstrual pain?'),
      Questionmodel(
          text: 'How can I improve my sleep during my period?',
          askAi: 'How can I improve my sleep during my period?'),
    ];
    questionSecond = [
      Questionmodel(
          text: 'What symptoms are common during my current cycle phase?',
          askAi:
              'Given that my last period started on ${lastPeriod} and my average cycle length is ${avgCycle} days. When is my next period likely to start?'),
      Questionmodel(
          text: 'Can you suggest remedies for my ${phase} cramps?',
          askAi: 'Can you suggest remedies for my ${phase} cramps?'),
      Questionmodel(
          text: 'How can I manage my PMS symptoms better?',
          askAi: 'How can I manage my PMS symptoms better?'),
    ];
    questionThree = [
      Questionmodel(
          text: 'What are my most fertile days this cycle?',
          askAi:
              'Given that my last period started on ${lastPeriod}  and my average cycle length is ${avgCycle} days. What are my most fertile days this cycle?'),
      Questionmodel(
          text: 'What are the chances of conception based on my cycle data?',
          askAi:
              ' Given that my last period started on ${lastPeriod}  and my average cycle length is ${avgCycle} days. What are the chances of conception based on my cycle data?'),
      Questionmodel(
          text: 'How can I track my cervical mucus changes?',
          askAi:
              'Given that my last period started on ${lastPeriod}  and my average cycle length is ${avgCycle} days. How can I track my cervical mucus changes?'),
    ];
    questionFour = [
      Questionmodel(
          text: 'Can you suggest eco-friendly menstrual products?',
          askAi: 'Can you suggest eco-friendly menstrual products?'),
      Questionmodel(
          text: 'How often should I change my tampon/pad based on my flow?',
          askAi: 'How often should I change my tampon/pad based on my flow?'),
      Questionmodel(
          text: 'What are the best products for overnight use?',
          askAi: 'What are the best products for overnight use?'),
      Questionmodel(
          text: 'What is the luteal phase, and why is it important?',
          askAi: 'What is the luteal phase, and why is it important?'),
      Questionmodel(
          text: 'What are the signs of a healthy menstrual cycle?',
          askAi: 'What are the signs of a healthy menstrual cycle?'),
      Questionmodel(
          text: 'Can you explain the difference between PMS and PMDD?',
          askAi: 'Can you explain the difference between PMS and PMDD?'),
      Questionmodel(
          text: 'Are my mood swings related to my cycle?',
          askAi: 'Are my mood swings related to my cycle?'),
    ];
  }

  String getGreetingMessage() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  String getCurrentTime() {
    return DateFormat('hh:mm a').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    // Ensure user data is loaded before building UI that relies on it
    if (MenstrualCycleWidget.userStore.user == null) {
      return Scaffold(body: Center(child: Text("Loading User Data...", style: TextStyle(color: Colors.white))));
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: mainColorLight,
            pinned: true,
            titleSpacing: 0,
            leading: IconButton(
              icon: Icon(CupertinoIcons.back, color: mainColorText),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              children: [
                Text(
                  'Clora Ai',
                  style: boldTextStyle(
                    color: mainColorText,
                    size: 18,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            expandedHeight: 0,
            elevation: 0,
            surfaceTintColor: mainColorLight,
            forceElevated: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 16),
                      height: 130,
                      width: context.width(),
                      color: mainColorLight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${getGreetingMessage()}👋 ',
                                  style: boldTextStyle(
                                    size: 18,
                                    weight: FontWeight.w500,
                                    color: mainColorText,
                                  ),
                                ),
                                TextSpan(
                                  text: MenstrualCycleWidget.userStore.user!.firstName,
                                  style: boldTextStyle(
                                    size: 18,
                                    weight: FontWeight.w400,
                                    color: mainColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          10.height,
                          Text(
                            'Ask AI provides instant answers to your fertility questions 24/7!',
                            textAlign: TextAlign.start,
                            style: boldTextStyle(
                              size: 14,
                              color: mainColorBodyText,
                              weight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Transform.translate(
                  offset: Offset(0, -25),
                  child: Container(
                    width: context.width(),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 20, left: 16, right: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('About',
                              textAlign: TextAlign.start,
                              style: boldTextStyle(
                                size: 18,
                                weight: FontWeight.w500,
                                color: mainColorText,
                              )),
                          20.height,
                          InfoCard(
                            description: 'Cycle Tracking and Prediction Questions',
                            index: 0,
                            onClick: (index) {
                              _showQuestionBottomSheet(context, questionFirst);
                            },
                          ),
                          10.height,
                          InfoCard(
                            description: 'Symptom Tracking and Analysis',
                            index: 1,
                            onClick: (index) {
                              _showQuestionBottomSheet(context, questionSecond);
                            },
                          ),
                          10.height,
                          InfoCard(
                            description: 'Fertility and Family Planning',
                            index: 2,
                            onClick: (index) {
                              _showQuestionBottomSheet(context, questionThree);
                            },
                          ),
                          10.height,
                          InfoCard(
                            description: 'Educational Content and FAQs',
                            index: 3,
                            onClick: (index) {
                              _showQuestionBottomSheet(context, questionFour);
                            },
                          ),
                          10.height,
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showQuestionBottomSheet(
      BuildContext context, List<Questionmodel>? question) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: AnimatedQuestionList(questions: question!)),
        );
      },
    );
  }
}
