import '../model/common/app_setting_model.dart';

class ServerLanguageResponse {
  bool? status;
  int? currentVersionNo;
  String? themeColor;
  AppVersionDetails? details;
  AppSettings? appSettings;
  List<LanguageJsonData>? data;
  String? revenueCatKey;

  ServerLanguageResponse(
      {this.status,
      this.data,
      this.currentVersionNo,
      this.themeColor,
      this.details,
      this.appSettings,
      this.revenueCatKey});

  ServerLanguageResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    currentVersionNo = json['version_code'];
    themeColor = json['theme_color'];
    revenueCatKey =
        json['revenueCatKey'] != null ? json['revenueCatKey'] : null;
    details = json['app_version'] != null
        ? AppVersionDetails.fromJson(json['app_version'])
        : null;
    appSettings = json['app_setting'] != null
        ? AppSettings.fromJson(json['app_setting'])
        : null;
    if (json['data'] != null) {
      data = <LanguageJsonData>[];
      json['data'].forEach((v) {
        data!.add(new LanguageJsonData.fromJson(v));
      });
    }
    // Theme Color.
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['version_code'] = this.currentVersionNo;
    data['theme_color'] = this.themeColor;
    if (details != null) {
      data['app_version'] = details!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LanguageJsonData {
  int? id;
  String? languageName;
  String? languageCode;
  String? countryCode;
  int? isRtl;
  int? isDefaultLanguage;
  List<ContentData>? contentData;
  String? createdAt;
  String? updatedAt;

  LanguageJsonData(
      {this.id,
      this.languageName,
      this.isRtl,
      this.contentData,
      this.isDefaultLanguage,
      this.createdAt,
      this.updatedAt,
      this.languageCode,
      this.countryCode});

  LanguageJsonData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    languageName = json['language_name'];
    isDefaultLanguage = json['id_default_language'];
    languageCode = json['language_code'];
    countryCode = json['country_code'];
    isRtl = json['is_rtl'];
    if (json['contentdata'] != null) {
      contentData = <ContentData>[];
      json['contentdata'].forEach((v) {
        contentData!.add(new ContentData.fromJson(v));
      });
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['language_name'] = this.languageName;
    data['country_code'] = this.countryCode;
    data['language_code'] = this.languageCode;
    data['id_default_language'] = this.isDefaultLanguage;
    data['is_rtl'] = this.isRtl;
    if (this.contentData != null) {
      data['contentdata'] = this.contentData!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class ContentData {
  int? keywordId;
  String? keywordName;
  String? keywordValue;

  ContentData({this.keywordId, this.keywordName, this.keywordValue});

  ContentData.fromJson(Map<String, dynamic> json) {
    keywordId = json['keyword_id'];
    keywordName = json['keyword_name'];
    keywordValue = json['keyword_value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['keyword_id'] = this.keywordId;
    data['keyword_name'] = this.keywordName;
    data['keyword_value'] = this.keywordValue;
    return data;
  }
}

class AppVersionDetails {
  bool? androidForceUpdate;
  int? androidVersionCode;
  String? appstoreUrl;
  bool? iosForceUpdate;
  int? iosVersion;
  String? playstoreUrl;

  AppVersionDetails(
      {this.androidForceUpdate,
      this.androidVersionCode,
      this.appstoreUrl,
      this.iosForceUpdate,
      this.iosVersion,
      this.playstoreUrl});

  AppVersionDetails.fromJson(Map<String, dynamic> json) {
    androidForceUpdate = json['android_force_update'];
    androidVersionCode = json['android_version_code'];
    appstoreUrl = json['appstore_url'];
    iosForceUpdate = json['ios_force_update'];
    iosVersion = json['ios_version'];
    playstoreUrl = json['playstore_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['android_force_update'] = this.androidForceUpdate;
    data['android_version_code'] = this.androidVersionCode;
    data['appstore_url'] = this.appstoreUrl;
    data['ios_force_update'] = this.iosForceUpdate;
    data['ios_version'] = this.iosVersion;
    data['playstore_url'] = this.playstoreUrl;
    return data;
  }
}
