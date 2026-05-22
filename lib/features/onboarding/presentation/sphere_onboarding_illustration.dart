import 'package:flutter/material.dart';

import '../../../app/theme/sphere_colors.dart';

class SphereOnboardingIllustration extends StatefulWidget {
  const SphereOnboardingIllustration({super.key, required this.icon});

  final IconData icon;

  @override
  State<SphereOnboardingIllustration> createState() =>
      _SphereOnboardingIllustrationState();
}

class _SphereOnboardingIllustrationState extends State<SphereOnboardingIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_pulse.value);
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse ring
              Container(
                width: 220 + t * 16,
                height: 220 + t * 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SphereColors.primary.withValues(alpha: 0.05 + t * 0.05),
                ),
              ),
              // Middle ring
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SphereColors.primary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: SphereColors.primary.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
              ),
              // Solid green disc
              Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: SphereColors.primary,
                ),
                child: Icon(
                  widget.icon,
                  size: 64,
                  color: SphereColors.onPrimary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
