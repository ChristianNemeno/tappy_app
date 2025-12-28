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
      questionId: json['QuestionId'],
      questionText: json['QuestionText'] ?? '',
      explanation: json['Explanation'],
      selectedChoiceId: json['SelectedChoiceId'],
      selectedChoiceText: json['SelectedChoiceText'] ?? '',
      correctChoiceId: json['CorrectChoiceId'],
      correctChoiceText: json['CorrectChoiceText'] ?? '',
      isCorrect: json['IsCorrect'] ?? false,
    );
  }
}