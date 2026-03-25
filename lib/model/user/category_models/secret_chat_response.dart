class SecretChatResponse {
  List<SecretPost>? data;

  SecretChatResponse({this.data});

  SecretChatResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <SecretPost>[];
      json['data'].forEach((v) {
        data!.add(new SecretPost.fromJson(v));
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

class SecretPost {
  int? id;
  int? categoryId;
  int? userId;
  String? userImage;
  String? categoryName;
  String? backgroundImage;
  String? categoryImage;
  String? description;
  bool? isLiked;
  bool? isFollowing;
  bool? isBookmark;
  bool? isComment;
  int? secretChatLikeCount;
  int? secretChatCommentCount;
  String? createdAt;

  SecretPost(
      {this.id,
        this.categoryId,
        this.userId,
        this.categoryName,
        this.userImage,
        this.backgroundImage,
        this.description,
        this.categoryImage,
        this.isLiked,
        this.isFollowing,
        this.isBookmark,
        this.isComment,
        this.secretChatLikeCount,
        this.secretChatCommentCount,
        this.createdAt});

  SecretPost.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['category_id'];
    userId = json['user_id'];
    categoryName = json['category_name'];
    userImage = json['user_image'];
    backgroundImage = json['background_image'];
    categoryImage = json['category_image'];
    description = json['description'];
    isLiked = json['is_liked'];
    isFollowing = json['is_following'];
    isBookmark = json['is_bookmark'];
    isComment = json['is_comment'];
    secretChatLikeCount = json['secret_chat_like_count'];
    secretChatCommentCount = json['secret_chat_comment_count'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['category_id'] = this.categoryId;
    data['user_id'] = this.userId;
    data['category_name'] = this.categoryName;
    data['user_image'] = this.userImage;
    data['background_image'] = this.backgroundImage;
    data['description'] = this.description;
    data['category_image'] = this.categoryImage;
    data['is_liked'] = this.isLiked;
    data['is_following']= this.isFollowing;
    data['is_bookmark']= this.isBookmark;
    data['is_comment']= this.isComment;
    data['secret_chat_like_count'] = this.secretChatLikeCount;
    data['secret_chat_comment_count'] = this.secretChatCommentCount;
    data['created_at'] = this.createdAt;
    return data;
  }
}
