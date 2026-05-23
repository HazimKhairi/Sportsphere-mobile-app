class RecoveryContent {
  const RecoveryContent({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.steps,
    this.thumbnailUrl,
    this.youtubeUrl,
    this.evidenceLevel = 'moderate',
    this.sportContext = 'general',
  });

  final String id;
  final String title;
  final String category; // 'stretching' | 'foam_rolling' | 'cold_therapy' | 'nutrition' | 'sleep' | 'active_recovery'
  final int durationMinutes;
  final List<String> steps;
  final String? thumbnailUrl;
  final String? youtubeUrl;
  final String evidenceLevel; // 'strong' | 'moderate' | 'emerging'
  final String sportContext;  // 'futsal' | 'football' | 'general'

  factory RecoveryContent.fromDoc(String id, Map<String, dynamic> d) => RecoveryContent(
        id: id,
        title: (d['title'] as String?) ?? 'Recovery',
        category: (d['category'] as String?) ?? 'stretching',
        durationMinutes: (d['durationMinutes'] as int?) ?? 10,
        steps: ((d['steps'] as List?)?.cast<String>()) ?? [],
        thumbnailUrl: d['thumbnailUrl'] as String?,
        youtubeUrl: d['youtubeUrl'] as String?,
        evidenceLevel: (d['evidenceLevel'] as String?) ?? 'moderate',
        sportContext: (d['sportContext'] as String?) ?? 'general',
      );
}
