import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/quiz.dart';
import '../../models/quiz_detail.dart';
import '../../services/quiz_service.dart';
import '../../providers/attempt_provider.dart';
import 'quiz_taking_screen.dart';
import 'leaderboard_screen.dart';

class QuizDetailScreen extends StatefulWidget {
  final int quizId;

  const QuizDetailScreen({super.key, required this.quizId});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  Quiz? _quiz;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuizDetails();
  }

  Future<void> _loadQuizDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final quizService = context.read<QuizService>();
      final quiz = await quizService.getQuizById(widget.quizId);
      
      if (mounted) {
        setState(() {
          _quiz = quiz;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startQuiz() async {
    if (_quiz == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Quiz'),
        content: Text(
          'This quiz has ${_quiz!.questionCount} questions.\n\n'
          'Once started, you must complete it in one session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading
    if (!mounted) return;
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
                Text('Loading quiz...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Fetch quiz with questions
      final quizService = context.read<QuizService>();
      final quizDetail = await quizService.getQuizWithQuestions(widget.quizId);

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Check if quiz has questions
      if (quizDetail.questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This quiz has no questions'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Navigate to quiz taking screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizTakingScreen(
            quiz: Quiz(
              id: quizDetail.id,
              title: quizDetail.title,
              description: quizDetail.description,
              createdById: quizDetail.createdById,
              createdByName: quizDetail.createdByName,
              isActive: quizDetail.isActive,
              questionCount: quizDetail.questionCount,
              createdAt: quizDetail.createdAt,
            ),
            questions: quizDetail.questions,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load quiz: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Details'),
        actions: [
          if (_quiz != null)
            IconButton(
              icon: const Icon(Icons.leaderboard),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LeaderboardScreen(
                      quizId: _quiz!.id,
                      quizTitle: _quiz!.title,
                    ),
                  ),
                );
              },
              tooltip: 'View Leaderboard',
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _quiz != null && _quiz!.isActive
        ? SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _startQuiz,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'Start Quiz',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          )
        : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load quiz',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadQuizDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_quiz == null) {
      return const Center(
        child: Text('Quiz not found'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Card(
            margin: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _quiz!.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.quiz,
                        label: '${_quiz!.questionCount} Questions',
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        icon: _quiz!.isActive ? Icons.check_circle : Icons.cancel,
                        label: _quiz!.isActive ? 'Active' : 'Inactive',
                        color: _quiz!.isActive ? Colors.green : Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Description Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _quiz!.description.isNotEmpty 
                    ? _quiz!.description 
                    : 'No description provided.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // Creator Info
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        _quiz!.createdByName.substring(0, 1).toUpperCase(),
                      ),
                    ),
                    title: const Text('Created by'),
                    subtitle: Text(_quiz!.createdByName),
                    trailing: Text(
                      _formatDate(_quiz!.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Quiz Info Cards
                _buildInfoCard(
                  icon: Icons.info_outline,
                  title: 'Quiz Information',
                  children: [
                    _buildInfoRow('Total Questions', '${_quiz!.questionCount}'),
                    const Divider(),
                    _buildInfoRow('Status', _quiz!.isActive ? 'Active' : 'Inactive'),
                    const Divider(),
                    _buildInfoRow('Created', _formatDateLong(_quiz!.createdAt)),
                  ],
                ),

                const SizedBox(height: 16),

                _buildInfoCard(
                  icon: Icons.tips_and_updates_outlined,
                  title: 'Instructions',
                  children: [
                    const Text(
                      '• Read each question carefully\n'
                      '• You must answer all questions\n'
                      '• You can navigate between questions\n'
                      '• Submit when you\'re ready',
                      style: TextStyle(height: 1.8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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

  String _formatDateLong(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}