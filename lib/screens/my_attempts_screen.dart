import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attempt_provider.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This attempt is not yet completed'),
          backgroundColor: Colors.orange,
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
        SnackBar(
          content: Text('Failed to load results: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAttempts,
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No attempts yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Take a quiz to see your history',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
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

  const _AttemptCard({
    required this.attempt,
    required this.onTap,
  });

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: attempt.isCompleted ? onTap : null,
        borderRadius: BorderRadius.circular(12),
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (attempt.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(attempt.score).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getScoreColor(attempt.score),
                        ),
                      ),
                      child: Text(
                        '${attempt.score.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(attempt.score),
                        ),
                      ),
                    ),
                  if (!attempt.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Text(
                        'Incomplete',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(attempt.startedAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(attempt.startedAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (attempt.isCompleted) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Completed on ${_formatDate(attempt.completedAt!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
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