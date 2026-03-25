import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extension_util/string_extensions.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/main.dart';
import 'package:clora_user/screens/user/sign_in_screen.dart';
import 'package:clora_user/screens/user/sign_up_screen.dart';
import 'package:clora_user/utils/app_common.dart';
import 'package:clora_user/utils/app_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../../extensions/new_colors.dart';
import '../../model/user/question_model.dart';
import '../../utils/dynamic_theme.dart';
import '../../utils/app_images.dart';

class QuestionsListScreen extends StatefulWidget {
  @override
  State<QuestionsListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionsListScreen> {
  int currentStep = 1;
  DateTime? _selectedDay;
  DateTime? _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    logScreenView("Question List screen");
  }

  String buildTitle() {
    switch (currentStep) {
      case 1:
        return questionsModel.step1.title.toString();
      case 2:
        return questionsModel.step2.title.toString();
      case 3:
        return questionsModel.step3.title.toString();
      case 4:
        return questionsModel.step4.title.toString();
      case 5:
        return questionsModel.step5.title.toString();
      default:
        return questionsModel.step7.title.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🌌 BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1F1C2C),
                  Color(0xFF928DAB),
                ],
              ),
            ),
          ),

          CustomScrollView(
            physics: NeverScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                pinned: true,
                toolbarHeight: 80,
                automaticallyImplyLeading: false,
                leading: currentStep > 1
                    ? IconButton(
                  icon: const Icon(
                    CupertinoIcons.back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (currentStep > 1) {
                      setState(() => currentStep--);
                    }
                  },
                )
                    : null,
                title: Text(
                  buildTitle(),
                  maxLines: 3,
                  style: boldTextStyle(color: Colors.white, size: 18),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: progressIndicator(),
                  ),
                ],
                elevation: 0,
              ),

              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    24.height,
                    _buildStep(),
                    140.height,
                  ],
                ),
              ),
            ],
          ),

          /// 🔥 CONTINUE BUTTON
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: _glassButton(
              text: language.continueText,
              onTap: () {
                if (currentStep < 6) {
                  setState(() => currentStep++);
                } else {
                  setValue(IS_USER_COMPLETED_QUE, true);
                  setValue(KEY_QUESTION_DATA, questionsModel.toJson());
                  SignUpScreen().launch(context);
                }
              },
            ),
          ),

          /// LOGIN CTA (STEP 1)
          Positioned(
            bottom: 90,
            left: 0,
            right: 0,
            child: TextButton(
              onPressed: () {
                UserSignInScreen().launch(context);
              },
              child: Text(
                language.alreadyHaveAnAccount,
                style: const TextStyle(color: Colors.white70),
              ),
            ).visible(currentStep == 1),
          ),
        ],
      ),
    );
  }

  /// ================= STEP SWITCH =================
  Widget _buildStep() {
    switch (currentStep) {
      case 1:
        return step1();
      case 2:
        return step2();
      case 3:
        return step3();
      case 4:
        return step4();
      case 5:
        return step5();
      default:
        return step7(context, setState);
    }
  }

  /// ================= STEP 1 (TRACKING ONLY) =================
  Widget step1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _glassCard(
        height: 90,
        child: ListTile(
          leading: Image.asset(ic_anchor, height: 32),
          title: Text(
            questionsModel.step1.options.first,
            style: boldTextStyle(color: Colors.white, size: 18),
            textAlign: TextAlign.center,
          ),
          trailing:
          const Icon(Icons.arrow_forward_ios, color: Colors.white),
          onTap: () {
            questionsModel.step1.selectedOption = 0;
            setState(() => currentStep = 2);
          },
        ),
      ),
    );
  }

  /// ================= STEP 2 =================
  Widget step2() {
    return Column(
      children: questionsModel.step2.options.map((e) {
        final index = questionsModel.step2.options.indexOf(e);
        final selected =
            questionsModel.step2.selectedOption == index;

        return _glassCard(
          height: 120,
          isSelected: selected,
          child: ListTile(
            leading: Image.asset(e.img.validate(), height: 40),
            title: Text(
              e.title.validate(),
              style:
              boldTextStyle(color: Colors.white, size: 18),
            ),
            subtitle: Text(
              e.desc.validate(),
              style:
              secondaryTextStyle(color: Colors.white70),
            ),
            trailing: selected
                ? Image.asset(ic_checkmark, height: 24)
                : null,
            onTap: () {
              setState(() {
                questionsModel.step2.selectedOption = index;
              });
            },
          ),
        ).paddingSymmetric(horizontal: 16, vertical: 8);
      }).toList(),
    );
  }

  /// ================= STEP 3 =================
  Widget step3() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: _focusedDay!,
      selectedDayPredicate: (day) =>
          isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        questionsModel.step3.selectedLastPeriodDate =
            DateFormat('yyyy-MM-dd').format(selectedDay);
      },
      headerStyle: HeaderStyle(
        titleTextStyle:
        boldTextStyle(color: Colors.white),
        titleCentered: true,
        formatButtonVisible: false,
      ),
      calendarStyle: CalendarStyle(
        todayDecoration:
        BoxDecoration(color: primaryColor, shape: BoxShape.circle),
        selectedDecoration:
        BoxDecoration(color: primaryColor, shape: BoxShape.circle),
        outsideDaysVisible: false,
      ),
    ).paddingSymmetric(horizontal: 16);
  }

  /// ================= STEP 4 =================
  Widget step4() {
    return _pickerStep(
      questionsModel.step4.cycleLengthList!,
          (value) {
        questionsModel.step4.selectedOption = value;
        userStore.setCycleLength(value);
      },
    );
  }

  /// ================= STEP 5 =================
  Widget step5() {
    return _pickerStep(
      questionsModel.step5.periodLengthList!,
          (value) {
        questionsModel.step5.selectedOption = value;
        userStore.setPeriodsLength(value);
      },
    );
  }

  Widget _pickerStep(List list, Function(int) onSelect) {
    return SizedBox(
      height: context.height() * 0.4,
      child: CupertinoPicker(
        itemExtent: 40,
        onSelectedItemChanged: (index) {
          final val = int.parse(list[index].toString());
          onSelect(val);
          setValue(KEY_QUESTION_DATA, questionsModel.toJson());
        },
        children: list.map((e) {
          return Center(
            child: Text(
              e.toString(),
              style:
              boldTextStyle(color: Colors.white, size: 26),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// ================= STEP 7 =================
  Widget step7(BuildContext context, StateSetter setState) {
    final ageOptions = generateBirthYearOptions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          questionsModel.step7.question1.toString(),
          style:
          boldTextStyle(color: Colors.white, size: 14),
        ),
        8.height,
        TextField(
          onChanged: (v) {
            questionsModel.step7.answerToQuestion1 = v;
            setValue(KEY_QUESTION_DATA, questionsModel.toJson());
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            hintText: "Enter your name",
          ),
        ),
        24.height,
        SizedBox(
          height: 180,
          child: CupertinoPicker(
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              questionsModel.step7.answerToQuestion2 =
              ageOptions[index];
              setValue(KEY_QUESTION_DATA, questionsModel.toJson());
            },
            children: ageOptions.map((age) {
              return Center(
                child: Text(
                  age,
                  style: boldTextStyle(
                      color: Colors.white, size: 22),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ).paddingAll(16);
  }

  /// ================= UI HELPERS =================

  Widget _glassCard({
    required double height,
    required Widget child,
    bool isSelected = false,
  }) {
    return GlassmorphicContainer(
      width: context.width(),
      height: height,
      borderRadius: 18,
      blur: 18,
      border: isSelected ? 2 : 1.2,
      alignment: Alignment.center,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(isSelected ? 0.35 : 0.25),
          Colors.white.withOpacity(0.08),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.6),
          Colors.white.withOpacity(0.25),
        ],
      ),
      child: child,
    );
  }

  Widget _glassButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return _glassCard(
      height: 54,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            text,
            style:
            boldTextStyle(color: Colors.white, size: 16),
          ),
        ),
      ),
    );
  }

  Widget progressIndicator() {
    return CircularPercentIndicator(
      radius: 26,
      lineWidth: 6,
      percent: (currentStep / 6).clamp(0, 1),
      center: Text(
        "$currentStep/6",
        style: boldTextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.white24,
      progressColor: primaryColor,
    );
  }
}
