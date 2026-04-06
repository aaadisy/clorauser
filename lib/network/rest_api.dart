import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:terminate_restart/terminate_restart.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/model/user/faq_model.dart';
import 'package:clora_user/service/reminder_service.dart';
import 'package:http/http.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../languageConfiguration/ServerLanguageResponse.dart';
import '../main.dart';
import '../model/bookmark_response_model.dart';
import '../model/common/app_setting_model.dart';
import '../model/common/default_message_response.dart';
import '../model/doctor/doctor_models/doctor_dashboard_model.dart';
import '../model/doctor/doctor_models/doctor_response.dart';
import '../model/doctor/doctor_models/health_expert_model.dart';
import '../model/common/article_models/article_response.dart';
import '../model/user/bookmark_model.dart';
import '../model/user/calculator_model.dart';
import '../model/user/category_models/all_category_model.dart';
import '../model/user/category_models/category_data_response.dart';
import '../model/user/category_models/comment_list_response.dart';
import '../model/user/category_models/secret_chat_response.dart';
import '../model/user/dashboard_article_model.dart';
import '../model/user/dashboard_response.dart';
import '../model/model.dart';
import '../model/user/expert_question_list_model.dart';
import '../model/user/rest_app_pin_model.dart';
import '../model/user/restore_data_model.dart';
import '../model/user/update_user_model.dart';
import '../model/user/user_models/user_model.dart';
import '../model/user/user_models/user_response_model.dart';
import '../model/video_category_model.dart';
import '../utils/app_constants.dart';
import 'network_utils.dart';
// import 'network_utils.dart';

// FOR Token(Authorization) Please remove comment from the network_utils.dart file

Future<DoctorResponse> logInApi(request) async {
  Response response = await buildHttpResponse('login',
      request: request, method: HttpMethod.post);
  if (!response.statusCode.isSuccessful()) {
    if (response.body.isJson()) {
      var json = jsonDecode(response.body);
      json = json['responseData'];

      if (json.containsKey('code') &&
          json['code'].toString().contains('invalid_username')) {
        throw 'invalid_username';
      }
    }
  }

  return await handleResponse(response).then((value) async {
    value = value['responseData'];
    DoctorResponse userModel = DoctorResponse.fromJson(value);
    DoctorResponse? userResponse = userModel;

    saveDoctorData(userResponse);
    await userStore.setLogin(true);
    return userModel;
  });
}

Future<UserResponse> logInAsUserApi(request) async {
  Response response = await buildHttpResponse('login',
      request: request, method: HttpMethod.post);
  if (!response.statusCode.isSuccessful()) {
    if (response.body.isJson()) {
      var json = jsonDecode(response.body);
      json = json['responseData'];
      if (json.containsKey('code') &&
          json['code'].toString().contains('invalid_username')) {
        throw 'invalid_username';
      }
    }
  }

  var value = await handleResponse(response);
  value = value['responseData'];
  UserResponse userModel = UserResponse.fromJson(value);

  saveUserData(userModel.data);
  await userStore.setLogin(true);
  // *** EXPLICITLY SAVE TOKEN TO SHARED PREFERENCES UPON LOGIN ***
  if (userModel.data?.apiToken.validate().isNotEmpty ?? false) {
    await sharedPreferences.setString(TOKEN, userModel.data!.apiToken.validate());
  }
  // -------------------------------------------
  return userModel;
}

Future<void> saveUserData(UserModel? userModel) async {
  if (userModel!.apiToken.validate().isNotEmpty)
    await userStore.setToken(userModel.apiToken.validate());

  await userStore.setUserID(userModel.id.validate());
  await userStore.setUserEmail(userModel.email.validate());
  await userStore.setFirstName(userModel.firstName.validate());
  await userStore.setLastName(userModel.lastName.validate());
}

//working
Future<Either<DefaultMessageResponse, UserModel>> registerApi(
    Map<String, dynamic> req) async {
  try {
    final response = await buildHttpResponse(
      'register',
      request: req,
      method: HttpMethod.post,
    );

    final v = await handleResponse(response);
    final responseData = v["responseData"];

    if (responseData['status'] == true) {
      final userModel = UserModel.fromJson(responseData['data']);
      return Right(userModel);
    } else {
      final errorResponse = DefaultMessageResponse.fromJson(responseData);
      return Left(errorResponse);
    }
  } catch (e) {
    // Handle any unexpected errors
    return Left(DefaultMessageResponse(
      status: false,
      message: e.toString(),
    ));
  }
}

//working
Future<UpdateUserModel> updateProfileApi(Map req) async {
  var response = await handleResponse(await buildHttpResponse('update-profile',
      request: req, method: HttpMethod.post));
  response = response['responseData'];

  return UpdateUserModel.fromJson(response);
}

/// Working
///  Backup data API
Future<DefaultMessageResponse> backupUserData(Map req) async {
  var response = await handleResponse(await buildHttpResponse('backup-data',
      method: HttpMethod.post, request: req));
  // response = response['responseData'];

  return DefaultMessageResponse.fromJson(response);
}

/// MANUAL BACKUP
Future<DefaultMessageResponse> manualBackupData(Map req) async {
  var response = await handleResponse(await buildHttpResponse('manual-backup',
      method: HttpMethod.post, request: req));
  // response = response['responseData'];
  return DefaultMessageResponse.fromJson(response);
}

Future<Either<DefaultMessageResponse, BackupRestoreResponse>>
restoreBackupApi() async {
  try {
    var response = await handleResponse(
        await buildHttpResponse('restore-data', method: HttpMethod.get));

    // final responseData = response['responseData'];
    if (response['status'] == true) {
      return Right(BackupRestoreResponse.fromJson(response));
    } else {
      return Left(DefaultMessageResponse.fromJson(response));
    }
  } catch (e) {
    return Left(DefaultMessageResponse(
      status: false,
      message: 'An error occurred',
    ));
  }
}

//working
Future<void> updateUserStatusApi(Map req) async {
  var id = req["id"];
  await handleResponse(await buildHttpResponse(
    'update-user-status?id=$id',
    request: req,
    method: HttpMethod.post,
  ));
}

//working
/// categorylist
Future<BookmarkResponseModel> getBookmarkApi() async {
  // *** FORCE TOKEN UPDATE BEFORE API CALL ***
  // Pulls the latest token from SharedPreferences into the observable userStore
  // to ensure buildHeaderTokens() uses the freshest value.
  final storedToken = getStringAsync(TOKEN);
  if (storedToken.isNotEmpty && storedToken != userStore.token) {
    await userStore.setToken(storedToken);
  }
  // -------------------------------------------

  log('\u001B[32m[API_CALL] Calling getBookmarkApi. Token read from userStore at call time: ${userStore.token}\u001B[39m'); // <-- ADDED LOG FOR API CALL SITE

  var response = await handleResponse(await buildHttpResponse(
      'get-bookmark-articles-list',
      method: HttpMethod.get));
  response = response["responseData"];
  return BookmarkResponseModel.fromJson(response);
}

//working
Future<AddBookmarkResponse> updateBookMarkStatus(Map req) async {
  var response = await handleResponse(await buildHttpResponse(
      'bookmark-articles',
      request: req,
      method: HttpMethod.post));
  response = response['responseData'];
  return AddBookmarkResponse.fromJson(response);
}

//working
// categorylist
Future<List<Symptoms>> AddSubSymptoms({String? token}) async {
  try {
    // Step 1: Decide which token to use
    String? tokenToSend = token;

    final storedToken = getStringAsync(TOKEN);

    // Priority:
    // 1. Passed token
    // 2. userStore token
    // 3. stored token (shared prefs)

    if (tokenToSend == null || tokenToSend.isEmpty) {
      if (userStore.token != null && userStore.token!.isNotEmpty) {
        tokenToSend = userStore.token;
      } else if (storedToken.isNotEmpty) {
        await userStore.setToken(storedToken);
        tokenToSend = storedToken;
      }
    } else {
      // Sync passed token to store
      if (tokenToSend != userStore.token) {
        await userStore.setToken(tokenToSend);
      }
    }

    // Final safety check
    if (tokenToSend == null || tokenToSend.isEmpty) {
      log('[API_CALL ERROR] No valid token found');
      return [];
    }

    log('\u001B[32m[API_CALL] sub-symptoms-list | Token: $tokenToSend\u001B[39m');

    // Step 2: API Call
    final response = await handleResponse(
      await buildHttpResponse(
        'sub-symptoms-list',
        method: HttpMethod.get,
        // 👉 IMPORTANT: pass token if your API needs header manually
        // headers: {
        //   HttpHeaders.authorizationHeader: 'Bearer $tokenToSend',
        // },
      ),
    );

    final res = response['responseData'];

    List<Symptoms> userSymptoms = [];

    if (res != null && res['data'] != null) {
      for (var v in res['data']) {
        userSymptoms.add(Symptoms.fromJson(v));
      }
    }

    return userSymptoms;
  } catch (e, stackTrace) {
    log('[API_CALL ERROR] sub-symptoms-list failed: $e');
    log(stackTrace.toString());
    return [];
  }
}

//not used in app
Future<UserResponse> getUserDetailsApi({int? id}) async {
  var response = await (handleResponse(
      await buildHttpResponse("user-detail?id=$id", method: HttpMethod.get)));
  response = response['responseData'];
  return UserResponse.fromJson(response);
}

//working
/// categorylist
Future<CategoryListResponse> getCategoryListApi({int? id}) async {
  // *** FORCE TOKEN UPDATE BEFORE API CALL ***
  // Pulls the latest token from SharedPreferences into the observable userStore
  // to ensure buildHeaderTokens() uses the freshest value.
  final storedToken = getStringAsync(TOKEN);
  if (storedToken.isNotEmpty && storedToken != userStore.token) {
    await userStore.setToken(storedToken);
  }
  // -------------------------------------------

  log('\u001B[32m[API_CALL] Calling category-list. Token read from userStore at call time: ${userStore.token}\u001B[39m'); // <-- ADDED LOG FOR API CALL SITE

  var response = await handleResponse(await buildHttpResponse(
      "category-list?goal_type=$id",
      method: HttpMethod.post));
  response = response['responseData'];
  return CategoryListResponse.fromJson(response);
}

/// categoryData
Future<CategoryDataResponse> getCategoryDetailsApi({int? categoryId}) async {
  var response = await (handleResponse(await buildHttpResponse(
      "get-category-data?category_id=$categoryId",
      method: HttpMethod.get)));
  response = response['responseData'];
  return CategoryDataResponse.fromJson(response);
}

//working
/// Dashboard
Future<DashboardResponse> getDashboardListApi(Map request, {String? token}) async {
  // ✅ STEP 1: FORCE TOKEN SYNC (MOST IMPORTANT)
  String? tokenToSend = userStore.token;
  final storedToken = getStringAsync(TOKEN);

  if (storedToken.isNotEmpty && (tokenToSend == null || tokenToSend.isEmpty)) {
    await userStore.setToken(storedToken);
    tokenToSend = storedToken;
  } else if (storedToken.isNotEmpty && storedToken != userStore.token) {
    await userStore.setToken(storedToken);
    tokenToSend = storedToken;
  }

  // 🔥 EXTRA SAFETY (THIS LINE FIXES MOST 401 BUGS)
  await userStore.setToken(tokenToSend);

  // 🔥 DEBUG
  log('\u001B[32m[API_CALL] dashboard-list FINAL TOKEN: ${userStore.token}\u001B[39m');

  // ✅ STEP 2: NORMAL API CALL (NO HEADER NEEDED)
  var response = await handleResponse(
    await buildHttpResponse(
      'dashboard-list',
      method: HttpMethod.post,
      request: request,
    ),
  );

  response = response['responseData'];
  return DashboardResponse.fromJson(response);
}

//working
///Delete User
Future<DefaultMessageResponse> deleteUserAccountApi() async {
  var response = await handleResponse(
      await buildHttpResponse('delete-user-account', method: HttpMethod.post));
  response = response['responseData'];
  return DefaultMessageResponse.fromJson(response);
}

//working
///Doctor Detail
Future<DoctorResponse> getDoctorDetailsApi() async {
  var response = await handleResponse(
      await buildHttpResponse('doctor-detail', method: HttpMethod.get));
  response = response['responseData'];
  return DoctorResponse.fromJson(response);
}

//working
///Change Password
Future<DefaultMessageResponse> changeHealthExpertPasswordApi(Map req) async {
  var response = await handleResponse(await buildHttpResponse('change-password',
      request: req, method: HttpMethod.post));
  response = response['responseData'];
  return DefaultMessageResponse.fromJson(response);
}

/// Forgot Password
Future<DefaultMessageResponse> forgotPasswordApi(Map req) async {
  var response = await handleResponse(await buildHttpResponse('forget-password',
      request: req, method: HttpMethod.post));
  response = response['responseData'];
  return DefaultMessageResponse.fromJson(response);
}

//working
///Doctor Article List
Future<ArticleList> getHealthExpertArticleListApi({int page = 1}) async {
  // *** FORCE TOKEN UPDATE BEFORE API CALL ***
  // Pulls the latest token from SharedPreferences into the observable userStore
  // to ensure buildHeaderTokens() uses the freshest value.
  final storedToken = getStringAsync(TOKEN);
  if (storedToken.isNotEmpty && storedToken != userStore.token) {
    await userStore.setToken(storedToken);
  }
  // -------------------------------------------

  log('\u001B[32m[API_CALL] Calling article-list. Token read from userStore at call time: ${userStore.token}\u001B[39m'); // <-- ADDED LOG FOR API CALL SITE

  var response = await handleResponse(await buildHttpResponse(
      'article-list?page=$page',
      method: HttpMethod.get));
  response = response['responseData'];
  return ArticleList.fromJson(response);
}

//working
///DeleteHealthExpert
Future<DefaultMessageResponse> deleteHealthExpertAccountApi() async {
  var response = await handleResponse(
      await buildHttpResponse('delete-user-account', method: HttpMethod.post));
  response = response['responseData'];
  return DefaultMessageResponse.fromJson(response);
}

//working
Future<HealthExpert> getHealthExpertListApi() async {
  // *** FORCE TOKEN UPDATE BEFORE API CALL ***
  // Pulls the latest token from SharedPreferences into the observable userStore
  // to ensure buildHeaderTokens() uses the freshest value.
  final storedToken = getStringAsync(TOKEN);
  if (storedToken.isNotEmpty && storedToken != userStore.token) {
    await userStore.setToken(storedToken);
  }
  // -------------------------------------------

  log('\u001B[32m[API_CALL] Calling health-expert-list. Token read from userStore at call time: ${userStore.token}\u001B[39m'); // <-- ADDED LOG FOR API CALL SITE

  var response = await handleResponse(
      await buildHttpResponse('health-expert-list', method: HttpMethod.get));
  response = response['responseData'];
  return HealthExpert.fromJson(response);
}

//working
Future<ArticleResponse> deleteArticleDataApi(int? id) async {
  var response = await handleResponse(
      await buildHttpResponse('article-delete/$id', method: HttpMethod.post));
  response = response['responseData'];
  return ArticleResponse.fromJson(response);
}

//working
///Calculator
Future<CalculatorResponse> fetchCalculatorToolsListApi() async {
  // *** FORCE TOKEN UPDATE BEFORE API CALL ***
  // Pulls the latest token from SharedPreferences into the observable userStore
  // to ensure buildHeaderTokens() uses the freshest value.
  final storedToken = getStringAsync(TOKEN);
  if (storedToken.isNotEmpty && storedToken != userStore.token) {
    await userStore.setToken(storedToken);
  }
  // -------------------------------------------

  log('\u001B[32m[API_CALL] Calling calculator-tool-list. Token read from userStore at call time: ${userStore.token}\u001B[39m'); // <-- ADDED LOG FOR API CALL SITE

  var response = await handleResponse(
      await buildHttpResponse("calculator-tool-list", method: HttpMethod.get));
  response = response['responseData'];
  return CalculatorResponse.fromJson(response);
}

///FAQ
//working
Future<FaqResponse> fetchFAQListApi() async {
  // *** FORCE TOKEN UPDATE BEFORE API CALL ***
  // Pulls the latest token from SharedPreferences into the observable userStore
  // to ensure buildHeaderTokens() uses the freshest value.
  final storedToken = getStringAsync(TOKEN);
  if (storedToken.isNotEmpty && storedToken != userStore.token) {
    await userStore.setToken(storedToken);
  }
  // -------------------------------------------

  log('\u001B[32m[API_CALL] Calling faq-list. Token read from userStore at call time: ${userStore.token}\u001B[39m'); // <-- ADDED LOG FOR API CALL SITE

  var response = await handleResponse(
      await buildHttpResponse("faq-list", method: HttpMethod.get));
  response = response['responseData'];
  return FaqResponse.fromJson(response);
}

/// Save question to expert
Future<DefaultMessageResponse> saveQuestionToExpertApi(Map req) async {
  var response = await handleResponse(await buildHttpResponse('askexpert-save',
      method: HttpMethod.post, request: req));
  response = response['responseData'];
  return DefaultMessageResponse.fromJson(response);
}

Future<DashboardArticle> DashboardArticleList(Map request,
    {int page = 2}) async {
  String url = 'dashboard-article-list?page=$page';
  var response = await handleResponse(
    await buildHttpResponse(
      url,
      method: HttpMethod.post,
      request: request,
    ),
  );
  return DashboardArticle.fromJson(response);
}

Future<DashboardArticle> TagArticleList(Map request, {int page = 1}) async {
  String url = 'tag-article-list?page=$page';
  var response = await handleResponse(
    await buildHttpResponse(
      url,
      method: HttpMethod.post,
      request: request,
    ),
  );
  return DashboardArticle.fromJson(response);
}

/// Get Expert Question List
Future<ExpertQuestionListModel> getQuestionToExpertApi({int page = 1}) async {
  // *** FORCE TOKEN UPDATE BEFORE API CALL ***
  // Pulls the latest token from SharedPreferences into the observable userStore
  // to ensure buildHeaderTokens() uses the freshest value.
  final storedToken = getStringAsync(TOKEN);
  if (storedToken.isNotEmpty && storedToken != userStore.token) {
    await userStore.setToken(storedToken);
  }
  // -------------------------------------------

  log('\u001B[32m[API_CALL] Calling assigndoctor-list. Token read from userStore at call time: ${userStore.token}\u001B[39m'); // <-- ADDED LOG FOR API CALL SITE

  var response = await handleResponse(await buildHttpResponse(
      "assigndoctor-list?page=$page",
      method: HttpMethod.get));
  response = response['responseData'];
  return ExpertQuestionListModel.fromJson(response);
}

Future<ExpertQuestionListModel> getPendingQuestionToExpertApi(
    {int page = 1}) async {
  // *** FORCE TOKEN UPDATE BEFORE API CALL ***
  // Pulls the latest token from SharedPreferences into the observable userStore
  // to ensure buildHeaderTokens() uses the freshest value.
  final storedToken = getStringAsync(TOKEN);
  if (storedToken.isNotEmpty && storedToken != userStore.token) {
    await userStore.setToken(storedToken);
  }
  // -------------------------------------------

  log('\u001B[32m[API_CALL] Calling askexpert-list. Token read from userStore at call time: ${userStore.token}\u001B[39m'); // <-- ADDED LOG FOR API CALL SITE

  var response = await handleResponse(await buildHttpResponse(
      "askexpert-list?page=$page",
      method: HttpMethod.get));
  response = response['responseData'];
  return ExpertQuestionListModel.fromJson(response);
}

Future<DefaultMessageResponse> deleteAskDataApi(int? id) async {
  var response = await handleResponse(
      await buildHttpResponse("askexpert-delete/$id", method: HttpMethod.post));
  response = response['responseData'];
  return DefaultMessageResponse.fromJson(response);
}

Future<DefaultMessageResponse> updateAskDataApi(String? id, Map req) async {
  var response = await handleResponse(await buildHttpResponse(
      "askexpert-update/$id",
      method: HttpMethod.post,
      request: req));
  response = response['responseData'];
  return DefaultMessageResponse.fromJson(response);
}

//working
//reset pin
Future<ResetAppPinModel> resetPinApi(Map req) async {
  var response = await handleResponse(await buildHttpResponse('send-code',
      request: req, method: HttpMethod.post));
  response = response['responseData'];
  return ResetAppPinModel.fromJson(response);
}

Future<void> clearSessionCache() async {
  final cacheDir = await getTemporaryDirectory();
  final crispCache = Directory('${cacheDir.path}/im.crisp.client');
  if (crispCache.existsSync()) {
    crispCache.deleteSync(recursive: true);
  }

  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('im.crisp.client.internal.cache.Preferences');
}

Future<void> clearAllChatGptCache() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    final chatGptKeys = keys.where((key) =>
    key.startsWith('chatgpt_cycle_') ||
        key.startsWith('chatgpt_pregnancy_'));

    for (final key in chatGptKeys) {
      await prefs.remove(key);
    }
  } catch (e) {
    print('Error clearing ChatGPT cache: $e');
  }
}

Future<void> logout(
    {bool isFromLogin = false, required BuildContext context}) async {
  resetAllReminders();
  await sharedPreferences.remove(IS_LOGIN);
  await sharedPreferences.remove(IS_USER_SIGNED_UP);
  await sharedPreferences.remove(TOKEN);
// await sharedPreferences.remove(QUE_lIST);
  await sharedPreferences.remove(IS_USER_COMPLETED_QUE);
  await sharedPreferences.remove(USER_ID);
  await sharedPreferences.remove(USER_TYPE);
  await sharedPreferences.remove(UID);
  await sharedPreferences.remove(USER_PROFILE_IMG);
  await sharedPreferences.remove(EMAIL);
  await sharedPreferences.remove(FIRSTNAME);
  await sharedPreferences.remove(PASSWORD);
  await sharedPreferences.remove(KEY_PHONE_NUMBER);
  await sharedPreferences.remove(KEY_REMINDER_DATA);
  await sharedPreferences.remove(KEY_QUESTION_DATA);
  await sharedPreferences.remove(IS_PASS_LOCK_SET);
  await sharedPreferences.remove(KEY_LAST_KNOWN_APP_LIFECYCLE_STATE);
  await sharedPreferences.remove(KEY_APP_BACKGROUND_TIME);
  await sharedPreferences.remove(IS_FINGERPRINT_LOCK_SET);
  await sharedPreferences.remove(IS_AUTHENTICATED);
  await sharedPreferences.remove(GOAL);
  await sharedPreferences.remove(PASSWORD);
  await sharedPreferences.remove(LAST_DATA_SYNC_DATETIME);
  await sharedPreferences.remove(IS_BACKUP_ENABLED);
  await sharedPreferences.remove(IS_BACKUP_POP_DISPLAYED);
  await sharedPreferences.remove(CURRENT_USER_PREGNANCY_WEEK);
  await sharedPreferences.remove(CURRENT_USER_CYCLE_DAY);
  await sharedPreferences.remove(IS_USER_LOCATION_UPDATED);
  await clearSessionCache();
  await clearAllChatGptCache();
  if (await GoogleSignIn().isSignedIn()) {
    await GoogleSignIn().signOut();
  }
  userStore.setLogin(false);
// Restart.restartApp();
// Full app restart
  await TerminateRestart.instance.restartApp(
    options: const TerminateRestartOptions(
      terminate: true,
    ),
  );
}


Future<List<VideoCategoryModel>> getVideoCategories() async {
  // *** FORCE TOKEN UPDATE BEFORE API CALL ***
  // Pulls the latest token from SharedPreferences into the observable userStore
  // to ensure buildHeaderTokens() uses the freshest value.
  final storedToken = getStringAsync(TOKEN);
  if (storedToken.isNotEmpty && storedToken != userStore.token) {
    await userStore.setToken(storedToken);
  }
  // -------------------------------------------

  log('\u001B[32m[API_CALL] Calling videos. Token read from userStore at call time: ${userStore.token}\u001B[39m'); // <-- ADDED LOG FOR API CALL SITE

  var response = await handleResponse(
    await buildHttpResponse('videos', method: HttpMethod.get),
  ).then((value) => value);

  response = response['data']; // 👈 IMPORTANT

  List<VideoCategoryModel> list = [];

  response.forEach((item) {
    list.add(VideoCategoryModel.fromJson(item));
  });

  return list;
}


Future<dynamic> firebaseLoginApi(Map req) async {
  var response = await handleResponse(
    await buildHttpResponse(
      'firebase-login',
      request: req,
      method: HttpMethod.post,
    ),
  );

  // Token Extraction and Saving Logic based on successful login log structure
  if (response != null && response['responseData'] != null) {
    final responseData = response['responseData'];
    // The structure observed in logs: responseData -> data -> api_token
    if (responseData['data'] != null && responseData['data']['api_token'] != null) {
      final apiToken = responseData['data']['api_token'].toString();
      if (apiToken.isNotEmpty) {
        // Save to shared preferences (consistent with logInAsUserApi)
        await sharedPreferences.setString(TOKEN, apiToken);
        // Update userStore immediately (consistent with buildHeaderTokens)
        await userStore.setToken(apiToken);
      }
    }
  }

  return response['responseData'];
}

Future<void> saveDoctorData(DoctorResponse? doctorData) async {
  await userStore.setDrName(doctorData!.data!.name.validate());
  await userStore.setUserDrEmail(doctorData.data!.email.validate());
  await userStore.setDrCareer(doctorData.data!.career.validate());
  await userStore.setDrExpertise(doctorData.data!.areaExpertise.validate());
  await userStore.setDrTagline(doctorData.data!.tagLine.validate());
  await userStore.setDrAwards(doctorData.data!.awardsAchievements.validate());
  await userStore.setDrDesc(doctorData.data!.shortDescription.validate());
  await userStore.setDrEducation(doctorData.data!.education.validate());
  await userStore
      .setDRprofileImage(doctorData.data!.healthExpertsImage.validate());
}

//working
// Subscribe
Future<DefaultMessageResponse> subscribeForPremium(Map req) async {
  var response = await handleResponse(
    await buildHttpResponse(
      'subscription-save',
      method: HttpMethod.post,
      request: req,
    ),
  );
  response = response['responseData'];
  return DefaultMessageResponse.fromJson(response);
}

// Doctor dashboard
Future<DoctorDashboardResponseData> getDoctorDashboard() async {
  // *** FORCE TOKEN UPDATE BEFORE API CALL ***
  // Pulls the latest token from SharedPreferences into the observable userStore
  // to ensure buildHeaderTokens() uses the freshest value.
  final storedToken = getStringAsync(TOKEN);
  if (storedToken.isNotEmpty && storedToken != userStore.token) {
    await userStore.setToken(storedToken);
  }
  // -------------------------------------------

  log('\u001B[32m[API_CALL] Calling doctor-dashboard. Token read from userStore at call time: ${userStore.token}\u001B[39m'); // <-- ADDED LOG FOR API CALL SITE

  var response = await handleResponse(
      await buildHttpResponse('doctor-dashboard', method: HttpMethod.get));
  response = response['responseData'];
  return DoctorDashboardResponseData.fromJson(response);
}

//working
// Language Data
Future<ServerLanguageResponse> getLanguageList(String? versionNo) async {
  var response = await handleResponse(await buildHttpResponse(
      "language-table-list?version_no=$versionNo",
      method: HttpMethod.get));
  response = response['responseData'];
  return ServerLanguageResponse.fromJson(response);
}

// AppSetting
Future<AppSettings> getAppSettings() async {
  var response = await handleResponse(
      await buildHttpResponse('appsetting', method: HttpMethod.get))
      .then((value) => value);
  response = response['responseData'];
  return AppSettings.fromJson(response);
}

Future<AllCategoryList> fetchAllCategoryApi() async {
  var response = await handleResponse(
    await buildHttpResponse("all-category-list", method: HttpMethod.get),
  );
  return AllCategoryList.fromJson(response);
}

Future<SecretChatResponse> getLatestPost() async {
  var response = await handleResponse(
    await buildHttpResponse("latest-chatlist", method: HttpMethod.get),
  );
  return SecretChatResponse.fromJson(response);
}

Future<SecretChatResponse> deletePostApi(int secretchat_id) async {
  return SecretChatResponse.fromJson(
    await handleResponse(
      await buildHttpResponse(
        'delete-userchat/$secretchat_id',
        method: HttpMethod.post,
      ),
    ),
  );
}

Future<DefaultMessageResponse> likePostApi(Map req) async {
  return DefaultMessageResponse.fromJson(await handleResponse(
      await buildHttpResponse('like-userchat',
          request: req, method: HttpMethod.post)));
}

Future<DefaultMessageResponse> savePostApi(Map req) async {
  return DefaultMessageResponse.fromJson(await handleResponse(
      await buildHttpResponse('bookmark-secretchat',
          request: req, method: HttpMethod.post)));
}

Future<DefaultMessageResponse> followApi(Map req) async {
  return DefaultMessageResponse.fromJson(await handleResponse(
      await buildHttpResponse('follwing-category',
          request: req, method: HttpMethod.post)));
}

Future<DefaultMessageResponse> saveCommentApi(Map req) async {
  return DefaultMessageResponse.fromJson(await handleResponse(
      await buildHttpResponse('save-comment',
          request: req, method: HttpMethod.post)));
}

Future<DefaultMessageResponse> saveReCommentApi(Map req) async {
  return DefaultMessageResponse.fromJson(await handleResponse(
      await buildHttpResponse('save-comment-reply',
          request: req, method: HttpMethod.post)));
}

Future<CommentListResponse> commentListApi(int id, int? page) async {
  return CommentListResponse.fromJson(await handleResponse(
      await buildHttpResponse('comment-list?secretchat_id=$id&page=$page',
          method: HttpMethod.get)));
}

Future<CommentListResponse> deleteReCommentApi(Map req) async {
  return CommentListResponse.fromJson(await handleResponse(
      await buildHttpResponse('delete-comment',
          request: req, method: HttpMethod.post)));
}

Future<CommentListResponse> deleteCommentReplyApi(Map req) async {
  return CommentListResponse.fromJson(await handleResponse(
      await buildHttpResponse('delete-comment-reply',
          request: req, method: HttpMethod.post)));
}

Future<SecretChatResponse> categoryPostApi(Map req) async {
  return SecretChatResponse.fromJson(await handleResponse(
      await buildHttpResponse('category-chatlist',
          request: req, method: HttpMethod.post)));
}

Future<DefaultMessageResponse> updateCommentApi(Map req) async {
  return DefaultMessageResponse.fromJson(await handleResponse(
      await buildHttpResponse('update-comment',
          request: req, method: HttpMethod.post)));
}

Future<DefaultMessageResponse> hidePostApi(Map req) async {
  return DefaultMessageResponse.fromJson(await handleResponse(
      await buildHttpResponse('hide-userchat',
          request: req, method: HttpMethod.post)));
}