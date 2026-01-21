import 'course.dart';

class SubjectDetail {
  final int id;
  final String name;
  final String? description;
  final List<Course> courses;

  SubjectDetail({
    required this.id,
    required this.name,
    this.description,
    required this.courses,
  });

  factory SubjectDetail.fromJson(Map<String, dynamic> json) {
    return SubjectDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      courses: (json['courses'] as List<dynamic>?)
              ?.map((c) => Course.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'courses': courses.map((c) => c.toJson()).toList(),
    };
  }
}
