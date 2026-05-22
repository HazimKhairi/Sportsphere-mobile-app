import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/sphere_colors.dart';

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

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) context.go('/onboarding');
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
      backgroundColor: SphereColors.surface,
      body: Center(
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(
            CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(
            opacity: _ctrl,
            child: Image.asset(
              'assets/brand/sphere_icon.png',
              width: 96,
              height: 96,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}
