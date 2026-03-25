class HealthExpert {
  Pagination? pagination;
  List<HealthExpertData>? data;

  HealthExpert({this.pagination, this.data});

  HealthExpert.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
    if (json['data'] != null) {
      data = <HealthExpertData>[];
      json['data'].forEach((v) {
        data!.add(new HealthExpertData.fromJson(v));
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

class HealthExpertData {
  int? id;
  String? name;
  String? email;
  String? tagLine;
  String? status;
  int? isAccess;
  String? healthExpertsImage;
  String? career;
  String? education;
  String? awardsAchievements;
  String? phone;
  String? areaExpertise;
  num? ratingAverage;
  int? ratingTotalCount;
  String? shortDescritpion;
  String? createdAt;
  String? updatedAt;
  int? experience;

  HealthExpertData(
      {this.id,
      this.name,
      this.email,
      this.tagLine,
      this.status,
      this.isAccess,
      this.healthExpertsImage,
      this.career,
      this.phone,
      this.education,
      this.experience,
      this.ratingAverage,
      this.ratingTotalCount,
      this.shortDescritpion,
      this.awardsAchievements,
      this.areaExpertise,
      this.createdAt,
      this.updatedAt});

  HealthExpertData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    tagLine = json['tag_line'];
    status = json['status'];
    isAccess = json['is_access'];
    healthExpertsImage = json['health_experts_image'];
    shortDescritpion = json['short_description'];
    career = json['career'];
    education = json['education'];
    experience = json['exprince'];
    ratingAverage = json['rating_average'];
    ratingTotalCount = json['rating_total_count'];
    phone = json['phone'];
    awardsAchievements = json['awards_achievements'];
    areaExpertise = json['area_expertise'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['tag_line'] = this.tagLine;
    data['status'] = this.status;
    data['is_access'] = this.isAccess;
    data['short_description'] = this.shortDescritpion;
    data['health_experts_image'] = this.healthExpertsImage;
    data['career'] = this.career;
    data['phone'] = this.phone;
    data['exprince'] = this.experience;
    data['rating_average'] = this.ratingAverage;
    data['rating_total_count'] = this.ratingTotalCount;
    data['education'] = this.education;
    data['awards_achievements'] = this.awardsAchievements;
    data['area_expertise'] = this.areaExpertise;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
