import 'package:flutter/material.dart';

class SphereFieldBackground extends StatelessWidget {
  const SphereFieldBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/brand/field_bg.webp',
          fit: BoxFit.cover,
          color: Colors.black.withValues(alpha: 0.50),
          colorBlendMode: BlendMode.darken,
        ),
        child,
      ],
    );
  }
}
