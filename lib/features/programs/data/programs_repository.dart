import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/program.dart';

class ProgramsRepository {
  ProgramsRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Streams published programs for a club, ordered by `createdAt` desc
  /// client-side (so no Firestore composite index is required).
  Stream<List<Program>> publishedProgramsStream({required String clubId}) {
    return _db
        .collection('clubs')
        .doc(clubId)
        .collection('programs')
        .where('status', isEqualTo: 'published')
        .snapshots()
        .map((snap) {
      final pairs = snap.docs.map((d) {
        final data = d.data();
        final ts = data['createdAt'];
        final created = ts is Timestamp
            ? ts.toDate()
            : DateTime.fromMillisecondsSinceEpoch(0);
        return (created, _fromDoc(d));
      }).toList();
      pairs.sort((a, b) => b.$1.compareTo(a.$1)); // desc
      return pairs.map((p) => p.$2).toList();
    });
  }

  Future<Program?> programById({
    required String clubId,
    required String programId,
  }) async {
    final doc = await _db
        .collection('clubs')
        .doc(clubId)
        .collection('programs')
        .doc(programId)
        .get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    return _fromMap(doc.id, data);
  }

  Program _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return _fromMap(doc.id, doc.data());
  }

  Program _fromMap(String id, Map<String, dynamic> data) {
    final regStart = data['registrationStart'];
    final regEnd = data['registrationEnd'];
    final rawName = data['name'] as String?;
    return Program(
      id: id,
      name: (rawName != null && rawName.isNotEmpty) ? rawName : 'Untitled program',
      description: (data['description'] as String?) ?? '',
      basePriceCents: (data['basePrice'] as int?) ?? 0,
      currency: (data['currency'] as String?) ?? 'MYR',
      coverImageUrl: data['coverImageUrl'] as String?,
      capacity: data['capacity'] as int?,
      currentRegistrants: (data['currentRegistrants'] as int?) ?? 0,
      registrationStart: regStart is Timestamp ? regStart.toDate() : null,
      registrationEnd: regEnd is Timestamp ? regEnd.toDate() : null,
    );
  }
}
