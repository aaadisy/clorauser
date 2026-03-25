import '../bookmark_response_model.dart';
import '../common/article_models/article_model.dart';

class DashboardArticle {
  String? status;
  Pagination? pagination;
  List<Article>? data;

  DashboardArticle({this.status, this.pagination, this.data});

  DashboardArticle.fromJson(Map<String, dynamic> json) {
    var responseData = json['responseData'] ?? {};
    status = responseData['status']?.toString();
    pagination = responseData['pagination'] != null
        ? Pagination.fromJson(responseData['pagination'])
        : null;
    if (responseData['data'] != null) {
      data = <Article>[];
      responseData['data'].forEach((v) {
        data!.add(Article.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> responseData = {};
    responseData['status'] = status;
    if (pagination != null) {
      responseData['pagination'] = pagination!.toJson();
    }
    if (data != null) {
      responseData['data'] = data!.map((v) => v.toJson()).toList();
    }
    return {'responseData': responseData};
  }
}
