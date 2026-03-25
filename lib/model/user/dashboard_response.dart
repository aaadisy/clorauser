import 'dart:developer';

import 'package:clora_user/model/model.dart';
import 'package:clora_user/model/user/user_models/pregnancy_detail_model.dart';
import 'package:clora_user/model/user/user_models/user_model.dart';
import '../doctor/doctor_models/health_expert_model.dart';

class DashboardResponse {
  UserModel? user;
  String? cycleDayImage;
  String? pregnancyImage;
  String? crispChatWebsiteId;
  String? crispChatIcon;
  String? chatgptKey;
  bool? isCrispChatEnabled;
  bool? isChatgptEnabled;
  List<DefaultLogCategory>? defaultLogCategory;
  List<Insights>? insights;
  List<Article>? articles;
  List<CycleDateDay>? cycleDateDays;
  List<PersonalisedInsight>? personalizedInsight;
  List<InsightPregnancyWeek>? insightPregnancyWeek;
  // SubscriptionPlan? subscriptionPlan;
  // SubscriptionFeatures? subscriptionFeatures;
  List<PregnancyData>? pregnancyDate;
  List<DailyInsights>? dailyInsights;
  List<AskExpertList>? askExpertList;
  AdsConfiguration? adsConfiguration;
  ShowAdsBasedOnConfig? showAdsBasedOnConfig;
  bool? subscriprtionAccess;
  bool? futureaskexpert;
  bool? futuredummydata;

  DashboardResponse({
    this.user,
    this.cycleDayImage,
    this.defaultLogCategory,
    this.insights,
    this.articles,
    this.crispChatWebsiteId,
    this.isCrispChatEnabled,
    this.chatgptKey,
    this.cycleDateDays,
    this.pregnancyImage,
    this.crispChatIcon,
    this.isChatgptEnabled,
    this.personalizedInsight,
    // this.subscriptionPlan,
    // this.subscriptionFeatures,
    this.dailyInsights,
    this.pregnancyDate,
    this.insightPregnancyWeek,
    this.adsConfiguration,
    this.askExpertList,
    this.subscriprtionAccess,
    this.showAdsBasedOnConfig,
    this.futureaskexpert,
    this.futuredummydata,
  });

  DashboardResponse.fromJson(Map<String, dynamic> json) {
    try {
      user = json['user'] != null ? new UserModel.fromJson(json['user']) : null;
      cycleDayImage =
          json['cycleDay_image'] != null ? json['cycleDay_image'] : null;
      crispChatWebsiteId = json['crisp_chat_website_id'] != null
          ? json['crisp_chat_website_id']
          : null;
      chatgptKey = json['chat_gpt_key'] != null ? json['chat_gpt_key'] : null;
      crispChatIcon =
          json['crisp_chat_icon'] != null ? json['crisp_chat_icon'] : null;
      isCrispChatEnabled = json['is_crisp_chat_enabled'] != null
          ? json['is_crisp_chat_enabled']
          : null;
      subscriprtionAccess = json['subscriprtion_access'] != null
          ? json['subscriprtion_access']
          : null;
      futureaskexpert =
          json['future_ask_expert'] != null ? json['future_ask_expert'] : null;
      futuredummydata =
          json['future_dummy_data'] != null ? json['future_dummy_data'] : null;
      isChatgptEnabled = json['is_chat_gpt_enabled'] != null
          ? json['is_chat_gpt_enabled']
          : null;
      pregnancyImage = json['pregnancyweek_image'] != null
          ? json['pregnancyweek_image']
          : null;
      // subscriptionPlan = json['subscription_plan'] != null
      //     ? SubscriptionPlan.fromJson(json['subscription_plan'])
      //     : null;
      // subscriptionFeatures = json['subscription_futures'] != null
      //     ? SubscriptionFeatures.fromJson(json['subscription_futures'])
      //     : null;
      adsConfiguration = json['facebookconfig'] != null
          ? AdsConfiguration.fromJson(json['facebookconfig'])
          : null;
      showAdsBasedOnConfig = json['subscriptionAdsFeatures'] != null
          ? ShowAdsBasedOnConfig.fromJson(json['subscriptionAdsFeatures'])
          : null;
      if (json['insights'] != null) {
        insights = <Insights>[];
        json['insights'].forEach((v) {
          insights!.add(new Insights.fromJson(v));
        });
      }

      if (json['daily_insights'] != null) {
        dailyInsights = <DailyInsights>[];
        json['daily_insights'].forEach((v) {
          dailyInsights!.add(new DailyInsights.fromJson(v));
        });
      }

      if (json['article'] != null) {
        articles = <Article>[];
        json['article'].forEach((v) {
          articles!.add(new Article.fromJson(v));
        });
      }
      if (json['cycleDateDay'] != null) {
        cycleDateDays = <CycleDateDay>[];
        json['cycleDateDay'].forEach((v) {
          cycleDateDays!.add(new CycleDateDay.fromJson(v));
        });
      }
      if (json['personalised_insights'] != null) {
        personalizedInsight = <PersonalisedInsight>[];
        json['personalised_insights'].forEach((v) {
          personalizedInsight!.add(new PersonalisedInsight.fromJson(v));
        });
      }

      if (json['pregnancy_date'] != null) {
        pregnancyDate = <PregnancyData>[];
        json['pregnancy_date'].forEach((v) {
          pregnancyDate!.add(new PregnancyData.fromJson(v));
        });
      }
      if (json['insights_pregnancy_week'] != null) {
        insightPregnancyWeek = <InsightPregnancyWeek>[];
        json['insights_pregnancy_week'].forEach((v) {
          insightPregnancyWeek!.add(new InsightPregnancyWeek.fromJson(v));
        });
      }
      if (json['ask_expert_list'] != null) {
        askExpertList = <AskExpertList>[];
        json['ask_expert_list'].forEach((v) {
          askExpertList!.add(new AskExpertList.fromJson(v));
        });
      }
    } catch (e, s) {
      log("Parsing Error $e, Trace $s");
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.pregnancyDate != null) {
      data['pregnancy_date'] =
          this.pregnancyDate!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DefaultLogCategory {
  int? id;
  String? type;
  String? name;
  Article? article;
  int? status;
  String? defaultLogCategoryImage;
  String? description;
  String? createdAt;
  String? updatedAt;

  DefaultLogCategory(
      {this.id,
      this.type,
      this.name,
      this.article,
      this.status,
      this.defaultLogCategoryImage,
      this.description,
      this.createdAt,
      this.updatedAt});

  DefaultLogCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    name = json['name'];
    article =
        json['article'] != null ? new Article.fromJson(json['article']) : null;
    status = json['status'];
    defaultLogCategoryImage = json['default_log_category_image'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['name'] = this.name;
    if (this.article != null) {
      data['article'] = this.article!.toJson();
    }
    data['status'] = this.status;
    data['default_log_category_image'] = this.defaultLogCategoryImage;
    data['description'] = this.description;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Symptoms {
  int? id;
  String? title;
  String? bgColor;
  Article? article;
  List<SubSymptoms>? subSymptoms;

  Symptoms({this.id, this.title, this.bgColor, this.article, this.subSymptoms});

  Symptoms.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    bgColor = json['bg_color'];
    article =
        json['article'] != null ? new Article.fromJson(json['article']) : null;
    if (json['sub_symptoms'] != null) {
      subSymptoms = <SubSymptoms>[];
      json['sub_symptoms'].forEach((v) {
        subSymptoms!.add(new SubSymptoms.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['bg_color'] = this.bgColor;
    if (this.article != null) {
      data['article'] = this.article!.toJson();
    }
    if (this.subSymptoms != null) {
      data['sub_symptoms'] = this.subSymptoms!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubSymptoms {
  int? id;
  String? title;
  String? subSymptomIcon;
  String? description;
  Article? article;
  bool? isSelected = false;

  SubSymptoms(
      {this.id,
      this.title,
      this.subSymptomIcon,
      this.description,
      this.isSelected = false,
      this.article});

  SubSymptoms.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    subSymptomIcon = json['sub_symptom_icon'];
    description = json['description'];
    article =
        json['article'] != null ? new Article.fromJson(json['article']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['sub_symptom_icon'] = this.subSymptomIcon;
    data['description'] = this.description;
    if (this.article != null) {
      data['article'] = this.article!.toJson();
    }
    return data;
  }
}

class ExpertData {
  int? id;
  String? name;
  String? tagLine;
  String? healthExpertsImage;

  ExpertData({this.id, this.name, this.tagLine, this.healthExpertsImage});

  ExpertData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    tagLine = json['tag_line'];
    healthExpertsImage = json['health_experts_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['tag_line'] = this.tagLine;
    data['health_experts_image'] = this.healthExpertsImage;
    return data;
  }
}

class UserSymptoms {
  int? id;
  int? userId;
  String? user;
  List<SubSymptom>? subSymptom;
  int? isPeriodStart;
  int? isPeriodEnd;
  int? flow;
  int? menstrualCramps;
  int? sex;
  int? bodyTemperature;
  int? weight;
  String? nots;
  int? water;
  String? waterType;
  String? meditation;
  String? sleep;
  String? currentDate;
  String? createdAt;
  String? updatedAt;

  UserSymptoms(
      {this.id,
      this.userId,
      this.user,
      this.subSymptom,
      this.isPeriodStart,
      this.isPeriodEnd,
      this.flow,
      this.menstrualCramps,
      this.sex,
      this.bodyTemperature,
      this.weight,
      this.nots,
      this.water,
      this.waterType,
      this.meditation,
      this.sleep,
      this.currentDate,
      this.createdAt,
      this.updatedAt});

  UserSymptoms.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    user = json['user'];
    if (json['sub_symptom'] != null) {
      subSymptom = <SubSymptom>[];
      json['sub_symptom'].forEach((v) {
        subSymptom!.add(new SubSymptom.fromJson(v));
      });
    }
    isPeriodStart = json['is_period_start'];
    isPeriodEnd = json['is_period_end'];
    flow = json['flow'];
    menstrualCramps = json['menstrual_cramps'];
    sex = json['sex'];
    bodyTemperature = json['body_temperature'];
    weight = json['weight'];
    nots = json['nots'];
    water = json['water'];
    waterType = json['water_type'];
    meditation = json['meditation'];
    sleep = json['sleep'];
    currentDate = json['current_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['user'] = this.user;
    if (this.subSymptom != null) {
      data['sub_symptom'] = this.subSymptom!.map((v) => v.toJson()).toList();
    }
    data['is_period_start'] = this.isPeriodStart;
    data['is_period_end'] = this.isPeriodEnd;
    data['flow'] = this.flow;
    data['menstrual_cramps'] = this.menstrualCramps;
    data['sex'] = this.sex;
    data['body_temperature'] = this.bodyTemperature;
    data['weight'] = this.weight;
    data['nots'] = this.nots;
    data['water'] = this.water;
    data['water_type'] = this.waterType;
    data['meditation'] = this.meditation;
    data['sleep'] = this.sleep;
    data['current_date'] = this.currentDate;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class SubSymptom {
  int? id;
  String? title;

  SubSymptom({this.id, this.title});

  SubSymptom.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    return data;
  }
}

class Insights {
  int? id;
  String? title;
  String? url;
  String? thumbnailImage;
  int? symptomsId;
  String? symptomsTitle;
  int? subSymptomsId;
  String? subSymptomsTitle;
  int? goalType;
  String? goalTypeName;
  int? viewType;
  String? viewTypeName;
  String? insightsVideo;
  List<StoryImage>? storyImage;
  List<CycleDateDay>? cycleDays;
  List<InsightData>? insightData;
  String? imageVideoImage;
  String? videoImageVideo;
  String? videoData;
  Article? article;
  int? categoryId;
  String? categoryName;
  String? createdAt;
  String? updatedAt;

  Insights({
    this.id,
    this.title,
    this.url,
    this.thumbnailImage,
    this.symptomsId,
    this.symptomsTitle,
    this.subSymptomsId,
    this.subSymptomsTitle,
    this.goalType,
    this.goalTypeName,
    this.viewType,
    this.viewTypeName,
    this.videoData,
    this.insightData,
    this.insightsVideo,
    this.storyImage,
    this.imageVideoImage,
    this.videoImageVideo,
    this.article,
    this.cycleDays,
    this.categoryId,
    this.categoryName,
    this.createdAt,
    this.updatedAt,
  });

  Insights.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    thumbnailImage = json['thumbnail_image'];
    symptomsId = json['symptoms_id'];
    symptomsTitle = json['symptoms_title'];
    subSymptomsId = json['sub_symptoms_id'];
    subSymptomsTitle = json['sub_symptoms_title'];
    goalType = json['goal_type'];
    goalTypeName = json['goal_type_name'];
    videoData = json['video_data'];
    viewType = json['view_type'];
    viewTypeName = json['view_type_name'];
    insightsVideo = json['insights_video'];
    if (json['story_image'] != null) {
      storyImage = <StoryImage>[];
      json['story_image'].forEach((v) {
        storyImage!.add(new StoryImage.fromJson(v));
      });
    }
    if (json['insight_data'] != null) {
      insightData = <InsightData>[];
      json['insight_data'].forEach((v) {
        insightData!.add(new InsightData.fromJson(v));
      });
    }
    imageVideoImage = json['image_video_image'];
    videoImageVideo = json['video_image_video'];
    article =
        json['article'] != null ? Article.fromJson(json['article']) : null;
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    cycleDays = json['cycleDateDay'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['url'] = url;
    data['thumbnail_image'] = thumbnailImage;
    data['symptoms_id'] = symptomsId;
    data['symptoms_title'] = symptomsTitle;
    data['sub_symptoms_id'] = subSymptomsId;
    data['sub_symptoms_title'] = subSymptomsTitle;
    data['goal_type'] = goalType;
    data['goal_type_name'] = goalTypeName;
    data['view_type'] = viewType;
    data['video_data'] = videoData;
    data['view_type_name'] = viewTypeName;
    data['insight_data'] = insightData;
    data['insights_video'] = insightsVideo;
    data['cycleDateDay'] = cycleDays;
    if (this.storyImage != null) {
      data['story_image'] = this.storyImage!.map((v) => v.toJson()).toList();
    }
    data['image_video_image'] = imageVideoImage;
    data['video_image_video'] = videoImageVideo;
    if (article != null) {
      data['article'] = article!.toJson();
    }
    data['category_id'] = categoryId;
    data['category_name'] = categoryName;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class StoryImage {
  int? id;
  String? url;

  StoryImage({this.id, this.url});

  StoryImage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['url'] = this.url;
    return data;
  }
}

class CycleDateDay {
  int? id;
  List<CycleDateData>? cycleDateData;
  String? title;
  String? thumbnailImage;
  int? goalType;
  String? goalTypeName;
  int? viewType;
  String? viewTypeName;
  Null videoData;
  List<StoryImage>? storyImage;
  String? imageVideoImage;
  String? videoImageVideo;
  Article? article;
  CategoryData? categoryData;
  String? podcastSection;
  String? createdAt;
  String? updatedAt;

  CycleDateDay(
      {this.id,
      this.cycleDateData,
      this.title,
      this.thumbnailImage,
      this.goalType,
      this.goalTypeName,
      this.viewType,
      this.viewTypeName,
      this.videoData,
      this.storyImage,
      this.imageVideoImage,
      this.videoImageVideo,
      this.podcastSection,
      this.article,
      this.categoryData,
      this.createdAt,
      this.updatedAt});

  CycleDateDay.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['cycle_date_data'] != null) {
      cycleDateData = <CycleDateData>[];
      json['cycle_date_data'].forEach((v) {
        cycleDateData!.add(new CycleDateData.fromJson(v));
      });
    }
    title = json['title'];
    thumbnailImage = json['thumbnail_image'];
    goalType = json['goal_type'];
    goalTypeName = json['goal_type_name'];
    viewType = json['view_type'];
    viewTypeName = json['view_type_name'];
    podcastSection = json['section_data_podcast'];
    videoData = json['video_data'];
    if (json['story_image'] != null) {
      storyImage = <StoryImage>[];
      json['story_image'].forEach((v) {
        storyImage!.add(new StoryImage.fromJson(v));
      });
    }
    imageVideoImage = json['image_video_image'];
    videoImageVideo = json['video_image_video'];
    article =
        json['article'] != null ? new Article.fromJson(json['article']) : null;
    if (json['category'] != null) {
      categoryData = CategoryData.fromJson(json['category']);
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.cycleDateData != null) {
      data['cycle_date_data'] =
          this.cycleDateData!.map((v) => v.toJson()).toList();
    }
    data['title'] = this.title;
    data['thumbnail_image'] = this.thumbnailImage;
    data['goal_type'] = this.goalType;
    data['goal_type_name'] = this.goalTypeName;
    data['view_type'] = this.viewType;
    data['view_type_name'] = this.viewTypeName;
    data['video_data'] = this.videoData;
    data['section_data_podcast'] = this.podcastSection;
    if (this.storyImage != null) {
      data['story_image'] = this.storyImage!.map((v) => v.toJson()).toList();
    }
    data['image_video_image'] = this.imageVideoImage;
    data['video_image_video'] = this.videoImageVideo;
    if (this.article != null) {
      data['article'] = this.article!.toJson();
    }
    data['category'] = this.categoryData!.toJson();
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class CycleDateData {
  int? id;
  int? slideType;
  String? title;
  String? message;
  String? cycleDateDataTextMessageImage;
  String? cycleDateDataQueAnsImage1;
  String? cycleDateDataQueAnsImage2;
  List<QuestionAndAnswer>? questionAndAnswer;
  Article? article;
  int? cycleDateId;
  int? status;
  String? createdAt;
  String? updatedAt;

  CycleDateData(
      {this.id,
      this.slideType,
      this.title,
      this.message,
      this.cycleDateDataTextMessageImage,
      this.cycleDateDataQueAnsImage1,
      this.cycleDateDataQueAnsImage2,
      this.questionAndAnswer,
      this.article,
      this.cycleDateId,
      this.status,
      this.createdAt,
      this.updatedAt});

  CycleDateData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slideType = json['slide_type'];
    title = json['title'];
    message = json['message'];
    cycleDateDataTextMessageImage = json['cycle_date_data_text_message_image'];
    cycleDateDataQueAnsImage1 = json['cycle_date_data_que_ans_image_1'];
    cycleDateDataQueAnsImage2 = json['cycle_date_data_que_ans_image_2'];
    if (json['questionanswer'] != null) {
      questionAndAnswer = <QuestionAndAnswer>[];
      json['questionanswer'].forEach((v) {
        questionAndAnswer!.add(new QuestionAndAnswer.fromJson(v));
      });
    }
    article =
        json['article'] != null ? new Article.fromJson(json['article']) : null;
    cycleDateId = json['cycle_date_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['slide_type'] = this.slideType;
    data['title'] = this.title;
    data['message'] = this.message;
    data['cycle_date_data_text_message_image'] =
        this.cycleDateDataTextMessageImage;
    data['cycle_date_data_que_ans_image_1'] = this.cycleDateDataQueAnsImage1;
    data['cycle_date_data_que_ans_image_2'] = this.cycleDateDataQueAnsImage2;
    if (this.questionAndAnswer != null) {
      data['questionanswer'] =
          this.questionAndAnswer!.map((v) => v.toJson()).toList();
    }
    if (this.article != null) {
      data['article'] = this.article!.toJson();
    }
    data['cycle_date_id'] = this.cycleDateId;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class QuestionAndAnswer {
  String? question;
  String? answer;
  String? image;

  QuestionAndAnswer({this.question, this.answer, this.image});

  QuestionAndAnswer.fromJson(Map<String, dynamic> json) {
    question = json['question'];
    answer = json['answer'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['question'] = this.question;
    data['answer'] = this.answer;
    data['image'] = this.image;
    return data;
  }
}

// class CycleDateDay {
//   final int id;
//   final String title;
//   final int slideType;
//   final String? message;
//   final String textMessageImage;
//   late final Article article;
//   final int cycleDateId;
//   final int status;
//   final List<QuestionAnswer>? questionAnswer;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//
//   CycleDateDay({
//     required this.id,
//     required this.title,
//     required this.slideType,
//     this.message,
//     required this.textMessageImage,
//     required this.article,
//     required this.cycleDateId,
//     required this.status,
//     required this.questionAnswer,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory CycleDateDay.fromJson(Map<String, dynamic> json) {
//     return CycleDateDay(
//       id: json['id'],
//       slideType: json['slide_type'],
//       title: json['title'],
//       message: json['message'],
//       textMessageImage: json['cycle_date_data_text_message_image'],
//       article: Article.fromJson(json['article']),
//       questionAnswer: json['questionanswer'] != null
//           ? (json['questionanswer'] as List)
//               .map((item) => QuestionAnswer.fromJson(item))
//               .toList()
//           : null,
//       // Handle null case
//       cycleDateId: json['cycle_date_id'],
//       status: json['status'],
//       createdAt: DateTime.parse(json['created_at']),
//       updatedAt: DateTime.parse(json['updated_at']),
//     );
//   }
// }
//
// class QuestionAnswer {
//   final String question;
//   final String answer;
//   final String image1;
//
//   QuestionAnswer({
//     required this.question,
//     required this.answer,
//     required this.image1,
//   });
//
//   // Convert JSON to Dart object
//   factory QuestionAnswer.fromJson(Map<String, dynamic> json) {
//     return QuestionAnswer(
//       question: json['question'],
//       answer: json['answer'],
//       image1: json["image"],
//     );
//   }
//
//   // Convert Dart object to JSON
//   Map<String, dynamic> toJson() {
//     return {'question': question, 'answer': answer, 'image': image1};
//   }
// }

class PersonalisedInsight {
  final int id;
  final String title;
  String? url; // Changed from Null? to String?
  final String thumbnailImage;
  final int insightsType;
  final int goalType;
  final String goalTypeName;
  final int viewType;
  final String viewTypeName;
  final String? insightsVideo;
  final List<StoryImage> storyImage;
  final String imageVideoImage;
  final String videoImageVideo;
  final String? videoData;
  final Article article;
  final String? createdAt;
  final String? updatedAt;

  PersonalisedInsight({
    required this.id,
    required this.url,
    required this.title,
    required this.thumbnailImage,
    required this.insightsType,
    required this.goalType,
    required this.goalTypeName,
    required this.viewType,
    required this.viewTypeName,
    this.insightsVideo,
    required this.storyImage,
    required this.videoData,
    required this.imageVideoImage,
    required this.videoImageVideo,
    required this.article,
    this.createdAt,
    this.updatedAt,
  });

  factory PersonalisedInsight.fromJson(Map<String, dynamic> json) {
    return PersonalisedInsight(
      id: json['id'],
      url: json['url'],
      title: json['title'],
      thumbnailImage: json['thumbnail_image'],
      insightsType: json['insights_type'],
      goalType: json['goal_type'],
      goalTypeName: json['goal_type_name'],
      viewType: json['view_type'],
      viewTypeName: json['view_type_name'],
      insightsVideo: json['insights_video'],
      storyImage: (json['story_image'] as List)
          .map((e) => StoryImage.fromJson(e))
          .toList(),
      videoData: json['video_data'],
      imageVideoImage: json['image_video_image'],
      videoImageVideo: json['video_image_video'],
      article: Article.fromJson(json['article']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class Tag {
  final int id;
  final String name;

  Tag({required this.id, required this.name});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
    );
  }
}

// class SubscriptionPlan {
//   final String subscriptionDescription;
//   final List<String> subscriptionImage;
//
//   SubscriptionPlan({
//     required this.subscriptionDescription,
//     required this.subscriptionImage,
//   });
//
//   factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
//     return SubscriptionPlan(
//       subscriptionDescription: json['subscription_description'],
//       subscriptionImage: List<String>.from(json['subscription_image']),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'subscription_description': subscriptionDescription,
//       'subscription_image': subscriptionImage,
//     };
//   }
// }
//
// class SubscriptionFeatures {
//   final bool adsRemoved;
//   final bool downloadReport;
//   final bool showPredictionData;
//   final bool viewPaidArticle;
//   final bool chatAi;
//   final bool canAskExpert;
//   final bool periodLengthGraph;
//   final bool waterGraph;
//   final bool sleepGraph;
//   final bool meditationGraph;
//   final bool weightGraph;
//   final bool cycleHistory;
//   final bool cycleTrendsGraph;
//   final bool bodyTemperatureGraph;
//
//   SubscriptionFeatures({
//     required this.adsRemoved,
//     required this.downloadReport,
//     required this.showPredictionData,
//     required this.viewPaidArticle,
//     required this.chatAi,
//     required this.periodLengthGraph,
//     required this.canAskExpert,
//     required this.waterGraph,
//     required this.sleepGraph,
//     required this.meditationGraph,
//     required this.weightGraph,
//     required this.cycleHistory,
//     required this.cycleTrendsGraph,
//     required this.bodyTemperatureGraph,
//   });
//
//   factory SubscriptionFeatures.fromJson(Map<String, dynamic> json) {
//     return SubscriptionFeatures(
//       adsRemoved: json['ads_removed'],
//       downloadReport: json['download_report'],
//       showPredictionData: json['show_prediction_data'],
//       viewPaidArticle: json['view_paid_article'],
//       chatAi: json['chat_ai'],
//       periodLengthGraph: json['period_length_graph'],
//       waterGraph: json['water_graph'],
//       canAskExpert: json['ask_and_expert'],
//       sleepGraph: json['sleep_graph'],
//       meditationGraph: json['meditation_graph'],
//       weightGraph: json['weight_graph'],
//       cycleHistory: json['Cycle_history'],
//       cycleTrendsGraph: json['cycle_trends_graph'],
//       bodyTemperatureGraph: json['body_temperature_graph'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'ads_removed': adsRemoved,
//       'download_report': downloadReport,
//       'show_prediction_data': showPredictionData,
//       'view_paid_article': viewPaidArticle,
//       'chat_ai': chatAi,
//       'period_length_graph': periodLengthGraph,
//       'water_graph': waterGraph,
//       'sleep_graph': sleepGraph,
//       'meditation_graph': meditationGraph,
//       'ask_and_expert': canAskExpert,
//       'weight_graph': weightGraph,
//       'Cycle_history': cycleHistory,
//       'cycle_trends_graph': cycleTrendsGraph,
//       'body_temperature_graph': bodyTemperatureGraph,
//     };
//   }
// }
//
// class SubscriptionModel {
//   final SubscriptionPlan subscriptionPlan;
//   final SubscriptionFeatures subscriptionFeatures;
//
//   SubscriptionModel({
//     required this.subscriptionPlan,
//     required this.subscriptionFeatures,
//   });
//
//   factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
//     return SubscriptionModel(
//       subscriptionPlan: SubscriptionPlan.fromJson(json['subscription_plan']),
//       subscriptionFeatures:
//           SubscriptionFeatures.fromJson(json['subscription_futures']),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'subscription_plan': subscriptionPlan.toJson(),
//       'subscription_futures': subscriptionFeatures.toJson(),
//     };
//   }
// }

class AskExpertList {
  final int id;
  final UserModel? user;
  final String title;
  final String description;
  final HealthExpertData? expert;
  final String? expertAnswer;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<dynamic> askexpertImage;

  AskExpertList({
    required this.id,
    required this.user,
    required this.title,
    required this.description,
    this.expert,
    this.expertAnswer,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.askexpertImage,
  });

  factory AskExpertList.fromJson(Map<String, dynamic> json) {
    return AskExpertList(
      id: json['id'],
      user: UserModel.fromJson(json['user']),
      title: json['title'],
      description: json['description'],
      expert: json['expert'] != null
          ? HealthExpertData.fromJson(json['expert'])
          : null,
      expertAnswer: json['expert_answer'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      askexpertImage: json['askexpert_image'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user?.toJson(),
      'title': title,
      'description': description,
      'expert': expert?.toJson(),
      'expert_answer': expertAnswer,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'askexpert_image': askexpertImage,
    };
  }
}

class InsightPregnancyWeek {
  int? id;
  String? title;
  String? thumbnailImage;
  int? goalType;
  String? goalTypeName;
  int? viewType;
  String? weeks;
  String? viewTypeName;
  String? videoData;
  String? insightsVideo;
  List<StoryImage>? storyImage;
  String? imageVideoImage;
  String? videoImageVideo;
  Article? article;
  String? categoryId;
  String? categoryName;
  String? createdAt;
  String? updatedAt;

  InsightPregnancyWeek(
      {this.id,
      this.title,
      this.thumbnailImage,
      this.goalType,
      this.goalTypeName,
      this.viewType,
      this.weeks,
      this.viewTypeName,
      this.videoData,
      this.insightsVideo,
      this.storyImage,
      this.imageVideoImage,
      this.videoImageVideo,
      this.article,
      this.categoryId,
      this.categoryName,
      this.createdAt,
      this.updatedAt});

  InsightPregnancyWeek.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    thumbnailImage = json['thumbnail_image'];
    goalType = json['goal_type'];
    goalTypeName = json['goal_type_name'];
    viewType = json['view_type'];
    weeks = json['weeks'];
    viewTypeName = json['view_type_name'];
    videoData = json['video_data'];
    insightsVideo = json['insights_video'];
    if (json['story_image'] != null) {
      storyImage = <StoryImage>[];
      json['story_image'].forEach((v) {
        storyImage!.add(new StoryImage.fromJson(v));
      });
    }
    imageVideoImage = json['image_video_image'];
    videoImageVideo = json['video_image_video'];
    article =
        json['article'] != null ? new Article.fromJson(json['article']) : null;
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['thumbnail_image'] = this.thumbnailImage;
    data['goal_type'] = this.goalType;
    data['goal_type_name'] = this.goalTypeName;
    data['view_type'] = this.viewType;
    data['weeks'] = this.weeks;
    data['view_type_name'] = this.viewTypeName;
    data['video_data'] = this.videoData;
    data['insights_video'] = this.insightsVideo;
    if (this.storyImage != null) {
      data['story_image'] = this.storyImage!.map((v) => v.toJson()).toList();
    }
    data['image_video_image'] = this.imageVideoImage;
    data['video_image_video'] = this.videoImageVideo;
    if (this.article != null) {
      data['article'] = this.article!.toJson();
    }
    data['category_id'] = this.categoryId;
    data['category_name'] = this.categoryName;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class InsightData {
  String? bgColor;
  String? textColor;
  String? titleName;
  String? description;

  InsightData({this.bgColor, this.textColor, this.titleName, this.description});

  InsightData.fromJson(Map<String, dynamic> json) {
    bgColor = json['bg_color'];
    textColor = json['text_color'];
    titleName = json['title_name'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bg_color'] = this.bgColor;
    data['text_color'] = this.textColor;
    data['title_name'] = this.titleName;
    data['description'] = this.description;
    return data;
  }
}

class DailyInsights {
  int? id;
  String? title;
  int? goalType;
  String? goalTypeName;
  String? phase;
  int? symptomsId;
  String? symptomsTitle;

  // int? subSymptomsId;
  String? subSymptomsTitle;
  String? createdAt;
  String? updatedAt;

  DailyInsights(
      {this.id,
      this.title,
      this.goalType,
      this.goalTypeName,
      this.phase,
      this.symptomsId,
      this.symptomsTitle,
      // this.subSymptomsId,
      this.subSymptomsTitle,
      this.createdAt,
      this.updatedAt});

  DailyInsights.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    goalType = json['goal_type'];
    goalTypeName = json['goal_type_name'];
    phase = json['phase'];
    symptomsId = json['symptoms_id'];
    symptomsTitle = json['symptoms_title'];
    // subSymptomsId = json['sub_symptoms_id'];
    subSymptomsTitle = json['sub_symptoms_title'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['goal_type'] = this.goalType;
    data['goal_type_name'] = this.goalTypeName;
    data['phase'] = this.phase;
    data['symptoms_id'] = this.symptomsId;
    data['symptoms_title'] = this.symptomsTitle;
    // data['sub_symptoms_id'] = this.subSymptomsId;
    data['sub_symptoms_title'] = this.subSymptomsTitle;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class AdsConfiguration {
  bool? adsconfigAccess;
  String? androidInterstitial;
  String? androidRewardedVideo;
  String? androidBanner;
  String? iosInterstitial;
  String? iosRewardedVideo;
  String? iosBanner;

  AdsConfiguration(
      {this.adsconfigAccess,
      this.androidInterstitial,
      this.androidRewardedVideo,
      this.androidBanner,
      this.iosInterstitial,
      this.iosRewardedVideo,
      this.iosBanner});

  AdsConfiguration.fromJson(Map<String, dynamic> json) {
    adsconfigAccess = json['facebookconfig_access'];
    androidInterstitial = json['android_interstitial'];
    androidRewardedVideo = json['android_rewarded_video'];
    androidBanner = json['android_banner'];
    iosInterstitial = json['ios_interstitial'];
    iosRewardedVideo = json['ios_rewarded_video'];
    iosBanner = json['ios_banner'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['facebookconfig_access'] = this.adsconfigAccess;
    data['android_interstitial'] = this.androidInterstitial;
    data['android_rewarded_video'] = this.androidRewardedVideo;
    data['android_banner'] = this.androidBanner;
    data['ios_interstitial'] = this.iosInterstitial;
    data['ios_rewarded_video'] = this.iosRewardedVideo;
    data['ios_banner'] = this.iosBanner;
    return data;
  }
}

class ShowAdsBasedOnConfig {
  bool? saveDailyLogs;
  bool? editPeriodData;
  bool? downloadImageData;
  bool? downloadPdfData;
  bool? downloadDoctorReport;
  bool? useCalculatorTools;
  bool? viewPaidArticle;

  ShowAdsBasedOnConfig({
    this.saveDailyLogs,
    this.editPeriodData,
    this.downloadImageData,
    this.downloadPdfData,
    this.downloadDoctorReport,
    this.useCalculatorTools,
    this.viewPaidArticle,
  });

  ShowAdsBasedOnConfig.fromJson(Map<String, dynamic> json) {
    saveDailyLogs = json['save_daily_logs'];
    editPeriodData = json['edit_period_data'];
    downloadImageData = json['download_image_data'];
    downloadPdfData = json['download_pdf_data'];
    downloadDoctorReport = json['download_doctor_report'];
    useCalculatorTools = json['use_calculator_tools'];
    viewPaidArticle = json['view_paid_article'];
  }

  Map<String, dynamic> toJson() {
    return {
      'save_daily_logs': saveDailyLogs,
      'edit_period_data': editPeriodData,
      'download_image_data': downloadImageData,
      'download_pdf_data': downloadPdfData,
      'download_doctor_report': downloadDoctorReport,
      'use_calculator_tools': useCalculatorTools,
      'view_paid_article': viewPaidArticle,
    };
  }
}
