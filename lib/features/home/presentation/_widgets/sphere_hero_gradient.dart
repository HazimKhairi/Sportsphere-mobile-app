import 'package:flutter/material.dart';
import '../../../../app/theme/sphere_colors.dart';

class SphereHeroGradient extends StatefulWidget {
  const SphereHeroGradient({super.key, this.height = 220});
  final double height;

  @override
  State<SphereHeroGradient> createState() => _SphereHeroGradientState();
}

class _SphereHeroGradientState extends State<SphereHeroGradient>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          final dx = (0.5 - (t - 0.5).abs()) * 0.8 - 0.2;
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(dx, -0.8),
                radius: 1.4,
                colors: [
                  SphereColors.primary.withValues(alpha: 0.18),
                  SphereColors.primary.withValues(alpha: 0.05),
                  SphereColors.surface,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          );
        },
      ),
    );
  }
}
