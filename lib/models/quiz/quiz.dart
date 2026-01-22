class Quiz {
  final int id;
  final String title;
  final String description;
  final int? unitId;
  final String? unitTitle;
  final int orderIndex;
  final DateTime createdAt;
  final String createdById;
  final String createdByName;
  final bool isActive;
  final int questionCount;
  final int? attemptCount;

  Quiz({
    required this.id,
    required this.title,
    String? description,
    this.unitId,
    this.unitTitle,
    required this.orderIndex,
    required this.createdAt,
    required this.createdById,
    required this.createdByName,
    required this.isActive,
    required this.questionCount,
    this.attemptCount,
  }) : description = description ?? 'No description provided';

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      unitId: json['unitId'] as int?,
      unitTitle: json['unitTitle'] as String?,
      orderIndex: json['orderIndex'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdById: json['createdById'] as String,
      createdByName: json['createdByName'] as String,
      isActive: json['isActive'] as bool,
      questionCount: json['questionCount'] as int,
      attemptCount: json['attemptCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'unitId': unitId,
      'unitTitle': unitTitle,
      'orderIndex': orderIndex,
      'createdAt': createdAt.toIso8601String(),
      'createdById': createdById,
      'createdByName': createdByName,
      'isActive': isActive,
      'questionCount': questionCount,
      'attemptCount': attemptCount,
    };
  }

  bool get isStandalone => unitId == null;
}