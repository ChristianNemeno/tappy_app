import 'create_choice_dto.dart';

class CreateQuestionDto {
  final String text;
  final String? explanation;
  final String? imageUrl;
  final List<CreateChoiceDto> choices;

  CreateQuestionDto({
    required this.text,
    this.explanation,
    this.imageUrl,
    required this.choices,
  });

  Map<String, dynamic> toJson() {
    return {
      'Text': text,
      if (explanation != null && explanation!.isNotEmpty) 'Explanation': explanation,
      if (imageUrl != null && imageUrl!.isNotEmpty) 'ImageUrl': imageUrl,
      'Choices': choices.map((c) => c.toJson()).toList(),
    };
  }
}
