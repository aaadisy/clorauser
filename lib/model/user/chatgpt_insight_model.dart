import 'dart:convert';

class HormoneInsight {
  final String estrogen;
  final String progesterone;

  HormoneInsight({
    required this.estrogen,
    required this.progesterone,
  });

  Map<String, dynamic> toJson() {
    return {
      'estrogen': estrogen,
      'progesterone': progesterone,
    };
  }

  factory HormoneInsight.fromJson(Map<String, dynamic> json) {
    return HormoneInsight(
      estrogen: json['estrogen'] ?? 'No estrogen data',
      progesterone: json['progesterone'] ?? 'No progesterone data',
    );
  }
}

class ChatGptInsight {
  final String? status;
  final String? overview;
  final HormoneInsight? hormones;
  final List<String>? healthTips;
  final List<String>? nutritionTips;
  final List<String>? physicalSymptoms;
  final List<String>? moodChanges;
  final List<String>? exerciseRecommendations;
  final List<String>? selfCareTips;
  final List<String>? skin;
  final List<String>? hydration;
  final List<String>? energy;
  final List<String>? motivation;
  final List<String>? fitness;
  final List<String>? social;
  final List<String>? calm;
  final List<String>? sleep;

  // Pregnancy-specific fields
  final List<String>? pregnancyChecklist;
  final List<String>? pregnancySymptoms;
  final String? massOfBaby;
  final String? babyGrowth;
  final List<String>? highlightsOfWeek;

  ChatGptInsight({
    this.status,
    this.overview,
    this.hormones,
    this.healthTips,
    this.nutritionTips,
    this.physicalSymptoms,
    this.moodChanges,
    this.exerciseRecommendations,
    this.selfCareTips,
    this.skin,
    this.hydration,
    this.energy,
    this.motivation,
    this.fitness,
    this.social,
    this.calm,
    this.sleep,
    // Pregnancy fields
    this.pregnancyChecklist,
    this.pregnancySymptoms,
    this.massOfBaby,
    this.babyGrowth,
    this.highlightsOfWeek,
  });

  factory ChatGptInsight.fromJson(Map<String, dynamic> json) {
    return ChatGptInsight(
      status: json['status'],
      overview: json['overview'],
      hormones: json['hormones'] != null
          ? HormoneInsight.fromJson(json['hormones'])
          : null,
      healthTips: _parseStringList(json['health_tips']),
      nutritionTips: _parseStringList(json['nutrition']),
      physicalSymptoms: _parseStringList(json['physical_symptoms']),
      moodChanges: _parseStringList(json['mood_changes']),
      exerciseRecommendations: _parseStringList(json['exercise']),
      selfCareTips: _parseStringList(json['self_care']),
      skin: _parseStringList(json['skin']),
      hydration: _parseStringList(json['hydration']),
      energy: _parseStringList(json['energy']),
      motivation: _parseStringList(json['motivation']),
      fitness: _parseStringList(json['fitness']),
      social: _parseStringList(json['social']),
      calm: _parseStringList(json['calm']),
      sleep: _parseStringList(json['sleep']),
      // Pregnancy fields
      pregnancyChecklist: _parseStringList(json['pregnancy_checklist']),
      pregnancySymptoms: _parseStringList(json['pregnancy_symptoms']),
      massOfBaby: json['mass_of_baby'],
      babyGrowth: json['baby_growth'],
      highlightsOfWeek: _parseStringList(json['highlights_of_week']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'overview': overview,
      'hormones': hormones?.toJson(),
      'health_tips': healthTips,
      'nutrition': nutritionTips,
      'physical_symptoms': physicalSymptoms,
      'mood_changes': moodChanges,
      'exercise': exerciseRecommendations,
      'self_care': selfCareTips,
      'skin': skin,
      'hydration': hydration,
      'energy': energy,
      'motivation': motivation,
      'fitness': fitness,
      'social': social,
      'calm': calm,
      'sleep': sleep,
      // Pregnancy fields
      'pregnancy_checklist': pregnancyChecklist,
      'pregnancy_symptoms': pregnancySymptoms,
      'mass_of_baby': massOfBaby,
      'baby_growth': babyGrowth,
      'highlights_of_week': highlightsOfWeek,
    };
  }

  static List<String>? _parseStringList(dynamic data) {
    if (data == null) return null;
    if (data is List) {
      return List<String>.from(data.map((item) => item.toString()));
    }
    return null;
  }


  static ChatGptInsight? parseCachedResponse(String? cachedResponse) {
    if (cachedResponse == null || cachedResponse.trim().isEmpty) {
      return null;
    }

    try {
      final decodedJson = jsonDecode(cachedResponse);
      if (decodedJson is! Map<String, dynamic>) {
        return null;
      }
      return ChatGptInsight.fromJson(decodedJson);
    } catch (e, stackTrace) {
      return null;
    }
  }

  bool get isPregnancyData => pregnancyChecklist != null;
}
