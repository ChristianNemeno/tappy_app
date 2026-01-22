class UpdateQuizDto {
  final String title;
  final String? description;
  final bool isActive;

  UpdateQuizDto({
    required this.title,
    this.description,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      if (description != null) 'Description': description,
      'IsActive': isActive,
    };
  }
}
