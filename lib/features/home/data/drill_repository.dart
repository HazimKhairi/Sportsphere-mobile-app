import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/today_drill.dart';
import '_daily_seed.dart';

class DrillRepository {
  DrillRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Future<TodayDrill?> todayDrillFor({
    required String playerId,
    required DateTime date,
  }) async {
    final snap = await _db.collection('drills').get();
    if (snap.docs.isEmpty) return null;

    final seed = djb2(dailySeedKey(date: date, playerId: playerId));
    final shuffled = shuffleSeeded(snap.docs, seed: seed);
    final pick = shuffled.first;
    final data = pick.data();

    return TodayDrill(
      id: pick.id,
      name: (data['name'] as String?) ?? 'Drill',
      difficulty: (data['difficulty'] as int?) ?? 1,
    );
  }
}
