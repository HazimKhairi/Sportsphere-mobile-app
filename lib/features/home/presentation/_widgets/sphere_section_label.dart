import 'package:flutter/material.dart';
import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';

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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.sc.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.sc.onSurfaceMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}
