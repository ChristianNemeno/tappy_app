import 'package:flutter/material.dart';
import '../models/quiz/quiz.dart';
import '../screens/quiz/quiz_detail_screen.dart';

class QuizCard extends StatelessWidget {
  final Quiz quiz;

  const QuizCard({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final cardRadius = _resolveCardRadius(context);
    final metaColor = colors.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: cardRadius,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizDetailScreen(quizId: quiz.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      quiz.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text('${quiz.questionCount} Qs'),
                    backgroundColor: colors.primaryContainer,
                    labelStyle: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                    side: BorderSide.none,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                quiz.description,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: metaColor),
                  const SizedBox(width: 4),
                  Text(
                    quiz.createdByName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: metaColor,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_today, size: 16, color: metaColor),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(quiz.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: metaColor,
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

  BorderRadius _resolveCardRadius(BuildContext context) {
    final shape = Theme.of(context).cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(Directionality.of(context));
    }
    return BorderRadius.circular(16);
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
