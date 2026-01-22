// lib/models/submit_attempt_request.dart
import 'submit_answer.dart';

class SubmitAttemptRequest {
  final int quizAttemptId;
  final List<SubmitAnswer> answers;

  SubmitAttemptRequest({
    required this.quizAttemptId,
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      'quizAttemptId': quizAttemptId,
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }
}