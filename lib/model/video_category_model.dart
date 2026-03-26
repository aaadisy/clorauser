import 'package:clora_user/model/video_model.dart';

class VideoCategoryModel {
  int? id;
  String? name;
  String? thumbnailUrl;
  List<VideoModel> videos; // ✅ always list

  VideoCategoryModel({
    this.id,
    this.name,
    this.thumbnailUrl,
    required this.videos,
  });

  factory VideoCategoryModel.fromJson(Map<String, dynamic> json) {
    return VideoCategoryModel(
      id: json['id'],
      name: json['name'],
      thumbnailUrl: json['thumbnail_url'],
      videos: json['videos'] != null
          ? List<VideoModel>.from(
        json['videos'].map((v) => VideoModel.fromJson(v)),
      )
          : [], // ✅ null safe
    );
  }
}