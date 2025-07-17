import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/history_model.dart';
import 'auth_view_model.dart';

class HistoryViewModel extends ChangeNotifier {
  final String _baseUrl = 'https://thinkflip-backend.onrender.com';
  final AuthViewModel _authViewModel;
  List<HistoryEntry> _history = [];
  String? _errorMessage;
  bool _isLoading = false;

  List<HistoryEntry> get history => _history;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  HistoryViewModel(this._authViewModel);

  Future<void> fetchHistory() async {
    if (!_authViewModel.isAuthenticated) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final token = _authViewModel.user?.jwtToken;
      final response = await http.get(
        Uri.parse('$_baseUrl/history/user-history'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _history = (data['history'] as List)
            .map((item) => HistoryEntry.fromJson(item))
            .toList();
        _history.sort((a, b) => b.date.compareTo(a.date)); 
      } else {
        _errorMessage = 'Failed to load history';
        try {
          final errorData = json.decode(response.body);
          _errorMessage = errorData['message'] ?? _errorMessage;
        } catch (_) {}
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}