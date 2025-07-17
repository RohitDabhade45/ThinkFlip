import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card_view_model.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:convert';
import 'swipe_card_view.dart';
import 'mcq_view.dart';

class EnterTextView extends StatefulWidget {
  const EnterTextView({super.key});

  @override
  State<EnterTextView> createState() => _CardViewState();
}

class _CardViewState extends State<EnterTextView> {
  final TextEditingController userInputController = TextEditingController();
  bool isGenerating = false;
  int currentIndex = 0;
  bool showHint = false;
  int mcqCount = 5; // Default MCQ count
  int flashcardCount = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CardViewModel>(context, listen: false).clearArticles();
    });
  }

  @override
  void dispose() {
    userInputController.dispose();
    super.dispose();
  }

  Future<void> _generateFlashcards(BuildContext context, String text) async {
    setState(() => isGenerating = true);
    try {
      final requestData = {
        "modelType": "text_only",
        "prompt": text,
        "number": flashcardCount
      };
      await Provider.of<CardViewModel>(context, listen: false)
          .sendMessage(jsonEncode(requestData));
      if (mounted) {
        userInputController.clear();
        setState(() => currentIndex = 0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating flashcards: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isGenerating = false);
      }
    }
  }

  void _showFlashcardCountDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        int tempCount = flashcardCount;
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
                setState(() => flashcardCount = tempCount);
                Navigator.pop(context);
                if (userInputController.text.isNotEmpty) {
                  _generateFlashcards(context, userInputController.text);
                }
              },
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );
  }

  void _showMCQCountDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        int tempCount = mcqCount;
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
                setState(() => mcqCount = tempCount);
                Navigator.pop(context);
                if (userInputController.text.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MCQView(
                        sourceText: userInputController.text,
                        count: mcqCount,
                      ),
                    ),
                  );
                }
              },
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flashcard Generator"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('How to Use'),
                  content: const Text(
                    '1. Enter or paste your text in the input field\n'
                    '2. Click "Generate Flashcards" to create cards\n'
                    '3. Tap on a card to flip it\n'
                    '4. Swipe cards left or right to navigate cards\n'
                    '5. Show/hide hint with the lightbulb button',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CardViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter Text to Generate Flashcards',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: userInputController,
                          decoration: InputDecoration(
                            hintText: "Type or paste your text here",
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.paste),
                              onPressed: () async {
                                final data = await Clipboard.getData('text/plain');
                                if (data?.text != null) {
                                  userInputController.text = data!.text!;
                                }
                              },
                              tooltip: 'Paste from clipboard',
                            ),
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
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
                          onPressed: isGenerating 
                            ? null 
                            : () {
                                if (userInputController.text.isNotEmpty) {
                                  _showFlashcardCountDialog(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter some text')),
                                  );
                                }
                              },
                          icon: isGenerating 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.auto_awesome, color: Colors.white),
                          label: Text(
                            isGenerating ? "Generating..." : "Generate Flashcards",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
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
                          onPressed: isGenerating 
                            ? null 
                            : () {
                                if (userInputController.text.isNotEmpty) {
                                  _showMCQCountDialog();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter some text')),
                                  );
                                }
                              },
                          icon: const Icon(Icons.psychology, color: Colors.white),
                          label: const Text(
                            "Generate MCQs",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (viewModel.articles.isEmpty && !isGenerating)
                  const Center(
                    child: Text(
                      'No flashcards generated yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                else if (!isGenerating && viewModel.articles.isNotEmpty)
                  Expanded(
                  child: viewModel.articles.isEmpty
                      ? const Center(child: Text("No flashcards generated yet"))
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 50.0), 
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: viewModel.articles
                                .asMap()
                                .entries
                                .map((entry) {
                              final int index = entry.key;
                              final article = entry.value;
                              final double rotationAngle = (index - viewModel.articles.length / 2) * 2.0;
                              final double offsetX = (index - viewModel.articles.length / 2) * 4;
                              final double offsetY = index * 4;
                              final double scale = 1 - index * 0.015;

                              return Positioned(
                                top: offsetY,
                                left: offsetX,
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..rotateZ(rotationAngle * pi / 180) // Rotate
                                    ..scale(scale), // Scale effect
                                  child: SwipeCardView(
                                    title: article.title,
                                    bodyText: article.description,
                                    frontColor: Colors.primaries[index % Colors.primaries.length],
                                    imageUrl: article.imageUrl,
                                    cardHeight: 380, // 🔥 Reduced height slightly
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}
