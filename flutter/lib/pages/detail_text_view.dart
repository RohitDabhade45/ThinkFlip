import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card_view_model.dart';
import 'card_view.dart';
import 'mcq_view.dart';

class DetailTextView extends StatefulWidget {
  final String myDetailedText;
  final String? imagePath;

  const DetailTextView({
    super.key,
    required this.myDetailedText,
    this.imagePath,
  });

  @override
  State<DetailTextView> createState() => _DetailTextViewState();
}

class _DetailTextViewState extends State<DetailTextView> {
  bool _isGenerating = false;
  bool _hasError = false;
  final ScrollController _scrollController = ScrollController();
  late int _flashcardCount;
  late int _mcqCount;

  @override
  void initState() {
    super.initState();
    _flashcardCount = (widget.myDetailedText.length / 300).ceil();
    _mcqCount = (widget.myDetailedText.length / 200).ceil();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _showFlashcardCountDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        int tempCount = _flashcardCount;
        return AlertDialog(
          title: const Text('Select Flashcard Count'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('How many flashcards would you like to generate?'),
                  Slider(
                    value: tempCount.toDouble(),
                    min: 1,
                    max: 15,
                    divisions: 14,
                    label: tempCount.toString(),
                    onChanged: (double value) {
                      setState(() => tempCount = value.toInt());
                    },
                  ),
                  Text('Selected: $tempCount flashcards'),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _flashcardCount = tempCount;
                Navigator.pop(context);
                _generateFlashcards(context);
              },
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMCQCountDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        int tempCount = _mcqCount;
        return AlertDialog(
          title: const Text('Select MCQ Count'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('How many MCQs would you like to generate?'),
                  Slider(
                    value: tempCount.toDouble(),
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: tempCount.toString(),
                    onChanged: (double value) {
                      setState(() => tempCount = value.toInt());
                    },
                  ),
                  Text('Selected: $tempCount MCQs'),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() => _mcqCount = tempCount);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => MCQView(
                          sourceText: widget.myDetailedText,
                          count: _mcqCount,
                        ),
                  ),
                );
              },
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateFlashcards(BuildContext context) async {
    print("🎯 [DEBUG] Starting _generateFlashcards");
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final viewModel = Provider.of<CardViewModel>(context, listen: false);
    
    setState(() {
      _isGenerating = true;
      _hasError = false;
    });

    try {
      print("🎯 [DEBUG] Creating request with count: $_flashcardCount");
      final requestData = {
        "modelType": "text_only",
        "prompt": widget.myDetailedText,
        "number": _flashcardCount
      };
      
      print("🎯 [DEBUG] Calling sendMessage on CardViewModel");
      await viewModel.sendMessage(jsonEncode(requestData));
      print("🎯 [DEBUG] sendMessage completed. Error state: ${viewModel.error}");
      
      if (!mounted) return;
      
      if (viewModel.error != null) {
        print("❌ [DEBUG] Error detected: ${viewModel.error}");
        setState(() => _hasError = true);
      } else if (viewModel.articles.isNotEmpty) {
        print("✅ [DEBUG] Got ${viewModel.articles.length} flashcards, navigating");
        navigator.push(
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider.value(
              value: viewModel,
              child: const CardView(),
            ),
          ),
        );
      } else {
        print("❌ [DEBUG] No flashcards but also no error");
        setState(() => _hasError = true);
      }
    } catch (e) {
      print("❌ [DEBUG] Exception in _generateFlashcards: $e");
      if (mounted) {
        setState(() => _hasError = true);
      }
    } finally {
      print("🎯 [DEBUG] Completing _generateFlashcards");
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Document Details"), elevation: 0),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.imagePath != null)
                    Hero(
                      tag: 'scan_image',
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                        ),
                        child: Image.file(
                          File(widget.imagePath!),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    if (widget.imagePath != null)
                    Card(
                    margin: const EdgeInsets.all(16.0),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.text_fields,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Extracted Text',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 250,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(
                                  0.2,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(8.0),
                              child: SelectableText(
                                widget.myDetailedText,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if(widget.imagePath == null)
                  Card(
                    margin: const EdgeInsets.all(16.0),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.text_fields,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Extracted Text',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 450,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(
                                  0.2,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(8.0),
                              child: SelectableText(
                                widget.myDetailedText,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4776E6).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed:
                                _isGenerating
                                    ? null
                                    : () => _showFlashcardCountDialog(),
                            icon:
                                _isGenerating
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Icon(
                                      Icons.auto_awesome,
                                      color: Colors.white,
                                    ),
                            label: Text(
                              _isGenerating
                                  ? 'Generating Flashcards...'
                                  : 'Generate Flashcards',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00C9FF).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed:
                                _isGenerating
                                    ? null
                                    : () => _showMCQCountDialog(),
                            icon: const Icon(
                              Icons.psychology,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Generate MCQs',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_hasError)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Card(
                  color: theme.colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            Provider.of<CardViewModel>(context).error ??
                                'Failed to generate flashcards. Please try again.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          color: theme.colorScheme.onErrorContainer,
                          onPressed: () => setState(() => _hasError = false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
