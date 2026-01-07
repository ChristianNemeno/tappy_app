import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/quiz_card.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  @override
  void initState() {
    super.initState();
    print('[INFO] DiscoverScreen: Initializing screen');
    Future.microtask(() {
      print('[DEBUG] DiscoverScreen: Fetching active quizzes');
      return context.read<QuizProvider>().fetchActiveQuizzes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Quizzes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('[INFO] DiscoverScreen: User triggered manual refresh');
              context.read<QuizProvider>().refreshQuizzes();
            },
          ),
        ],
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.quizzes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.quizzes.isEmpty) {
            print('[ERROR] DiscoverScreen: Displaying error state - ${provider.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error ?? 'An error occurred'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      print('[INFO] DiscoverScreen: User pressed retry button');
                      provider.refreshQuizzes();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.quizzes.isEmpty) {
            print('[INFO] DiscoverScreen: No quizzes available to display');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No quizzes available',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          print('[INFO] DiscoverScreen: Displaying ${provider.quizzes.length} quizzes');
          return RefreshIndicator(
            onRefresh: () {
              print('[DEBUG] DiscoverScreen: Pull-to-refresh triggered');
              return provider.refreshQuizzes();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.quizzes.length,
              itemBuilder: (context, index) {
                return QuizCard(quiz: provider.quizzes[index]);
              },
            ),
          );
        },
      ),
    );
  }
}