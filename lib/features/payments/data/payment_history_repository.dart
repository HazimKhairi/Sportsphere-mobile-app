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
    return _db
        .collection('stripe_payments')
        .where('playerId', isEqualTo: playerId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
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
    );
  }
}
