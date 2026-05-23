import 'package:cloud_firestore/cloud_firestore.dart';

class RecoveryLog {
  const RecoveryLog({
    required this.id,
    required this.date,
    required this.dateStr,
    required this.fatigue,
    required this.sleepQuality,
    required this.muscleSoreness,
    required this.stress,
    required this.mood,
    required this.wellnessScore,
    this.soreSites = const [],
    this.notes,
  });

  final String id;
  final DateTime date;
  final String dateStr; // 'YYYY-MM-DD'
  final int fatigue;        // 1–7 (Hooper Index)
  final int sleepQuality;   // 1–7
  final int muscleSoreness; // 1–7
  final int stress;         // 1–7
  final int mood;           // 1–7
  final int wellnessScore;  // 0–100
  final List<String> soreSites;
  final String? notes;

  static int computeScore(int fatigue, int sleep, int soreness, int stress, int mood) {
    final sum = fatigue + sleep + soreness + stress + mood;
    return (100 - ((sum - 5) / 30 * 100)).round().clamp(0, 100);
  }

  factory RecoveryLog.fromDoc(String id, Map<String, dynamic> d) => RecoveryLog(
        id: id,
        date: (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        dateStr: (d['dateStr'] as String?) ?? '',
        fatigue: (d['fatigue'] as int?) ?? 4,
        sleepQuality: (d['sleepQuality'] as int?) ?? 4,
        muscleSoreness: (d['muscleSoreness'] as int?) ?? 4,
        stress: (d['stress'] as int?) ?? 4,
        mood: (d['mood'] as int?) ?? 4,
        wellnessScore: (d['wellnessScore'] as int?) ?? 50,
        soreSites: ((d['soreSites'] as List?)?.cast<String>()) ?? [],
        notes: d['notes'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'date': Timestamp.fromDate(date),
        'dateStr': dateStr,
        'fatigue': fatigue,
        'sleepQuality': sleepQuality,
        'muscleSoreness': muscleSoreness,
        'stress': stress,
        'mood': mood,
        'wellnessScore': wellnessScore,
        'soreSites': soreSites,
        if (notes != null) 'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
