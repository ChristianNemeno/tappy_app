class CreateCourseRequest {
  final String title;
  final String? description;
  final int subjectId;

  CreateCourseRequest({
    required this.title,
    this.description,
    required this.subjectId,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'subjectId': subjectId,
    };
  }
}

class UpdateCourseRequest {
  final String title;
  final String? description;
  final int subjectId;

  UpdateCourseRequest({
    required this.title,
    this.description,
    required this.subjectId,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'subjectId': subjectId,
    };
  }
}
