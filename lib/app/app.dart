import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/domain/app_user.dart';
import '../features/auth/presentation/auth_providers.dart';
import '../features/notifications/presentation/fcm_providers.dart';
import '../features/role_pick/presentation/role_providers.dart';
import 'router.dart';
import 'theme/sphere_theme.dart';
import 'theme/theme_provider.dart';

class SphereApp extends ConsumerStatefulWidget {
  const SphereApp({super.key});

  @override
  ConsumerState<SphereApp> createState() => _SphereAppState();
}

class _SphereAppState extends ConsumerState<SphereApp> {
  StreamSubscription<RemoteMessage>? _fcmSub;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(selectedRoleProvider.notifier).load();
      ref.read(themeModeNotifierProvider.notifier).load();
    });
    _initFcmHandlers();
  }

  void _initFcmHandlers() {
    // Foreground messages — show an in-app snackbar with a tap-to-scan action.
    _fcmSub = FirebaseMessaging.onMessage.listen(_handleMessage);

    // App opened from a background notification tap.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // App launched from a terminated state via notification.
    FirebaseMessaging.instance.getInitialMessage().then((msg) {
      if (msg != null) _handleMessage(msg);
    });
  }

  void _handleMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;
    final sessionId = data['sessionId'] as String?;

    if (type == 'session_start' && sessionId != null && sessionId.isNotEmpty) {
      final router = ref.read(routerProvider);
      router.push('/qr-scan/$sessionId');
    }
  }

  @override
  void dispose() {
    _fcmSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);

    ref.listen<AsyncValue<AppUser?>>(currentUserProvider, (prev, next) {
      next.whenData((user) {
        if (user != null) {
          ref.read(fcmBootstrapProvider);
        }
      });
    });

    return MaterialApp.router(
      title: 'SportSphere',
      debugShowCheckedModeBanner: false,
      theme: buildSphereLightTheme(),
      darkTheme: buildSphereDarkTheme(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
