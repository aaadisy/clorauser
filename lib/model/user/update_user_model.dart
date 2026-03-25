import 'package:clora_user/model/user/user_models/user_model.dart';

class UpdateUserModel {
  bool? status;
  UserModel? data;
  String? message;

  UpdateUserModel({
    this.status,
    this.data,
    this.message,
  });

  // Factory constructor to create an instance from a JSON map
  factory UpdateUserModel.fromJson(Map<String, dynamic> json) {
    return UpdateUserModel(
      status: json['status'],
      data: json['data'] != null ? UserModel.fromJson(json['data']) : null,
      message: json['message'],
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.toJson(),
      'message': message,
    };
  }
}
