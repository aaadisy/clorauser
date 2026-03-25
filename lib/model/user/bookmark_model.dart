class AddBookmarkResponse {
  String? message;
  Data? data;

  AddBookmarkResponse({this.message, this.data});

  AddBookmarkResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
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

class Data {
  String? articleId;
  int? userId;
  String? isBookmark;
  String? updatedAt;
  String? createdAt;
  int? id;

  Data(
      {this.articleId,
      this.userId,
      this.isBookmark,
      this.updatedAt,
      this.createdAt,
      this.id});

  Data.fromJson(Map<String, dynamic> json) {
    articleId = json['article_id'];
    userId = json['user_id'];
    isBookmark = json['is_bookmark'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['article_id'] = this.articleId;
    data['user_id'] = this.userId;
    data['is_bookmark'] = this.isBookmark;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    return data;
  }
}
