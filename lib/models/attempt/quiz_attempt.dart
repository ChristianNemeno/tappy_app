// lib/models/quiz_attempt.dart
class QuizAttempt {
  final int id;
  final int quizId;
  final String quizTitle;
  final String userId;
  final String userName;
  final DateTime startedAt;
  final DateTime? completedAt;
  final double score;
  final bool isCompleted;

  QuizAttempt({
    required this.id,
    required this.quizId,
    required this.quizTitle,
    required this.userId,
    required this.userName,
    required this.startedAt,
    this.completedAt,
    required this.score,
    required this.isCompleted,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'],
      quizId: json['quizId'],
      quizTitle: json['quizTitle'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      startedAt: DateTime.parse(json['startedAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      score: (json['score'] ?? 0).toDouble(),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'quizTitle': quizTitle,
      'userId': userId,
      'userName': userName,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'score': score,
      'isCompleted': isCompleted,
    };
  }
}
