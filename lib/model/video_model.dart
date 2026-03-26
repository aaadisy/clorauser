class VideoModel {
  int? id;
  String? title;
  String? videoUrl;
  String? thumbnailUrl;
  String? duration;

  VideoModel({
    this.id,
    this.title,
    this.videoUrl,
    this.thumbnailUrl,
    this.duration,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      title: json['title'],
      videoUrl: json['video_url'],
      thumbnailUrl: json['thumbnail_url'],
      duration: json['video_duration']?.toString(), // ✅ safe
    );
  }
}