import 'question.dart';

class QuizDetail {
  final int id;
  final String title;
  final String description;
  final int createdById;
  final String createdByName;
  final bool isActive;
  final int questionCount;
  final DateTime createdAt;
  final List<Question> questions;

  QuizDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.createdById,
    required this.createdByName,
    required this.isActive,
    required this.questionCount,
    required this.createdAt,
    required this.questions,
  });

  factory QuizDetail.fromJson(Map<String, dynamic> json) {
    return QuizDetail(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdById: json['createdById'],
      createdByName: json['createdByName'],
      isActive: json['isActive'],
      questionCount: json['questionCount'],
      createdAt: DateTime.parse(json['createdAt']),
      questions: json['questions'] != null
          ? (json['questions'] as List<dynamic>)
              .map((q) => Question.fromJson(q))
              .toList()
          : [],
    );
  }
}
