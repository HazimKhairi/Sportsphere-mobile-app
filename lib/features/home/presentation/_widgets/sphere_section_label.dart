import 'package:flutter/material.dart';
import '../../../../app/theme/sphere_colors.dart';

class SphereSectionLabel extends StatelessWidget {
  const SphereSectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: SphereColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: SphereColors.onSurfaceMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}
