import '../../user/category_models/category_data_response.dart';
import 'article_reference_model.dart';

class Article {
  int? id;
  String? name;
  List<Tags>? tags;
  int? goalType;
  String? goalTypeName;
  String? type;
  String? description;
  ExpertData? expertData;
  int? bookmark;
  List<ArticleReference>? articleReference;
  String? articleImage;
  String? createdAt;
  String? updatedAt;

  Article(
      {this.id,
      this.name,
      this.tags,
      this.goalType,
      this.goalTypeName,
      this.description,
      this.type,
      this.expertData,
      this.articleReference,
      this.bookmark,
      this.articleImage,
      this.createdAt,
      this.updatedAt});

  Article.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['tags'] != null) {
      tags = <Tags>[];
      json['tags'].forEach((v) {
        tags!.add(new Tags.fromJson(v));
      });
    }
    goalType = json['goal_type'];
    goalTypeName = json['goal_type_name'];
    description = json['description'];
    bookmark = json['bookmark'];
    type = json['type'];
    expertData = json['expert_data'] != null
        ? new ExpertData.fromJson(json['expert_data'])
        : null;
    if (json['article_reference'] != null) {
      articleReference = <ArticleReference>[];
      json['article_reference'].forEach((v) {
        articleReference!.add(new ArticleReference.fromJson(v));
      });
    }
    articleImage = json['article_image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    if (this.tags != null) {
      data['tags'] = this.tags!.map((v) => v.toJson()).toList();
    }
    data['goal_type'] = this.goalType;
    data['goal_type_name'] = this.goalTypeName;
    data['description'] = this.description;
    data['bookmark'] = this.bookmark;
    data['type'] = this.type;
    if (this.expertData != null) {
      data['expert_data'] = this.expertData!.toJson();
    }
    if (this.articleReference != null) {
      data['article_reference'] =
          this.articleReference!.map((v) => v.toJson()).toList();
    }
    data['article_image'] = this.articleImage;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
