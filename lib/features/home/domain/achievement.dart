enum AchievementTier { bronze, silver, gold, platinum, unknown }

extension AchievementTierLabel on AchievementTier {
  String get label {
    switch (this) {
      case AchievementTier.bronze:
        return 'Bronze';
      case AchievementTier.silver:
        return 'Silver';
      case AchievementTier.gold:
        return 'Gold';
      case AchievementTier.platinum:
        return 'Platinum';
      case AchievementTier.unknown:
        return '';
    }
  }
}

AchievementTier tierFromString(String? raw) {
  switch (raw) {
    case 'bronze':
      return AchievementTier.bronze;
    case 'silver':
      return AchievementTier.silver;
    case 'gold':
      return AchievementTier.gold;
    case 'platinum':
      return AchievementTier.platinum;
    default:
      return AchievementTier.unknown;
  }
}

class Achievement {
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
    required this.points,
    required this.unlocked,
    this.iconName,
    this.category = '',
    this.requirement = '',
    this.unlockedAt,
  });

  final String id;
  final String name;
  final String description;
  final AchievementTier tier;
  final int points;
  final bool unlocked;
  final String? iconName;
  final String category;
  final String requirement;
  final DateTime? unlockedAt;
}
