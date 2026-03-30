import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  int? id;
  String? firstName;
  String? lastName;
  String? displayName;
  int? age;
  String? email;
  int? goalType;
  String? goalTypeName;
  String? periodStartDate;
  int? cycleLength;
  int? periodLength;
  int? lutealPhase;
  String? userType;
  String? profileImage;
  String? loginType;
  String? playerId;
  String? timezone;
  int? isLinked;
  String? partnerName;
  String? lastNotificationSeen;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? isBackup;
  String? lastSyncDate;
  String? encryptedUserData;
  String? apiToken;
  String? uid;
  String? city;
  String? region;
  String? countryName;
  String? countryCode;
  List<String>? caseSearch;
  bool? isPresence;
  int? lastSeen;
  List<DocumentReference>? blockedTo;
  String? phoneNumber;
  Timestamp? firebaseCreatedAt;
  Timestamp? firebaseUpdatedAt;
  String? pin;
  String? streamToken;
  String? profileCompleted; // ✅ ADD THIS

  UserModel(
      {this.id,
      this.firstName,
      this.lastName,
      this.displayName,
      this.email,
      this.goalType,
      this.goalTypeName,
      this.periodStartDate,
      this.city,
      this.region,
      this.countryCode,
      this.age,
      this.countryName,
      this.cycleLength,
      this.periodLength,
      this.lutealPhase,
      this.userType,
      this.profileImage,
      this.loginType,
      this.playerId,
      this.isBackup,
      this.timezone,
      this.isLinked,
      this.lastSyncDate,
      this.encryptedUserData,
      this.partnerName,
      this.lastNotificationSeen,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.apiToken,
      this.uid,
      this.caseSearch,
      this.isPresence,
      this.lastSeen,
      this.blockedTo,
      this.phoneNumber,
      this.firebaseCreatedAt,
      this.firebaseUpdatedAt,
      this.pin,
      this.streamToken,
      this.profileCompleted,});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json['id'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        age: json['age'],
        displayName: json['display_name'],
        email: json['email'],
        goalType: json['goal_type'],
        goalTypeName: json['goal_type_name'],
        periodStartDate: json['period_start_date'],
        cycleLength: json['cycle_length'],
        periodLength: json['period_length'],
        lutealPhase: json['luteal_phase'],
        userType: json['user_type'],
        profileImage: json['profile_image'],
        loginType: json['login_type'],
        playerId: json['player_id'],
        city: json['city'],
        region: json['region'],
        countryName: json['country_name'],
        countryCode: json['country_code'],
        lastSyncDate: json['last_sync_date'],
        timezone: json['timezone'],
        encryptedUserData: json['encrypted_user_data'],
        isLinked: json['is_linked'],
        isBackup: json['is_backup'],
        partnerName: json['partner_name'],
        lastNotificationSeen: json['last_notification_seen'],
        status: json['status'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        apiToken: json['api_token'],
        uid: json['uid'],
        caseSearch: json['case_search'] != null
            ? List<String>.from(json['case_search'])
            : [],
        isPresence: json['is_present'],
        lastSeen: json['last_seen'],
        blockedTo: json['blocked_to'] != null
            ? List<DocumentReference>.from(json['blocked_to'])
            : [],
        phoneNumber: json['phone_number'],
        firebaseCreatedAt: json["firebase_created_at"],
        pin: json["pin"],
        streamToken: json['stream_token'],
        firebaseUpdatedAt: json["firebase_updated_at"],
        profileCompleted: json['profile_completed']?.toString());
  }

  get is_chat_available => null;


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['age'] = this.age;
    data['display_name'] = this.displayName;
    data['email'] = this.email;
    data['goal_type'] = this.goalType;
    data['goal_type_name'] = this.goalTypeName;
    data['period_start_date'] = this.periodStartDate;
    data['cycle_length'] = this.cycleLength;
    data['period_length'] = this.periodLength;
    data['luteal_phase'] = this.lutealPhase;
    data['user_type'] = this.userType;
    data['profile_image'] = this.profileImage;
    data['login_type'] = this.loginType;
    data['player_id'] = this.playerId;
    data['timezone'] = this.timezone;
    data['is_linked'] = this.isLinked;
    data['encrypted_user_data'] = this.encryptedUserData;
    data['partner_name'] = this.partnerName;
    data['last_notification_seen'] = this.lastNotificationSeen;
    data['status'] = this.status;
    data['last_sync_date'] = this.lastSyncDate;
    data['is_backup'] = this.isBackup;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['api_token'] = this.apiToken;
    data['uid'] = this.uid;
    data['case_search'] = this.caseSearch;
    data['is_present'] = this.isPresence;
    data['last_seen'] = this.lastSeen;
    data['blocked_to'] = this.blockedTo;
    data['phone_number'] = this.phoneNumber;
    data['firebase_created_at'] = this.firebaseCreatedAt;
    data['firebase_updated_at'] = this.firebaseUpdatedAt;
    data['pin'] = this.pin;
    data['stream_token'] = this.streamToken;

    return data;
  }
}
