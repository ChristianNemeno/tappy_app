import 'package:flutter/material.dart';
import '../../models/create_question_dto.dart';
import '../../models/create_choice_dto.dart';

class AddQuestionsScreen extends StatefulWidget {
  final List<CreateQuestionDto> initialQuestions;

  const AddQuestionsScreen({
    super.key,
    this.initialQuestions = const [],
  });

  @override
  State<AddQuestionsScreen> createState() => _AddQuestionsScreenState();
}

class _AddQuestionsScreenState extends State<AddQuestionsScreen> {
  final List<_QuestionBuilder> _questions = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuestions.isNotEmpty) {
      _questions.addAll(
        widget.initialQuestions.map((q) => _QuestionBuilder.fromDto(q)),
      );
    } else {
      _addQuestion();
    }
  }

  void _addQuestion() {
    setState(() {
      _questions.add(_QuestionBuilder());
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  bool _validateAll() {
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one question'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      
      if (question.textController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Question ${i + 1}: Text is required'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      if (question.choices.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Question ${i + 1}: Must have at least 2 choices'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      if (question.choices.length > 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Question ${i + 1}: Cannot have more than 6 choices'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      final hasEmptyChoice = question.choices.any(
        (c) => c.textController.text.trim().isEmpty,
      );
      if (hasEmptyChoice) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Question ${i + 1}: All choices must have text'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      final correctCount = question.choices.where((c) => c.isCorrect).length;
      if (correctCount != 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Question ${i + 1}: Exactly one choice must be marked correct',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    return true;
  }

  void _saveQuestions() {
    if (!_validateAll()) return;

    final questions = _questions.map((q) => q.toDto()).toList();
    Navigator.pop(context, questions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Questions'),
        actions: [
          TextButton.icon(
            onPressed: _saveQuestions,
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Each question must have 2-6 choices with exactly one correct answer',
                    style: TextStyle(fontSize: 13, color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return _QuestionCard(
                  key: ValueKey(_questions[index]),
                  questionNumber: index + 1,
                  question: _questions[index],
                  onRemove: _questions.length > 1
                      ? () => _removeQuestion(index)
                      : null,
                  onUpdate: () => setState(() {}),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addQuestion,
        icon: const Icon(Icons.add),
        label: const Text('Add Question'),
      ),
    );
  }
}

class _QuestionBuilder {
  final TextEditingController textController;
  final TextEditingController explanationController;
  final TextEditingController imageUrlController;
  final List<_ChoiceBuilder> choices;

  _QuestionBuilder()
      : textController = TextEditingController(),
        explanationController = TextEditingController(),
        imageUrlController = TextEditingController(),
        choices = [
          _ChoiceBuilder(isCorrect: true),
          _ChoiceBuilder(isCorrect: false),
        ];

  _QuestionBuilder.fromDto(CreateQuestionDto dto)
      : textController = TextEditingController(text: dto.text),
        explanationController = TextEditingController(text: dto.explanation ?? ''),
        imageUrlController = TextEditingController(text: dto.imageUrl ?? ''),
        choices = dto.choices
            .map((c) => _ChoiceBuilder.fromDto(c))
            .toList();

  CreateQuestionDto toDto() {
    return CreateQuestionDto(
      text: textController.text.trim(),
      explanation: explanationController.text.trim().isEmpty
          ? null
          : explanationController.text.trim(),
      imageUrl: imageUrlController.text.trim().isEmpty
          ? null
          : imageUrlController.text.trim(),
      choices: choices.map((c) => c.toDto()).toList(),
    );
  }

  void dispose() {
    textController.dispose();
    explanationController.dispose();
    imageUrlController.dispose();
    for (var choice in choices) {
      choice.dispose();
    }
  }
}

class _ChoiceBuilder {
  final TextEditingController textController;
  bool isCorrect;

  _ChoiceBuilder({required this.isCorrect})
      : textController = TextEditingController();

  _ChoiceBuilder.fromDto(CreateChoiceDto dto)
      : textController = TextEditingController(text: dto.text),
        isCorrect = dto.isCorrect;

  CreateChoiceDto toDto() {
    return CreateChoiceDto(
      text: textController.text.trim(),
      isCorrect: isCorrect,
    );
  }

  void dispose() {
    textController.dispose();
  }
}

class _QuestionCard extends StatefulWidget {
  final int questionNumber;
  final _QuestionBuilder question;
  final VoidCallback? onRemove;
  final VoidCallback onUpdate;

  const _QuestionCard({
    super.key,
    required this.questionNumber,
    required this.question,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  bool _showOptionalFields = false;

  void _addChoice() {
    if (widget.question.choices.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 6 choices per question'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      widget.question.choices.add(_ChoiceBuilder(isCorrect: false));
    });
    widget.onUpdate();
  }

  void _removeChoice(int index) {
    if (widget.question.choices.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum 2 choices per question'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      widget.question.choices.removeAt(index);
    });
    widget.onUpdate();
  }

  void _setCorrectChoice(int index) {
    setState(() {
      for (int i = 0; i < widget.question.choices.length; i++) {
        widget.question.choices[i].isCorrect = (i == index);
      }
    });
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  child: Text('${widget.questionNumber}'),
                ),
                const SizedBox(width: 12),
                Text(
                  'Question ${widget.questionNumber}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (widget.onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onRemove,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Question Text
            TextField(
              controller: widget.question.textController,
              decoration: const InputDecoration(
                labelText: 'Question Text *',
                hintText: 'Enter the question',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Optional Fields Toggle
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showOptionalFields = !_showOptionalFields;
                });
              },
              icon: Icon(_showOptionalFields ? Icons.expand_less : Icons.expand_more),
              label: Text(
                _showOptionalFields ? 'Hide Optional Fields' : 'Show Optional Fields',
              ),
            ),

            if (_showOptionalFields) ...[
              const SizedBox(height: 8),
              TextField(
                controller: widget.question.explanationController,
                decoration: const InputDecoration(
                  labelText: 'Explanation (Optional)',
                  hintText: 'Explain the correct answer',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: widget.question.imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (Optional)',
                  hintText: 'https://example.com/image.jpg',
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Choices Header
            Row(
              children: [
                const Text(
                  'Choices',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${widget.question.choices.length}/6)',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Spacer(),
                if (widget.question.choices.length < 6)
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: _addChoice,
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Choices List
            ...widget.question.choices.asMap().entries.map((entry) {
              final index = entry.key;
              final choice = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Correct Choice Radio
                    Radio<int>(
                      value: index,
                      groupValue: widget.question.choices
                          .indexWhere((c) => c.isCorrect),
                      onChanged: (value) {
                        if (value != null) _setCorrectChoice(value);
                      },
                    ),
                    // Choice Text
                    Expanded(
                      child: TextField(
                        controller: choice.textController,
                        decoration: InputDecoration(
                          hintText: 'Choice ${index + 1}',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: choice.isCorrect
                              ? Colors.green.withOpacity(0.05)
                              : null,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    // Remove Choice Button
                    if (widget.question.choices.length > 2)
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeChoice(index),
                      ),
                  ],
                ),
              );
            }).toList(),

            // Validation Info
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Select the radio button for the correct answer',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
