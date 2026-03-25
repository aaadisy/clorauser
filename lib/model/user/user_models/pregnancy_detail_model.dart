import '../../common/article_models/article_model.dart';

class PregnancyDetail {
  Pagination? pagination;
  List<PregnancyData>? data;

  PregnancyDetail({this.pagination, this.data});

  PregnancyDetail.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
    if (json['data'] != null) {
      data = <PregnancyData>[];
      json['data'].forEach((v) {
        data!.add(new PregnancyData.fromJson(v));
      });
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

class PregnancyData {
  int? id;
  String? pregnancyDate;
  String? title;
  int? status;
  String? pregnancyDateImage;
  Article? article;
  String? createdAt;
  String? updatedAt;

  PregnancyData(
      {this.id,
      this.pregnancyDate,
      this.title,
      this.status,
      this.pregnancyDateImage,
      this.article,
      this.createdAt,
      this.updatedAt});

  PregnancyData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pregnancyDate = json['pregnancy_date'];
    title = json['title'];
    status = json['status'];
    pregnancyDateImage = json['pregnancy_date_image'];
    article =
        json['article'] != null ? new Article.fromJson(json['article']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['pregnancy_date'] = this.pregnancyDate;
    data['title'] = this.title;
    data['status'] = this.status;
    data['pregnancy_date_image'] = this.pregnancyDateImage;
    if (this.article != null) {
      data['article'] = this.article!.toJson();
    }
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

// class Article {
//   int? id;
//   String? name;
//   List<Tags>? tags;
//   int? articleType;
//   int? goalType;
//   String? type;
//   String? goalTypeName;
//   int? bookmark;
//   String? description;
//   ExpertData? expertData;
//   List<ArticleReference>? articleReference;
//   String? articleImage;
//   String? createdAt;
//   String? updatedAt;
//
//   Article(
//       {this.id,
//         this.name,
//         this.tags,
//         this.articleType,
//         this.goalType,
//         this.type,
//         this.goalTypeName,
//         this.bookmark,
//         this.description,
//         this.expertData,
//         this.articleReference,
//         this.articleImage,
//         this.createdAt,
//         this.updatedAt});
//
//   Article.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     if (json['tags'] != null) {
//       tags = <Tags>[];
//       json['tags'].forEach((v) {
//         tags!.add(new Tags.fromJson(v));
//       });
//     }
//     articleType = json['article_type'];
//     goalType = json['goal_type'];
//     type = json['type'];
//     goalTypeName = json['goal_type_name'];
//     bookmark = json['bookmark'];
//     description = json['description'];
//     expertData = json['expert_data'] != null
//         ? new ExpertData.fromJson(json['expert_data'])
//         : null;
//     if (json['article_reference'] != null) {
//       articleReference = <ArticleReference>[];
//       json['article_reference'].forEach((v) {
//         articleReference!.add(new ArticleReference.fromJson(v));
//       });
//     }
//     articleImage = json['article_image'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     if (this.tags != null) {
//       data['tags'] = this.tags!.map((v) => v.toJson()).toList();
//     }
//     data['article_type'] = this.articleType;
//     data['goal_type'] = this.goalType;
//     data['type'] = this.type;
//     data['goal_type_name'] = this.goalTypeName;
//     data['bookmark'] = this.bookmark;
//     data['description'] = this.description;
//     if (this.expertData != null) {
//       data['expert_data'] = this.expertData!.toJson();
//     }
//     if (this.articleReference != null) {
//       data['article_reference'] =
//           this.articleReference!.map((v) => v.toJson()).toList();
//     }
//     data['article_image'] = this.articleImage;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }

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

class ArticleReference {
  int? id;
  String? referenceName;

  ArticleReference({this.id, this.referenceName});

  ArticleReference.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    referenceName = json['reference_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['reference_name'] = this.referenceName;
    return data;
  }
}
