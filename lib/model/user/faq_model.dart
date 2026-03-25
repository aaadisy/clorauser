import 'dart:developer';

import '../common/article_models/article_model.dart';

class FaqResponse {
  Pagination? pagination;
  List<FaqData>? data;

  FaqResponse({this.pagination, this.data});

  FaqResponse.fromJson(Map<String, dynamic> json) {
    try {
      pagination = json['pagination'] != null
          ? new Pagination.fromJson(json['pagination'])
          : null;
      if (json['data'] != null) {
        data = <FaqData>[];
        json['data'].forEach((v) {
          data!.add(new FaqData.fromJson(v));
        });
      }
    } catch (e, s) {
      log("FaqResponse    =======>>>> ${e}, STACK ${s}");
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Pagination {
  int? totalItems;
  int? perPage;
  int? currentPage;
  int? totalPages;

  Pagination(
      {this.totalItems, this.perPage, this.currentPage, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    totalItems = json['total_items'];
    perPage = json['per_page'];
    currentPage = json['currentPage'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_items'] = this.totalItems;
    data['per_page'] = this.perPage;
    data['currentPage'] = this.currentPage;
    data['totalPages'] = this.totalPages;
    return data;
  }
}

class FaqData {
  int? id;
  String? question;
  String? answer;
  int? goalType;
  String? goalTypeName;
  int? categoryId;
  String? categoryName;
  String? url;
  int? status;
  Article? article;
  String? createdAt;
  String? updatedAt;

  FaqData(
      {this.id,
      this.question,
      this.answer,
      this.goalType,
      this.goalTypeName,
      this.categoryId,
      this.categoryName,
      this.url,
      this.status,
      this.article,
      this.createdAt,
      this.updatedAt});

  FaqData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    answer = json['answer'];
    goalType = json['goal_type'];
    goalTypeName = json['goal_type_name'];
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    url = json['url'];
    status = json['status'];
    article =
        json['article'] != null ? Article.fromJson(json['article']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['question'] = this.question;
    data['answer'] = this.answer;
    data['goal_type'] = this.goalType;
    data['goal_type_name'] = this.goalTypeName;
    data['category_id'] = this.categoryId;
    data['category_name'] = this.categoryName;
    data['url'] = this.url;
    data['status'] = this.status;
    data['article'] = this.article;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Tags {
  int? id;
  String? name;

  Tags({this.id, this.name});

  Tags.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
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
