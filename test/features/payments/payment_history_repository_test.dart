import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportsphere_mobile/features/payments/data/payment_history_repository.dart';
import 'package:sportsphere_mobile/features/payments/domain/payment_record.dart';

Future<FakeFirebaseFirestore> seed(List<Map<String, dynamic>> payments) async {
  final fs = FakeFirebaseFirestore();
  for (final p in payments) {
    await fs.collection('stripe_payments').doc(p['id'] as String).set(p);
  }
  return fs;
}

void main() {
  group('streamForPlayer', () {
    test('returns payments for player ordered by createdAt desc', () async {
      final fs = await seed([
        {
          'id': 'a',
          'playerId': 'p1',
          'amount': 15050,
          'currency': 'MYR',
          'paymentMethod': 'card',
          'status': 'cleared',
          'createdAt': Timestamp.fromDate(DateTime(2026, 5, 1)),
        },
        {
          'id': 'b',
          'playerId': 'p1',
          'amount': 5000,
          'currency': 'MYR',
          'paymentMethod': 'cash',
          'status': 'PENDING_APPROVAL',
          'createdAt': Timestamp.fromDate(DateTime(2026, 5, 20)),
        },
        {
          'id': 'c',
          'playerId': 'p2',
          'amount': 9999,
          'currency': 'MYR',
          'paymentMethod': 'card',
          'status': 'cleared',
          'createdAt': Timestamp.fromDate(DateTime(2026, 5, 10)),
        },
      ]);

      final repo = PaymentHistoryRepository(firestore: fs);
      final list = await repo.streamForPlayer(playerId: 'p1').first;
      expect(list.map((p) => p.id).toList(), ['b', 'a']);
    });

    test('returns empty when player has no payments', () async {
      final fs = await seed([]);
      final repo = PaymentHistoryRepository(firestore: fs);
      final list = await repo.streamForPlayer(playerId: 'nobody').first;
      expect(list, isEmpty);
    });

    test('caps at limit (default 10)', () async {
      final fs = await seed([
        for (var i = 0; i < 15; i++)
          {
            'id': 'p$i',
            'playerId': 'p1',
            'amount': 100,
            'currency': 'MYR',
            'paymentMethod': 'card',
            'status': 'cleared',
            'createdAt': Timestamp.fromDate(DateTime(2026, 5, 1).add(Duration(days: i))),
          },
      ]);
      final repo = PaymentHistoryRepository(firestore: fs);
      final list = await repo.streamForPlayer(playerId: 'p1').first;
      expect(list, hasLength(10));
    });

    test('maps payment method + status enums correctly', () async {
      final fs = await seed([
        {
          'id': 'a',
          'playerId': 'p1',
          'amount': 100,
          'currency': 'MYR',
          'paymentMethod': 'cash',
          'status': 'PENDING_APPROVAL',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        },
      ]);
      final repo = PaymentHistoryRepository(firestore: fs);
      final list = await repo.streamForPlayer(playerId: 'p1').first;
      expect(list.first.method, PaymentMethodKind.cash);
      expect(list.first.status, PaymentStatusKind.pendingApproval);
    });

    test('defaults missing fields gracefully', () async {
      final fs = await seed([
        {
          'id': 'a',
          'playerId': 'p1',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        },
      ]);
      final repo = PaymentHistoryRepository(firestore: fs);
      final list = await repo.streamForPlayer(playerId: 'p1').first;
      expect(list.first.amountCents, 0);
      expect(list.first.currency, 'MYR');
      expect(list.first.method, PaymentMethodKind.unknown);
      expect(list.first.status, PaymentStatusKind.unknown);
    });
  });

  group('byId', () {
    test('returns the payment when exists', () async {
      final fs = await seed([
        {
          'id': 'a',
          'playerId': 'p1',
          'amount': 15050,
          'currency': 'MYR',
          'paymentMethod': 'card',
          'status': 'cleared',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        },
      ]);
      final repo = PaymentHistoryRepository(firestore: fs);
      final p = await repo.byId('a');
      expect(p, isNotNull);
      expect(p!.amountCents, 15050);
    });

    test('returns null when missing', () async {
      final fs = await seed([]);
      final repo = PaymentHistoryRepository(firestore: fs);
      final p = await repo.byId('nope');
      expect(p, isNull);
    });
  });
}
