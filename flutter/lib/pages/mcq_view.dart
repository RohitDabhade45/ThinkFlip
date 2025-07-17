import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mcq_view_model.dart';
import '../models/mcq_model.dart';
import 'mcq_completion_screen.dart';

class MCQView extends StatelessWidget {
  final String sourceText;
  final int count;

  const MCQView({
    super.key, 
    required this.sourceText,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MCQViewModel()..generateMCQs(sourceText, count),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Practice Questions'),
          actions: [
            Consumer<MCQViewModel>(
              builder: (context, viewModel, _) => TextButton.icon(
                onPressed: () => viewModel.resetQuiz(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ),
          ],
        ),
        body: Consumer<MCQViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.error != null) {
              return Center(child: Text(viewModel.error!));
            }

            if (viewModel.questions.isEmpty) {
              return const Center(child: Text('No questions generated'));
            }

            // Navigate to completion screen when all questions are answered
            if (viewModel.completedQuestions == viewModel.questions.length) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MCQCompletionScreen(
                      sourceText: sourceText,
                      score: viewModel.score,
                      totalAttempts: viewModel.totalAttempts,
                      totalQuestions: viewModel.questions.length,
                    ),
                  ),
                );
              });
            }

            return Column(
              children: [
                // Progress and Score Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Score: ${viewModel.score}/${viewModel.totalAttempts}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Progress: ${viewModel.completedQuestions}/${viewModel.questions.length}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                LinearProgressIndicator(
                  value: viewModel.progressPercentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                // Questions List
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.questions.length,
                    itemBuilder: (context, index) {
                      final question = viewModel.questions[index];
                      return QuestionCard(
                        questionNumber: index + 1,
                        question: question,
                        onAnswered: (isCorrect) {
                          viewModel.recordAnswer(index, isCorrect);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class QuestionCard extends StatefulWidget {
  final int questionNumber;
  final MCQModel question;
  final Function(bool isCorrect) onAnswered;

  const QuestionCard({
    super.key,
    required this.questionNumber,
    required this.question,
    required this.onAnswered,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  String? selectedOption;
  bool showExplanation = false;

  void _handleAnswer(String? value) {
    if (value != null && selectedOption == null) {
      setState(() {
        selectedOption = value;
        showExplanation = true;
      });
      widget.onAnswered(value == widget.question.correctOption);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool answered = selectedOption != null;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Question ${widget.questionNumber}:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (answered)
                  Icon(
                    selectedOption == widget.question.correctOption
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: selectedOption == widget.question.correctOption
                        ? Colors.green
                        : Colors.red,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.question.question),
            const SizedBox(height: 16),
            ...widget.question.options.map((option) {
              final isSelected = selectedOption == option;
              final isCorrect = widget.question.correctOption == option;
              final showResult = selectedOption != null;

              return ListTile(
                title: Text(option),
                leading: Radio<String>(
                  value: option,
                  groupValue: selectedOption,
                  onChanged: answered ? null : _handleAnswer,
                ),
                tileColor: showResult
                    ? isCorrect
                        ? Colors.green.withOpacity(0.2)
                        : isSelected
                            ? Colors.red.withOpacity(0.2)
                            : null
                    : null,
              );
            }).toList(),
            if (showExplanation) ...[
              const SizedBox(height: 16),
              Text(
                'Explanation:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(widget.question.explanation),
              if (selectedOption != widget.question.correctOption) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedOption = null;
                      showExplanation = false;
                    });
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}