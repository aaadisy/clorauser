class CommentListResponse {
  Pagination? pagination;
  List<CommentData>? data;

  CommentListResponse({this.pagination, this.data});

  CommentListResponse.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
    if (json['data'] != null) {
      data = <CommentData>[];
      json['data'].forEach((v) {
        data!.add(new CommentData.fromJson(v));
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

class CommentData {
  int? id;
  String? comment;
  int? userId;
  String? userImage;
  bool? canEdit;
  String? createdAt;
  int? commentReplyCount;
  List<CommentReply>? commentReply;
  String? updatedAt;

  CommentData(
      {this.id,
        this.comment,
        this.userId,
        this.userImage,
        this.canEdit,
        this.createdAt,
        this.commentReplyCount,
        this.commentReply,
        this.updatedAt});

  CommentData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    comment = json['comment'];
    userId = json['user_id'];
    userImage = json['user_image'];
    canEdit = json['can_edit'];
    createdAt = json['created_at'];
    commentReplyCount = json['comment_reply_count'];
    if (json['comment_reply'] != null) {
      commentReply = <CommentReply>[];
      json['comment_reply'].forEach((v) {
        commentReply!.add(new CommentReply.fromJson(v));
      });
    }
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['comment'] = this.comment;
    data['user_id'] = this.userId;
    data['user_image'] = this.userImage;
    data['can_edit'] = this.canEdit;
    data['created_at'] = this.createdAt;
    data['comment_reply_count'] = this.commentReplyCount;
    if (this.commentReply != null) {
      data['comment_reply'] =
          this.commentReply!.map((v) => v.toJson()).toList();
    }
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class CommentReply {
  int? id;
  String? comment;
  int? userId;
  String? userImage;
  int? commentId;
  bool? canEdit;
  String? createdAt;
  String? updatedAt;

  CommentReply(
      {this.id,
        this.comment,
        this.userId,
        this.userImage,
        this.commentId,
        this.canEdit,
        this.createdAt,
        this.updatedAt});

  CommentReply.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    comment = json['comment'];
    userId = json['user_id'];
    userImage = json['user_image'];
    commentId = json['comment_id'];
    canEdit = json['can_edit'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['comment'] = this.comment;
    data['user_id'] = this.userId;
    data['user_image'] = this.userImage;
    data['comment_id'] = this.commentId;
    data['can_edit'] = this.canEdit;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
