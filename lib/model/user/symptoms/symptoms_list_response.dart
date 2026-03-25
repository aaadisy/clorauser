class SymptomsListResponse {
  List<SymptomsListModel>? data;

  SymptomsListResponse({this.data});

  SymptomsListResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <SymptomsListModel>[];
      json['data'].forEach((v) {
        data!.add(new SymptomsListModel.fromJson(v));
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

class SymptomsListModel {
  int? id;
  String? title;
  String? bgColor;
  String? createdAt;

  SymptomsListModel({this.id, this.title, this.bgColor, this.createdAt});

  SymptomsListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    bgColor = json['bg_color'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['bg_color'] = this.bgColor;
    data['created_at'] = this.createdAt;
    return data;
  }
}
