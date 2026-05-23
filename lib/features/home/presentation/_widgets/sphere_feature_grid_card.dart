import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../../app/theme/sphere_radius.dart';
import '../../../../app/theme/sphere_spacing.dart';

const double _kCardBlur = 20.0;

class SphereFeatureGridCard extends StatelessWidget {
  const SphereFeatureGridCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    this.metricWidget,
    this.loading = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
  final Widget? metricWidget;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: SphereRadius.cardRect,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _kCardBlur, sigmaY: _kCardBlur),
        child: GestureDetector(
          onTap: loading ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(SphereSpacing.x16),
            decoration: BoxDecoration(
              color: context.sc.surfaceElev1.withValues(alpha: 0.60),
              borderRadius: SphereRadius.cardRect,
              border: Border(
                top: BorderSide(
                  color: accentColor.withValues(alpha: 0.40),
                ),
                left: BorderSide(
                  color: accentColor.withValues(alpha: 0.40),
                ),
                right: BorderSide(
                  color: context.sc.onSurface.withValues(alpha: 0.08),
                ),
                bottom: BorderSide(
                  color: context.sc.onSurface.withValues(alpha: 0.08),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.15),
                  blurRadius: _kCardBlur,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: SphereSpacing.x24,
                  color: accentColor,
                ),
                const Spacer(),
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.sc.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.geist(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: context.sc.onSurfaceMuted,
                  ),
                ),
                if (metricWidget != null) ...[
                  const SizedBox(height: 4),
                  metricWidget!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SphereGridProgressBar extends StatelessWidget {
  const SphereGridProgressBar({
    super.key,
    required this.value,
    required this.color,
  });

  /// Progress value between 0.0 and 1.0.
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, animatedValue, _) {
        return ClipRRect(
          borderRadius: SphereRadius.pillRect,
          child: LinearProgressIndicator(
            value: animatedValue,
            minHeight: 4,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );
      },
    );
  }
}
