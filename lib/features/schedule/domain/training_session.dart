class TrainingSession {
  const TrainingSession({
    required this.id,
    required this.name,
    required this.startTime,
    required this.location,
    required this.attendees,
  });
  final String id;
  final String name;
  final DateTime startTime;
  final String location;
  final List<String> attendees;
}
