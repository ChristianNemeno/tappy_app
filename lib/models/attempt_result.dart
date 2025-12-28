// lib/models/attempt_result.dart
import 'question_result.dart';

class AttemptResult {
  final int quizAttemptId;
  final String quizTitle;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final double score;
  final double percentage;
  final DateTime startedAt;
  final DateTime completedAt;
  final String duration;
  final List<QuestionResult> questionResults;

  AttemptResult({
    required this.quizAttemptId,
    required this.quizTitle,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.score,
    required this.percentage,
    required this.startedAt,
    required this.completedAt,
    required this.duration,
    required this.questionResults,
  });

  factory AttemptResult.fromJson(Map<String, dynamic> json) {
    return AttemptResult(
      quizAttemptId: json['QuizAttemptId'],
      quizTitle: json['QuizTitle'] ?? '',
      totalQuestions: json['TotalQuestions'],
      correctAnswers: json['CorrectAnswers'],
      incorrectAnswers: json['IncorrectAnswers'],
      score: (json['Score'] ?? 0).toDouble(),
      percentage: (json['Percentage'] ?? 0).toDouble(),
      startedAt: DateTime.parse(json['StartedAt']),
      completedAt: DateTime.parse(json['CompletedAt']),
      duration: json['Duration'] ?? '',
      questionResults: (json['QuestionResults'] as List<dynamic>)
          .map((q) => QuestionResult.fromJson(q))
          .toList(),
    );
  }
}