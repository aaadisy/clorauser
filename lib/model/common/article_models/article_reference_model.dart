class ArticleReference {
  int? id;
  String? referenceName;

  ArticleReference({this.id, this.referenceName});

  ArticleReference.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    referenceName = json['reference_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['reference_name'] = this.referenceName;
    return data;
  }
}
