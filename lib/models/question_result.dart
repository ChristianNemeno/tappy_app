class QuestionResult {
  final int questionId;
  final String questionText;
  final String? explanation;
  final int selectedChoiceId;
  final String selectedChoiceText;
  final int correctChoiceId;
  final String correctChoiceText;
  final bool isCorrect;

  QuestionResult({
    required this.questionId,
    required this.questionText,
    this.explanation,
    required this.selectedChoiceId,
    required this.selectedChoiceText,
    required this.correctChoiceId,
    required this.correctChoiceText,
    required this.isCorrect,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      questionId: json['questionId'],
      questionText: json['questionText'] ?? '',
      explanation: json['explanation'],
      selectedChoiceId: json['selectedChoiceId'],
      selectedChoiceText: json['selectedChoiceText'] ?? '',
      correctChoiceId: json['correctChoiceId'],
      correctChoiceText: json['correctChoiceText'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
    );
  }
}