class CoachProfile {
  const CoachProfile({
    required this.id,
    required this.name,
    required this.role,
    this.email,
    this.photoUrl,
    this.bio,
    this.yearsExperience,
    required this.specialties,
    required this.ageGroups,
    required this.languages,
    required this.previousClubs,
    this.philosophy,
    required this.achievements,
    required this.certificationsCount,
    required this.teamIds,
  });

  final String id;
  final String name;
  final String role;
  final String? email;
  final String? photoUrl;
  final String? bio;
  final int? yearsExperience;
  final List<String> specialties;
  final List<String> ageGroups;
  final List<String> languages;
  final List<String> previousClubs;
  final String? philosophy;
  final List<String> achievements;
  final int certificationsCount;
  final List<String> teamIds;

  factory CoachProfile.fromJson(Map<String, dynamic> json) {
    List<String> strings(dynamic raw) {
      if (raw is List) return raw.whereType<String>().toList();
      return const [];
    }

    return CoachProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      bio: json['bio'] as String?,
      yearsExperience: (json['yearsExperience'] as num?)?.toInt(),
      specialties: strings(json['specialties']),
      ageGroups: strings(json['ageGroups']),
      languages: strings(json['languages']),
      previousClubs: strings(json['previousClubs']),
      philosophy: json['philosophy'] as String?,
      achievements: strings(json['achievements']),
      certificationsCount: (json['certificationsCount'] as num?)?.toInt() ?? 0,
      teamIds: strings(json['teamIds']),
    );
  }
}
