import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tappy_app/providers/quiz_provider.dart';
import 'package:tappy_app/widgets/design/buttons.dart';
import 'package:tappy_app/widgets/design/fixed_width_container.dart';
import 'package:tappy_app/widgets/design/inline_message_banner.dart';
import 'package:tappy_app/widgets/design/surface_card.dart';
import 'package:tappy_app/widgets/quiz_card.dart';

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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
            print(
              '[ERROR] DiscoverScreen: Displaying error state - ${provider.error}',
            );
            return _CenteredPanel(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InlineMessageBanner(
                    title: 'Could not load quizzes',
                    message: provider.error ?? 'An error occurred',
                    variant: InlineMessageVariant.error,
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Retry',
                    onPressed: () {
                      print('[INFO] DiscoverScreen: User pressed retry button');
                      provider.refreshQuizzes();
                    },
                  ),
                ],
              ),
            );
          }

          if (provider.quizzes.isEmpty) {
            print('[INFO] DiscoverScreen: No quizzes available to display');
            return RefreshIndicator(
              onRefresh: () {
                print('[DEBUG] DiscoverScreen: Pull-to-refresh triggered');
                return provider.refreshQuizzes();
              },
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
                          Icons.quiz,
                          size: 72,
                          color: colors.onSurfaceVariant.withAlpha(115),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No quizzes available',
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pull to refresh, or try again in a moment.',
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        PrimaryButton(
                          label: 'Refresh',
                          onPressed: () {
                            print(
                              '[INFO] DiscoverScreen: User pressed refresh button',
                            );
                            provider.refreshQuizzes();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          print(
            '[INFO] DiscoverScreen: Displaying ${provider.quizzes.length} quizzes',
          );
          return RefreshIndicator(
            onRefresh: () {
              print('[DEBUG] DiscoverScreen: Pull-to-refresh triggered');
              return provider.refreshQuizzes();
            },
            child: FixedWidthContainer(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: provider.quizzes.length,
                itemBuilder: (context, index) {
                  return QuizCard(quiz: provider.quizzes[index]);
                },
              ),
            ),
          );
        },
      ),
    );
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
