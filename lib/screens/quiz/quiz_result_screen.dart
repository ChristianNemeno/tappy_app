import 'package:flutter/material.dart';
import '../../models/attempt_result.dart';
import 'detailed_review_screen.dart';
import 'leaderboard_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final AttemptResult result;
  final int? quizId;

  const QuizResultScreen({
    super.key,
    required this.result,
    this.quizId,
  });

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
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
    print('[DEBUG] QuizResultScreen: Score - ${result.score}/${result.totalQuestions} (${result.percentage.toStringAsFixed(1)}%)');
    print('[DEBUG] QuizResultScreen: Correct: ${result.correctAnswers}, Incorrect: ${result.incorrectAnswers}');
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
                  colors: [
                    scoreColor.withOpacity(0.2),
                    scoreColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      _getScoreIcon(result.percentage),
                      size: 80,
                      color: scoreColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getScoreMessage(result.percentage),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: scoreColor,
                          width: 4,
                        ),
                      ),
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scoreColor.withOpacity(0.1),
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
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      result.quizTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Statistics
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.check_circle,
                          iconColor: Colors.green,
                          label: 'Correct',
                          value: '${result.correctAnswers}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.cancel,
                          iconColor: Colors.red,
                          label: 'Incorrect',
                          value: '${result.incorrectAnswers}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.quiz,
                          iconColor: Colors.blue,
                          label: 'Total Questions',
                          value: '${result.totalQuestions}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.timer,
                          iconColor: Colors.orange,
                          label: 'Duration',
                          value: result.duration,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  const Text(
                    'Review',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailedReviewScreen(
                            result: result,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.list_alt),
                    label: const Text('View Detailed Review'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                  if (quizId != null) const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Back to Home'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Time Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
                  ),
                ],
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: iconColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
    );
  }
}
