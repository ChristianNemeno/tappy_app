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
      quizAttemptId: json['quizAttemptId'],
      quizTitle: json['quizTitle'] ?? '',
      totalQuestions: json['totalQuestions'],
      correctAnswers: json['correctAnswers'],
      incorrectAnswers: json['incorrectAnswers'],
      score: (json['score'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      startedAt: DateTime.parse(json['startedAt']),
      completedAt: DateTime.parse(json['completedAt']),
      duration: json['duration'] ?? '',
      questionResults: (json['questionResults'] as List<dynamic>)
          .map((q) => QuestionResult.fromJson(q))
          .toList(),
    );
  }
}