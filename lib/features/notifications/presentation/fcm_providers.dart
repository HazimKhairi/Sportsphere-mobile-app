import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api/api_client.dart';
import '../data/fcm_repository.dart';

part 'fcm_providers.g.dart';

const _kFcmDeviceIdKey = 'fcm_device_id';

@Riverpod(keepAlive: true)
FcmRepository fcmRepository(FcmRepositoryRef ref) {
  return FcmRepository(dio: buildApiClient(baseUrl: 'https://sprtsphr.app'));
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
    final info = await PackageInfo.fromPlatform();
    final platform = Platform.isIOS ? 'ios' : 'android';
    final deviceId = await ref.read(fcmRepositoryProvider).registerDevice(
          token: token,
          platform: platform,
          appVersion: '${info.version}+${info.buildNumber}',
        );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFcmDeviceIdKey, deviceId);
  }
}

/// Best-effort: read the persisted deviceId, call unregisterDevice, clear pref.
/// Never throws — logout must always succeed locally.
@riverpod
Future<void> Function() fcmLogoutCleanup(FcmLogoutCleanupRef ref) {
  return () async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString(_kFcmDeviceIdKey);
      if (deviceId != null) {
        try {
          await ref.read(fcmRepositoryProvider).unregisterDevice(deviceId);
        } catch (_) {
          // Server unreachable: keep local cleanup going.
        }
        await prefs.remove(_kFcmDeviceIdKey);
      }
    } catch (_) {
      // Even reading prefs failed — log nothing, continue.
    }
  };
}
