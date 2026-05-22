import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sportsphere_mobile/features/home/data/points_repository.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late PointsRepository repo;

  setUp(() {
    dio = _MockDio();
    registerFallbackValue(Options());
    repo = PointsRepository(dio: dio);
  });

  test('fetchSummary success', () async {
    when(() => dio.get<Map<String, dynamic>>('/api/player-app/points'))
        .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/api/player-app/points'),
              statusCode: 200,
              data: {
                'totalPoints': 150,
                'availablePoints': 100,
                'history': [
                  {
                    'id': 'doc-uuid-1',
                    'action': 'drill_complete',
                    'points': 10,
                    'description': 'Completed drill: 1v1 Dribbling Challenge',
                    'balanceAfter': 100,
                    'createdAt': '2026-05-22T10:30:00Z',
                  },
                  {
                    'id': 'doc-uuid-2',
                    'action': 'reward_redemption',
                    'points': -50,
                    'description': 'Redeemed: RM10 Store Voucher',
                    'balanceAfter': 90,
                    'createdAt': '2026-05-20T14:22:00Z',
                  },
                ],
              },
            ));

    final summary = await repo.fetchSummary();

    expect(summary.totalPoints, 150);
    expect(summary.availablePoints, 100);
    expect(summary.history.length, 2);
    expect(summary.history[0].points, 10);
    expect(summary.history[1].points, -50);
  });

  test('fetchSummary propagates DioException', () async {
    when(() => dio.get<Map<String, dynamic>>('/api/player-app/points'))
        .thenThrow(DioException(
      requestOptions: RequestOptions(path: '/api/player-app/points'),
      response: Response(
        requestOptions: RequestOptions(path: '/api/player-app/points'),
        statusCode: 500,
        data: {'error': 'Internal server error'},
      ),
      type: DioExceptionType.badResponse,
    ));

    expect(
      () => repo.fetchSummary(),
      throwsA(isA<PointsException>()),
    );
  });
}
