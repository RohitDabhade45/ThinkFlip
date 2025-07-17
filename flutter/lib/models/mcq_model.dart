class MCQModel {
  final String question;
  final List<String> options;
  final String correctOption;
  final String explanation;

  MCQModel({
    required this.question,
    required this.options,
    required this.correctOption,
    required this.explanation,
  });

  factory MCQModel.fromJson(Map<String, dynamic> json) {
    return MCQModel(
      question: json['question'] as String,
      options: List<String>.from(json['options']),
      correctOption: json['correctOption'] as String,
      explanation: json['explanation'] as String,
    );
  }
}