class BackupRestoreResponse {
  final bool status;
  final String message;
  final BackupData? data;

  BackupRestoreResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory BackupRestoreResponse.fromJson(Map<String, dynamic> json) {
    return BackupRestoreResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? BackupData.fromJson(json['data']) : null,
    );
  }
}

class BackupData {
  final String isBackup;
  final String encryptedUserData;
  final String lastSyncDate;

  BackupData({
    required this.isBackup,
    required this.encryptedUserData,
    required this.lastSyncDate,
  });

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      isBackup: json['is_backup'] ?? '',
      encryptedUserData: json['encrypted_user_data'] ?? '',
      lastSyncDate: json['last_sync_date'] ?? '',
    );
  }
}
