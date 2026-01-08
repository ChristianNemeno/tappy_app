import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/question.dart';
import '../../models/quiz.dart';
import '../../providers/attempt_provider.dart';
import 'quiz_result_screen.dart';

class QuizTakingScreen extends StatefulWidget {
  final Quiz quiz;
  final List<Question> questions;

  const QuizTakingScreen({
    super.key,
    required this.quiz,
    required this.questions,
  });

  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  final PageController _pageController = PageController();
  int _currentQuestionIndex = 0;
  bool _isStarting = true;

  @override
  void initState() {
    super.initState();
    print('[INFO] QuizTakingScreen: Screen initialized for quiz ${widget.quiz.id}');
    print('[DEBUG] QuizTakingScreen: Total questions: ${widget.questions.length}');
    _initializeAttempt();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeAttempt() async {
    print('[DEBUG] QuizTakingScreen: Initializing quiz attempt');
    final provider = context.read<AttemptProvider>();
    final success = await provider.startAttempt(
      widget.quiz.id,
      widget.questions,
    );

    if (success) {
      print('[SUCCESS] QuizTakingScreen: Attempt started successfully');
    } else {
      print('[ERROR] QuizTakingScreen: Failed to start attempt');
    }

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to start quiz'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isStarting = false;
    });
  }

  void _onPageChanged(int index) {
    print('[DEBUG] QuizTakingScreen: Navigated to question ${index + 1}');
    setState(() {
      _currentQuestionIndex = index;
    });
  }

  void _navigateToQuestion(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _navigateToQuestion(_currentQuestionIndex - 1);
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      _navigateToQuestion(_currentQuestionIndex + 1);
    }
  }

  Future<void> _showSubmitDialog() async {
    print('[DEBUG] QuizTakingScreen: Submit button pressed');
    final provider = context.read<AttemptProvider>();
    
    // Check if all questions are answered
    final validationError = provider.validateCompletion();
    print('[DEBUG] QuizTakingScreen: Answered ${provider.answeredCount}/${provider.totalQuestions} questions');
    
    if (validationError != null) {
      // Show warning about unanswered questions
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Incomplete Quiz'),
            ],
          ),
          content: Text(
            validationError,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Review'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Submit Anyway'),
            ),
          ],
        ),
      );

      if (proceed != true) return;
    }

    // Final confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Submit Quiz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have answered ${provider.answeredCount} of ${provider.totalQuestions} questions.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Once submitted, you cannot change your answers.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Submit the attempt
    await _submitAttempt();
  }

  Future<void> _submitAttempt() async {
    final provider = context.read<AttemptProvider>();
    
    final success = await provider.submitAttempt();

    if (!mounted) return;

    if (success && provider.lastResult != null) {
      // Navigate to result screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            result: provider.lastResult!,
            quizId: widget.quiz.id,
          ),
        ),
      );
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to submit quiz'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showQuestionOverview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _QuestionOverviewSheet(
        questions: widget.questions,
        currentIndex: _currentQuestionIndex,
        onQuestionTap: (index) {
          Navigator.pop(context);
          _navigateToQuestion(index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isStarting) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.quiz.title),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Starting quiz...'),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Quiz'),
            content: const Text(
              'Are you sure you want to exit? Your progress will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Stay'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.quiz.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.grid_view),
              onPressed: _showQuestionOverview,
              tooltip: 'Question Overview',
            ),
          ],
        ),
        body: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: widget.questions.length,
                itemBuilder: (context, index) {
                  return _QuestionCard(
                    question: widget.questions[index],
                    questionNumber: index + 1,
                    totalQuestions: widget.questions.length,
                  );
                },
              ),
            ),
            _buildNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Consumer<AttemptProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1} of ${widget.questions.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provider.answeredCount} answered',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              CircularProgressIndicator(
                value: provider.progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(provider.progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationBar() {
    return Consumer<AttemptProvider>(
      builder: (context, provider, child) {
        final isFirstQuestion = _currentQuestionIndex == 0;
        final isLastQuestion = _currentQuestionIndex == widget.questions.length - 1;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                if (!isFirstQuestion)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousQuestion,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                if (!isFirstQuestion && !isLastQuestion)
                  const SizedBox(width: 12),
                if (!isLastQuestion)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _nextQuestion,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                if (isLastQuestion)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: provider.isLoading ? null : _showSubmitDialog,
                      icon: provider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.check),
                      label: Text(provider.isLoading ? 'Submitting...' : 'Submit'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final Question question;
  final int questionNumber;
  final int totalQuestions;

  const _QuestionCard({
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AttemptProvider>(
      builder: (context, provider, child) {
        final selectedChoiceId = provider.getAnswer(question.id);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Question text
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    question.text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Question image (if available)
              if (question.imageUrl != null && question.imageUrl!.isNotEmpty)
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    question.imageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: const EdgeInsets.all(32),
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 48),
                        ),
                      );
                    },
                  ),
                ),
              if (question.imageUrl != null && question.imageUrl!.isNotEmpty)
                const SizedBox(height: 16),

              // Choices
              const Text(
                'Select your answer:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...question.choices.map((choice) {
                final isSelected = selectedChoiceId == choice.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ChoiceCard(
                    choice: choice,
                    isSelected: isSelected,
                    onTap: () {
                      provider.setAnswer(question.id, choice.id);
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final dynamic choice;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.choice,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                choice.text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionOverviewSheet extends StatelessWidget {
  final List<Question> questions;
  final int currentIndex;
  final Function(int) onQuestionTap;

  const _QuestionOverviewSheet({
    required this.questions,
    required this.currentIndex,
    required this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AttemptProvider>(
      builder: (context, provider, child) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Question Overview',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${provider.answeredCount}/${questions.length}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Grid
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        final isAnswered = provider.isQuestionAnswered(question.id);
                        final isCurrent = index == currentIndex;

                        return InkWell(
                          onTap: () => onQuestionTap(index),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? Theme.of(context).primaryColor
                                  : isAnswered
                                      ? Colors.green
                                      : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isCurrent
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: (isCurrent || isAnswered)
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Legend
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _LegendItem(
                          color: Theme.of(context).primaryColor,
                          label: 'Current',
                        ),
                        _LegendItem(
                          color: Colors.green,
                          label: 'Answered',
                        ),
                        _LegendItem(
                          color: Colors.grey[200]!,
                          label: 'Unanswered',
                          textColor: Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final Color? textColor;

  const _LegendItem({
    required this.color,
    required this.label,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
