import 'package:dio/dio.dart';

/// Interceptor that injects the active club ID as `X-Club-Id` header.
/// Call [setClubId] whenever the active club changes.
class ClubIdInterceptor extends Interceptor {
  String? _clubId;

  void setClubId(String? clubId) => _clubId = clubId;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final id = _clubId;
    if (id != null && id.isNotEmpty) {
      options.headers['X-Club-Id'] = id;
    }
    handler.next(options);
  }
}
