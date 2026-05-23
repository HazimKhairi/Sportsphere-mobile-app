import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/drill.dart';
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

    final name = data['name'];
    return TodayDrill(
      id: pick.id,
      name: name is String && name.isNotEmpty ? name : 'Drill',
      difficulty: _parseDifficulty(data['difficulty']),
    );
  }

  Stream<List<Drill>> listDrillsStream() {
    return _db.collection('drills').snapshots().map((snap) {
      final list = snap.docs.map(_fromFullDoc).toList();
      list.sort((a, b) => a.difficulty.compareTo(b.difficulty));
      return list;
    });
  }

  Future<Drill?> drillById(String id) async {
    final doc = await _db.collection('drills').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    return _fromFullMap(doc.id, data);
  }

  // Firestore stores difficulty as int or String — handle both.
  static int _parseDifficulty(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 1;
    return 1;
  }

  Drill _fromFullDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return _fromFullMap(doc.id, doc.data());
  }

  Drill _fromFullMap(String id, Map<String, dynamic> data) {
    final attrs = data['targetAttributes'];
    final attrList = (attrs is List)
        ? attrs.cast<String>().toList()
        : const <String>[];
    return Drill(
      id: id,
      name: (data['name'] as String?)?.isNotEmpty == true
          ? data['name'] as String
          : 'Untitled drill',
      category: (data['category'] as String?) ?? '',
      difficulty: _parseDifficulty(data['difficulty']),
      youtubeUrl: data['youtubeUrl'] as String?,
      description: (data['description'] as String?) ?? '',
      targetAttributes: attrList,
      iconName: data['iconName'] as String?,
    );
  }
}
