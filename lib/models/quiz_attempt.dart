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
      id: json['Id'],
      quizId: json['QuizId'],
      quizTitle: json['QuizTitle'] ?? '',
      userId: json['UserId'] ?? '',
      userName: json['UserName'] ?? '',
      startedAt: DateTime.parse(json['StartedAt']),
      completedAt: json['CompletedAt'] != null
          ? DateTime.parse(json['CompletedAt'])
          : null,
      score: (json['Score'] ?? 0).toDouble(),
      isCompleted: json['IsCompleted'] ?? false,
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
