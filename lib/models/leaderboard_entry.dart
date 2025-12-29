class LeaderboardEntry {
  final int id;
  final String userName;
  final double score;
  final DateTime completedAt;

  LeaderboardEntry({
    required this.id,
    required this.userName,
    required this.score,
    required this.completedAt,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['Id'],
      userName: json['UserName'] ?? '',
      score: (json['Score'] ?? 0).toDouble(),
      completedAt: DateTime.parse(json['CompletedAt']),
    );
  }
}
