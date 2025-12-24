class Quiz {
  final int id;
  final String title;
  final String description;
  final int createdById;
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
      id: json['Id'],
      title: json['Title'],
      description: json['Description'],
      createdById: json['CreatedById'],
      createdByName: json['CreatedByName'],
      isActive: json['IsActive'],
      questionCount: json['QuestionCount'],
      createdAt: DateTime.parse(json['CreatedAt']),
    );
  }
}