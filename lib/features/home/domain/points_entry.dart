class PointsEntry {
  const PointsEntry({
    required this.id,
    required this.action,
    required this.points,
    required this.description,
    required this.balanceAfter,
    required this.createdAt,
  });
  final String id;
  final String action;
  final int points;
  final String description;
  final int balanceAfter;
  final DateTime createdAt;
}
