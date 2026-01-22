import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/attempt/quiz_attempt.dart';
import '../services/attempt_service.dart';
import 'quiz/quiz_result_screen.dart';
import 'package:tappy_app/widgets/design/buttons.dart';
import 'package:tappy_app/widgets/design/fixed_width_container.dart';
import 'package:tappy_app/widgets/design/inline_message_banner.dart';
import 'package:tappy_app/widgets/design/pill_tag.dart';
import 'package:tappy_app/widgets/design/surface_card.dart';

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
      return _CenteredPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InlineMessageBanner(
              title: 'Failed to load attempts',
              message: _error!,
              variant: InlineMessageVariant.error,
            ),
            const SizedBox(height: 12),
            PrimaryButton(label: 'Retry', onPressed: _loadAttempts),
          ],
        ),
      );
    }

    if (_attempts.isEmpty) {
      final theme = Theme.of(context);
      final colors = theme.colorScheme;
      return RefreshIndicator(
        onRefresh: _loadAttempts,
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
                    Icons.history,
                    size: 72,
                    color: colors.onSurfaceVariant.withAlpha(115),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No attempts yet',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Take a quiz to see your history.',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(label: 'Refresh', onPressed: _loadAttempts),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAttempts,
      child: FixedWidthContainer(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
          itemCount: _attempts.length,
          itemBuilder: (context, index) {
            final attempt = _attempts[index];
            return _AttemptRow(
              attempt: attempt,
              onTap: () => _viewResult(attempt),
            );
          },
        ),
      ),
    );
  }
}

class _AttemptRow extends StatelessWidget {
  final QuizAttempt attempt;
  final VoidCallback onTap;

  const _AttemptRow({required this.attempt, required this.onTap});

  Color _scoreColor(ColorScheme colors, double score) {
    if (score >= 80) return Colors.green.shade700;
    if (score >= 60) return Colors.amber.shade800;
    return colors.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final secondary =
        theme.textTheme.bodySmall?.color ?? colors.onSurfaceVariant;

    final isTappable = attempt.isCompleted;
    final scoreColor = _scoreColor(colors, attempt.score);

    return SurfaceCard(
      bordered: true,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: InkWell(
        onTap: isTappable ? onTap : null,
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
                    child: Text(
                      attempt.quizTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (attempt.isCompleted)
                    PillTag(
                      label: '${attempt.score.toStringAsFixed(1)}%',
                      color: scoreColor,
                    )
                  else
                    PillTag(
                      label: 'Incomplete',
                      color: colors.onSurfaceVariant,
                      backgroundAlpha: 20,
                      borderAlpha: 48,
                      textStyle: TextStyle(color: colors.onSurfaceVariant),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: secondary),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(attempt.startedAt),
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: secondary),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(attempt.startedAt),
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: isTappable
                        ? colors.onSurfaceVariant
                        : colors.onSurfaceVariant.withAlpha(90),
                  ),
                ],
              ),
              if (attempt.isCompleted) ...[
                const SizedBox(height: 8),
                Text(
                  'Completed ${_formatDate(attempt.completedAt!)}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: LinkButton(label: 'View results', onPressed: onTap),
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
