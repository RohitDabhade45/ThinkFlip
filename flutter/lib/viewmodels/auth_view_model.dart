import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  String? _errorMessage;
  UserModel? _user;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  static const String _tokenKey = 'jwtToken';
  static const String _userKey = 'currentUser';

  AuthViewModel() {
    debugPrint('🔐 AuthViewModel initialized');
    checkSession();
  }

  Future<void> checkSession() async {
    debugPrint('🔍 Checking for existing session...');
    _isLoading = true;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userData = prefs.getString(_userKey);

    debugPrint('📦 Stored token: ${token?.substring(0, 10)}...');
    debugPrint('📦 Stored user data exists: ${userData != null}');

    if (token != null && userData != null) {
      try {
        // First load the stored user data
        _user = UserModel.fromJson(json.decode(userData));
        debugPrint('👤 Loaded user data for: ${_user?.name}');
        
        // Set authenticated immediately to show home screen
        _isAuthenticated = true;
        notifyListeners();
        debugPrint('🏠 Set initial authenticated state');
        
        // Then validate the token with the server
        final isValid = await _authService.validateToken(token);
        debugPrint('🔑 Token validation result: $isValid');
        
        if (!isValid) {
          debugPrint('⚠️ Token invalid, logging out');
          await logout();
        }
      } catch (e) {
        debugPrint('❌ Error checking session: $e');
        // Only log out if there's an actual error, not if the server is temporarily unavailable
        if (e.toString().contains('unauthorized') || e.toString().contains('expired')) {
          debugPrint('🚪 Unauthorized/expired token, logging out');
          await logout();
        } else {
          // If it's a network error, keep the user logged in
          debugPrint('📡 Network error but keeping user logged in');
          _isAuthenticated = true;
        }
      }
    } else {
      debugPrint('📭 No stored session found');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final authResponse = await _authService.register(username, email, password);
      if (authResponse.success) {
        await _saveUserData(authResponse);
        _isAuthenticated = true;
        _user = authResponse;
        return true;
      } else {
        _errorMessage = authResponse.message;
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final authResponse = await _authService.login(email, password);
      if (authResponse.success) {
        await _saveUserData(authResponse);
        _isAuthenticated = true;
        _user = authResponse;
        debugPrint('✅ Login successful for user: ${authResponse.name}');
        return true;
      } else {
        _errorMessage = authResponse.message;
        debugPrint('❌ Login failed: $_errorMessage');
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Login error: $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    debugPrint('🚪 Logging out user: ${_user?.name}');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    
    _isAuthenticated = false;
    _user = null;
    _errorMessage = null;
    notifyListeners();
    debugPrint('✅ Logout complete');
  }

  Future<void> _saveUserData(UserModel user) async {
    debugPrint('💾 Saving user data for: ${user.name}');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, user.jwtToken);
    await prefs.setString(_userKey, json.encode(user.toJson()));
    debugPrint('✅ User data saved successfully');
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}