import 'package:flutter/material.dart';

class SphereFieldBackground extends StatelessWidget {
  const SphereFieldBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          right: -60,
          bottom: 80,
          child: Opacity(
            opacity: 0.07,
            child: Image.asset(
              'assets/brand/app_icon.png',
              width: 380,
              height: 380,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
