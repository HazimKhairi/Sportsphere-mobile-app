class DrillCompletionResult {
  const DrillCompletionResult({
    required this.pointsEarned,
    required this.currentStreak,
    required this.longestStreak,
    required this.isNewBest,
  });
  final int pointsEarned;
  final int currentStreak;
  final int longestStreak;
  final bool isNewBest;
}
