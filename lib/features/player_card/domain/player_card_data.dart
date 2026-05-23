class PlayerCardData {
  const PlayerCardData({
    required this.playerName,
    required this.position,
    required this.ovr,
    required this.rarityTier,
    this.playerPhoto,
    this.age,
    this.clubName,
    this.pac,
    this.sho,
    this.pas,
    this.dri,
    this.def,
    this.phy,
    this.gkDiv,
    this.gkHan,
    this.gkKic,
    this.gkRef,
    this.gkSpd,
    this.gkPos,
    this.qrCodeData,
    this.trainingSummary,
  });

  factory PlayerCardData.fromJson(Map<String, dynamic> json) {
    return PlayerCardData(
      playerName: json['playerName'] as String? ?? '',
      position: json['position'] as String? ?? '',
      ovr: (json['OVR'] as num?)?.toInt() ?? 0,
      rarityTier: _parseRarity(json['rarityTier']),
      playerPhoto: json['playerPhoto'] as String?,
      age: (json['age'] as num?)?.toInt(),
      clubName: json['clubName'] as String?,
      pac: (json['PAC'] as num?)?.toInt(),
      sho: (json['SHO'] as num?)?.toInt(),
      pas: (json['PAS'] as num?)?.toInt(),
      dri: (json['DRI'] as num?)?.toInt(),
      def: (json['DEF'] as num?)?.toInt(),
      phy: (json['PHY'] as num?)?.toInt(),
      gkDiv: (json['GK_DIV'] as num?)?.toInt(),
      gkHan: (json['GK_HAN'] as num?)?.toInt(),
      gkKic: (json['GK_KIC'] as num?)?.toInt(),
      gkRef: (json['GK_REF'] as num?)?.toInt(),
      gkSpd: (json['GK_SPD'] as num?)?.toInt(),
      gkPos: (json['GK_POS'] as num?)?.toInt(),
      qrCodeData: json['qrCodeData'] as String?,
    );
  }

  final String playerName;
  final String position;
  final int ovr;
  final RarityTier rarityTier;
  final String? playerPhoto;
  final int? age;
  final String? clubName;
  final int? pac;
  final int? sho;
  final int? pas;
  final int? dri;
  final int? def;
  final int? phy;
  final int? gkDiv;
  final int? gkHan;
  final int? gkKic;
  final int? gkRef;
  final int? gkSpd;
  final int? gkPos;
  final String? qrCodeData;
  final TrainingSummary? trainingSummary;

  bool get isGoalkeeper => position == 'GK';

  List<StatEntry> get outfieldStats => [
        if (pac != null) StatEntry('PAC', pac!),
        if (sho != null) StatEntry('SHO', sho!),
        if (pas != null) StatEntry('PAS', pas!),
        if (dri != null) StatEntry('DRI', dri!),
        if (def != null) StatEntry('DEF', def!),
        if (phy != null) StatEntry('PHY', phy!),
      ];

  List<StatEntry> get gkStats => [
        if (gkDiv != null) StatEntry('DIV', gkDiv!),
        if (gkHan != null) StatEntry('HAN', gkHan!),
        if (gkKic != null) StatEntry('KIC', gkKic!),
        if (gkRef != null) StatEntry('REF', gkRef!),
        if (gkSpd != null) StatEntry('SPD', gkSpd!),
        if (gkPos != null) StatEntry('POS', gkPos!),
      ];

  List<StatEntry> get activeStats => isGoalkeeper ? gkStats : outfieldStats;

  static RarityTier _parseRarity(dynamic v) {
    return switch (v as String? ?? '') {
      'gold' => RarityTier.gold,
      'silver' => RarityTier.silver,
      'diamond' => RarityTier.diamond,
      _ => RarityTier.bronze,
    };
  }
}

enum RarityTier { bronze, silver, gold, diamond }

extension RarityTierExt on RarityTier {
  String get label => switch (this) {
        RarityTier.bronze => 'Bronze',
        RarityTier.silver => 'Silver',
        RarityTier.gold => 'Gold',
        RarityTier.diamond => 'Diamond',
      };
}

class StatEntry {
  const StatEntry(this.key, this.value);
  final String key;
  final int value;
}

class TrainingSummary {
  const TrainingSummary({
    required this.totalRatedSessions,
    required this.lastRatedAt,
    required this.perAttribute,
  });

  factory TrainingSummary.fromJson(Map<String, dynamic> json) {
    return TrainingSummary(
      totalRatedSessions: (json['totalRatedSessions'] as num?)?.toInt() ?? 0,
      lastRatedAt: json['lastRatedAt'] as String?,
      perAttribute: (json['perAttribute'] as List<dynamic>?)
              ?.map((e) => AttributeSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  final int totalRatedSessions;
  final String? lastRatedAt;
  final List<AttributeSummary> perAttribute;
}

class AttributeSummary {
  const AttributeSummary({
    required this.key,
    required this.latest,
    required this.previousAvg,
    required this.trend,
    required this.history,
  });

  factory AttributeSummary.fromJson(Map<String, dynamic> json) {
    return AttributeSummary(
      key: json['key'] as String? ?? '',
      latest: (json['latest'] as num?)?.toInt(),
      previousAvg: (json['previousAvg'] as num?)?.toInt(),
      trend: json['trend'] as String?,
      history: (json['history'] as List<dynamic>?)
              ?.map((e) => (e as Map<String, dynamic>)['score'] as num?)
              .whereType<num>()
              .map((n) => n.toDouble())
              .toList() ??
          [],
    );
  }

  final String key;
  final int? latest;
  final int? previousAvg;
  final String? trend;
  final List<double> history;
}
