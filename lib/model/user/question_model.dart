import 'package:clora_user/main.dart';
import 'package:clora_user/utils/app_constants.dart';

import '../../utils/app_common.dart';
import '../../utils/app_images.dart';

class QuestionsModel {
  Step1 step1;
  Step2 step2;
  Step3 step3;
  Step4 step4;
  Step5 step5;
  Step6 step6;
  Step7 step7;

  QuestionsModel({
    required this.step1,
    required this.step2,
    required this.step3,
    required this.step4,
    required this.step5,
    required this.step6,
    required this.step7,
  });

  factory QuestionsModel.fromJson(Map<String, dynamic> json) {
    return QuestionsModel(
      step1: Step1.fromJson(json['step1']),
      step2: Step2.fromJson(json['step2']),
      step3: Step3.fromJson(json['step3']),
      step4: Step4.fromJson(json['step4']),
      step5: Step5.fromJson(json['step5']),
      step6: Step6.fromJson(json['step6']),
      step7: Step7.fromJson(json['step7']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step1': step1.toJson(),
      'step2': step2.toJson(),
      'step3': step3.toJson(),
      'step4': step4.toJson(),
      'step5': step5.toJson(),
      'step6': step6.toJson(),
      'step7': step7.toJson(),
    };
  }
}

class Step1 {
  String title;
  List<String> options;
  int? selectedOption;
  bool? isSkip;
  bool? isConfirm;

  Step1(
      {required this.title,
      required this.options,
      this.isConfirm = false,
      this.isSkip = false,
      this.selectedOption = -1});

  factory Step1.fromJson(Map<String, dynamic> json) {
    return Step1(
      title: json['title'],
      options: List<String>.from(json['options']),
      selectedOption: json['selectedOption'],
      isSkip: json['isSkip'],
      isConfirm: json['isConfirm'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['options'] = this.options;
    data['selectedOption'] = this.selectedOption;
    data['isSkip'] = this.isSkip;
    data['isConfirm'] = this.isConfirm;
    return data;
  }
}

class Step2 {
  String? title;
  String? desc;
  List<GoalTypeModel> options = [];
  int? selectedOption = 0;
  bool? isSkip;
  bool? isConfirm;

  Step2(
      {required this.title,
      required this.desc,
      required this.options,
      this.isConfirm = false,
      this.isSkip = false,
      this.selectedOption = 0});

  Step2.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    desc = json['desc'];
    isSkip = json['isSkip'];
    selectedOption = json['selectedOption'] ?? 0;
    isConfirm = json['isConfirm'];
    if (json['options'] != null) {
      options = <GoalTypeModel>[];
      json['options'].forEach((v) {
        options.add(new GoalTypeModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['title'] = this.title;
    data['desc'] = this.desc;
    data['isSkip'] = this.isSkip;
    data['isConfirm'] = this.isConfirm;
    data['selectedOption'] = this.selectedOption;

    if (this.options.isNotEmpty) {
      data['options'] = this.options.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Step3 {
  String? title;
  String? desc;
  String? selectedLastPeriodDate;
  bool? isSkip;
  bool? isConfirm;

  Step3(
      {required this.title,
      required this.desc,
      required this.selectedLastPeriodDate,
      this.isConfirm = false,
      this.isSkip = false});

  factory Step3.fromJson(Map<String, dynamic> json) {
    return Step3(
      title: json['title'],
      desc: json['desc'],
      selectedLastPeriodDate: json['selectedLastPeriodDate'],
      isSkip: json['isSkip'],
      isConfirm: json['isConfirm'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['desc'] = this.desc;
    data['selectedLastPeriodDate'] = this.selectedLastPeriodDate;
    data['isSkip'] = this.isSkip;
    data['isConfirm'] = this.isConfirm;

    return data;
  }
}

class Step4 {
  String? title;
  List<String>? cycleLengthList;
  int? selectedOption;
  bool? isSkip;
  bool? isConfirm;

  Step4(
      {required this.title,
      required this.cycleLengthList,
      this.isConfirm = false,
      this.isSkip = false,
      this.selectedOption = DEFAULT_CYCLE_LENGTH});

  Step4.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    isSkip = json['isSkip'];
    selectedOption = json['selectedOption'];
    isConfirm = json['isConfirm'];
    if (json['cycleLengthList'] != null) {
      cycleLengthList = <String>[];
      json['cycleLengthList'].forEach((v) {
        cycleLengthList!.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['title'] = this.title;
    data['isSkip'] = this.isSkip;
    data['isConfirm'] = this.isConfirm;
    data['selectedOption'] = this.selectedOption;

    if (this.cycleLengthList != null) {
      data['cycleLengthList'] = this.cycleLengthList!.map((v) => v).toList();
    }
    return data;
  }
}

class Step5 {
  String? title;
  String? desc;
  List<String>? periodLengthList;
  int? selectedOption;
  bool? isSkip;
  bool? isConfirm;

  Step5(
      {required this.title,
      required this.desc,
      required this.periodLengthList,
      this.isConfirm = false,
      this.isSkip = false,
      this.selectedOption = DEFAULT_PERIOD_LENGTH});

  Step5.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    desc = json['desc'];
    isSkip = json['isSkip'];
    selectedOption = json['selectedOption'];
    isConfirm = json['isConfirm'];
    if (json['periodLengthList'] != null) {
      periodLengthList = <String>[];
      json['periodLengthList'].forEach((v) {
        periodLengthList!.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['title'] = this.title;
    data['desc'] = this.desc;
    data['isSkip'] = this.isSkip;
    data['isConfirm'] = this.isConfirm;
    data['selectedOption'] = this.selectedOption;

    if (this.periodLengthList != null) {
      data['periodLengthList'] = this.periodLengthList!.map((v) => v).toList();
    }
    return data;
  }
}

class Step6 {
  String? title;
  String? desc;
  List<Object>? lutealLengthList;
  int? selectedOption;
  bool? isSkip;
  bool? isConfirm;

  Step6(
      {required this.title,
      required this.desc,
      required this.lutealLengthList,
      this.isConfirm = false,
      this.isSkip = false,
      this.selectedOption = -1});

  Step6.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    desc = json['desc'];
    isSkip = json['isSkip'];
    selectedOption = json['selectedOption'];
    isConfirm = json['isConfirm'];
    if (json['lutealLengthList'] != null) {
      lutealLengthList = <Object>[];
      json['lutealLengthList'].forEach((v) {
        lutealLengthList!.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['title'] = this.title;
    data['desc'] = this.desc;
    data['isSkip'] = this.isSkip;
    data['isConfirm'] = this.isConfirm;
    data['selectedOption'] = this.selectedOption;

    if (this.lutealLengthList != null) {
      data['lutealLengthList'] = this.lutealLengthList!.map((v) => v).toList();
    }
    return data;
  }
}

class Step7 {
  String? title;
  String? desc;
  String? question1;
  String? question2;
  String? answerToQuestion1;
  String? answerToQuestion2;
  bool? skip;
  bool? confirm;

  Step7({
    required this.title,
    required this.desc,
    required this.question1,
    required this.question2,
    this.answerToQuestion1,
    this.answerToQuestion2,
    this.skip = false,
    this.confirm = false,
  });

  Step7.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    desc = json['desc'];
    question1 = json['question1'];
    question2 = json['question2'];
    answerToQuestion1 = json['answerToQuestion1'];
    answerToQuestion2 = json['answerToQuestion2'];
    skip = json['skip'];
    confirm = json['confirm'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['desc'] = desc;
    data['question1'] = question1;
    data['question2'] = question2;
    data['answerToQuestion1'] = answerToQuestion1;
    data['answerToQuestion2'] = answerToQuestion2;
    data['skip'] = skip;
    data['confirm'] = confirm;
    return data;
  }
}

class GoalTypeModel {
  String? img;
  String? title;
  String? desc;

  GoalTypeModel({
    required this.img,
    required this.title,
    required this.desc,
  });

  factory GoalTypeModel.fromJson(Map<String, dynamic> json) {
    return GoalTypeModel(
      img: json['img'],
      title: json['title'],
      desc: json['desc'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['desc'] = this.desc;
    data['img'] = this.img;

    return data;
  }
}

Step1 step1 = Step1(
    title: "${language.areYouUsing} Clora ${language.forYourself} ?",
    options: ["${language.yesForTracking}. ", "${language.yesAsADoctor}."]);
// "No, I have partner code."
Step2 step2 = Step2(
    title: "${language.whatIsYourGoalType}?",
    desc: "${language.allFeatureswWillBeAvailable}",
    options: [
      GoalTypeModel(
          img: ic_track_cycle,
          title: "${language.trackCycle}",
          desc: "${language.stayPreparedForYourNextPeriod}."),
      // GoalTypeModel(
      //     img: ic_get_pragnency,
      //     title: "Get Pregnant",
      //     desc: "Discover your fertility window and learn when you're likely to ovulate."),
      GoalTypeModel(
          img: ic_track_pregnancy,
          title: "${language.trackPregnancy}",
          desc: "${language.monitorChangesInYourBody}.")
    ],
    selectedOption: 0,
    isConfirm: true);
Step3 step3 = Step3(
    title: "${language.whenDidYourLastPeriod}",
    desc: "${language.provideThisInformationSoThatWeCanPredict}.",
    selectedLastPeriodDate: "",
    isSkip: true,
    isConfirm: true);
Step4 step4 = Step4(
    title: "${language.whatIsYourCycleLength} ?",
    cycleLengthList: getCycleLengthList(),
    selectedOption: DEFAULT_CYCLE_LENGTH,
    isConfirm: true,
    isSkip: true);
Step5 step5 = Step5(
    title: "${language.whatIsYourPeriodDuration} ?",
    desc: "${language.whatIsYourPeriodDurationDescription}.",
    periodLengthList: getPeriodLengthList(),
    selectedOption: DEFAULT_PERIOD_LENGTH,
    isConfirm: true,
    isSkip: true);
Step6 step6 = Step6(
    title: "What is Luteal Phase?",
    desc:
        "The luteal phase is the duration between ovulation and the start of your period. Logging its length helps improve the accuracy of ovulation predictions.",
    lutealLengthList: getLutealLengthList(),
    selectedOption: -1,
    isConfirm: true,
    isSkip: true);
Step7 step7 = Step7(
  title: "Complete Your Profile",
  desc:
      "Help us personalize your experience by providing some basic information",
  question1: "What is your full name?",
  question2: "What year were you born?",
  answerToQuestion1: null,
  answerToQuestion2: null,
  confirm: true,
  skip: true,
);
QuestionsModel questionsModel = QuestionsModel(
  step1: step1,
  step2: step2,
  step3: step3,
  step4: step4,
  step5: step5,
  step6: step6,
  step7: step7,
);
