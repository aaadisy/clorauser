class HealthExpertModel {
  int? id;
  String? name;
  String? email;
  String? tagLine;
  String? status;
  int? isAccess;
  String? healthExpertsImage;
  String? shortDescription;
  String? career;
  String? education;
  String? awardsAchievements;
  String? areaExpertise;
  String? apiToken;
  DoctorSchedule? doctorSchedule;

  HealthExpertModel(
      {this.id,
      this.name,
      this.email,
      this.tagLine,
      this.status,
      this.isAccess,
      this.healthExpertsImage,
      this.shortDescription,
      this.career,
      this.education,
      this.awardsAchievements,
      this.areaExpertise,
      this.apiToken,
      this.doctorSchedule});

  HealthExpertModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    tagLine = json['tag_line'];
    status = json['status'];
    isAccess = json['is_access'];
    healthExpertsImage = json['health_experts_image'];
    shortDescription = json['short_description'];
    career = json['career'];
    education = json['education'];
    awardsAchievements = json['awards_achievements'];
    areaExpertise = json['area_expertise'];
    apiToken = json['api_token'];
    doctorSchedule = json['doctor_schedule'] != null
        ? DoctorSchedule.fromJson(json['doctor_schedule'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['tag_line'] = this.tagLine;
    data['status'] = this.status;
    data['is_access'] = this.isAccess;
    data['health_experts_image'] = this.healthExpertsImage;
    data['short_description'] = this.shortDescription;
    data['career'] = this.career;
    data['education'] = this.education;
    data['awards_achievements'] = this.awardsAchievements;
    data['area_expertise'] = this.areaExpertise;
    data['api_token'] = this.apiToken;
    if (this.doctorSchedule != null) {
      data['doctor_schedule'] = this.doctorSchedule?.toJson();
    }
    return data;
  }
}

class DoctorSchedule {
  Map<String, Map<String, TimeSlot>> doctorSchedule;

  DoctorSchedule({required this.doctorSchedule});

  factory DoctorSchedule.fromJson(Map<String, dynamic> json) {
    return DoctorSchedule(
      doctorSchedule: Map.fromEntries(
        json.entries.map(
          (e) => MapEntry(
            e.key,
            Map.fromEntries(
              (e.value as Map<String, dynamic>).entries.map(
                    (e) => MapEntry(
                      e.key,
                      TimeSlot.fromJson(e.value),
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_schedule': Map.fromEntries(
        doctorSchedule.entries.map(
          (e) => MapEntry(
            e.key,
            Map.fromEntries(
              e.value.entries.map(
                (e) => MapEntry(e.key, e.value.toJson()),
              ),
            ),
          ),
        ),
      ),
    };
  }
}

class TimeSlot {
  int? userId;

  TimeSlot({this.userId});

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
    };
  }
}
