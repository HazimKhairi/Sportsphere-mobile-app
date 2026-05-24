class ScoutingProfile {
  const ScoutingProfile({
    required this.displayName,
    required this.dob,
    required this.state,
    required this.sport,
    required this.primaryPosition,
    required this.yearsPlaying,
    required this.level,
    required this.availability,
    required this.visibility,
    required this.reach,
    required this.affiliation,
    this.photoUrl,
    this.city,
    this.secondaryPositions = const [],
    this.foot,
    this.pastClubs = const [],
    this.achievements,
    this.skills = const {},
    this.highlightVideoUrl,
    this.actionPhotoUrls = const [],
    this.parentEmail,
    this.representativeHistory = const [],
    this.tournamentHistory = const [],
  });

  factory ScoutingProfile.fromJson(Map<String, dynamic> json) {
    final avail = json['availability'] as Map<String, dynamic>? ?? {};
    final aff = json['affiliation'] as Map<String, dynamic>? ?? {};
    return ScoutingProfile(
      displayName: json['displayName'] as String? ?? '',
      dob: json['dob'] as String? ?? '',
      state: json['state'] as String? ?? '',
      city: json['city'] as String?,
      sport: json['sport'] as String? ?? 'football',
      primaryPosition: json['primaryPosition'] as String? ?? '',
      secondaryPositions: (json['secondaryPositions'] as List<dynamic>?)
              ?.cast<String>() ??
          [],
      foot: json['foot'] as String?,
      yearsPlaying: (json['yearsPlaying'] as num?)?.toInt() ?? 0,
      pastClubs: (json['pastClubs'] as List<dynamic>?)
              ?.map((e) => PastClubEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      achievements: json['achievements'] as String?,
      level: json['level'] as String? ?? 'recreational',
      skills: (json['skills'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      highlightVideoUrl: json['highlightVideoUrl'] as String?,
      actionPhotoUrls:
          (json['actionPhotoUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      availability: ScoutingAvailability.fromJson(avail),
      visibility: json['visibility'] as String? ?? 'hidden',
      reach: json['reach'] as String? ?? 'state',
      affiliation: ScoutingAffiliation.fromJson(aff),
      parentEmail: json['parentEmail'] as String?,
      representativeHistory: (json['representativeHistory'] as List<dynamic>?)
              ?.map((e) => RepresentativeEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tournamentHistory: (json['tournamentHistory'] as List<dynamic>?)
              ?.map((e) => TournamentEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  final String displayName;
  final String dob;
  final String state;
  final String? city;
  final String sport;
  final String primaryPosition;
  final List<String> secondaryPositions;
  final String? foot;
  final int yearsPlaying;
  final List<PastClubEntry> pastClubs;
  final String? achievements;
  final String level;
  final Map<String, double> skills;
  final String? highlightVideoUrl;
  final List<String> actionPhotoUrls;
  final ScoutingAvailability availability;
  final String visibility;
  final String reach;
  final ScoutingAffiliation affiliation;
  final String? photoUrl;
  final String? parentEmail;
  final List<RepresentativeEntry> representativeHistory;
  final List<TournamentEntry> tournamentHistory;

  bool get isOpen => visibility == 'open';
  bool get isFreeAgent => affiliation.type == 'free_agent';

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'dob': dob,
        'state': state,
        if (city != null) 'city': city,
        'sport': sport,
        'primaryPosition': primaryPosition,
        'secondaryPositions': secondaryPositions,
        if (foot != null) 'foot': foot,
        'yearsPlaying': yearsPlaying,
        'pastClubs': pastClubs.map((e) => e.toJson()).toList(),
        if (achievements != null) 'achievements': achievements,
        'level': level,
        if (skills.isNotEmpty) 'skills': skills,
        if (highlightVideoUrl != null) 'highlightVideoUrl': highlightVideoUrl,
        'actionPhotoUrls': actionPhotoUrls,
        'availability': availability.toJson(),
        'visibility': visibility,
        'reach': reach,
        if (parentEmail != null) 'parentEmail': parentEmail,
        if (representativeHistory.isNotEmpty)
          'representativeHistory': representativeHistory.map((e) => e.toJson()).toList(),
        if (tournamentHistory.isNotEmpty)
          'tournamentHistory': tournamentHistory.map((e) => e.toJson()).toList(),
      };

  ScoutingProfile copyWith({
    String? displayName,
    String? dob,
    String? state,
    String? city,
    String? sport,
    String? primaryPosition,
    List<String>? secondaryPositions,
    String? foot,
    int? yearsPlaying,
    List<PastClubEntry>? pastClubs,
    String? achievements,
    String? level,
    Map<String, double>? skills,
    String? highlightVideoUrl,
    List<String>? actionPhotoUrls,
    ScoutingAvailability? availability,
    String? visibility,
    String? reach,
    ScoutingAffiliation? affiliation,
    String? photoUrl,
    String? parentEmail,
    List<RepresentativeEntry>? representativeHistory,
    List<TournamentEntry>? tournamentHistory,
  }) =>
      ScoutingProfile(
        displayName: displayName ?? this.displayName,
        dob: dob ?? this.dob,
        state: state ?? this.state,
        city: city ?? this.city,
        sport: sport ?? this.sport,
        primaryPosition: primaryPosition ?? this.primaryPosition,
        secondaryPositions: secondaryPositions ?? this.secondaryPositions,
        foot: foot ?? this.foot,
        yearsPlaying: yearsPlaying ?? this.yearsPlaying,
        pastClubs: pastClubs ?? this.pastClubs,
        achievements: achievements ?? this.achievements,
        level: level ?? this.level,
        skills: skills ?? this.skills,
        highlightVideoUrl: highlightVideoUrl ?? this.highlightVideoUrl,
        actionPhotoUrls: actionPhotoUrls ?? this.actionPhotoUrls,
        availability: availability ?? this.availability,
        visibility: visibility ?? this.visibility,
        reach: reach ?? this.reach,
        affiliation: affiliation ?? this.affiliation,
        photoUrl: photoUrl ?? this.photoUrl,
        parentEmail: parentEmail ?? this.parentEmail,
        representativeHistory: representativeHistory ?? this.representativeHistory,
        tournamentHistory: tournamentHistory ?? this.tournamentHistory,
      );
}

class PastClubEntry {
  const PastClubEntry({
    required this.name,
    required this.fromYear,
    this.toYear,
    this.notes,
    this.role,
    this.sport,
  });

  factory PastClubEntry.fromJson(Map<String, dynamic> json) => PastClubEntry(
        name: json['name'] as String? ?? '',
        fromYear: (json['fromYear'] as num?)?.toInt() ?? 2000,
        toYear: (json['toYear'] as num?)?.toInt(),
        notes: json['notes'] as String?,
        role: json['role'] as String?,
        sport: json['sport'] as String?,
      );

  final String name;
  final int fromYear;
  final int? toYear;
  final String? notes;
  final String? role;
  final String? sport;

  Map<String, dynamic> toJson() => {
        'name': name,
        'fromYear': fromYear,
        if (toYear != null) 'toYear': toYear,
        if (notes != null) 'notes': notes,
        if (role != null) 'role': role,
        if (sport != null) 'sport': sport,
      };
}

class ScoutingAvailability {
  const ScoutingAvailability({
    required this.weekday,
    required this.weekend,
    required this.hoursPerWeek,
    required this.travelRadiusKm,
    required this.paidTrialsAccepted,
  });

  factory ScoutingAvailability.fromJson(Map<String, dynamic> json) =>
      ScoutingAvailability(
        weekday: json['weekday'] as bool? ?? false,
        weekend: json['weekend'] as bool? ?? true,
        hoursPerWeek: (json['hoursPerWeek'] as num?)?.toInt() ?? 5,
        travelRadiusKm: (json['travelRadiusKm'] as num?)?.toInt() ?? 50,
        paidTrialsAccepted: json['paidTrialsAccepted'] as bool? ?? false,
      );

  final bool weekday;
  final bool weekend;
  final int hoursPerWeek;
  final int travelRadiusKm;
  final bool paidTrialsAccepted;

  Map<String, dynamic> toJson() => {
        'weekday': weekday,
        'weekend': weekend,
        'hoursPerWeek': hoursPerWeek,
        'travelRadiusKm': travelRadiusKm,
        'paidTrialsAccepted': paidTrialsAccepted,
      };
}

class ScoutingAffiliation {
  const ScoutingAffiliation({
    required this.type,
    this.clubId,
    this.clubName,
    this.transferStatus,
  });

  factory ScoutingAffiliation.fromJson(Map<String, dynamic> json) =>
      ScoutingAffiliation(
        type: json['type'] as String? ?? 'free_agent',
        clubId: json['clubId'] as String?,
        clubName: json['clubName'] as String?,
        transferStatus: json['transferStatus'] as String?,
      );

  final String type;
  final String? clubId;
  final String? clubName;
  final String? transferStatus;
}

class RepresentativeEntry {
  const RepresentativeEntry({
    required this.level,
    required this.teamName,
    required this.sport,
    required this.year,
    this.achievement,
    this.notes,
  });

  factory RepresentativeEntry.fromJson(Map<String, dynamic> json) => RepresentativeEntry(
        level: json['level'] as String? ?? 'other',
        teamName: json['teamName'] as String? ?? '',
        sport: json['sport'] as String? ?? 'football',
        year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
        achievement: json['achievement'] as String?,
        notes: json['notes'] as String?,
      );

  final String level;
  final String teamName;
  final String sport;
  final int year;
  final String? achievement;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'level': level,
        'teamName': teamName,
        'sport': sport,
        'year': year,
        if (achievement != null) 'achievement': achievement,
        if (notes != null) 'notes': notes,
      };
}

class TournamentEntry {
  const TournamentEntry({
    required this.name,
    required this.year,
    required this.sport,
    this.organiser,
    this.achievement,
    this.notes,
  });

  factory TournamentEntry.fromJson(Map<String, dynamic> json) => TournamentEntry(
        name: json['name'] as String? ?? '',
        year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
        sport: json['sport'] as String? ?? 'football',
        organiser: json['organiser'] as String?,
        achievement: json['achievement'] as String?,
        notes: json['notes'] as String?,
      );

  final String name;
  final int year;
  final String sport;
  final String? organiser;
  final String? achievement;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'name': name,
        'year': year,
        'sport': sport,
        if (organiser != null) 'organiser': organiser,
        if (achievement != null) 'achievement': achievement,
        if (notes != null) 'notes': notes,
      };
}

const kScoutingLevelLabels = {
  'recreational': 'Recreational',
  'school': 'School Team',
  'district': 'District (MSSD)',
  'state': 'State (MSSM)',
  'national': 'National',
  'semipro_pro': 'Semi-pro / Pro',
};

const kMalaysianStates = [
  'Johor',
  'Kedah',
  'Kelantan',
  'Melaka',
  'Negeri Sembilan',
  'Pahang',
  'Perak',
  'Perlis',
  'Pulau Pinang',
  'Sabah',
  'Sarawak',
  'Selangor',
  'Terengganu',
  'Kuala Lumpur',
  'Labuan',
  'Putrajaya',
];

const kFootballPositions = [
  'GK', 'RB', 'LB', 'CB', 'CDM', 'CM', 'CAM', 'RW', 'LW', 'ST',
];

const kFutsalPositions = ['GK', 'Defender', 'Winger', 'Pivot'];

const kFootballSkills = ['pace', 'passing', 'shooting', 'dribbling', 'defense', 'physical'];
const kFutsalSkills = ['control', 'passing', 'finishing', 'agility', 'defense', 'stamina'];

const kRepresentativeLevelLabels = {
  'mssd': 'MSSD (Daerah)',
  'mssm': 'MSSM (Negeri)',
  'state': 'Pasukan Negeri',
  'national': 'Kebangsaan',
  'other': 'Lain-lain',
};

const kAchievementLabels = {
  'champion': 'Champion',
  'runner_up': 'Runner-up',
  'third': '3rd Place',
  'participant': 'Participant',
  'top_scorer': 'Top Scorer',
  'best_player': 'Best Player',
};

const kAchievementIcons = {
  'champion': '🥇',
  'runner_up': '🥈',
  'third': '🥉',
  'participant': '',
  'top_scorer': '⚽',
  'best_player': '⭐',
};
