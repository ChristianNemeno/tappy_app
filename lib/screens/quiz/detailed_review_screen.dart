import 'package:flutter/material.dart';
import '../../models/attempt_result.dart';
import '../../models/question_result.dart';
import '../../theme/tokens.dart';
import '../../widgets/design/fixed_width_container.dart';
import '../../widgets/design/quiz_tiles.dart';
import '../../widgets/design/surface_card.dart';

class DetailedReviewScreen extends StatefulWidget {
  final AttemptResult result;

  const DetailedReviewScreen({super.key, required this.result});

  @override
  State<DetailedReviewScreen> createState() => _DetailedReviewScreenState();
}

class _DetailedReviewScreenState extends State<DetailedReviewScreen> {
  String _filterMode = 'all'; // 'all', 'correct', 'incorrect'

  List<QuestionResult> get _filteredQuestions {
    switch (_filterMode) {
      case 'correct':
        return widget.result.questionResults.where((q) => q.isCorrect).toList();
      case 'incorrect':
        return widget.result.questionResults
            .where((q) => !q.isCorrect)
            .toList();
      default:
        return widget.result.questionResults;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('[INFO] DetailedReviewScreen: Displaying detailed review');
    print(
      '[DEBUG] DetailedReviewScreen: Filter mode: $_filterMode, Questions shown: ${_filteredQuestions.length}',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Review'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterMode = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.list),
                    SizedBox(width: 12),
                    Text('All Questions'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'correct',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Correct Only'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'incorrect',
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Incorrect Only'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Bar
          _buildSummaryBar(),
          // Questions List
          Expanded(
            child: _filteredQuestions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _filteredQuestions.length,
                    itemBuilder: (context, index) {
                      final question = _filteredQuestions[index];
                      final originalIndex =
                          widget.result.questionResults.indexOf(question) + 1;
                      return _QuestionReviewCard(
                        question: question,
                        questionNumber: originalIndex,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(14),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: FixedWidthContainer(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: QuizMetricTile(
                  icon: Icons.check_circle,
                  accentColor: AppColors.success,
                  label: 'Correct',
                  value: '${widget.result.correctAnswers}',
                  isActive: _filterMode == 'correct',
                  onTap: () {
                    setState(() {
                      _filterMode = _filterMode == 'correct'
                          ? 'all'
                          : 'correct';
                    });
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 4),
              Expanded(
                child: QuizMetricTile(
                  icon: Icons.cancel,
                  accentColor: AppColors.danger,
                  label: 'Incorrect',
                  value: '${widget.result.incorrectAnswers}',
                  isActive: _filterMode == 'incorrect',
                  onTap: () {
                    setState(() {
                      _filterMode = _filterMode == 'incorrect'
                          ? 'all'
                          : 'incorrect';
                    });
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 4),
              Expanded(
                child: QuizMetricTile(
                  icon: Icons.quiz,
                  accentColor: AppColors.info,
                  label: 'Total',
                  value: '${widget.result.totalQuestions}',
                  isActive: _filterMode == 'all',
                  onTap: () {
                    setState(() {
                      _filterMode = 'all';
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_filterMode) {
      case 'correct':
        message = 'No correct answers found';
        icon = Icons.sentiment_dissatisfied;
        break;
      case 'incorrect':
        message = 'All answers are correct!';
        icon = Icons.sentiment_very_satisfied;
        break;
      default:
        message = 'No questions to review';
        icon = Icons.quiz;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: AppColors.textGray),
          ),
        ],
      ),
    );
  }
}

class _QuestionReviewCard extends StatelessWidget {
  final QuestionResult question;
  final int questionNumber;

  const _QuestionReviewCard({
    required this.question,
    required this.questionNumber,
  });

  @override
  Widget build(BuildContext context) {
    final correctness = question.isCorrect
        ? QuizCorrectness.correct
        : QuizCorrectness.incorrect;

    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withAlpha(80),
                  ),
                ),
                child: Text(
                  'Q$questionNumber',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.questionText,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    QuizCorrectnessPill(correctness: correctness),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          ReviewAnswerTile(
            label: 'Your Answer',
            answerText: question.selectedChoiceText,
            correctness: question.isCorrect
                ? QuizCorrectness.correct
                : QuizCorrectness.incorrect,
          ),
          const SizedBox(height: AppSpacing.sm + 4),

          if (!question.isCorrect) ...[
            ReviewAnswerTile(
              label: 'Correct Answer',
              answerText: question.correctChoiceText,
              correctness: QuizCorrectness.correct,
            ),
            const SizedBox(height: AppSpacing.sm + 4),
          ],

          if (question.explanation != null &&
              question.explanation!.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: AppSpacing.sm + 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: Colors.amber.shade800,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explanation',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.amber.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        question.explanation!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
