import '../../common/article_models/article_model.dart';
import 'category_list_response.dart';

class CategoryDataResponse {
  int? id;
  String? title;
  String? description;
  String? categoryImage;
  String? createdAt;
  List<ImageSection>? imageSection;
  List<InfoSections>? infoSections;
  List<CommonQueSectionData>? commonQueSectionData;
  List<SectionDataMainList>? sectionDataMainList;

  CategoryDataResponse(
      {this.id,
      this.title,
      this.description,
      this.categoryImage,
      this.createdAt,
      this.imageSection,
      this.infoSections,
      this.commonQueSectionData,
      this.sectionDataMainList});

  CategoryDataResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    categoryImage = json['category_image'];
    createdAt = json['created_at'];
    if (json['image_section'] != null) {
      imageSection = <ImageSection>[];
      json['image_section'].forEach((v) {
        imageSection!.add(new ImageSection.fromJson(v));
      });
    }
    if (json['info_sections'] != null) {
      infoSections = <InfoSections>[];
      json['info_sections'].forEach((v) {
        infoSections!.add(new InfoSections.fromJson(v));
      });
    }
    if (json['common_que_section_data'] != null) {
      commonQueSectionData = <CommonQueSectionData>[];
      json['common_que_section_data'].forEach((v) {
        commonQueSectionData!.add(new CommonQueSectionData.fromJson(v));
      });
    }
    if (json['section_data_main_list'] != null) {
      sectionDataMainList = <SectionDataMainList>[];
      json['section_data_main_list'].forEach((v) {
        sectionDataMainList!.add(new SectionDataMainList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['category_image'] = this.categoryImage;
    data['created_at'] = this.createdAt;
    if (this.imageSection != null) {
      data['image_section'] =
          this.imageSection!.map((v) => v.toJson()).toList();
    }
    if (this.infoSections != null) {
      data['info_sections'] =
          this.infoSections!.map((v) => v.toJson()).toList();
    }
    if (this.commonQueSectionData != null) {
      data['common_que_section_data'] =
          this.commonQueSectionData!.map((v) => v.toJson()).toList();
    }
    if (this.sectionDataMainList != null) {
      data['section_data_main_list'] =
          this.sectionDataMainList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ImageSection {
  int? id;
  String? title;
  String? goalType;
  Article? article;
  Null url;
  String? imageSectionThumbnailImage;

  ImageSection(
      {this.id,
      this.title,
      this.goalType,
      this.article,
      this.url,
      this.imageSectionThumbnailImage});

  ImageSection.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    goalType = json['goal_type'];
    article =
        json['article'] != null ? Article.fromJson(json['article']) : null;
    url = json['url'];
    imageSectionThumbnailImage = json['image_section_thumbnail_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['goal_type'] = this.goalType;
    if (article != null) {
      data['article'] = article!.toJson();
    }
    data['url'] = this.url;
    data['image_section_thumbnail_image'] = this.imageSectionThumbnailImage;
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

class InfoSections {
  int? id;
  String? title;
  String? description;
  String? infoSectionImage;

  InfoSections({this.id, this.title, this.description, this.infoSectionImage});

  InfoSections.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    infoSectionImage = json['info_section_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['info_section_image'] = this.infoSectionImage;
    return data;
  }
}

class CommonQueSectionData {
  int? id;
  String? question;
  String? answer;
  String? url;
  int? status;
  Article? article;

  CommonQueSectionData(
      {this.id,
      this.question,
      this.answer,
      this.url,
      this.status,
      this.article});

  CommonQueSectionData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    answer = json['answer'];
    url = json['url'];
    status = json['status'];
    article =
        json['article'] != null ? new Article.fromJson(json['article']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['question'] = this.question;
    data['answer'] = this.answer;
    return data;
  }
}

class SectionDataMainList {
  int? id;
  String? title;
  int? categoryId;
  String? categoryName;
  List<SubSectionData>? subSectionData;
  //List<SubSectionData>? subSectionData;

  SectionDataMainList(
      {this.id,
      this.title,
      this.categoryId,
      this.categoryName,
      this.subSectionData});

  SectionDataMainList.fromJson(Map<String, dynamic> json) {
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
