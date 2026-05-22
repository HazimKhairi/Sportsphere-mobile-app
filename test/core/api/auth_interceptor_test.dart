import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sportsphere_mobile/core/api/auth_interceptor.dart';

class _MockUser extends Mock implements User {}

void main() {
  test('AuthInterceptor adds Authorization Bearer header with ID token', () async {
    final user = _MockUser();
    when(() => user.getIdToken(true)).thenAnswer((_) async => 'TEST_TOKEN');

    final interceptor = AuthInterceptor(currentUser: () => user);
    final options = RequestOptions(path: '/test');
    final handler = _CapturingRequestHandler();

    await interceptor.onRequest(options, handler);

    expect(options.headers['Authorization'], 'Bearer TEST_TOKEN');
  });
}

class _CapturingRequestHandler extends RequestInterceptorHandler {
  @override
  void next(RequestOptions requestOptions) {}
}
