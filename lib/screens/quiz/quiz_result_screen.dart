import 'package:flutter/material.dart';
import '../../models/attempt_result.dart';
import '../../theme/tokens.dart';
import '../../widgets/design/fixed_width_container.dart';
import '../../widgets/design/quiz_tiles.dart';
import '../../widgets/design/surface_card.dart';
import 'detailed_review_screen.dart';
import 'leaderboard_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final AttemptResult result;
  final int? quizId;

  const QuizResultScreen({super.key, required this.result, this.quizId});

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.warning;
    return AppColors.danger;
  }

  String _getScoreMessage(double percentage) {
    if (percentage >= 90) return 'Excellent! 🎉';
    if (percentage >= 80) return 'Great Job! 👏';
    if (percentage >= 70) return 'Good Work! 👍';
    if (percentage >= 60) return 'Not Bad! 💪';
    return 'Keep Practicing! 📚';
  }

  IconData _getScoreIcon(double percentage) {
    if (percentage >= 80) return Icons.emoji_events;
    if (percentage >= 60) return Icons.stars;
    return Icons.trending_up;
  }

  @override
  Widget build(BuildContext context) {
    print('[INFO] QuizResultScreen: Displaying results');
    print(
      '[DEBUG] QuizResultScreen: Score - ${result.score}/${result.totalQuestions} (${result.percentage.toStringAsFixed(1)}%)',
    );
    print(
      '[DEBUG] QuizResultScreen: Correct: ${result.correctAnswers}, Incorrect: ${result.incorrectAnswers}',
    );
    final scoreColor = _getScoreColor(result.percentage);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Score Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scoreColor.withAlpha(40), scoreColor.withAlpha(10)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    Icon(
                      _getScoreIcon(result.percentage),
                      size: 80,
                      color: scoreColor,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _getScoreMessage(result.percentage),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                        color: scoreColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: scoreColor, width: 4),
                      ),
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scoreColor.withAlpha(20),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${result.percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: scoreColor,
                                ),
                              ),
                              Text(
                                'Score',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      result.quizTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            FixedWidthContainer(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Statistics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: QuizMetricTile(
                            icon: Icons.check_circle,
                            accentColor: AppColors.success,
                            label: 'Correct',
                            value: '${result.correctAnswers}',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm + 4),
                        Expanded(
                          child: QuizMetricTile(
                            icon: Icons.cancel,
                            accentColor: AppColors.danger,
                            label: 'Incorrect',
                            value: '${result.incorrectAnswers}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm + 4),
                    Row(
                      children: [
                        Expanded(
                          child: QuizMetricTile(
                            icon: Icons.quiz,
                            accentColor: AppColors.info,
                            label: 'Total Questions',
                            value: '${result.totalQuestions}',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm + 4),
                        Expanded(
                          child: QuizMetricTile(
                            icon: Icons.timer,
                            accentColor: AppColors.warning,
                            label: 'Duration',
                            value: result.duration,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      'Review',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailedReviewScreen(result: result),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list_alt),
                      label: const Text('View Detailed Review'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          AppSizes.minTapTarget,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm + 4),
                    if (quizId != null)
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LeaderboardScreen(
                                quizId: quizId!,
                                quizTitle: result.quizTitle,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.leaderboard),
                        label: const Text('View Leaderboard'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(
                            AppSizes.minTapTarget,
                          ),
                        ),
                      ),
                    if (quizId != null)
                      const SizedBox(height: AppSpacing.sm + 4),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Back to Home'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          AppSizes.minTapTarget,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    SurfaceCard(
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.play_circle,
                            label: 'Started',
                            value: _formatDateTime(result.startedAt),
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.check_circle,
                            label: 'Completed',
                            value: _formatDateTime(result.completedAt),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
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
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textGray),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 14, color: AppColors.textGray)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
