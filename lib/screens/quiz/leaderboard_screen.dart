import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/leaderboard_entry.dart';
import '../../services/attempt_service.dart';
import '../../providers/auth_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  final int quizId;
  final String quizTitle;

  const LeaderboardScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<LeaderboardEntry> _entries = [];
  bool _isLoading = true;
  String? _error;
  int _topCount = 10;

  @override
  void initState() {
    super.initState();
    print('[INFO] LeaderboardScreen: Screen initialized for quiz ${widget.quizId}');
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    print('[DEBUG] LeaderboardScreen: Loading top $_topCount entries');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final attemptService = context.read<AttemptService>();
      final entries = await attemptService.getLeaderboard(
        widget.quizId,
        topCount: _topCount,
      );

      print('[SUCCESS] LeaderboardScreen: Loaded ${entries.length} leaderboard entries');
      if (mounted) {
        setState(() {
          _entries = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[ERROR] LeaderboardScreen: Failed to load leaderboard - $e');
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _changeTopCount(int count) {
    setState(() {
      _topCount = count;
    });
    _loadLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Leaderboard'),
            Text(
              widget.quizTitle,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list),
            onSelected: _changeTopCount,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 10,
                child: Text('Top 10'),
              ),
              const PopupMenuItem(
                value: 25,
                child: Text('Top 25'),
              ),
              const PopupMenuItem(
                value: 50,
                child: Text('Top 50'),
              ),
              const PopupMenuItem(
                value: 100,
                child: Text('Top 100'),
              ),
            ],
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
              'Failed to load leaderboard',
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
              onPressed: _loadLeaderboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No leaderboard data yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to complete this quiz!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      child: Column(
        children: [
          // Top 3 Podium
          if (_entries.isNotEmpty) _buildPodium(),

          // Leaderboard List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                final rank = index + 1;
                return _LeaderboardCard(
                  entry: entry,
                  rank: rank,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    final top3 = _entries.take(3).toList();
    if (top3.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          if (top3.length > 1)
            Expanded(
              child: _PodiumPlace(
                entry: top3[1],
                rank: 2,
                height: 100,
                color: Colors.grey[400]!,
              ),
            ),
          const SizedBox(width: 8),
          // 1st Place
          Expanded(
            child: _PodiumPlace(
              entry: top3[0],
              rank: 1,
              height: 140,
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 8),
          // 3rd Place
          if (top3.length > 2)
            Expanded(
              child: _PodiumPlace(
                entry: top3[2],
                rank: 3,
                height: 80,
                color: Colors.brown[300]!,
              ),
            ),
        ],
      ),
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final double height;
  final Color color;

  const _PodiumPlace({
    required this.entry,
    required this.rank,
    required this.height,
    required this.color,
  });

  String _getMedal(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUserName = authProvider.userName ?? '';
        final isCurrentUser = entry.userName == currentUserName;

        return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar
        Container(
          width: rank == 1 ? 70 : 60,
          height: rank == 1 ? 70 : 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrentUser
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
            border: Border.all(
              color: color,
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              entry.userName.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: rank == 1 ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: isCurrentUser ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Name
        Text(
          entry.userName,
          style: TextStyle(
            fontSize: rank == 1 ? 14 : 12,
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
            color: isCurrentUser ? Theme.of(context).primaryColor : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        // Score
        Text(
          '${entry.score.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: rank == 1 ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        // Podium
        Container(
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              _getMedal(rank),
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
      ],
        );
      },
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;

  const _LeaderboardCard({
    required this.entry,
    required this.rank,
  });

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[300]!;
      default:
        return Colors.grey[300]!;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.military_tech;
      case 3:
        return Icons.stars;
      default:
        return Icons.person;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUserName = authProvider.userName ?? '';
        final isCurrentUser = entry.userName == currentUserName;
        final rankColor = _getRankColor(rank);
        final scoreColor = _getScoreColor(entry.score);

        return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isCurrentUser ? 4 : 1,
      color: isCurrentUser
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentUser
            ? BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Rank Badge
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rank <= 3 ? rankColor.withOpacity(0.2) : Colors.grey[100],
                border: Border.all(
                  color: rank <= 3 ? rankColor : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (rank <= 3)
                    Icon(
                      _getRankIcon(rank),
                      size: 16,
                      color: rankColor,
                    ),
                  if (rank <= 3) const SizedBox(height: 2),
                  Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: rank <= 3 ? 12 : 16,
                      fontWeight: FontWeight.bold,
                      color: rank <= 3 ? rankColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.userName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isCurrentUser
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isCurrentUser
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'You',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(entry.completedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: scoreColor),
              ),
              child: Text(
                '${entry.score.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
