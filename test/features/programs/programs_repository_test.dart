import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportsphere_mobile/features/programs/data/programs_repository.dart';

Future<FakeFirebaseFirestore> seed(
  List<Map<String, dynamic>> programs, {
  String clubId = 'club_1',
}) async {
  final fs = FakeFirebaseFirestore();
  for (final p in programs) {
    await fs
        .collection('clubs')
        .doc(clubId)
        .collection('programs')
        .doc(p['id'] as String)
        .set(p);
  }
  return fs;
}

void main() {
  group('publishedProgramsStream', () {
    test('returns only programs with status published', () async {
      final fs = await seed([
        {
          'id': 'p1',
          'name': 'Junior Training',
          'description': 'For U13 players',
          'basePrice': 15050,
          'currency': 'MYR',
          'status': 'published',
        },
        {
          'id': 'p2',
          'name': 'Hidden Draft',
          'status': 'draft',
        },
      ]);
      final repo = ProgramsRepository(firestore: fs);
      final list = await repo.publishedProgramsStream(clubId: 'club_1').first;
      expect(list, hasLength(1));
      expect(list.first.id, 'p1');
      expect(list.first.name, 'Junior Training');
      expect(list.first.basePriceCents, 15050);
      expect(list.first.currency, 'MYR');
    });

    test('returns empty when no published programs', () async {
      final fs = await seed([]);
      final repo = ProgramsRepository(firestore: fs);
      final list = await repo.publishedProgramsStream(clubId: 'club_1').first;
      expect(list, isEmpty);
    });

    test('orders by createdAt desc when present', () async {
      final fs = await seed([
        {
          'id': 'a',
          'name': 'A',
          'status': 'published',
          'createdAt': Timestamp.fromDate(DateTime(2026, 5, 1)),
        },
        {
          'id': 'b',
          'name': 'B',
          'status': 'published',
          'createdAt': Timestamp.fromDate(DateTime(2026, 5, 20)),
        },
      ]);
      final repo = ProgramsRepository(firestore: fs);
      final list = await repo.publishedProgramsStream(clubId: 'club_1').first;
      expect(list.map((p) => p.id).toList(), ['b', 'a']);
    });

    test('defaults missing fields gracefully', () async {
      final fs = await seed([
        {
          'id': 'p1',
          'status': 'published',
        },
      ]);
      final repo = ProgramsRepository(firestore: fs);
      final list = await repo.publishedProgramsStream(clubId: 'club_1').first;
      expect(list.first.name, 'Untitled program');
      expect(list.first.description, '');
      expect(list.first.basePriceCents, 0);
      expect(list.first.currency, 'MYR');
      expect(list.first.coverImageUrl, isNull);
    });
  });

  group('programById', () {
    test('returns program when exists', () async {
      final fs = await seed([
        {
          'id': 'p1',
          'name': 'A',
          'status': 'published',
          'basePrice': 5000,
        },
      ]);
      final repo = ProgramsRepository(firestore: fs);
      final p = await repo.programById(clubId: 'club_1', programId: 'p1');
      expect(p, isNotNull);
      expect(p!.basePriceCents, 5000);
    });

    test('returns null when missing', () async {
      final fs = await seed([]);
      final repo = ProgramsRepository(firestore: fs);
      final p = await repo.programById(clubId: 'club_1', programId: 'missing');
      expect(p, isNull);
    });
  });
}
