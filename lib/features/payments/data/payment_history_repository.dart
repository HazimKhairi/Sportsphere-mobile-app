import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/payment_record.dart';

class PaymentHistoryRepository {
  PaymentHistoryRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Stream<List<PaymentRecord>> streamForPlayer({
    required String playerId,
    int limit = 10,
  }) {
    // Merge two real-time streams without orderBy (avoids composite index).
    // Documents may use either playerId or userId — check both.
    late StreamController<List<PaymentRecord>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? sub1, sub2;
    var docs1 = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    var docs2 = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

    void emit() {
      final seen = <String>{};
      final merged = <PaymentRecord>[];
      for (final doc in [...docs1, ...docs2]) {
        if (seen.add(doc.id)) merged.add(_fromDoc(doc));
      }
      merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      controller.add(merged.take(limit).toList());
    }

    controller = StreamController<List<PaymentRecord>>(
      onListen: () {
        sub1 = _db
            .collection('stripe_payments')
            .where('playerId', isEqualTo: playerId)
            .limit(50)
            .snapshots()
            .listen(
              (snap) {
                docs1 = snap.docs;
                emit();
              },
              onError: controller.addError,
            );
        sub2 = _db
            .collection('stripe_payments')
            .where('userId', isEqualTo: playerId)
            .limit(50)
            .snapshots()
            .listen(
              (snap) {
                docs2 = snap.docs;
                emit();
              },
              onError: controller.addError,
            );
      },
      onCancel: () {
        sub1?.cancel();
        sub2?.cancel();
      },
    );

    return controller.stream;
  }

  Future<PaymentRecord?> byId(String id) async {
    final doc = await _db.collection('stripe_payments').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    return _fromMap(doc.id, data);
  }

  PaymentRecord _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return _fromMap(doc.id, doc.data());
  }

  PaymentRecord _fromMap(String id, Map<String, dynamic> data) {
    final ts = data['createdAt'];
    return PaymentRecord(
      id: id,
      amountCents: (data['amount'] as int?) ?? 0,
      currency: (data['currency'] as String?) ?? 'MYR',
      method: PaymentMethodKind.fromString(data['paymentMethod'] as String?),
      status: PaymentStatusKind.fromString(data['status'] as String?),
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
      programId: data['programId'] as String?,
      programName: data['programName'] as String?,
      receiptUrl: data['receiptUrl'] as String?,
    );
  }
}
