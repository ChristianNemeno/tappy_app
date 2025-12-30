import 'create_question_dto.dart';

class CreateQuizDto {
  final String title;
  final String? description;
  final List<CreateQuestionDto> questions;

  CreateQuizDto({
    required this.title,
    this.description,
    required this.questions,
  });

  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      if (description != null && description!.isNotEmpty) 'Description': description,
      'Questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}
