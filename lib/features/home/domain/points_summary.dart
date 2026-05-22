import 'points_entry.dart';

class PointsSummary {
  const PointsSummary({
    required this.totalPoints,
    required this.availablePoints,
    required this.history,
  });
  final int totalPoints;
  final int availablePoints;
  final List<PointsEntry> history;
}
