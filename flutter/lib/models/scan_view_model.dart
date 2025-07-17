import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/history_service.dart';
import '../viewmodels/auth_view_model.dart';
import 'card_view_model.dart'; // Import CardViewModel to use sendMessage()

enum SortOption {
  dateNewest,
  dateOldest,
  nameAZ,
  nameZA,
}

class ScannedDocument {
  final String text;
  final DateTime dateScanned;
  final String imagePath;

  ScannedDocument({required this.text, required this.dateScanned, required this.imagePath});

  Map<String, dynamic> toJson() => {
    'text': text,
    'dateScanned': dateScanned.toIso8601String(),
    'imagePath': imagePath,
  };

  factory ScannedDocument.fromJson(Map<String, dynamic> json) => ScannedDocument(
    text: json['text'],
    dateScanned: DateTime.parse(json['dateScanned']),
    imagePath: json['imagePath'],
  );
}

class ScanViewModel extends ChangeNotifier {
  static const String _storageKey = 'scanned_documents';
  List<ScannedDocument> allScannedDocs = [];
  final CardViewModel cardViewModel = CardViewModel(); // Initialize CardViewModel
  late final HistoryService _historyService;
  final AuthViewModel _authViewModel;
  SortOption _currentSort = SortOption.dateNewest;

  SortOption get currentSort => _currentSort;

  ScanViewModel(this._authViewModel) {
    _historyService = HistoryService(_authViewModel);
    _loadDocuments(); // Load saved documents when ViewModel is created
  }

  void sortDocuments(SortOption option) {
    _currentSort = option;
    switch (option) {
      case SortOption.dateNewest:
        allScannedDocs.sort((a, b) => b.dateScanned.compareTo(a.dateScanned));
      case SortOption.dateOldest:
        allScannedDocs.sort((a, b) => a.dateScanned.compareTo(b.dateScanned));
      case SortOption.nameAZ:
        allScannedDocs.sort((a, b) => a.text.compareTo(b.text));
      case SortOption.nameZA:
        allScannedDocs.sort((a, b) => b.text.compareTo(a.text));
    }
    notifyListeners();
  }

  Future<void> _loadDocuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null) {
        final List<dynamic> jsonList = json.decode(jsonStr);
        allScannedDocs = jsonList
            .map((json) => ScannedDocument.fromJson(json))
            .toList();
        sortDocuments(SortOption.dateNewest);
      }
    } catch (e) {
      debugPrint('Error loading documents: $e');
    }
  }

  Future<void> _saveDocuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonStr = json.encode(
        allScannedDocs.map((doc) => doc.toJson()).toList()
      );
      await prefs.setString(_storageKey, jsonStr);
    } catch (e) {
      debugPrint('Error saving documents: $e');
    }
  }

  Future<void> processScannedImages(List<String> scannedImages) async {
    final textRecognizer = TextRecognizer();

    for (var imagePath in scannedImages) {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      String extractedText = recognizedText.text;

      // Save document locally
      final scannedDoc = ScannedDocument(
        text: extractedText,
        dateScanned: DateTime.now(),
        imagePath: imagePath,
      );
      allScannedDocs.add(scannedDoc);
      await _saveDocuments(); // Save to persistent storage

      // Save to backend
      await _historyService.saveDocument(extractedText);
    }

    textRecognizer.close();
    // Apply default sorting after adding new documents
    sortDocuments(SortOption.dateNewest);
  }
}
