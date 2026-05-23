class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.muscleGroups,
    required this.equipment,
    this.demonstrationUrl,
    this.videoUrl,
    this.description = '',
    this.defaultSets = 3,
    this.defaultReps = 8,
  });

  final String id;
  final String name;
  final String category;
  final List<String> muscleGroups;
  final String equipment;
  final String? demonstrationUrl;
  final String? videoUrl;
  final String description;
  final int defaultSets;
  final int defaultReps;

  factory Exercise.fromMap(String id, Map<String, dynamic> d) => Exercise(
        id: id,
        name: (d['name'] as String?) ?? 'Exercise',
        category: (d['category'] as String?) ?? '',
        muscleGroups: ((d['muscleGroups'] as List?)?.cast<String>()) ?? [],
        equipment: (d['equipment'] as String?) ?? 'bodyweight',
        demonstrationUrl: d['demonstrationUrl'] as String?,
        videoUrl: d['videoUrl'] as String?,
        description: (d['description'] as String?) ?? '',
        defaultSets: (d['defaultSets'] as int?) ?? 3,
        defaultReps: (d['defaultReps'] as int?) ?? 8,
      );
}
