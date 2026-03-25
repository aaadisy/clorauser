class AllCategory {
  int? id;
  String? name;
  String? categoryImage;
  bool? isFollowing;

  AllCategory({this.id, this.name,this.categoryImage,this.isFollowing});

  AllCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    categoryImage= json['category_image'];
    isFollowing= json['is_following'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    data['category_image']= categoryImage;
    data['is_following']=isFollowing;
    return data;
  }
}

class AllCategoryList {
  List<AllCategory>? data;

  AllCategoryList({this.data});

  AllCategoryList.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <AllCategory>[];
      json['data'].forEach((v) {
        data!.add(AllCategory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    if (data != null) {
      map['data'] = data!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
