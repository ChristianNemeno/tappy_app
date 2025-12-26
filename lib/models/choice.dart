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
      id: json['id'],
      text: json['text'] ?? '',
      isCorrect: json['isCorrect'],
      questionId: json['questionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      if (isCorrect != null) 'isCorrect': isCorrect,
      'questionId': questionId,
    };
  }
}