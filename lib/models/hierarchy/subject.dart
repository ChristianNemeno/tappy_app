class Subject {
  final int id;
  final String name;
  final String? description;
  final int courseCount;

  Subject({
    required this.id,
    required this.name,
    this.description,
    required this.courseCount,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      courseCount: json['courseCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'courseCount': courseCount,
    };
  }
}
