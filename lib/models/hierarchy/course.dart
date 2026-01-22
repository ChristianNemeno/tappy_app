class Course {
  final int id;
  final String title;
  final String? description;
  final int subjectId;
  final String subjectName;
  final int unitCount;

  Course({
    required this.id,
    required this.title,
    this.description,
    required this.subjectId,
    required this.subjectName,
    required this.unitCount,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      subjectId: json['subjectId'] as int,
      subjectName: json['subjectName'] as String,
      unitCount: json['unitCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'unitCount': unitCount,
    };
  }
}
