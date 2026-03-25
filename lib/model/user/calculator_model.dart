import '../common/article_models/article_model.dart';

class CalculatorResponse {
  Pagination? pagination;
  List<CalculatorItem>? data;
  List<Expert>? experts; // Added this line

  CalculatorResponse({this.pagination, this.data, this.experts});

  CalculatorResponse.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
    if (json['data'] != null) {
      data = <CalculatorItem>[];
      json['data'].forEach((v) {
        data!.add(CalculatorItem.fromJson(v));
      });
    }
    if (json['experts'] != null) {
      experts = <Expert>[];
      json['experts'].forEach((v) {
        experts!.add(Expert.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (experts != null) {
      data['experts'] = experts!.map((v) => v.toJson()).toList();
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
    currentPage = json['current_page'];
    totalPages = json['total_pages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['total_items'] = totalItems;
    data['per_page'] = perPage;
    data['current_page'] = currentPage;
    data['total_pages'] = totalPages;
    return data;
  }
}

class CalculatorItem {
  int? id;
  String? type;
  String? name;
  Article? article;
  int? status;
  String? calculatorThumbailImage;
  String? description;
  String? createdAt;
  String? updatedAt;

  CalculatorItem({
    this.id,
    this.type,
    this.name,
    this.article,
    this.status,
    this.calculatorThumbailImage,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  CalculatorItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    name = json['name'];
    article =
        json['article'] != null ? Article.fromJson(json['article']) : null;
    status = json['status'];
    calculatorThumbailImage = json['calculator_thumbail_image'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['type'] = type;
    data['name'] = name;
    if (article != null) {
      data['article'] = article!.toJson();
    }
    data['status'] = status;
    data['calculator_thumbail_image'] = calculatorThumbailImage;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Expert {
  int? id;
  String? name;
  String? expertise;

  Expert({this.id, this.name, this.expertise});

  Expert.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    expertise = json['expertise'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    data['expertise'] = expertise;
    return data;
  }
}
