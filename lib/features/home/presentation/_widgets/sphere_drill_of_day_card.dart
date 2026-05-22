import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../app/theme/sphere_colors.dart';
import '../../../../app/theme/sphere_radius.dart';
import '../../../../app/theme/sphere_spacing.dart';

class SphereDrillOfDayCard extends StatelessWidget {
  const SphereDrillOfDayCard({
    super.key,
    this.onTap,
    this.drillName = 'Juggle 50 reps',
    this.drillSubtitle = '5 min · level 2 ball control',
    this.loading = false,
  });
  final VoidCallback? onTap;
  final String drillName;
  final String drillSubtitle;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final bool hasDrill = drillName.isNotEmpty;
    final String resolvedTitle = hasDrill ? drillName : 'Coming soon';
    final String resolvedSubtitle =
        hasDrill ? drillSubtitle : 'New drill drops tomorrow.';

    return Material(
      color: Colors.transparent,
      borderRadius: SphereRadius.cardRect,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: SphereRadius.cardRect,
        child: Container(
          height: 180,
          padding: const EdgeInsets.all(SphereSpacing.x20),
          decoration: BoxDecoration(
            borderRadius: SphereRadius.cardRect,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1F1F1F),
                Color(0xFF0F2A0F),
              ],
            ),
            border: Border.all(color: SphereColors.borderSubtle),
          ),
          child: Stack(
            children: [
              const Positioned(
                right: -10,
                top: -10,
                child: Opacity(
                  opacity: 0.08,
                  child: Icon(
                    LucideIcons.dumbbell,
                    size: 180,
                    color: SphereColors.primary,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: SphereColors.primary.withValues(alpha: 0.18),
                      borderRadius: SphereRadius.pillRect,
                      border: Border.all(
                        color: SphereColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      'TODAY’S DRILL',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SphereColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 1.2,
                          ),
                    ),
                  ),
                  const Spacer(),
                  if (loading) ...[
                    Container(
                      width: 200,
                      height: 24,
                      decoration: BoxDecoration(
                        color: SphereColors.surfaceElev2,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 140,
                      height: 14,
                      decoration: BoxDecoration(
                        color: SphereColors.surfaceElev2,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ] else ...[
                    Text(
                      resolvedTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: SphereColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      resolvedSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: SphereColors.onSurfaceMuted,
                          ),
                    ),
                  ],
                  const SizedBox(height: SphereSpacing.x16),
                  Row(
                    children: [
                      Opacity(
                        opacity: loading ? 0.5 : 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: const BoxDecoration(
                            color: SphereColors.primary,
                            borderRadius: SphereRadius.pillRect,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.play, size: 14, color: SphereColors.onPrimary),
                              const SizedBox(width: 6),
                              Text(
                                'Start',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: SphereColors.onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
