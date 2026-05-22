import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sportsphere_mobile/features/home/data/drill_session_repository.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late DrillSessionRepository repo;

  setUp(() {
    dio = _MockDio();
    registerFallbackValue(Options());
    repo = DrillSessionRepository(dio: dio);
  });

  test('recordSession POSTs drillId + reps + durationMs + mode', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/player-app/drill-sessions',
          data: any(named: 'data'),
        )).thenAnswer((_) async => Response(
              requestOptions:
                  RequestOptions(path: '/api/player-app/drill-sessions'),
              statusCode: 200,
              data: {'sessionId': 'ds_abc', 'streakDays': 8},
            ));

    final result = await repo.recordSession(
      drillId: 'd1',
      reps: 50,
      durationMs: 180000,
      mode: 'kneeLine',
    );

    expect(result.sessionId, 'ds_abc');
    expect(result.streakDays, 8);
    verify(() => dio.post<Map<String, dynamic>>(
          '/api/player-app/drill-sessions',
          data: {
            'drillId': 'd1',
            'reps': 50,
            'durationMs': 180000,
            'mode': 'kneeLine',
          },
        )).called(1);
  });

  test('recordSession defaults streakDays to 0 when not returned', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/player-app/drill-sessions',
          data: any(named: 'data'),
        )).thenAnswer((_) async => Response(
              requestOptions:
                  RequestOptions(path: '/api/player-app/drill-sessions'),
              statusCode: 200,
              data: {'sessionId': 'x'},
            ));

    final result = await repo.recordSession(
      drillId: 'd', reps: 1, durationMs: 1000, mode: 'tap',
    );
    expect(result.streakDays, 0);
  });

  test('recordSession throws DrillSessionException on 4xx', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/player-app/drill-sessions',
          data: any(named: 'data'),
        )).thenThrow(DioException(
          requestOptions:
              RequestOptions(path: '/api/player-app/drill-sessions'),
          response: Response(
            requestOptions:
                RequestOptions(path: '/api/player-app/drill-sessions'),
            statusCode: 400,
            data: {'error': 'Invalid drill'},
          ),
          type: DioExceptionType.badResponse,
        ));

    expect(
      () => repo.recordSession(
        drillId: 'd', reps: 1, durationMs: 1000, mode: 'tap',
      ),
      throwsA(isA<DrillSessionException>()),
    );
  });
}
