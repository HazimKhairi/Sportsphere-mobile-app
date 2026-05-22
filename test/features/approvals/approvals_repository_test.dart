import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sportsphere_mobile/features/approvals/data/approvals_repository.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late ApprovalsRepository repo;

  const pendingJson = {
    'pendingApproval': [
      {
        'id': 'pay_001',
        'payerName': 'Ahmad Zulkifli',
        'payerEmail': 'ahmad@example.com',
        'description': 'Program: Football U12',
        'base': 10000,
        'customerTotal': 10000,
        'currency': 'MYR',
        'paymentMethod': 'cash',
        'createdAt': {'_seconds': 1716000000},
      }
    ]
  };

  setUp(() {
    dio = _MockDio();
    registerFallbackValue(Options());
    repo = ApprovalsRepository(dio: dio);
  });

  // ── fetchPending ──────────────────────────────────────────────────────────

  test('fetchPending success — parses list correctly', () async {
    when(() => dio.get<Map<String, dynamic>>(
          '/api/admin/payments/pending',
          options: any(named: 'options'),
        )).thenAnswer((_) async => Response(
              requestOptions:
                  RequestOptions(path: '/api/admin/payments/pending'),
              statusCode: 200,
              data: pendingJson,
            ));

    final list = await repo.fetchPending(clubId: 'club_1');

    expect(list.length, 1);
    expect(list[0].payerName, 'Ahmad Zulkifli');
    expect(list[0].formattedAmount, 'MYR 100.00');
  });

  test('fetchPending passes X-Club-Id header', () async {
    when(() => dio.get<Map<String, dynamic>>(
          '/api/admin/payments/pending',
          options: any(named: 'options'),
        )).thenAnswer((_) async {
      // Capture and verify header via invocation
      final captured = verify(() => dio.get<Map<String, dynamic>>(
            '/api/admin/payments/pending',
            options: captureAny(named: 'options'),
          )).captured;
      // Verify the header is present
      final opts = captured.first as Options;
      expect(opts.headers?['X-Club-Id'], 'club_xyz');
      return Response(
        requestOptions: RequestOptions(path: '/api/admin/payments/pending'),
        statusCode: 200,
        data: const <String, dynamic>{'pendingApproval': <dynamic>[]},
      );
    });

    await repo.fetchPending(clubId: 'club_xyz');
  });

  test('fetchPending propagates ApprovalsException on 403', () async {
    when(() => dio.get<Map<String, dynamic>>(
          '/api/admin/payments/pending',
          options: any(named: 'options'),
        )).thenThrow(DioException(
      requestOptions: RequestOptions(path: '/api/admin/payments/pending'),
      response: Response(
        requestOptions: RequestOptions(path: '/api/admin/payments/pending'),
        statusCode: 403,
        data: {'error': 'Forbidden'},
      ),
      type: DioExceptionType.badResponse,
    ));

    expect(
      () => repo.fetchPending(clubId: 'club_1'),
      throwsA(isA<ApprovalsException>()),
    );
  });

  // ── approve ───────────────────────────────────────────────────────────────

  test('approve success — completes without throwing', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/admin/payments/pay1/approve',
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(
                  path: '/api/admin/payments/pay1/approve'),
              statusCode: 200,
              data: {'ok': true},
            ));

    await expectLater(
      repo.approve(paymentId: 'pay1', clubId: 'club_1'),
      completes,
    );
  });

  test('approve propagates ApprovalsException on 400', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/admin/payments/pay1/approve',
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenThrow(DioException(
      requestOptions:
          RequestOptions(path: '/api/admin/payments/pay1/approve'),
      response: Response(
        requestOptions:
            RequestOptions(path: '/api/admin/payments/pay1/approve'),
        statusCode: 400,
        data: {'error': 'Already processed'},
      ),
      type: DioExceptionType.badResponse,
    ));

    expect(
      () => repo.approve(paymentId: 'pay1', clubId: 'club_1'),
      throwsA(isA<ApprovalsException>()),
    );
  });

  // ── reject ────────────────────────────────────────────────────────────────

  test('reject success — completes without throwing', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/admin/payments/pay1/reject',
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => Response(
              requestOptions:
                  RequestOptions(path: '/api/admin/payments/pay1/reject'),
              statusCode: 200,
              data: {'ok': true},
            ));

    await expectLater(
      repo.reject(
          paymentId: 'pay1',
          clubId: 'club_1',
          reason: 'Wrong amount'),
      completes,
    );
  });

  test('reject propagates ApprovalsException on 400', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/admin/payments/pay1/reject',
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenThrow(DioException(
      requestOptions:
          RequestOptions(path: '/api/admin/payments/pay1/reject'),
      response: Response(
        requestOptions:
            RequestOptions(path: '/api/admin/payments/pay1/reject'),
        statusCode: 400,
        data: {'error': 'Invalid reason'},
      ),
      type: DioExceptionType.badResponse,
    ));

    expect(
      () => repo.reject(
          paymentId: 'pay1', clubId: 'club_1', reason: 'Wrong amount'),
      throwsA(isA<ApprovalsException>()),
    );
  });
}
