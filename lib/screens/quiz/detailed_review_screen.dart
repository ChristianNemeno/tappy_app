import 'package:flutter/material.dart';
import '../../models/attempt_result.dart';
import '../../models/question_result.dart';

class DetailedReviewScreen extends StatefulWidget {
  final AttemptResult result;

  const DetailedReviewScreen({
    super.key,
    required this.result,
  });

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
        return widget.result.questionResults.where((q) => !q.isCorrect).toList();
      default:
        return widget.result.questionResults;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredQuestions.length,
                    itemBuilder: (context, index) {
                      final question = _filteredQuestions[index];
                      final originalIndex = widget.result.questionResults
                          .indexOf(question) + 1;
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryChip(
            icon: Icons.check_circle,
            color: Colors.green,
            label: 'Correct',
            count: widget.result.correctAnswers,
            isActive: _filterMode == 'correct',
            onTap: () {
              setState(() {
                _filterMode = _filterMode == 'correct' ? 'all' : 'correct';
              });
            },
          ),
          _SummaryChip(
            icon: Icons.cancel,
            color: Colors.red,
            label: 'Incorrect',
            count: widget.result.incorrectAnswers,
            isActive: _filterMode == 'incorrect',
            onTap: () {
              setState(() {
                _filterMode = _filterMode == 'incorrect' ? 'all' : 'incorrect';
              });
            },
          ),
          _SummaryChip(
            icon: Icons.quiz,
            color: Colors.blue,
            label: 'Total',
            count: widget.result.totalQuestions,
            isActive: _filterMode == 'all',
            onTap: () {
              setState(() {
                _filterMode = 'all';
              });
            },
          ),
        ],
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
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _SummaryChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: question.isCorrect
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: question.isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    'Q$questionNumber',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: question.isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.questionText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            question.isCorrect
                                ? Icons.check_circle
                                : Icons.cancel,
                            size: 16,
                            color: question.isCorrect
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            question.isCorrect ? 'Correct' : 'Incorrect',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: question.isCorrect
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Your Answer
            _AnswerSection(
              label: 'Your Answer',
              choiceText: question.selectedChoiceText,
              isCorrect: question.isCorrect,
              highlight: true,
            ),
            const SizedBox(height: 12),

            // Correct Answer (if wrong)
            if (!question.isCorrect) ...[
              _AnswerSection(
                label: 'Correct Answer',
                choiceText: question.correctChoiceText,
                isCorrect: true,
                highlight: true,
              ),
              const SizedBox(height: 12),
            ],

            // Explanation
            if (question.explanation != null &&
                question.explanation!.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: Colors.amber[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explanation',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          question.explanation!,
                          style: TextStyle(
                            fontSize: 14,
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
      ),
    );
  }
}

class _AnswerSection extends StatelessWidget {
  final String label;
  final String choiceText;
  final bool isCorrect;
  final bool highlight;

  const _AnswerSection({
    required this.label,
    required this.choiceText,
    required this.isCorrect,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight ? color.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: highlight
            ? Border.all(color: color, width: 2)
            : Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        children: [
          if (highlight)
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: color,
              size: 24,
            ),
          if (highlight) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: highlight ? color : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  choiceText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
                    color: highlight ? color : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
