import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/theme_provider.dart';
import '../../home/presentation/_widgets/sphere_hero_gradient.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';

class ThemePickerScreen extends ConsumerWidget {
  const ThemePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeModeNotifierProvider);

    return Stack(
      children: [
        const Positioned(top: 0, left: 0, right: 0, child: SphereHeroGradient()),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                SphereSpacing.x24,
                SphereSpacing.x16,
                SphereSpacing.x24,
                90,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Material(
                        color: context.sc.surfaceElev1,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () => context.canPop()
                              ? context.pop()
                              : context.go('/profile'),
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(LucideIcons.chevronLeft,
                                size: 20, color: context.sc.onSurface),
                          ),
                        ),
                      ),
                      const SizedBox(width: SphereSpacing.x12),
                      Text(
                        'Theme',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: SphereSpacing.x8),
                  Text(
                    'Choose your preferred appearance.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                  const SizedBox(height: SphereSpacing.x32),
                  const SphereSectionLabel('Appearance'),
                  const SizedBox(height: SphereSpacing.x12),
                  Container(
                    decoration: BoxDecoration(
                      color: context.sc.surfaceElev1,
                      borderRadius: SphereRadius.cardRect,
                      border: Border.all(color: context.sc.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        _ThemeOption(
                          icon: LucideIcons.moon,
                          label: 'Dark',
                          subtitle: 'Easy on the eyes',
                          selected: currentMode == ThemeMode.dark,
                          onTap: () => ref
                              .read(themeModeNotifierProvider.notifier)
                              .setMode(ThemeMode.dark),
                        ),
                        Divider(color: context.sc.borderSubtle, height: 1),
                        _ThemeOption(
                          icon: LucideIcons.sun,
                          label: 'Light',
                          subtitle: 'Bright and clean',
                          selected: currentMode == ThemeMode.light,
                          onTap: () => ref
                              .read(themeModeNotifierProvider.notifier)
                              .setMode(ThemeMode.light),
                        ),
                        Divider(color: context.sc.borderSubtle, height: 1),
                        _ThemeOption(
                          icon: LucideIcons.smartphone,
                          label: 'System',
                          subtitle: 'Follows your device setting',
                          selected: currentMode == ThemeMode.system,
                          onTap: () => ref
                              .read(themeModeNotifierProvider.notifier)
                              .setMode(ThemeMode.system),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SphereSpacing.x16,
          vertical: SphereSpacing.x12,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? context.sc.primary.withValues(alpha: 0.18)
                    : context.sc.surfaceElev2,
                border: Border.all(
                  color: selected
                      ? context.sc.primary.withValues(alpha: 0.5)
                      : context.sc.borderSubtle,
                ),
              ),
              child: Icon(
                icon,
                size: 18,
                color: selected
                    ? context.sc.primary
                    : context.sc.onSurfaceMuted,
              ),
            ),
            const SizedBox(width: SphereSpacing.x12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.sc.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(LucideIcons.check,
                  size: 16, color: context.sc.primary),
          ],
        ),
      ),
    );
  }
}
