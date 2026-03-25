import 'package:clora_user/model/doctor/doctor_models/doctor_user_model.dart';
import 'package:clora_user/model/user/dashboard_response.dart';

class DoctorDashboardModel {
  DoctorDashboardResponseData? responseData;

  DoctorDashboardModel({this.responseData});

  DoctorDashboardModel.fromJson(Map<String, dynamic> json) {
    responseData = json['responseData'] != null
        ? new DoctorDashboardResponseData.fromJson(json['responseData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.responseData != null) {
      data['responseData'] = this.responseData!.toJson();
    }
    return data;
  }
}

class DoctorDashboardResponseData {
  HealthExpertModel? data;
  String? crispChatWebsiteId;
  String? crispChatIcon;
  String? chatgptKey;
  bool? isCrispChatEnabled;
  bool? isChatgptEnabled;
  int? newQution;
  int? myAnswers;
  List<AskExpertList>? askexpertList;
  bool? futureaskexpert;

  DoctorDashboardResponseData({
    this.data,
    this.crispChatWebsiteId,
    this.isCrispChatEnabled,
    this.chatgptKey,
    this.crispChatIcon,
    this.isChatgptEnabled,
    this.newQution,
    this.myAnswers,
    this.askexpertList,
    this.futureaskexpert,
  });

  DoctorDashboardResponseData.fromJson(Map<String, dynamic> json) {
    data = json['health_expert'] != null
        ? new HealthExpertModel.fromJson(json['health_expert'])
        : null;
    crispChatWebsiteId = json['crisp_chat_website_id'] != null
        ? json['crisp_chat_website_id']
        : null;
    chatgptKey = json['chat_gpt_key'] != null ? json['chat_gpt_key'] : null;
    crispChatIcon =
        json['crisp_chat_icon'] != null ? json['crisp_chat_icon'] : null;
    isCrispChatEnabled = json['is_crisp_chat_enabled'] != null
        ? json['is_crisp_chat_enabled']
        : null;
    isChatgptEnabled = json['is_chat_gpt_enabled'] != null
        ? json['is_chat_gpt_enabled']
        : null;
    futureaskexpert =
        json['future_ask_expert'] != null ? json['future_ask_expert'] : null;
    newQution = json['new_qution'];
    myAnswers = json['my_answers'];
    if (json['askexpert_list'] != null) {
      askexpertList = <AskExpertList>[];
      json['askexpert_list'].forEach((v) {
        askexpertList!.add(new AskExpertList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['new_qution'] = this.newQution;
    data['my_answers'] = this.myAnswers;
    if (this.askexpertList != null) {
      data['askexpert_list'] =
          this.askexpertList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SessionExpert {
  int? id;
  String? name;
  String? tagLine;
  String? healthExpertsImage;

  SessionExpert({this.id, this.name, this.tagLine, this.healthExpertsImage});

  SessionExpert.fromJson(Map<String, dynamic> json) {
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
