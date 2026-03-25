import 'doctor_user_model.dart'; // Ensure this import is correct

class DoctorResponse {
  bool? status;
  String? message;
  HealthExpertModel? data;

  DoctorResponse({this.status, this.message, this.data});

  DoctorResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? HealthExpertModel.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}
