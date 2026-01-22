import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz/quiz.dart';
import '../services/quiz_service.dart';
import 'quiz/create_quiz_screen.dart';
import 'quiz/edit_quiz_screen.dart';
import 'quiz/quiz_detail_screen.dart';
import 'package:tappy_app/widgets/design/buttons.dart';
import 'package:tappy_app/widgets/design/fixed_width_container.dart';
import 'package:tappy_app/widgets/design/inline_message_banner.dart';
import 'package:tappy_app/widgets/design/pill_tag.dart';
import 'package:tappy_app/widgets/design/surface_card.dart';

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
    _loadQuizzes();
  } // no error here

  Future<void> _loadQuizzes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final quizService = context.read<QuizService>();
      final quizzes = await quizService.getMyQuizzes();
      if (mounted) {
        setState(() {
          _quizzes = quizzes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createQuiz() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateQuizScreen()),
    );
    if (!mounted) return;
    if (result == true) {
      _loadQuizzes();
    }
  }

  Future<void> _editQuiz(Quiz quiz) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditQuizScreen(quiz: quiz)),
    );
    if (!mounted) return;
    if (result == true) {
      _loadQuizzes();
    }
  }

  void _openQuiz(Quiz quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizDetailScreen(quizId: quiz.id)),
    );
  }

  Future<bool> _confirmToggleQuizStatus(Quiz quiz) async {
    final nextActive = !quiz.isActive;
    final verb = nextActive ? 'Activate' : 'Deactivate';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$verb Quiz'),
        content: Text(
          'Are you sure you want to $verb "${quiz.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(verb),
          ),
        ],
      ),
    );

    return result == true;
  }

  Future<void> _toggleQuizStatus(Quiz quiz) async {
    final confirmed = await _confirmToggleQuizStatus(quiz);
    if (!confirmed) return;
    if (!mounted) return;

    try {
      final quizService = context.read<QuizService>();
      await quizService.toggleQuizStatus(quiz.id);
      if (!mounted) return;

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
    if (!mounted) return;

    try {
      final quizService = context.read<QuizService>();
      await quizService.deleteQuiz(quiz.id);
      if (!mounted) return;

      final colors = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Quiz deleted successfully'),
          backgroundColor: colors.primaryContainer,
        ),
      );
      _loadQuizzes();
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
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadQuizzes,
          ),
          TextButton.icon(
            onPressed: _createQuiz,
            icon: const Icon(Icons.add),
            label: const Text('Create Quiz'),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _CenteredPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InlineMessageBanner(
              title: 'Failed to load quizzes',
              message: _error!,
              variant: InlineMessageVariant.error,
            ),
            const SizedBox(height: 12),
            PrimaryButton(label: 'Retry', onPressed: _loadQuizzes),
          ],
        ),
      );
    }

    if (_quizzes.isEmpty) {
      final theme = Theme.of(context);
      final colors = theme.colorScheme;
      return RefreshIndicator(
        onRefresh: _loadQuizzes,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
            _CenteredPanel(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 72,
                    color: colors.onSurfaceVariant.withAlpha(115),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No quizzes yet',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Create your first quiz to share or practice.',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Create quiz',
                    icon: Icons.add,
                    onPressed: _createQuiz,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQuizzes,
      child: FixedWidthContainer(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
          itemCount: _quizzes.length,
          itemBuilder: (context, index) {
            final quiz = _quizzes[index];
            return _QuizRow(
              quiz: quiz,
              onOpen: () => _openQuiz(quiz),
              onEdit: () => _editQuiz(quiz),
              onToggle: () => _toggleQuizStatus(quiz),
              onDelete: () => _deleteQuiz(quiz),
            );
          },
        ),
      ),
    );
  }
}

enum _QuizMenuAction { edit, toggle, delete }

class _QuizRow extends StatelessWidget {
  const _QuizRow({
    required this.quiz,
    required this.onOpen,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final Quiz quiz;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final secondary =
        theme.textTheme.bodySmall?.color ?? colors.onSurfaceVariant;

    final isActive = quiz.isActive;
    final statusColor = isActive ? colors.primary : colors.onSurfaceVariant;

    return SurfaceCard(
      bordered: true,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          const SizedBox(height: 6),
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
                  const SizedBox(width: 12),
                  PillTag(
                    label: isActive ? 'Active' : 'Inactive',
                    color: statusColor,
                    backgroundAlpha: isActive ? 24 : 18,
                    borderAlpha: isActive ? 64 : 48,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.quiz, size: 16, color: secondary),
                  const SizedBox(width: 6),
                  Text(
                    '${quiz.questionCount} questions',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.calendar_today, size: 16, color: secondary),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(quiz.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  PopupMenuButton<_QuizMenuAction>(
                    tooltip: 'Quiz actions',
                    onSelected: (action) {
                      switch (action) {
                        case _QuizMenuAction.edit:
                          onEdit();
                          break;
                        case _QuizMenuAction.toggle:
                          onToggle();
                          break;
                        case _QuizMenuAction.delete:
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: _QuizMenuAction.edit,
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Edit'),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: _QuizMenuAction.toggle,
                        child: ListTile(
                          leading: Icon(
                            isActive
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          title: Text(isActive ? 'Deactivate' : 'Activate'),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: _QuizMenuAction.delete,
                        child: ListTile(
                          leading: Icon(Icons.delete_outline, color: colors.error),
                          title: Text('Delete', style: TextStyle(color: colors.error)),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
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

class _CenteredPanel extends StatelessWidget {
  const _CenteredPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FixedWidthContainer(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SurfaceCard(
            bordered: true,
            margin: EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
