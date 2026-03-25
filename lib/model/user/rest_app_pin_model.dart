class ResetAppPinModel {
  final String message;
  final String code;
  final bool status;

  ResetAppPinModel({
    required this.message,
    required this.code,
    required this.status,
  });

  factory ResetAppPinModel.fromJson(Map<String, dynamic> json) {
    return ResetAppPinModel(
      message: json['message'] ?? '',
      code: json['code'] ?? '',
      status: json['status'] ?? false,
    );
  }
}
