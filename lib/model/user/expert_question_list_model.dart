import 'package:clora_user/model/user/dashboard_response.dart';

class ExpertQuestionListModel {
  List<AskExpertList>? data;

  ExpertQuestionListModel({this.data});

  ExpertQuestionListModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <AskExpertList>[];
      json['data'].forEach((v) {
        data!.add(new AskExpertList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
