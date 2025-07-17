import 'dart:convert';
import 'package:http/http.dart' as http;
import '../viewmodels/auth_view_model.dart';

class HistoryService {
  final AuthViewModel _authViewModel;
  static const String baseUrl = 'https://thinkflip-backend.onrender.com';

  HistoryService(this._authViewModel);

  Future<bool> saveDocument(String content) async {
    try {
      final token = _authViewModel.user?.jwtToken;
      if (token == null) {
        print('No authentication token available');
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/history/save-document'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode({'content': content}),
      );

      if (response.statusCode != 200) {
        print('Error saving document. Status code: ${response.statusCode}, Response: ${response.body}');
      }

      return response.statusCode == 200;
    } catch (e) {
      print('Error saving document: $e');
      return false;
    }
  }
}