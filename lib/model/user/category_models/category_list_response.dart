import '../../common/article_models/article_model.dart';

class CategoryListResponse {
  List<CategoryData>? categoryData;
  List<SectionData>? sectionData;

  CategoryListResponse({this.categoryData, this.sectionData});

  CategoryListResponse.fromJson(Map<String, dynamic> json) {
    if (json['category_data'] != null) {
      categoryData = <CategoryData>[];
      json['category_data'].forEach((v) {
        categoryData!.add(new CategoryData.fromJson(v));
      });
    }
    if (json['section_data'] != null) {
      sectionData = <SectionData>[];
      json['section_data'].forEach((v) {
        sectionData!.add(new SectionData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.categoryData != null) {
      data['category_data'] =
          this.categoryData!.map((v) => v.toJson()).toList();
    }
    if (this.sectionData != null) {
      data['section_data'] = this.sectionData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CategoryData {
  int? id;
  String? title;
  int? goalType;
  String? goalTypeName;
  String? description;
  String? categoryImage;
  String? categoryThumbnailImage;
  String? createdAt;

  CategoryData(
      {this.id,
      this.title,
      this.goalType,
      this.goalTypeName,
      this.description,
      this.categoryImage,
      this.categoryThumbnailImage,
      this.createdAt});

  CategoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    goalType = json['goal_type'];
    goalTypeName = json['goal_type_name'];
    description = json['description'];
    categoryImage = json['category_image'];
    categoryThumbnailImage = json['category_thumbnail_image'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['goal_type'] = this.goalType;
    data['goal_type_name'] = this.goalTypeName;
    data['description'] = this.description;
    data['category_image'] = this.categoryImage;
    data['category_thumbnail_image'] = this.categoryThumbnailImage;
    data['created_at'] = this.createdAt;
    return data;
  }
}

class SectionData {
  int? id;
  String? title;
  int? categoryId;
  String? categoryName;
  List<SubSectionData>? subSectionData;

  SectionData(
      {this.id,
      this.title,
      this.categoryId,
      this.categoryName,
      this.subSectionData});

  SectionData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    if (json['sub_section_data'] != null) {
      subSectionData = <SubSectionData>[];
      json['sub_section_data'].forEach((v) {
        subSectionData!.add(new SubSectionData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['category_id'] = this.categoryId;
    data['category_name'] = this.categoryName;
    if (this.subSectionData != null) {
      data['sub_section_data'] =
          this.subSectionData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubSectionData {
  int? id;
  String? title;
  int? viewType;
  String? viewTypeName;
  String? description;
  int? categoryId;
  String? categoryName;
  String? url;
  List<Article>? article;
  String? sectionDataImage;
  List<SectionDataStoryImage>? sectionDataStoryImage;
  List<SectionDataVideo>? sectionDataVideo;
  String? sectionDataPodcast;
  int? status;

  SubSectionData(
      {this.id,
      this.title,
      this.viewType,
      this.viewTypeName,
      this.description,
      this.categoryId,
      this.categoryName,
      this.url,
      this.article,
      this.sectionDataImage,
      this.sectionDataStoryImage,
      this.sectionDataVideo,
      this.sectionDataPodcast,
      this.status});

  SubSectionData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    viewType = json['view_type'];
    viewTypeName = json['view_type_name'];
    description = json['description'];
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    url = json['url'];
    if (json['article'] != null) {
      article = <Article>[];
      json['article'].forEach((v) {
        article!.add(new Article.fromJson(v));
      });
    }
    sectionDataImage = json['section_data_image'];
    if (json['section_data_story_image'] != null) {
      sectionDataStoryImage = <SectionDataStoryImage>[];
      json['section_data_story_image'].forEach((v) {
        sectionDataStoryImage!.add(new SectionDataStoryImage.fromJson(v));
      });
    }
    if (json['section_data_video'] != null) {
      sectionDataVideo = <SectionDataVideo>[];
      json['section_data_video'].forEach((v) {
        sectionDataVideo!.add(new SectionDataVideo.fromJson(v));
      });
    }
    sectionDataPodcast = json['section_data_podcast'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['view_type'] = this.viewType;
    data['view_type_name'] = this.viewTypeName;
    data['description'] = this.description;
    data['category_id'] = this.categoryId;
    data['category_name'] = this.categoryName;
    data['url'] = this.url;
    if (this.article != null) {
      data['article'] = this.article!.map((v) => v.toJson()).toList();
    }
    data['section_data_image'] = this.sectionDataImage;
    if (this.sectionDataStoryImage != null) {
      data['section_data_story_image'] =
          this.sectionDataStoryImage!.map((v) => v.toJson()).toList();
    }
    if (this.sectionDataVideo != null) {
      data['section_data_video'] =
          this.sectionDataVideo!.map((v) => v.toJson()).toList();
    }
    data['section_data_podcast'] = this.sectionDataPodcast;
    data['status'] = this.status;
    return data;
  }
}

class SectionDataStoryImage {
  int? id;
  String? url;

  SectionDataStoryImage({this.id, this.url});

  SectionDataStoryImage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['url'] = this.url;
    return data;
  }
}

class SectionDataVideo {
  int? id;
  String? videoTitle;
  String? videoDuration;
  String? thumbnailImage;
  String? fileUrl;

  SectionDataVideo(
      {this.id,
      this.videoTitle,
      this.videoDuration,
      this.thumbnailImage,
      this.fileUrl});

  SectionDataVideo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    videoTitle = json['video_title'];
    videoDuration = json['video_duration'];
    thumbnailImage = json['thumbnail_image'];
    fileUrl = json['file_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['video_title'] = this.videoTitle;
    data['video_duration'] = this.videoDuration;
    data['thumbnail_image'] = this.thumbnailImage;
    data['file_url'] = this.fileUrl;
    return data;
  }
}
