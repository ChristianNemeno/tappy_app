import 'quiz.dart';

class UnitDetail {
  final int id;
  final String title;
  final int orderIndex;
  final int courseId;
  final String courseTitle;
  final List<Quiz> quizzes;

  UnitDetail({
    required this.id,
    required this.title,
    required this.orderIndex,
    required this.courseId,
    required this.courseTitle,
    required this.quizzes,
  });

  factory UnitDetail.fromJson(Map<String, dynamic> json) {
    return UnitDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      orderIndex: json['orderIndex'] as int,
      courseId: json['courseId'] as int,
      courseTitle: json['courseTitle'] as String,
      quizzes: (json['quizzes'] as List<dynamic>?)
              ?.map((q) => Quiz.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'orderIndex': orderIndex,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'quizzes': quizzes.map((q) => q.toJson()).toList(),
    };
  }
}
