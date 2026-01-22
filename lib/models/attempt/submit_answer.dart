// lib/models/submit_answer.dart
class SubmitAnswer {
  final int questionId;
  final int choiceId;

  SubmitAnswer({
    required this.questionId,
    required this.choiceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'choiceId': choiceId,
    };
  }
}