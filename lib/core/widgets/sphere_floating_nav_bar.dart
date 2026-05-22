import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/sphere_colors.dart';
import '../../app/theme/sphere_spacing.dart';

class SphereFloatingNavBar extends StatelessWidget {
  const SphereFloatingNavBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  final List<SphereNavTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SphereSpacing.x16,
          0,
          SphereSpacing.x16,
          SphereSpacing.x20,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                color: SphereColors.surfaceElev1.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x80000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (var i = 0; i < tabs.length; i++)
                      _NavTab(
                        tab: tabs[i],
                        active: i == currentIndex,
                        onTap: () => onTap(i),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SphereNavTab {
  const SphereNavTab({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final SphereNavTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? SphereColors.primary : SphereColors.onSurfaceMuted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: active ? 1.0 : 0.92,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              child: Icon(tab.icon, size: 24, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: GoogleFonts.geist(
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
