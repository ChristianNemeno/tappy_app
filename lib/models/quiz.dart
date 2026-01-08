class Quiz {
  final int id;
  final String title;
  final String description;
  final String createdById;
  final String createdByName;
  final bool isActive;
  final int questionCount;
  final DateTime createdAt;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.createdById,
    required this.createdByName,
    required this.isActive,
    required this.questionCount,
    required this.createdAt,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdById: json['createdById'],
      createdByName: json['createdByName'],
      isActive: json['isActive'],
      questionCount: json['questionCount'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}