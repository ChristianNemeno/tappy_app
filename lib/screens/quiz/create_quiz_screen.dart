import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/quiz/create_quiz_dto.dart';
import '../../models/quiz/create_question_dto.dart';
import '../../models/quiz/create_choice_dto.dart';
import '../../services/quiz_service.dart';
import 'add_questions_screen.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  List<CreateQuestionDto> _questions = [];
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    print('[INFO] CreateQuizScreen: Screen initialized');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addQuestions() async {
    print('[DEBUG] CreateQuizScreen: Opening add questions screen');
    if (!_formKey.currentState!.validate()) return;

    final result = await Navigator.push<List<CreateQuestionDto>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionsScreen(
          initialQuestions: _questions,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _questions = result;
      });
    }
  }

  Future<void> _createQuiz() async {
    print('[DEBUG] CreateQuizScreen: Attempting to create quiz');
    if (!_formKey.currentState!.validate()) {
      print('[DEBUG] CreateQuizScreen: Form validation failed');
      return;
    }

    if (_questions.isEmpty) {
      print('[DEBUG] CreateQuizScreen: No questions added');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one question'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final quizService = context.read<QuizService>();
      final dto = CreateQuizDto(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        questions: _questions,
      );

      print('[INFO] CreateQuizScreen: Creating quiz with ${_questions.length} questions');
      await quizService.createQuiz(dto);
      print('[SUCCESS] CreateQuizScreen: Quiz created successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('[ERROR] CreateQuizScreen: Failed to create quiz - $e');
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quiz'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Quiz Title *',
                hintText: 'Enter quiz title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                if (value.trim().length < 3) {
                  return 'Title must be at least 3 characters';
                }
                if (value.trim().length > 200) {
                  return 'Title must not exceed 200 characters';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter quiz description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value != null && value.trim().length > 2000) {
                  return 'Description must not exceed 2000 characters';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Questions Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.quiz),
                        const SizedBox(width: 8),
                        Text(
                          'Questions',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _questions.isEmpty
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _questions.isEmpty
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ),
                          child: Text(
                            '${_questions.length} questions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _questions.isEmpty
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_questions.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.quiz, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'No questions added yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._questions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final question = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                child: Text('${index + 1}'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      question.text,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${question.choices.length} choices',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _addQuestions,
                      icon: Icon(_questions.isEmpty ? Icons.add : Icons.edit),
                      label: Text(
                        _questions.isEmpty ? 'Add Questions' : 'Edit Questions',
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Create Button
            ElevatedButton.icon(
              onPressed: _isCreating ? null : _createQuiz,
              icon: _isCreating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(_isCreating ? 'Creating...' : 'Create Quiz'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
