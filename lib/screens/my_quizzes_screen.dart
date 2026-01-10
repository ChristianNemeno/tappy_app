import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import 'quiz/create_quiz_screen.dart';
import 'quiz/edit_quiz_screen.dart';
import 'quiz/quiz_detail_screen.dart';

class MyQuizzesScreen extends StatefulWidget {
  const MyQuizzesScreen({super.key});

  @override
  State<MyQuizzesScreen> createState() => _MyQuizzesScreenState();
}

class _MyQuizzesScreenState extends State<MyQuizzesScreen> {
  List<Quiz> _quizzes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('[INFO] MyQuizzesScreen: Screen initialized');
    _loadQuizzes();
  } // no error here

  Future<void> _loadQuizzes() async {
    print('[DEBUG] MyQuizzesScreen: Loading user quizzes');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final quizService = context.read<QuizService>();
      final quizzes = await quizService.getMyQuizzes();

      print('[SUCCESS] MyQuizzesScreen: Loaded ${quizzes.length} quizzes');
      if (mounted) {
        setState(() {
          _quizzes = quizzes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[ERROR] MyQuizzesScreen: Failed to load quizzes - $e');
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleQuizStatus(Quiz quiz) async {
    print('[DEBUG] MyQuizzesScreen: Toggling status for quiz ${quiz.id}');
    try {
      final quizService = context.read<QuizService>();
      await quizService.toggleQuizStatus(quiz.id);
      print('[SUCCESS] MyQuizzesScreen: Quiz status toggled');

      if (mounted) {
        final colors = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              quiz.isActive
                  ? 'Quiz deactivated successfully'
                  : 'Quiz activated successfully',
            ),
            backgroundColor: colors.primaryContainer,
          ),
        );
        _loadQuizzes();
      }
    } catch (e) {
      if (mounted) {
        final colors = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: colors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteQuiz(Quiz quiz) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: Text(
          'Are you sure you want to delete "${quiz.title}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final quizService = context.read<QuizService>();
      await quizService.deleteQuiz(quiz.id);

      if (mounted) {
        final colors = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Quiz deleted successfully'),
            backgroundColor: colors.primaryContainer,
          ),
        );
        _loadQuizzes();
      }
    } catch (e) {
      if (mounted) {
        final colors = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: colors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Quizzes'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadQuizzes),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateQuizScreen()),
          );
          if (result == true) {
            _loadQuizzes();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Quiz'),
      ),
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: colors.error),
            const SizedBox(height: 16),
            Text('Failed to load quizzes', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadQuizzes,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_quizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz,
              size: 80,
              color: colors.onSurfaceVariant.withOpacity(0.45),
            ),
            const SizedBox(height: 16),
            Text('No quizzes yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Create your first quiz!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQuizzes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _quizzes.length,
        itemBuilder: (context, index) {
          final quiz = _quizzes[index];
          return _QuizManagementCard(
            quiz: quiz,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizDetailScreen(quizId: quiz.id),
                ),
              );
            },
            onEdit: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditQuizScreen(quiz: quiz),
                ),
              );
              if (result == true) {
                _loadQuizzes();
              }
            },
            onToggle: () => _toggleQuizStatus(quiz),
            onDelete: () => _deleteQuiz(quiz),
          );
        },
      ),
    );
  }
}

class _QuizManagementCard extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _QuizManagementCard({
    required this.quiz,
    required this.onTap,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  BorderRadius _resolveCardRadius(BuildContext context) {
    final shape = Theme.of(context).cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(Directionality.of(context));
    }
    return BorderRadius.circular(16);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final cardRadius = _resolveCardRadius(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: cardRadius,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (quiz.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            quiz.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(quiz.isActive ? 'Active' : 'Inactive'),
                    backgroundColor: quiz.isActive
                        ? colors.primaryContainer
                        : colors.onSurfaceVariant.withOpacity(0.10),
                    labelStyle: theme.textTheme.labelMedium?.copyWith(
                      color: quiz.isActive
                          ? colors.onPrimaryContainer
                          : colors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                    side: BorderSide(
                      color: quiz.isActive
                          ? colors.primary
                          : colors.outlineVariant,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.quiz, size: 16, color: colors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${quiz.questionCount} questions',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(quiz.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: onToggle,
                    icon: Icon(
                      quiz.isActive ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                    ),
                    label: Text(quiz.isActive ? 'Deactivate' : 'Activate'),
                  ),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete, size: 18, color: colors.error),
                    label: Text(
                      'Delete',
                      style: TextStyle(color: colors.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
