import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sportsphere_mobile/features/payments/data/cash_payment_repository.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late CashPaymentRepository repo;

  setUp(() {
    dio = _MockDio();
    registerFallbackValue(Options());
    repo = CashPaymentRepository(dio: dio);
  });

  test('declarePayment POSTs to /api/payments/cash/declare with programId + amount', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/payments/cash/declare',
          data: any(named: 'data'),
        )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/api/payments/cash/declare'),
              statusCode: 200,
              data: {'paymentId': 'pay_abc', 'status': 'PENDING_APPROVAL'},
            ));

    final result = await repo.declarePayment(
      programId: 'prog_1',
      amountCents: 15050,
      currency: 'MYR',
    );

    expect(result.paymentId, 'pay_abc');
    expect(result.status, 'PENDING_APPROVAL');
    verify(() => dio.post<Map<String, dynamic>>(
          '/api/payments/cash/declare',
          data: {
            'programId': 'prog_1',
            'amount': 15050,
            'currency': 'MYR',
          },
        )).called(1);
  });

  test('default currency is MYR', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/payments/cash/declare',
          data: any(named: 'data'),
        )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/api/payments/cash/declare'),
              statusCode: 200,
              data: {'paymentId': 'x', 'status': 'PENDING_APPROVAL'},
            ));

    await repo.declarePayment(programId: 'p', amountCents: 100);

    verify(() => dio.post<Map<String, dynamic>>(
          '/api/payments/cash/declare',
          data: {'programId': 'p', 'amount': 100, 'currency': 'MYR'},
        )).called(1);
  });

  test('throws CashDeclarationException on 4xx', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/payments/cash/declare',
          data: any(named: 'data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/payments/cash/declare'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/payments/cash/declare'),
            statusCode: 400,
            data: {'error': 'Invalid program'},
          ),
          type: DioExceptionType.badResponse,
        ));

    expect(
      () => repo.declarePayment(programId: 'bad', amountCents: 100),
      throwsA(isA<CashDeclarationException>()),
    );
  });
}
