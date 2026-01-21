import 'unit.dart';

class CourseDetail {
  final int id;
  final String title;
  final String? description;
  final int subjectId;
  final String subjectName;
  final List<Unit> units;

  CourseDetail({
    required this.id,
    required this.title,
    this.description,
    required this.subjectId,
    required this.subjectName,
    required this.units,
  });

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    return CourseDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      subjectId: json['subjectId'] as int,
      subjectName: json['subjectName'] as String,
      units: (json['units'] as List<dynamic>?)
              ?.map((u) => Unit.fromJson(u as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'units': units.map((u) => u.toJson()).toList(),
    };
  }
}
