import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sportsphere_mobile/features/home/data/drill_completion_repository.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late DrillCompletionRepository repo;

  setUp(() {
    dio = _MockDio();
    registerFallbackValue(Options());
    repo = DrillCompletionRepository(dio: dio);
  });

  test('markComplete success returns DrillCompletionResult', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/player-app/drills/abc/complete',
        )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(
                  path: '/api/player-app/drills/abc/complete'),
              statusCode: 200,
              data: {
                'pointsEarned': 10,
                'currentStreak': 5,
                'longestStreak': 7,
                'isNewBest': false,
              },
            ));

    final result = await repo.markComplete(drillId: 'abc');

    expect(result.pointsEarned, 10);
    expect(result.currentStreak, 5);
    expect(result.longestStreak, 7);
    expect(result.isNewBest, false);
    verify(() => dio.post<Map<String, dynamic>>(
          '/api/player-app/drills/abc/complete',
        )).called(1);
  });

  test('markComplete throws DrillAlreadyCompletedToday on 409', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/player-app/drills/abc/complete',
        )).thenThrow(DioException(
          requestOptions:
              RequestOptions(path: '/api/player-app/drills/abc/complete'),
          response: Response(
            requestOptions:
                RequestOptions(path: '/api/player-app/drills/abc/complete'),
            statusCode: 409,
            data: {'error': 'Already trained today'},
          ),
          type: DioExceptionType.badResponse,
        ));

    expect(
      () => repo.markComplete(drillId: 'abc'),
      throwsA(isA<DrillAlreadyCompletedToday>()),
    );
  });

  test('markComplete throws DrillCompletionException on other error', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/player-app/drills/abc/complete',
        )).thenThrow(DioException(
          requestOptions:
              RequestOptions(path: '/api/player-app/drills/abc/complete'),
          response: Response(
            requestOptions:
                RequestOptions(path: '/api/player-app/drills/abc/complete'),
            statusCode: 500,
            data: {'error': 'Internal server error'},
          ),
          type: DioExceptionType.badResponse,
        ));

    expect(
      () => repo.markComplete(drillId: 'abc'),
      throwsA(isA<DrillCompletionException>()),
    );
  });
}
