import 'doctor_user_model.dart';

class UpdateDoctorResponse {
  String? message;
  HealthExpertModel? data;

  UpdateDoctorResponse({this.message, this.data});

  UpdateDoctorResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null
        ? new HealthExpertModel.fromJson(json['data'])
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
