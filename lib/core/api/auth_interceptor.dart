import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({User? Function()? currentUser})
      : _currentUser = currentUser ?? (() => FirebaseAuth.instance.currentUser);

  final User? Function() _currentUser;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final user = _currentUser();
    if (user != null) {
      final token = await user.getIdToken(true);
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
