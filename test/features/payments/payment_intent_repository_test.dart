import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sportsphere_mobile/features/payments/data/payment_intent_repository.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late PaymentIntentRepository repo;

  setUp(() {
    dio = _MockDio();
    registerFallbackValue(Options());
    repo = PaymentIntentRepository(dio: dio);
  });

  test('createPaymentIntent posts amount + programId + currency', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/payments/create-payment-intent',
          data: any(named: 'data'),
        )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/api/payments/create-payment-intent'),
              statusCode: 200,
              data: {
                'clientSecret': 'pi_secret_abc',
                'paymentIntentId': 'pi_abc',
              },
            ));

    final intent = await repo.createPaymentIntent(
      programId: 'prog_1',
      amountCents: 15050,
      currency: 'MYR',
    );

    expect(intent.clientSecret, 'pi_secret_abc');
    expect(intent.paymentIntentId, 'pi_abc');
    verify(() => dio.post<Map<String, dynamic>>(
          '/api/payments/create-payment-intent',
          data: {
            'programId': 'prog_1',
            'amount': 15050,
            'currency': 'MYR',
          },
        )).called(1);
  });

  test('default currency is MYR', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/payments/create-payment-intent',
          data: any(named: 'data'),
        )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/api/payments/create-payment-intent'),
              statusCode: 200,
              data: {'clientSecret': 'x', 'paymentIntentId': 'y'},
            ));

    await repo.createPaymentIntent(programId: 'p', amountCents: 100);

    verify(() => dio.post<Map<String, dynamic>>(
          '/api/payments/create-payment-intent',
          data: {
            'programId': 'p',
            'amount': 100,
            'currency': 'MYR',
          },
        )).called(1);
  });

  test('throws PaymentIntentException on 4xx error', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/payments/create-payment-intent',
          data: any(named: 'data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/payments/create-payment-intent'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/payments/create-payment-intent'),
            statusCode: 400,
            data: {'error': 'Invalid program'},
          ),
          type: DioExceptionType.badResponse,
        ));

    expect(
      () => repo.createPaymentIntent(programId: 'bad', amountCents: 100),
      throwsA(isA<PaymentIntentException>()),
    );
  });

  test('throws PaymentIntentException on network failure', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/payments/create-payment-intent',
          data: any(named: 'data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/payments/create-payment-intent'),
          type: DioExceptionType.connectionError,
        ));

    expect(
      () => repo.createPaymentIntent(programId: 'p', amountCents: 100),
      throwsA(isA<PaymentIntentException>()),
    );
  });
}
