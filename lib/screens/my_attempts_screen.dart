import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_attempt.dart';
import '../services/attempt_service.dart';
import 'quiz/quiz_result_screen.dart';

class MyAttemptsScreen extends StatefulWidget {
  const MyAttemptsScreen({super.key});

  @override
  State<MyAttemptsScreen> createState() => _MyAttemptsScreenState();
}

class _MyAttemptsScreenState extends State<MyAttemptsScreen> {
  List<QuizAttempt> _attempts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('[INFO] MyAttemptsScreen: Screen initialized');
    _loadAttempts();
  }

  Future<void> _loadAttempts() async {
    print('[DEBUG] MyAttemptsScreen: Loading user attempts');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final attemptService = context.read<AttemptService>();
      final attempts = await attemptService.getUserAttempts();
      print('[SUCCESS] MyAttemptsScreen: Loaded ${attempts.length} attempts');

      if (mounted) {
        setState(() {
          _attempts = attempts;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[ERROR] MyAttemptsScreen: Failed to load attempts - $e');
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _viewResult(QuizAttempt attempt) async {
    print('[DEBUG] MyAttemptsScreen: Viewing result for attempt ${attempt.id}');
    if (!attempt.isCompleted) {
      print('[DEBUG] MyAttemptsScreen: Attempt is not completed');
      final colors = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: colors.tertiaryContainer,
          content: Text(
            'This attempt is not yet completed',
            style: TextStyle(color: colors.onTertiaryContainer),
          ),
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading results...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final attemptService = context.read<AttemptService>();
      final result = await attemptService.getAttemptResult(attempt.id);

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to result screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(result: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        // Keep messaging identical; use theme-driven colors.
        SnackBar(
          content: Text(
            'Failed to load results: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attempts'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAttempts),
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
      final colors = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: colors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load attempts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAttempts,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_attempts.isEmpty) {
      final theme = Theme.of(context);
      final colors = theme.colorScheme;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: colors.onSurfaceVariant.withOpacity(0.45),
            ),
            const SizedBox(height: 16),
            Text('No attempts yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Take a quiz to see your history',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAttempts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _attempts.length,
        itemBuilder: (context, index) {
          final attempt = _attempts[index];
          return _AttemptCard(
            attempt: attempt,
            onTap: () => _viewResult(attempt),
          );
        },
      ),
    );
  }
}

class _AttemptCard extends StatelessWidget {
  final QuizAttempt attempt;
  final VoidCallback onTap;

  const _AttemptCard({required this.attempt, required this.onTap});

  Color _scoreColor(ColorScheme colors, double score) {
    if (score >= 80) return colors.primary;
    if (score >= 60) return colors.tertiary;
    return colors.error;
  }

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
        onTap: attempt.isCompleted ? onTap : null,
        borderRadius: cardRadius,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      attempt.quizTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (attempt.isCompleted)
                    Chip(
                      label: Text('${attempt.score.toStringAsFixed(1)}%'),
                      backgroundColor: _scoreColor(
                        colors,
                        attempt.score,
                      ).withOpacity(0.16),
                      labelStyle: theme.textTheme.labelMedium?.copyWith(
                        color: _scoreColor(colors, attempt.score),
                        fontWeight: FontWeight.w800,
                      ),
                      side: BorderSide(
                        color: _scoreColor(colors, attempt.score),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                    ),
                  if (!attempt.isCompleted)
                    Chip(
                      label: const Text('Incomplete'),
                      backgroundColor: colors.onSurfaceVariant.withOpacity(
                        0.10,
                      ),
                      labelStyle: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                      side: BorderSide(color: colors.outlineVariant),
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
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(attempt.startedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(attempt.startedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (attempt.isCompleted) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Completed on ${_formatDate(attempt.completedAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
              if (attempt.isCompleted) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('View Results'),
                    ),
                  ],
                ),
              ],
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

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
