import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

import '../main.dart';
import '../extensions/shared_pref.dart';
import '../model/user/chatgpt_insight_model.dart';

class ChatGptService {
  static const String _baseUrl = "https://api.openai.com/v1";
  static const String _assistantId = "asst_7oxnV6JsbZ2rSsgNgEfQ1un2";

  static String get _apiKey => chatgptKey ?? "";

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey',
    'OpenAI-Beta': 'assistants=v2'
  };

  // ==========================================================
  // CLO CHAT (WITH MEMORY)
  // ==========================================================

  static Future<String> sendMessage(String message) async {
    String? threadId = getStringAsync("clo_thread_id");

    // Create thread if not exists
    if (threadId == null || threadId.isEmpty) {
      final userName = getStringAsync("FIRSTNAME") ?? "User";

      final threadRes = await http.post(
        Uri.parse("$_baseUrl/threads"),
        headers: _headers,
        body: jsonEncode({
          "messages": [
            {
              "role": "user",
              "content":
              "User name is $userName. Please remember this for future conversations."
            }
          ]
        }),
      );

      final threadData = jsonDecode(threadRes.body);
      threadId = threadData['id'];
      setValue("clo_thread_id", threadId);
    }

    // Add user message
    await http.post(
      Uri.parse("$_baseUrl/threads/$threadId/messages"),
      headers: _headers,
      body: jsonEncode({
        "role": "user",
        "content": message,
      }),
    );

    // Create run
    final runRes = await http.post(
      Uri.parse("$_baseUrl/threads/$threadId/runs"),
      headers: _headers,
      body: jsonEncode({
        "assistant_id": _assistantId,
      }),
    );

    final runId = jsonDecode(runRes.body)['id'];

    // Wait for run to complete
    await _waitForRun(threadId!, runId);

    // Wait until assistant response exists
    return await _waitForAssistantMessage(threadId);
  }

  // ==========================================================
  // WAIT FOR ASSISTANT MESSAGE
  // ==========================================================

  static Future<String> _waitForAssistantMessage(String threadId) async {
    int retries = 0;

    while (retries < 20) {
      final messageRes = await http.get(
        Uri.parse("$_baseUrl/threads/$threadId/messages?limit=10"),
        headers: _headers,
      );

      final messageData = jsonDecode(messageRes.body);
      final List messages = messageData['data'];

      for (var msg in messages) {
        if (msg['role'] == 'assistant') {
          return msg['content'][0]['text']['value'];
        }
      }

      await Future.delayed(const Duration(milliseconds: 700));
      retries++;
    }

    throw Exception("Assistant response timeout");
  }

  // ==========================================================
  // LOAD OLD THREAD
  // ==========================================================

  static Future<List<Map<String, dynamic>>> getThreadMessages() async {
    String? threadId = getStringAsync("clo_thread_id");

    if (threadId == null || threadId.isEmpty) return [];

    final response = await http.get(
      Uri.parse("$_baseUrl/threads/$threadId/messages"),
      headers: _headers,
    );

    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['data']);
  }

  // ==========================================================
  // MULTIMODAL CHAT (IMAGE + TEXT) using Chat Completions API (GPT-4o)
  // This bypasses the existing thread management for a direct, single-turn vision query.
  // ==========================================================
  static Future<String> sendMessageWithImageUrl({
    required String textContent,
    required String imageUrl,
  }) async {
    final dio = Dio(); 

    // Use Chat Completions endpoint, which supports vision models like gpt-4o and remote URLs.
    final ChatCompletionsEndpoint = '$_baseUrl/chat/completions';

    final Map<String, dynamic> requestBody = {
      "model": "gpt-4o", // Use a multimodal model
      "messages": [
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text": textContent,
            },
            {
              "type": "image_url",
              "image_url": {
                "url": imageUrl, // Send the public URL from your server
              }
            }
          ]
        }
      ],
      "max_tokens": 1000
    };

    final response = await dio.post(
      ChatCompletionsEndpoint,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        }
      ),
      data: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map && data.containsKey('choices') && data['choices'] is List && data['choices'].isNotEmpty) {
             // Extract content from the first choice's message
             return data['choices'][0]['message']['content'] ?? "No response text found.";
        } else {
             return "AI returned success status but no choice content.";
        }
    } else {
        throw Exception("Chat Completions request failed with status: ${response.statusCode}. Data: ${response.data}");
    }
  }


  // ==========================================================
  // STRUCTURED JSON METHODS
  // ==========================================================

  static Future<ChatGptInsight> getCycleDayInfo(
      int day, int cycleLength, int periodLength, String lang) async {
    final prompt =
        "Provide structured JSON about day $day of menstrual cycle in $lang language.";

    return await _runSinglePrompt(prompt);
  }

  static Future<ChatGptInsight> getPregnancyWeekInfo(
      int week, String lang) async {
    final prompt =
        "Provide structured JSON about week $week of pregnancy in $lang language.";

    return await _runSinglePrompt(prompt);
  }

  static Future<ChatGptInsight> _runSinglePrompt(String prompt) async {
    final threadRes = await http.post(
      Uri.parse("$_baseUrl/threads"),
      headers: _headers,
      body: jsonEncode({
        "messages": [
          {"role": "user", "content": prompt}
        ]
      }),
    );

    final threadId = jsonDecode(threadRes.body)['id'];

    final runRes = await http.post(
      Uri.parse("$_baseUrl/threads/$threadId/runs"),
      headers: _headers,
      body: jsonEncode({"assistant_id": _assistantId}),
    );

    final runId = jsonDecode(runRes.body)['id'];

    await _waitForRun(threadId, runId);

    final messageRes = await http.get(
      Uri.parse("$_baseUrl/threads/$threadId/messages?limit=10"),
      headers: _headers,
    );

    final messages = jsonDecode(messageRes.body)['data'];

    for (var msg in messages) {
      if (msg['role'] == 'assistant') {
        final content = msg['content'][0]['text']['value'];
        final parsedJson = jsonDecode(content);
        return ChatGptInsight.fromJson(parsedJson);
      }
    }

    throw Exception("No assistant message found");
  }

  // ==========================================================

  static Future<void> _waitForRun(String threadId, String runId) async {
    while (true) {
      final res = await http.get(
        Uri.parse("$_baseUrl/threads/$threadId/runs/$runId"),
        headers: _headers,
      );

      final status = jsonDecode(res.body)['status'];

      if (status == "completed") break;

      if (status == "failed" ||
          status == "cancelled" ||
          status == "expired") {
        throw Exception("Run failed: $status");
      }

      await Future.delayed(const Duration(milliseconds: 700));
    }
  }
}