import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String baseURL = 'https://thinkflip-backend.onrender.com/auth';
  static const int _maxRetries = 2;
  static const int _timeoutSeconds = 30;
  static const Duration _retryDelay = Duration(seconds: 2);

  String _handleError(dynamic error) {
    if (error is SocketException) {
      return 'Unable to connect to server. Please check your internet connection.';
    } else if (error is http.ClientException) {
      return 'Connection error. Please try again later.';
    } else if (error is TimeoutException) {
      return 'Server is taking too long to respond. Please try again.';
    } else if (error is FormatException) {
      return 'Invalid response from server. Please try again later.';
    }
    return error.toString();
  }

  Future<T> _retryRequest<T>(Future<T> Function() request) async {
    int attempts = 0;
    while (attempts < _maxRetries) {
      try {
        return await request();
      } catch (e) {
        attempts++;
        if (e is TimeoutException || e is SocketException) {
          if (attempts < _maxRetries) {
            debugPrint('🔄 Retrying request (attempt ${attempts + 1}/${_maxRetries})');
            await Future.delayed(_retryDelay);
            continue;
          }
        }
        rethrow;
      }
    }
    throw Exception('Max retry attempts reached');
  }

  Future<UserModel> register(String username, String email, String password) async {
    debugPrint('Starting registration for user: $username, email: $email');
    
    return _retryRequest(() async {
      try {
        final url = Uri.parse('$baseURL/signup');
        debugPrint('Registration URL: ${url.toString()}');

        final body = {
          'name': username,
          'email': email,
          'password': password,
        };
        debugPrint('Registration request body: ${json.encode(body)}');

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body),
        ).timeout(
          Duration(seconds: _timeoutSeconds),
          onTimeout: () => throw TimeoutException(
            'Connection timed out. The server might be busy, please try again.',
          ),
        );

        debugPrint('Registration response status code: ${response.statusCode}');
        debugPrint('Registration response raw data: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          try {
            final authResponse = UserModel.fromJson(json.decode(response.body));
            debugPrint('Registration successful: Email: ${authResponse.email}, Name: ${authResponse.name}');
            return authResponse;
          } catch (e) {
            debugPrint('Error parsing registration response: $e');
            throw Exception('Invalid response format from server');
          }
        } else {
          var errorMessage = 'Registration failed';
          try {
            final errorBody = json.decode(response.body);
            errorMessage = errorBody['message'] ?? errorMessage;
          } catch (_) {}
          throw Exception(errorMessage);
        }
      } catch (e) {
        debugPrint('Error during registration: $e');
        throw Exception(_handleError(e));
      }
    });
  }

  Future<UserModel> login(String email, String password) async {
    debugPrint('Starting login for email: $email');
    
    return _retryRequest(() async {
      try {
        final url = Uri.parse('$baseURL/login');
        debugPrint('Login URL: ${url.toString()}');

        final body = {
          "email": email,
          "password": password,
        };
        debugPrint('Login request body (email only): ${json.encode({'email': email})}');

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body),
        ).timeout(
          Duration(seconds: _timeoutSeconds),
          onTimeout: () => throw TimeoutException(
            'Connection timed out. The server might be busy, please try again.',
          ),
        );

        debugPrint('Login response status code: ${response.statusCode}');

        if (response.statusCode == 200) {
          try {
            final authResponse = UserModel.fromJson(json.decode(response.body));
            debugPrint('Login successful: Email: ${authResponse.email}, Name: ${authResponse.name}');
            return authResponse;
          } catch (e) {
            debugPrint('Error parsing login response: $e');
            throw Exception('Invalid response format from server');
          }
        } else {
          var errorMessage = 'Login failed';
          try {
            final errorBody = json.decode(response.body);
            errorMessage = errorBody['message'] ?? errorMessage;
          } catch (_) {}
          throw Exception(errorMessage);
        }
      } catch (e) {
        debugPrint('Error during login: $e');
        throw Exception(_handleError(e));
      }
    });
  }

  Future<bool> validateToken(String token) async {
    return _retryRequest(() async {
      try {
        // final url = Uri.parse('$baseURL/validate-token');
        // debugPrint('🔐 Validating token at: ${url.toString()}');
        
        // final response = await http.get(
        //   url,
        //   headers: {
        //     'Authorization': 'Bearer $token',
        //     'Content-Type': 'application/json',
        //   },
        // ).timeout(
        //   Duration(seconds: _timeoutSeconds),
        //   onTimeout: () => throw TimeoutException('Connection timed out'),
        // );

        // debugPrint('🔑 Token validation response status: ${response.statusCode}');
        return true;
      } catch (e) {
        debugPrint('Token validation error: $e');
        throw Exception(_handleError(e));
      }
    });
  }
}