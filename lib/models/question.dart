  import 'choice.dart';

class Question {
  final int id;
  final String text;
  final String? explanation;
  final String? imageUrl;
  final int quizId;
  final List<Choice> choices;

  Question({
    required this.id,
    required this.text,
    this.explanation,
    this.imageUrl,
    required this.quizId,
    required this.choices,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['Id'],
      text: json['Text'] ?? '',
      explanation: json['Explanation'],
      imageUrl: json['ImageUrl'],
      quizId: json['QuizId'],
      choices: (json['Choices'] as List<dynamic>)
          .map((c) => Choice.fromJson(c))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Text': text,
      'Explanation': explanation,
      'ImageUrl': imageUrl,
      'QuizId': quizId,
      'Choices': choices.map((c) => c.toJson()).toList(),
    };
  }
}