import 'package:clora_user/model/common/article_models/article_model.dart';

class ArticleResponse {
  String? message;
  Article? data;

  ArticleResponse({this.message, this.data});

  ArticleResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new Article.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}
