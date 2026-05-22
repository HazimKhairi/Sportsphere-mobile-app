import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/body_composition_entry.dart';

class BodyCompositionRepository {
  BodyCompositionRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Stream<List<BodyCompositionEntry>> streamForPlayer({
    required String playerId,
  }) {
    return _db
        .collection('players')
        .doc(playerId)
        .collection('body_composition')
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(_fromDoc).toList();
      list.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
      return list;
    });
  }

  Future<void> addEntry({
    required String playerId,
    double? weightKg,
    double? heightCm,
    double? bodyFatPct,
    double? muscleMassKg,
  }) async {
    final payload = <String, dynamic>{
      'recordedAt': Timestamp.fromDate(DateTime.now()),
    };
    if (weightKg != null) payload['weightKg'] = weightKg;
    if (heightCm != null) payload['heightCm'] = heightCm;
    if (bodyFatPct != null) payload['bodyFatPct'] = bodyFatPct;
    if (muscleMassKg != null) payload['muscleMassKg'] = muscleMassKg;
    await _db
        .collection('players')
        .doc(playerId)
        .collection('body_composition')
        .add(payload);
  }

  BodyCompositionEntry _fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final ts = data['recordedAt'];
    final recordedAt = ts is Timestamp
        ? ts.toDate()
        : DateTime.fromMillisecondsSinceEpoch(0);
    double? asDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      return null;
    }

    return BodyCompositionEntry(
      id: doc.id,
      recordedAt: recordedAt,
      weightKg: asDouble(data['weightKg']),
      heightCm: asDouble(data['heightCm']),
      bodyFatPct: asDouble(data['bodyFatPct']),
      muscleMassKg: asDouble(data['muscleMassKg']),
    );
  }
}
