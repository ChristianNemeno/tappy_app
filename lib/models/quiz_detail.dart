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
      id: json['Id'],
      title: json['Title'],
      description: json['Description'],
      createdById: json['CreatedById'],
      createdByName: json['CreatedByName'],
      isActive: json['IsActive'],
      questionCount: json['QuestionCount'],
      createdAt: DateTime.parse(json['CreatedAt']),
      questions: json['Questions'] != null
          ? (json['Questions'] as List<dynamic>)
              .map((q) => Question.fromJson(q))
              .toList()
          : [],
    );
  }
}
