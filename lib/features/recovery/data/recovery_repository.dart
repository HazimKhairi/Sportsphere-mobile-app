import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/recovery_content.dart';
import '../domain/recovery_log.dart';

class RecoveryRepository {
  RecoveryRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Stream<RecoveryLog?> todayLogStream(String userId) {
    final today = _todayStr();
    return _db
        .collection('users')
        .doc(userId)
        .collection('recovery_logs')
        .where('dateStr', isEqualTo: today)
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty
            ? null
            : RecoveryLog.fromDoc(s.docs.first.id, s.docs.first.data()));
  }

  Stream<List<RecoveryLog>> recentLogsStream(String userId, {int days = 14}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _db
        .collection('users')
        .doc(userId)
        .collection('recovery_logs')
        .where('date', isGreaterThan: Timestamp.fromDate(cutoff))
        .orderBy('date', descending: true)
        .limit(days)
        .snapshots()
        .map((s) => s.docs
            .map((d) => RecoveryLog.fromDoc(d.id, d.data()))
            .toList());
  }

  Future<void> saveLog(String userId, RecoveryLog log) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('recovery_logs')
        .add(log.toMap());
  }

  Stream<List<RecoveryContent>> contentStream({String? category}) {
    Query<Map<String, dynamic>> q = _db
        .collection('recovery_content')
        .where('isActive', isEqualTo: true)
        .limit(50);
    if (category != null) q = q.where('category', isEqualTo: category);
    return q
        .orderBy('sortOrder')
        .snapshots()
        .map((s) => s.docs
            .map((d) => RecoveryContent.fromDoc(d.id, d.data()))
            .toList());
  }

  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
