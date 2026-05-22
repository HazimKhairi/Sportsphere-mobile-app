import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/fcm_repository.dart';

part 'fcm_providers.g.dart';

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
    await ref.read(fcmRepositoryProvider).registerDevice(
          token: token,
          platform: platform,
          appVersion: '${info.version}+${info.buildNumber}',
        );
  }
}
