class PredictionModel {
  String? title;
  String? desc;
  int? days;
  PredictionModel({this.title, this.desc, this.days});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['desc'] = this.desc;
    data['days'] = this.days;

    return data;
  }

  // A method that converts a Map into a PredictionModel.
  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
        title: json['title'], desc: json['desc'], days: json["days"]);
  }
}
