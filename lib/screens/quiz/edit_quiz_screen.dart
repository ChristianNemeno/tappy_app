import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/quiz.dart';
import '../../models/update_quiz_dto.dart';
import '../../services/quiz_service.dart';

class EditQuizScreen extends StatefulWidget {
  final Quiz quiz;

  const EditQuizScreen({
    super.key,
    required this.quiz,
  });

  @override
  State<EditQuizScreen> createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late bool _isActive;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    print('[INFO] EditQuizScreen: Screen initialized for quiz ${widget.quiz.id}');
    _titleController = TextEditingController(text: widget.quiz.title);
    _descriptionController = TextEditingController(text: widget.quiz.description);
    _isActive = widget.quiz.isActive;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateQuiz() async {
    print('[DEBUG] EditQuizScreen: Attempting to update quiz');
    if (!_formKey.currentState!.validate()) {
      print('[DEBUG] EditQuizScreen: Form validation failed');
      return;
    }

    print('[INFO] EditQuizScreen: Updating quiz ${widget.quiz.id}');
    setState(() {
      _isUpdating = true;
    });

    try {
      final quizService = context.read<QuizService>();
      final dto = UpdateQuizDto(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        isActive: _isActive,
      );

      await quizService.updateQuiz(widget.quiz.id, dto);
      print('[SUCCESS] EditQuizScreen: Quiz updated successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('[ERROR] EditQuizScreen: Failed to update quiz - $e');
      if (mounted) {
        setState(() {
          _isUpdating = false;
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
        title: const Text('Edit Quiz'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You can only edit quiz metadata. To modify questions, please create a new quiz.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

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
                labelText: 'Description',
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

            // Status Toggle
            Card(
              child: SwitchListTile(
                title: const Text('Active Status'),
                subtitle: Text(
                  _isActive
                      ? 'Quiz is visible to users'
                      : 'Quiz is hidden from users',
                ),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                secondary: Icon(
                  _isActive ? Icons.visibility : Icons.visibility_off,
                  color: _isActive ? Colors.green : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quiz Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz Information',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.quiz,
                      label: 'Questions',
                      value: '${widget.quiz.questionCount}',
                    ),
                    const Divider(),
                    _InfoRow(
                      icon: Icons.person,
                      label: 'Created by',
                      value: widget.quiz.createdByName,
                    ),
                    const Divider(),
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: 'Created',
                      value: _formatDate(widget.quiz.createdAt),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Update Button
            ElevatedButton.icon(
              onPressed: _isUpdating ? null : _updateQuiz,
              icon: _isUpdating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isUpdating ? 'Updating...' : 'Update Quiz'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
