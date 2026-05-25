import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../l10n/app_localizations.dart';

import '../../../app/theme/sphere_theme_ext.dart';
import '../../../app/locale_provider.dart';
import '../../../app/theme/sphere_field_background.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../home/presentation/_widgets/sphere_hero_gradient.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';

const _languages = [
  ('en', 'English', '🇬🇧'),
  ('ms', 'Bahasa Malaysia', '🇲🇾'),
];

class LanguagePickerScreen extends ConsumerWidget {
  const LanguagePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeNotifierProvider);
    final selected = locale.languageCode;

    return SphereFieldBackground(
      child: Stack(
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
                            padding: const EdgeInsets.all(10),
                            child: Icon(LucideIcons.chevronLeft,
                                size: 20, color: context.sc.onSurface),
                          ),
                        ),
                      ),
                      const SizedBox(width: SphereSpacing.x12),
                      Text(
                        AppLocalizations.of(context)!.language,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: SphereSpacing.x8),
                  Text(
                    AppLocalizations.of(context)!.languageSelectHint,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                  const SizedBox(height: SphereSpacing.x32),
                  SphereSectionLabel(AppLocalizations.of(context)!.availableLanguages),
                  const SizedBox(height: SphereSpacing.x12),
                  Container(
                    decoration: BoxDecoration(
                      color: context.sc.surfaceElev1,
                      borderRadius: SphereRadius.cardRect,
                      border: Border.all(color: context.sc.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < _languages.length; i++) ...[
                          _LangOption(
                            code: _languages[i].$1,
                            label: _languages[i].$2,
                            badge: _languages[i].$3,
                            selected: selected == _languages[i].$1,
                            onTap: () => ref
                                .read(localeNotifierProvider.notifier)
                                .setLocale(_languages[i].$1),
                          ),
                          if (i < _languages.length - 1)
                            Divider(
                                color: context.sc.borderSubtle, height: 1),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.code,
    required this.label,
    required this.badge,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final String label;
  final String badge;
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
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: selected
                    ? context.sc.primary.withValues(alpha: 0.18)
                    : context.sc.surfaceElev2,
                border: Border.all(
                  color: selected
                      ? context.sc.primary.withValues(alpha: 0.5)
                      : context.sc.borderSubtle,
                ),
              ),
              child: Text(badge, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: SphereSpacing.x12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.sc.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (selected)
              Icon(LucideIcons.check, size: 16, color: context.sc.primary),
          ],
        ),
      ),
    );
  }
}
