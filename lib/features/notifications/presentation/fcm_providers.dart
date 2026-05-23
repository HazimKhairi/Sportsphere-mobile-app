import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/sphere_config.dart';
import '../data/fcm_repository.dart';

part 'fcm_providers.g.dart';

const _kFcmTokenKey = 'fcm_token';

@Riverpod(keepAlive: true)
FcmRepository fcmRepository(FcmRepositoryRef ref) {
  return FcmRepository(dio: buildApiClient(baseUrl: SphereConfig.apiBaseUrl));
}

@Riverpod(keepAlive: true)
class FcmBootstrap extends _$FcmBootstrap {
  @override
  Future<void> build() async {
    final fm = FirebaseMessaging.instance;
    final settings = await fm.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;
    final token = await fm.getToken();
    if (token == null) return;
    await ref.read(fcmRepositoryProvider).registerToken(token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFcmTokenKey, token);
  }
}

/// Best-effort: unregister FCM token on logout.
@riverpod
Future<void> Function() fcmLogoutCleanup(FcmLogoutCleanupRef ref) {
  return () async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_kFcmTokenKey);
      if (token != null) {
        try {
          await ref.read(fcmRepositoryProvider).unregisterToken(token);
        } catch (_) {}
        await prefs.remove(_kFcmTokenKey);
      }
    } catch (_) {}
  };
}
