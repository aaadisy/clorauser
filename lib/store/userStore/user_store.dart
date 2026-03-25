
import 'package:clora_user/model/user/user_models/user_model.dart';
import 'package:mobx/mobx.dart';

import '../../extensions/shared_pref.dart';
import '../../model/doctor/doctor_models/doctor_user_model.dart';
import '../../utils/app_constants.dart';

part 'user_store.g.dart';

class UserStore = UserStoreBase with _$UserStore;

abstract class UserStoreBase with Store {
  @observable
  bool isLoggedIn = false;

  @observable
  int userId = 0;

  @observable
  String email = '';

  @observable
  String password = '';

  @observable
  String fName = '';

  @observable
  String lName = '';

  @observable
  String profileImage = '';

  @observable
  String token = '';

  @observable
  String username = '';

  @observable
  int goalIndex = 0;

  @observable
  DateTime? selectedDateTime;

  @observable
  int cycleLength = 0;

  @observable
  int periodsLength = 0;

  @observable
  int lutealPhase = 0;

  @observable
  String periodDate = "";

  @observable
  int hourIndex = 0;

  @observable
  int minuteIndex = 0;

  @observable
  String time = "";

  @observable
  bool periodReminder = false;

  @observable
  bool fertilityReminder = false;

  @observable
  bool ovulationReminder = false;

  @observable
  int chatNotificationCount = 0;

  @observable
  String DrName = "";

  @observable
  String DrDesc = "";

  @observable
  String DrTagline = "";

  @observable
  String DRprofileImage = "";

  @observable
  String DrCareer = "";

  @observable
  String DrEducation = "";

  @observable
  String DrAwards = "";

  @observable
  String DrExpertise = "";

  @observable
  String DrEmail = '';

  @observable
  String DrPassword = '';

  @observable
  bool isDrLoggedIn = false;

  @observable
  String LoginUsertype = '';

  @observable
  UserModel? user = null;

  @observable
  HealthExpertModel? doctor = null;

  @action
  Future<void> setDoctorData(HealthExpertModel doctorData,
      {bool isInitialization = false}) async {
    doctor = doctorData;
  }

  @action
  Future<void> setUserModelData(UserModel userData,
      {bool isInitialization = false}) async {
    user = userData;
  }

  @action
  Future<void> setDrName(String val, {bool isInitialization = false}) async {
    DrName = val;
    if (!isInitialization) await setValue(DR_NAME, val);
  }

  @action
  Future<void> setDrDesc(String val, {bool isInitialization = false}) async {
    DrDesc = val;
    if (!isInitialization) await setValue(DR_DESC, val);
  }

  @action
  Future<void> setDrTagline(String val, {bool isInitialization = false}) async {
    DrTagline = val;
    if (!isInitialization) await setValue(DR_TAGLINE, val);
  }

  @action
  Future<void> setDRprofileImage(String val,
      {bool isInitialization = false}) async {
    DRprofileImage = val;
    if (!isInitialization) await setValue(DR_PROFILE_IMG, val);
  }

  @action
  Future<void> setDrCareer(String val, {bool isInitialization = false}) async {
    DrCareer = val;
    if (!isInitialization) await setValue(DR_CAREER, val);
  }

  @action
  Future<void> setDrEducation(String val,
      {bool isInitialization = false}) async {
    DrEducation = val;
    if (!isInitialization) await setValue(DR_EDUCATION, val);
  }

  @action
  Future<void> setDrAwards(String val, {bool isInitialization = false}) async {
    DrAwards = val;
    if (!isInitialization) await setValue(DR_AWARDS, val);
  }

  @action
  Future<void> setDrExpertise(String val,
      {bool isInitialization = false}) async {
    DrExpertise = val;
    if (!isInitialization) await setValue(DR_EXPERTISE, val);
  }

  @action
  Future<void> setUserDrEmail(String val,
      {bool isInitialization = false}) async {
    DrEmail = val;
    if (!isInitialization) await setValue(DR_EMAIL, val);
  }

  @action
  Future<void> setDrPassword(String val,
      {bool isInitialization = false}) async {
    DrPassword = val;
    if (!isInitialization) await setValue(DR_PASSWORD, val);
  }

  @action
  Future<void> setLoginUsertype(String val,
      {bool isInitialization = false}) async {
    LoginUsertype = val;
    if (!isInitialization) await setValue("", val);
  }

/*  @action
  Future<PaidUserDetails> setPaidUserDetails(PaidUserDetails val,
      {bool isInitialization = false}) async {
    paidUserDetails = val;
    if (!isInitialization) await setValue("", val);
  }*/

  @action
  Future<void> setHourIndex(int val, {bool isInitialization = false}) async {
    hourIndex = val;
    if (!isInitialization) await setValue(HOUR_INDEX, val);
  }

  @action
  Future<void> setMinuteIndex(int val, {bool isInitialization = false}) async {
    minuteIndex = val;
    if (!isInitialization) await setValue(MINUTE_INDEX, val);
  }

  @action
  Future<void> setTime(int val, int val1,
      {bool isInitialization = false}) async {
    time =
        val.toString().padLeft(2, '0') + ':' + val1.toString().padLeft(2, '0');
    if (!isInitialization) await setValue(TEST_TIME, time);
  }

  @action
  Future<void> setPeriodDate(String val,
      {bool isInitialization = false}) async {
    periodDate = val;
    if (!isInitialization) await setValue(PERIOD_START_DATE, val);
  }

  @action
  Future<void> setPeriodStartDate(DateTime dateTime) async {
    selectedDateTime = dateTime;
  }

  @action
  Future<void> setGoal(int val, {bool isInitialization = false}) async {
    goalIndex = val;
    if (!isInitialization) await setValue(GOAL, val);
  }

  @action
  Future<void> setCycleLength(int val, {bool isInitialization = false}) async {
    cycleLength = val;
    if (!isInitialization) await setValue(CYCLE_LENGTH, val);
  }

  @action
  Future<void> setPeriodsLength(int val,
      {bool isInitialization = false}) async {
    periodsLength = val;
    if (!isInitialization) await setValue(PERIOD_LENGTH, val);
  }

  @action
  Future<void> setLutealPhase(int val, {bool isInitialization = false}) async {
    lutealPhase = val;
    if (!isInitialization) await setValue(LUTEAL_PHASE, val);
  }

  @action
  Future<void> setUsername(String val, {bool isInitialization = false}) async {
    username = val;
    if (!isInitialization) await setValue(USERNAME, val);
  }

  @action
  Future<void> setToken(String val, {bool isInitialization = false}) async {
    token = val;
    if (!isInitialization) await setValue(TOKEN, val);
  }

  @action
  Future<void> setUserImage(String val, {bool isInitialization = false}) async {
    profileImage = val;
    if (!isInitialization) await setValue(USER_PROFILE_IMG, val);
  }

  @action
  Future<void> setUserID(int val, {bool isInitialization = false}) async {
    userId = val;
    if (!isInitialization) await setValue(USER_ID, val);
  }

  @action
  Future<void> setLogin(bool val, {bool isInitializing = false}) async {
    isLoggedIn = val;
    if (!isInitializing) await setValue(IS_LOGIN, val);
  }

  @action
  Future<void> setFirstName(String val, {bool isInitialization = false}) async {
    fName = val;
    if (!isInitialization) await setValue(FIRSTNAME, val);
  }

  @action
  Future<void> setLastName(String val, {bool isInitialization = false}) async {
    lName = val;
    if (!isInitialization) await setValue(LASTNAME, val);
  }

  @action
  Future<void> setUserEmail(String val, {bool isInitialization = false}) async {
    email = val;
    if (!isInitialization) await setValue(EMAIL, val);
  }

  @action
  Future<void> setUserPassword(String val,
      {bool isInitialization = false}) async {
    password = val;
    if (!isInitialization) await setValue(PASSWORD, val);
  }

  @action
  Future<void> clearUserData() async {
    fName = '';
    lName = '';
    profileImage = '';
    token = '';
    username = '';
  }
}
