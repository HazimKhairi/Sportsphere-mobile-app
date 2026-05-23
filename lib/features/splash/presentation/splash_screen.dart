import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    // Wait for pulse, remove native splash, then navigate.
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      try {
        FlutterNativeSplash.remove();
      } catch (_) {
        // No-op in widget tests where the native splash was never preserved.
      }
      context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.sc.surface,
      body: Center(
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(
            CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(
            opacity: _ctrl,
            child: Image.asset(
              'assets/brand/app_icon.png',
              width: 120,
              height: 120,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}
