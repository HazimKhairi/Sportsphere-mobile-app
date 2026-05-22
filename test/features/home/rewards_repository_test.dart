import 'package:dio/dio.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sportsphere_mobile/features/home/data/rewards_repository.dart';
import 'package:sportsphere_mobile/features/home/domain/redemption_result.dart';

class _MockDio extends Mock implements Dio {}

Future<FakeFirebaseFirestore> seedRewards(
  String clubId,
  List<Map<String, dynamic>> rewards,
) async {
  final fs = FakeFirebaseFirestore();
  for (final r in rewards) {
    await fs
        .collection('clubs')
        .doc(clubId)
        .collection('rewards')
        .doc(r['id'] as String)
        .set(r);
  }
  return fs;
}

void main() {
  group('streamCatalog', () {
    test('returns active rewards sorted by costPoints asc', () async {
      final fs = await seedRewards('club_1', [
        {
          'id': 'a',
          'name': 'Sticker pack',
          'cost': 100,
          'active': true,
        },
        {
          'id': 'b',
          'name': 'T-shirt',
          'cost': 500,
          'active': true,
        },
        {
          'id': 'c',
          'name': 'Hat',
          'cost': 250,
          'active': true,
        },
        {
          'id': 'd',
          'name': 'Hidden',
          'cost': 50,
          'active': false,
        },
      ]);
      final repo = RewardsRepository(firestore: fs, dio: _MockDio());
      final list = await repo.streamCatalog(clubId: 'club_1').first;
      expect(list.map((r) => r.id).toList(), ['a', 'c', 'b']);
    });

    test('returns empty when no rewards', () async {
      final fs = await seedRewards('club_1', const []);
      final repo = RewardsRepository(firestore: fs, dio: _MockDio());
      final list = await repo.streamCatalog(clubId: 'club_1').first;
      expect(list, isEmpty);
    });

    test('defaults missing fields safely', () async {
      final fs = await seedRewards('club_1', [
        {'id': 'a'},
      ]);
      final repo = RewardsRepository(firestore: fs, dio: _MockDio());
      final list = await repo.streamCatalog(clubId: 'club_1').first;
      expect(list.first.name, 'Reward');
      expect(list.first.costPoints, 0);
      expect(list.first.active, true);
      expect(list.first.stock, isNull);
    });

    test('inStock + available reflect stock + active', () async {
      final fs = await seedRewards('club_1', [
        {'id': 'a', 'cost': 10, 'stock': 5, 'active': true},
        {'id': 'b', 'cost': 10, 'stock': 0, 'active': true},
        {'id': 'c', 'cost': 10, 'active': true}, // unlimited
      ]);
      final repo = RewardsRepository(firestore: fs, dio: _MockDio());
      final list = await repo.streamCatalog(clubId: 'club_1').first;
      final byId = {for (final r in list) r.id: r};
      expect(byId['a']!.inStock, true);
      expect(byId['b']!.inStock, false);
      expect(byId['b']!.available, false);
      expect(byId['c']!.inStock, true);
    });
  });

  group('pointsBalanceStream', () {
    test('reads players/{uid}.points', () async {
      final fs = FakeFirebaseFirestore();
      await fs.collection('players').doc('p1').set({'points': 320});
      final repo = RewardsRepository(firestore: fs, dio: _MockDio());
      final balance = await repo.pointsBalanceStream(playerId: 'p1').first;
      expect(balance, 320);
    });

    test('returns 0 when missing', () async {
      final fs = FakeFirebaseFirestore();
      final repo = RewardsRepository(firestore: fs, dio: _MockDio());
      final balance =
          await repo.pointsBalanceStream(playerId: 'absent').first;
      expect(balance, 0);
    });
  });

  group('redeem', () {
    test('POSTs rewardId to /api/player-app/rewards/redeem', () async {
      final dio = _MockDio();
      registerFallbackValue(Options());
      when(() => dio.post<Map<String, dynamic>>(
            '/api/player-app/rewards/redeem',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
                requestOptions: RequestOptions(
                  path: '/api/player-app/rewards/redeem',
                ),
                statusCode: 200,
                data: {
                  'code': 'SPHR-ABCD-1234',
                  'remainingPoints': 200,
                  'expiresAt': '2026-12-31T23:59:59Z',
                },
              ));

      final repo = RewardsRepository(
        firestore: FakeFirebaseFirestore(),
        dio: dio,
      );
      final result = await repo.redeem(rewardId: 'reward_1');

      expect(result.code, 'SPHR-ABCD-1234');
      expect(result.remainingPoints, 200);
      expect(result.expiresAt, DateTime.utc(2026, 12, 31, 23, 59, 59));
      verify(() => dio.post<Map<String, dynamic>>(
            '/api/player-app/rewards/redeem',
            data: {'rewardId': 'reward_1'},
          )).called(1);
    });

    test('throws RewardsException on insufficient points (402)', () async {
      final dio = _MockDio();
      registerFallbackValue(Options());
      when(() => dio.post<Map<String, dynamic>>(
            '/api/player-app/rewards/redeem',
            data: any(named: 'data'),
          )).thenThrow(DioException(
            requestOptions:
                RequestOptions(path: '/api/player-app/rewards/redeem'),
            response: Response(
              requestOptions:
                  RequestOptions(path: '/api/player-app/rewards/redeem'),
              statusCode: 402,
              data: {'error': 'Not enough points'},
            ),
            type: DioExceptionType.badResponse,
          ));

      final repo = RewardsRepository(
        firestore: FakeFirebaseFirestore(),
        dio: dio,
      );
      expect(
        () => repo.redeem(rewardId: 'reward_1'),
        throwsA(isA<RewardsException>()),
      );
    });

    test('handles null expiresAt', () async {
      final dio = _MockDio();
      registerFallbackValue(Options());
      when(() => dio.post<Map<String, dynamic>>(
            '/api/player-app/rewards/redeem',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
                requestOptions: RequestOptions(
                  path: '/api/player-app/rewards/redeem',
                ),
                statusCode: 200,
                data: {'code': 'SPHR-X', 'remainingPoints': 0},
              ));

      final repo = RewardsRepository(
        firestore: FakeFirebaseFirestore(),
        dio: dio,
      );
      final r = await repo.redeem(rewardId: 'x');
      expect(r.expiresAt, isNull);
    });
  });
}
