import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/unit.dart';
import '../models/quiz.dart';
import '../providers/unit_provider.dart';
import '../widgets/breadcrumb_navigation.dart';
import '../widgets/quiz_card.dart';

class UnitListScreen extends StatefulWidget {
  final int courseId;
  final String courseName;
  final String subjectName;

  const UnitListScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.subjectName,
  });

  @override
  State<UnitListScreen> createState() => _UnitListScreenState();
}

class _UnitListScreenState extends State<UnitListScreen> {
  @override
  void initState() {
    super.initState();
    print('[INFO] UnitListScreen: Initializing screen for course ${widget.courseId}');
    Future.microtask(() {
      print('[DEBUG] UnitListScreen: Fetching units for course ${widget.courseId}');
      return context.read<UnitProvider>().fetchUnitsByCourse(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('[INFO] UnitListScreen: User triggered manual refresh');
              context.read<UnitProvider>().fetchUnitsByCourse(widget.courseId);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          BreadcrumbNavigation(
            items: [
              BreadcrumbItem(
                label: 'Subjects',
                onTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
              BreadcrumbItem(
                label: widget.subjectName,
                onTap: () => Navigator.pop(context),
              ),
              BreadcrumbItem(
                label: widget.courseName,
              ),
            ],
          ),
          Expanded(
            child: Consumer<UnitProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.units.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: colors.error),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load units',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => provider.fetchUnitsByCourse(widget.courseId),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.units.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 64,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No units available',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This course has no units yet',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchUnitsByCourse(widget.courseId),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.units.length,
                    itemBuilder: (context, index) {
                      final unit = provider.units[index];
                      return _UnitCard(
                        unit: unit,
                        subjectName: widget.subjectName,
                        courseName: widget.courseName,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatefulWidget {
  final Unit unit;
  final String subjectName;
  final String courseName;

  const _UnitCard({
    required this.unit,
    required this.subjectName,
    required this.courseName,
  });

  @override
  State<_UnitCard> createState() => _UnitCardState();
}

class _UnitCardState extends State<_UnitCard> {
  bool _isExpanded = false;
  List<Quiz>? _quizzes;
  bool _isLoadingQuizzes = false;
  String? _error;

  Future<void> _loadQuizzes() async {
    if (_quizzes != null) return; // Already loaded

    setState(() {
      _isLoadingQuizzes = true;
      _error = null;
    });

    try {
      final unitProvider = context.read<UnitProvider>();
      final quizzes = await unitProvider.fetchQuizzesByUnit(widget.unit.id);
      
      if (mounted) {
        setState(() {
          _quizzes = quizzes;
          _isLoadingQuizzes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoadingQuizzes = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              if (_isExpanded) {
                _loadQuizzes();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.unit.orderIndex}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.unit.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.unit.quizCount} ${widget.unit.quizCount == 1 ? 'Quiz' : 'Quizzes'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            if (_isLoadingQuizzes)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Failed to load quizzes',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _loadQuizzes,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (_quizzes == null || _quizzes!.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No quizzes in this unit',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: _quizzes!.map((quiz) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: QuizCard(quiz: quiz),
                    );
                  }).toList(),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
