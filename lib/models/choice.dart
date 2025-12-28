class Choice {
  final int id;
  final String text;
  final bool? isCorrect; // null during quiz, true/false in results
  final int questionId;

  Choice({
    required this.id,
    required this.text,
    this.isCorrect,
    required this.questionId,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      id: json['Id'],
      text: json['Text'] ?? '',
      isCorrect: json['IsCorrect'],
      questionId: json['QuestionId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Text': text,
      if (isCorrect != null) 'IsCorrect': isCorrect,
      'QuestionId': questionId,
    };
  }
}