import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'mcq_model.dart';

class MCQViewModel extends ChangeNotifier {
  List<MCQModel> questions = [];
  bool isLoading = false;
  String? error;
  
  int _score = 0;
  int _totalAttempts = 0;
  Set<int> _completedQuestions = {};

  int get score => _score;
  int get totalAttempts => _totalAttempts;
  int get completedQuestions => _completedQuestions.length;
  double get progressPercentage => questions.isEmpty ? 0 : (_completedQuestions.length / questions.length) * 100;
  
  void recordAnswer(int questionIndex, bool isCorrect) {
    _totalAttempts++;
    if (isCorrect) {
      _score++;
    }
    _completedQuestions.add(questionIndex);
    notifyListeners();
  }

  void resetQuiz() {
    _score = 0;
    _totalAttempts = 0;
    _completedQuestions.clear();
    notifyListeners();
  }

  Future<void> generateMCQs(String text, int count) async {
    isLoading = true;
    error = null;
    resetQuiz();
    notifyListeners();

    try {
      final url = Uri.parse('https://thinkflip-backend.onrender.com/gemini/mcq');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'modelType': 'text_only',
          'prompt': text,
          'number': count
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        questions = List<MCQModel>.from(
          data['result'].map((x) => MCQModel.fromJson(x)),
        );
      } else {
        error = 'Failed to generate MCQs';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}