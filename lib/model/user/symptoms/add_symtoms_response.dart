class AddSymptomResponse {
  String? message;
  AddSymptomModel? data;

  AddSymptomResponse({this.message, this.data});

  AddSymptomResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null
        ? new AddSymptomModel.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class AddSymptomModel {
  int? id;
  int? userId;
  String? user;
  List<SubSymptom>? subSymptom;
  int? isPeriodStart;
  int? isPeriodEnd;
  int? flow;
  int? menstrualCramps;
  int? sex;
  int? bodyTemperature;
  int? weight;
  String? nots;
  int? water;
  String? waterType;
  String? meditation;
  String? sleep;
  String? currentDate;
  String? createdAt;
  String? updatedAt;

  AddSymptomModel(
      {this.id,
      this.userId,
      this.user,
      this.subSymptom,
      this.isPeriodStart,
      this.isPeriodEnd,
      this.flow,
      this.menstrualCramps,
      this.sex,
      this.bodyTemperature,
      this.weight,
      this.nots,
      this.water,
      this.waterType,
      this.meditation,
      this.sleep,
      this.currentDate,
      this.createdAt,
      this.updatedAt});

  AddSymptomModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    user = json['user'];
    if (json['sub_symptom'] != null) {
      subSymptom = <SubSymptom>[];
      json['sub_symptom'].forEach((v) {
        subSymptom!.add(new SubSymptom.fromJson(v));
      });
    }
    isPeriodStart = json['is_period_start'];
    isPeriodEnd = json['is_period_end'];
    flow = json['flow'];
    menstrualCramps = json['menstrual_cramps'];
    sex = json['sex'];
    bodyTemperature = json['body_temperature'];
    weight = json['weight'];
    nots = json['nots'];
    water = json['water'];
    waterType = json['water_type'];
    meditation = json['meditation'];
    sleep = json['sleep'];
    currentDate = json['current_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['user'] = this.user;
    if (this.subSymptom != null) {
      data['sub_symptom'] = this.subSymptom!.map((v) => v.toJson()).toList();
    }
    data['is_period_start'] = this.isPeriodStart;
    data['is_period_end'] = this.isPeriodEnd;
    data['flow'] = this.flow;
    data['menstrual_cramps'] = this.menstrualCramps;
    data['sex'] = this.sex;
    data['body_temperature'] = this.bodyTemperature;
    data['weight'] = this.weight;
    data['nots'] = this.nots;
    data['water'] = this.water;
    data['water_type'] = this.waterType;
    data['meditation'] = this.meditation;
    data['sleep'] = this.sleep;
    data['current_date'] = this.currentDate;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class SubSymptom {
  int? id;
  String? title;

  SubSymptom({this.id, this.title});

  SubSymptom.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    return data;
  }
}
