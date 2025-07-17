import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card_view_model.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'swipe_card_view.dart';

class CardView extends StatefulWidget {
  const CardView({super.key});

  @override
  State<CardView> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  int currentIndex = 0;
  bool showHint = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flashcards"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('How to Use'),
                      content: const Text(
                        '1. Tap on a card to flip it\n'
                        '2. Swipe cards left or right to navigate cards\n'
                        '3. Show/hide hint with the lightbulb button',
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                if (viewModel.articles.isEmpty)
                  const Center(
                    child: Text(
                      'No flashcards available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                else
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children:
                            viewModel.articles.asMap().entries.map((entry) {
                              final int index = entry.key;
                              final article = entry.value;
                              final double rotationAngle =
                                  (index - viewModel.articles.length / 2) * 2.0;
                              final double offsetX =
                                  (index - viewModel.articles.length / 2) * 4;
                              final double offsetY = index * 4;
                              final double scale = 1 - index * 0.015;

                              return Positioned(
                                top: offsetY,
                                left: offsetX,
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform:
                                      Matrix4.identity()
                                        ..rotateZ(rotationAngle * pi / 180)
                                        ..scale(scale),
                                  child: SwipeCardView(
                                    title: article.title,
                                    bodyText: article.description,
                                    frontColor:
                                        Colors.primaries[index %
                                            Colors.primaries.length],
                                    imageUrl: article.imageUrl,
                                    cardHeight: 380,
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
