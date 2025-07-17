import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'card_model.dart';

class CardViewModel extends ChangeNotifier {
  List<CardModel> articles = [];
  String? error;

  Future<void> sendMessage(String text) async {
    final url = Uri.parse("https://thinkflip-backend.onrender.com/gemini");
    error = null;

    try {
      print("🌐 [DEBUG] Starting sendMessage");
      print("🌐 Sending request to: $url");
      
      Map<String, dynamic> requestData;
      try {
        print("📦 [DEBUG] Attempting to parse text as JSON");
        requestData = jsonDecode(text);
        print("📦 [DEBUG] Successfully parsed JSON request: $requestData");
      } catch (_) {
        print("📦 [DEBUG] Text is not JSON, creating default request");
        requestData = MessageRequest(
          modelType: "text_only", 
          prompt: text,
          number: 10
        ).toJson();
        print("📦 [DEBUG] Created default request: $requestData");
      }

      final requestBody = jsonEncode(requestData);
      print("📦 Request Body: $requestBody");

      print("🔄 [DEBUG] Sending HTTP request...");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      print("🔄 Response Status Code: ${response.statusCode}");
      print("📝 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ [DEBUG] Got 200 response, parsing body");
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse.containsKey("result") &&
            decodedResponse["result"] is List) {
          print("✅ [DEBUG] Response contains result array");
          articles = MessageResponse.fromJson(decodedResponse).result;
          print("✅ [DEBUG] Parsed ${articles.length} flashcards");
          if (articles.isEmpty) {
            print("❌ [DEBUG] No flashcards in response");
            error = "No flashcards were generated. Please try with different text.";
          } else {
            print("✅ [DEBUG] Successfully got ${articles.length} flashcards");
          }
          notifyListeners();
        } else {
          print("❌ [DEBUG] Invalid response format: $decodedResponse");
          error = "Invalid response format from server";
        }
      } else {
        print("❌ [DEBUG] HTTP error ${response.statusCode}: ${response.body}");
        error = "Server error: ${response.statusCode}";
      }
    } catch (e) {
      print("❌ [DEBUG] Exception in sendMessage: $e");
      error = "Network error: $e";
    }
    print("🔄 [DEBUG] Finished sendMessage. Error: $error");
    notifyListeners();
  }

  void clearArticles() {
    articles.clear();
    notifyListeners();
  }
}
