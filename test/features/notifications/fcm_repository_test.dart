import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sportsphere_mobile/features/notifications/data/fcm_repository.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late FcmRepository repo;

  setUp(() {
    dio = _MockDio();
    registerFallbackValue(Options());
    repo = FcmRepository(dio: dio);
  });

  test('registerDevice posts token + platform + version to /api/users/devices', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/users/devices',
          data: any(named: 'data'),
        )).thenAnswer((_) async => Response<Map<String, dynamic>>(
              requestOptions: RequestOptions(path: '/api/users/devices'),
              statusCode: 200,
              data: {'deviceId': 'dev_123'},
            ));

    final id = await repo.registerDevice(
      token: 'fcm_abc',
      platform: 'ios',
      appVersion: '1.0.0+1',
    );

    expect(id, 'dev_123');
    verify(() => dio.post<Map<String, dynamic>>(
          '/api/users/devices',
          data: {
            'token': 'fcm_abc',
            'platform': 'ios',
            'appVersion': '1.0.0+1',
          },
        )).called(1);
  });

  test('unregisterDevice DELETEs /api/users/devices/{id}', () async {
    when(() => dio.delete<void>('/api/users/devices/dev_123'))
        .thenAnswer((_) async => Response<void>(
              requestOptions: RequestOptions(path: '/api/users/devices/dev_123'),
              statusCode: 204,
            ));

    await repo.unregisterDevice('dev_123');

    verify(() => dio.delete<void>('/api/users/devices/dev_123')).called(1);
  });
}
