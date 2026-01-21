class Unit {
  final int id;
  final String title;
  final int orderIndex;
  final int courseId;
  final String courseTitle;
  final int quizCount;

  Unit({
    required this.id,
    required this.title,
    required this.orderIndex,
    required this.courseId,
    required this.courseTitle,
    required this.quizCount,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] as int,
      title: json['title'] as String,
      orderIndex: json['orderIndex'] as int,
      courseId: json['courseId'] as int,
      courseTitle: json['courseTitle'] as String,
      quizCount: json['quizCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'orderIndex': orderIndex,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'quizCount': quizCount,
    };
  }
}
