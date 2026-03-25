import '../../user/calculator_model.dart';
import 'article_model.dart';

class ArticleList {
  String? status;
  Pagination? pagination;
  List<Article>? data;

  ArticleList({this.status, this.pagination, this.data});

  ArticleList.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
    if (json['data'] != null) {
      data = <Article>[];
      json['data'].forEach((v) {
        data!.add(new Article.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
