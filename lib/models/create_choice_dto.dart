class CreateChoiceDto {
  final String text;
  final bool isCorrect;

  CreateChoiceDto({
    required this.text,
    required this.isCorrect,
  });

  Map<String, dynamic> toJson() {
    return {
      'Text': text,
      'IsCorrect': isCorrect,
    };
  }
}
