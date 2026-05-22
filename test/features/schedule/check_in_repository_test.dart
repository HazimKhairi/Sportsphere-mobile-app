import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sportsphere_mobile/features/schedule/data/check_in_repository.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late CheckInRepository repo;

  setUp(() {
    dio = _MockDio();
    registerFallbackValue(Options());
    repo = CheckInRepository(dio: dio);
  });

  test('checkIn posts sessionId + qrPayload to /api/attendance/check-in', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/attendance/check-in',
          data: any(named: 'data'),
        )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/api/attendance/check-in'),
              statusCode: 200,
              data: {'status': 'checked_in'},
            ));

    final result = await repo.checkIn(
      sessionId: 'sess_1',
      qrPayload: 'qr_data',
    );

    expect(result, CheckInResult.success);
    verify(() => dio.post<Map<String, dynamic>>(
          '/api/attendance/check-in',
          data: {
            'sessionId': 'sess_1',
            'qrPayload': 'qr_data',
          },
        )).called(1);
  });

  test('checkIn returns mismatch when status code is 400', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/attendance/check-in',
          data: any(named: 'data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/attendance/check-in'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/attendance/check-in'),
            statusCode: 400,
          ),
          type: DioExceptionType.badResponse,
        ));

    final result = await repo.checkIn(
      sessionId: 'sess_1',
      qrPayload: 'wrong',
    );
    expect(result, CheckInResult.mismatch);
  });

  test('checkIn returns failure on network error', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/attendance/check-in',
          data: any(named: 'data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/attendance/check-in'),
          type: DioExceptionType.connectionError,
        ));

    final result = await repo.checkIn(
      sessionId: 'sess_1',
      qrPayload: 'q',
    );
    expect(result, CheckInResult.failure);
  });
}
