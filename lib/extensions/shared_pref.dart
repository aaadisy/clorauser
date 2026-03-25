import 'dart:convert';

import 'package:clora_user/model/user/user_models/user_model.dart';
import 'package:menstrual_cycle_widget/utils/enumeration.dart';

import '../../extensions/extension_util/bool_extensions.dart';
import '../../extensions/extension_util/double_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import 'constants.dart';

/// Returns SharedPref Instance
Future<SharedPreferences> getSharedPref() async {
  return await SharedPreferences.getInstance();
}

/// Add a value in SharedPref based on their type - Must be a String, int, bool, double, Map<String, dynamic> or StringList
Future<bool> setValue(String key, dynamic value, {bool print = true}) async {
  if (value is String) {
    return await sharedPreferences.setString(key, value.validate());
  } else if (value is int) {
    return await sharedPreferences.setInt(key, value.validate());
  } else if (value is bool) {
    return await sharedPreferences.setBool(key, value.validate());
  } else if (value is double) {
    return await sharedPreferences.setDouble(key, value.validate());
  } else if (value is Map<String, dynamic>) {
    return await sharedPreferences.setString(key, jsonEncode(value));
  } else if (value is List<String>) {
    return await sharedPreferences.setStringList(key, value);
  } else {
    throw ArgumentError(
        'Invalid value ${value.runtimeType} - Must be a String, int, bool, double, Map<String, dynamic> or StringList');
  }
}

Future<void> saveUserToLocalStorage(UserModel user) async {
  final prefs = await SharedPreferences.getInstance();
  final userJson = user.toJson(); // Convert to Map
  final userString = jsonEncode(userJson); // Convert to String
  await prefs.setString('user', userString); // Store in SharedPreferences
}

Future<UserModel?> getUserFromLocalStorage() async {
  final prefs = await SharedPreferences.getInstance();
  final userString = prefs.getString('user');
  if (userString == null) return null;

  final userJson = jsonDecode(userString);
  return UserModel.fromJson(userJson);
}

/// Returns List of Keys that matches with given Key
List<String> getMatchingSharedPrefKeys(String key) {
  List<String> keys = [];

  sharedPreferences.getKeys().forEach((element) {
    if (element.contains(key)) {
      keys.add(element);
    }
  });

  return keys;
}

/// Returns a StringList if exists in SharedPref
List<String>? getStringListAsync(String key) {
  return sharedPreferences.getStringList(key);
}

/// Returns a Bool if exists in SharedPref
bool getBoolAsync(String key, {bool defaultValue = false}) {
  final value = sharedPreferences.get(key);
  if (value is String) {
    return false;
  }
  return value as bool? ?? defaultValue;
}

/// Returns a Double if exists in SharedPref
double getDoubleAsync(String key, {double defaultValue = 0.0}) {
  return sharedPreferences.getDouble(key) ?? defaultValue;
}

/// Returns a Int if exists in SharedPref
int getIntAsync(String key, {int defaultValue = 0}) {
  return sharedPreferences.getInt(key) ?? defaultValue;
}

/// Returns a String if exists in SharedPref
String getStringAsync(String key, {String defaultValue = ''}) {
  return sharedPreferences.getString(key) ?? defaultValue;
}

/// Returns a JSON if exists in SharedPref
Map<String, dynamic> getJSONAsync(String key,
    {Map<String, dynamic>? defaultValue}) {
  if (sharedPreferences.containsKey(key) &&
      sharedPreferences.getString(key).validate().isNotEmpty) {
    return jsonDecode(sharedPreferences.getString(key)!);
  } else {
    return defaultValue ?? {};
  }
}

/// remove key from SharedPref
Future<bool> removeKey(String key) async {
  return await sharedPreferences.remove(key);
}

/// clear SharedPref
Future<bool> clearSharedPref() async {
  return await sharedPreferences.clear();
}

/////////////////////////////////////////////////////////////////////// DEPRECATED \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

/// add a Double in SharedPref
@Deprecated('Use setValue instead')
Future<bool> setDoubleAsync(String key, double value) async {
  return await sharedPreferences.setDouble(key, value);
}

/// add a Bool in SharedPref
@Deprecated('Use setValue instead')
Future<bool> setBoolAsync(String key, bool value) async {
  return await sharedPreferences.setBool(key, value);
}

/// add a Int in SharedPref
@Deprecated('Use setValue instead')
Future<bool> setIntAsync(String key, int value) async {
  return await sharedPreferences.setInt(key, value);
}

/// add a String in SharedPref
@Deprecated('Use setValue instead')
Future<bool> setStringAsync(String key, String value) async {
  return await sharedPreferences.setString(key, value);
}

/// add a JSON in SharedPref
@Deprecated('Use setValue instead')
Future<bool> setJSONAsync(String key, String value) async {
  return await sharedPreferences.setString(key, jsonEncode(value));
}

/// Returns a String if exists in SharedPref
@Deprecated('Use getStringAsync instead without using await')
Future<String> getString(String key, {defaultValue = ''}) async {
  return await getSharedPref().then((pref) {
    return pref.getString(key) ?? defaultValue;
  });
}

/// Returns a Int if exists in SharedPref
@Deprecated('Use getIntAsync instead without using await')
Future<int> getInt(String key, {defaultValue = 0}) async {
  return await getSharedPref().then((pref) {
    return pref.getInt(key) ?? defaultValue;
  });
}

/// Returns a Double if exists in SharedPref
@Deprecated('Use getDoubleAsync instead without using await')
Future<double> getDouble(String key, {defaultValue = 0.0}) async {
  return await getSharedPref().then((pref) {
    return pref.getDouble(key) ?? defaultValue;
  });
}

/// Returns a Bool if exists in SharedPref
@Deprecated('Use getBoolAsync instead without using await')
Future<bool> getBool(String key, {defaultValue = false}) async {
  return await getSharedPref().then((pref) {
    return pref.getBool(key) ?? defaultValue;
  });
}

/// add a String in SharedPref
@Deprecated('Use setValue instead')
Future<bool> setString(String key, String value) async {
  return await getSharedPref().then((pref) async {
    return await pref.setString(key, value);
  });
}

/// add a Int in SharedPref
@Deprecated('Use setValue instead')
Future<bool> setInt(String key, int value) async {
  return await getSharedPref().then((pref) async {
    return await pref.setInt(key, value);
  });
}

/// add a Bool in SharedPref
@Deprecated('Use setValue instead')
Future<bool> setBool(String key, bool value) async {
  return await getSharedPref().then((pref) async {
    return await pref.setBool(key, value);
  });
}

/// add a Double in SharedPref
@Deprecated('Use setValue instead')
Future<bool> setDouble(String key, double value) async {
  return await getSharedPref().then((pref) async {
    return await pref.setDouble(key, value);
  });
}

Future<MenstrualCycleTheme?> getCycleTheme() async {
  final cycleThemeString = getStringAsync(MENSTRUAL_CYCLE_THEME);
  if (cycleThemeString.isNotEmpty) {
    return MenstrualCycleTheme.values.firstWhere(
      (e) => e.toString().split('.').last == cycleThemeString,
      orElse: () => MenstrualCycleTheme.arcs,
    );
  }
  return null;
}

Future<PhaseTextBoundaries?> getPhaseText() async {
  final phaseTextString = getStringAsync(PHASE_TEXT_BOUNDARIES);
  if (phaseTextString.isNotEmpty) {
    return PhaseTextBoundaries.values.firstWhere(
      (e) => e.toString().split('.').last == phaseTextString,
      orElse: () => PhaseTextBoundaries.outside,
    );
  }
  return null;
}

Future<MenstrualCycleViewType?> getViewText() async {
  final viewTextString = getStringAsync(MENSTRUAL_WIDGET_VIEW_TYPE);
  if (viewTextString.isNotEmpty) {
    return MenstrualCycleViewType.values.firstWhere(
      (e) => e.toString().split('.').last == viewTextString,
      orElse: () => MenstrualCycleViewType.text,
    );
  }
  return null;
}
