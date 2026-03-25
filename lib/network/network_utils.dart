import 'dart:convert';
import 'dart:io';

import 'package:clora_user/extensions/extension_util/int_extensions.dart';
import 'package:clora_user/screens/user/questions_list_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../extensions/common.dart';
import '../extensions/constants.dart';
import '../extensions/system_utils.dart';
import '../main.dart';
import '../utils/app_common.dart';
import '../utils/app_config.dart';

Map<String, String> buildHeaderTokens() {
  Map<String, String> header = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    HttpHeaders.cacheControlHeader: 'no-cache',
    HttpHeaders.acceptHeader: 'application/json; charset=utf-8',
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Allow-Origin': '*',
  };

  if (userStore.isLoggedIn) {
    header.putIfAbsent(
        HttpHeaders.authorizationHeader, () => 'Bearer ${userStore.token}');
  }
  log(jsonEncode(header));
  return header;
}

Uri buildBaseUrl(String endPoint) {
  Uri url = Uri.parse(endPoint);
  if (!endPoint.startsWith('http'))
    url = Uri.parse('$APP_BASE_URL/api/$endPoint');
  return url;
}

Future<Response> buildHttpResponse(String endPoint,
    {HttpMethod method = HttpMethod.get, Map? request}) async {
  if (await isNetworkAvailable()) {
    var headers = buildHeaderTokens();
    Uri url = buildBaseUrl(endPoint);

    Response response;

    if (method == HttpMethod.post) {
      response =
          await http.post(url, body: jsonEncode(request), headers: headers);
    } else if (method == HttpMethod.delete) {
      response = await delete(url, headers: headers);
    } else if (method == HttpMethod.put) {
      response = await put(url, body: jsonEncode(request), headers: headers);
    } else {
      response = await get(url, headers: headers);
    }

    apiURLResponseLog(
      url: url.toString(),
      endPoint: endPoint,
      headers: jsonEncode(headers),
      hasRequest: method == HttpMethod.post || method == HttpMethod.put,
      request: jsonEncode(request),
      statusCode: response.statusCode.validate(),
      responseBody: response.body,
      methodType: method.name,
    );
    // log('Response ($method): ${response.statusCode} ${response.body}');

    return response;
  } else {
    throw errorInternetNotAvailable;
  }
}

@deprecated
Future<Response> getRequest(String endPoint) async =>
    buildHttpResponse(endPoint);

@deprecated
Future<Response> postRequest(String endPoint, Map request) async =>
    buildHttpResponse(endPoint, request: request, method: HttpMethod.post);

Future handleResponse(Response response) async {
  if (!await isNetworkAvailable()) {
    throw errorInternetNotAvailable;
  }

  if (response.statusCode.isSuccessful()) {
    return jsonDecode(response.body);
  } else {
    var string = await (isJsonValid(response.body));
    if (string!.isNotEmpty) {
      if (string.toString().contains("Unauthenticated")) {
        userStore.clearUserData();

        userStore.setLogin(false);
        push(QuestionsListScreen(), isNewTask: true);
      } else {
        throw string;
      }
    } else {
      throw 'Please try again later.';
    }
  }
}

//region Common
enum HttpMethod { get, post, delete, put }

class TokenException implements Exception {
  final String message;

  const TokenException([this.message = ""]);

  String toString() => "FormatException: $message";
}
//endregion

Future<String?> isJsonValid(json) async {
  try {
    var f = jsonDecode(json) as Map<String, dynamic>;
    return f['message'];
  } catch (e) {
    log(e.toString());
    return "";
  }
}

JsonDecoder decoder = JsonDecoder();
JsonEncoder encoder = JsonEncoder.withIndent('  ');
void prettyPrintJson(String input) {
  var object = decoder.convert(input);
  var prettyString = encoder.convert(object);
  prettyString.split('\n').forEach((element) => log(element));
}

void apiURLResponseLog(
    {String url = "",
    String endPoint = "",
    String headers = "",
    String request = "",
    int statusCode = 0,
    dynamic responseBody = "",
    String methodType = "",
    bool hasRequest = false}) {
  log("\u001B[39m \u001b[96m┌───────────────────────────────────────────────────────────────────────────────────────────────────────┐\u001B[39m");
  log("\u001B[39m \u001b[96m Time: ${DateTime.now()}\u001B[39m");
  log("\u001b[31m Url: \u001B[39m $url");
  log("\u001b[31m Header: \u001B[39m \u001b[96m$headers\u001B[39m");
  if (request.isNotEmpty)
    log("\u001b[31m Request: \u001B[39m \u001b[96m$request\u001B[39m");
  log("${statusCode.isSuccessful() ? "\u001b[32m" : "\u001b[31m"}");
  log('Response ($methodType) $statusCode ${statusCode.isSuccessful() ? "\u001b[32m" : "\u001b[31m"} ');
  prettyPrintJson(responseBody);
  log("\u001B[0m");
  log("\u001B[39m \u001b[96m└───────────────────────────────────────────────────────────────────────────────────────────────────────┘\u001B[39m");
}

Future<MultipartRequest> getMultiPartRequest(String endPoint,
    {String? baseUrl}) async {
  String url = '${baseUrl ?? buildBaseUrl(endPoint).toString()}';
  log(url);
  return MultipartRequest('POST', Uri.parse(url));
}

Future<void> sendMultiPartRequest(MultipartRequest multiPartRequest,
    {Function(dynamic)? onSuccess, Function(dynamic)? onError}) async {
  http.Response response =
      await http.Response.fromStream(await multiPartRequest.send());
  printEraAppLogs("Result: ${response.body}");

  if (response.statusCode.isSuccessful()) {
    onSuccess?.call(response.body);
  } else {
    onError?.call(errorSomethingWentWrong);
  }
}
