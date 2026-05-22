import 'package:dio/dio.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sportsphere_mobile/features/home/data/rewards_repository.dart';
import 'package:sportsphere_mobile/features/home/domain/redemption_result.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late RewardsRepository repo;

  setUp(() {
    dio = _MockDio();
    registerFallbackValue(Options());
    repo = RewardsRepository(
      firestore: FakeFirebaseFirestore(),
      dio: dio,
    );
  });

  group('fetchMyVouchers', () {
    test('fetchMyVouchers success', () async {
      when(() => dio.get<Map<String, dynamic>>(
            '/api/player-app/rewards/my-vouchers',
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(
              path: '/api/player-app/rewards/my-vouchers',
            ),
            statusCode: 200,
            data: {
              'vouchers': [
                {
                  'id': 'voucher-uuid',
                  'code': 'SPHR-A1B2C3D4E5F6',
                  'rewardName': 'RM10 Store Voucher',
                  'discountValue': 'RM10',
                  'expiresAt': '2026-06-21T10:30:00Z',
                  'status': 'active',
                },
              ],
            },
          ));

      final result = await repo.fetchMyVouchers();

      expect(result.length, 1);
      expect(result[0].code, 'SPHR-A1B2C3D4E5F6');
      expect(result[0].isActive, true);
    });

    test('fetchMyVouchers returns empty list when no vouchers', () async {
      when(() => dio.get<Map<String, dynamic>>(
            '/api/player-app/rewards/my-vouchers',
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(
              path: '/api/player-app/rewards/my-vouchers',
            ),
            statusCode: 200,
            data: <String, dynamic>{'vouchers': <dynamic>[]},
          ));

      final result = await repo.fetchMyVouchers();

      expect(result, isEmpty);
    });

    test('fetchMyVouchers propagates DioException', () async {
      when(() => dio.get<Map<String, dynamic>>(
            '/api/player-app/rewards/my-vouchers',
          )).thenThrow(DioException(
        requestOptions: RequestOptions(
          path: '/api/player-app/rewards/my-vouchers',
        ),
        response: Response(
          requestOptions: RequestOptions(
            path: '/api/player-app/rewards/my-vouchers',
          ),
          statusCode: 500,
          data: {'error': 'Internal server error'},
        ),
        type: DioExceptionType.badResponse,
      ));

      expect(
        () => repo.fetchMyVouchers(),
        throwsA(isA<RewardsException>()),
      );
    });
  });
}
