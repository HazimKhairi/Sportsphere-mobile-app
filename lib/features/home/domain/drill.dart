class Drill {
  const Drill({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    this.youtubeUrl,
    this.description = '',
    this.targetAttributes = const [],
    this.iconName,
  });

  final String id;
  final String name;

  /// e.g. 'juggle', 'toe_taps', 'back_vee', 'tic_toc', 'inside_outside', 'sole_rolls'
  final String category;
  final int difficulty;
  final String? youtubeUrl;
  final String description;
  final List<String> targetAttributes;
  final String? iconName;
}
