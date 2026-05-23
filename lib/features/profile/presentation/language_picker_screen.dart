import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../home/presentation/_widgets/sphere_hero_gradient.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';

const _languages = [
  ('en', 'English', '🇬🇧'),
  ('ms', 'Bahasa Malaysia', '🇲🇾'),
];

class LanguagePickerScreen extends StatefulWidget {
  const LanguagePickerScreen({super.key});

  @override
  State<LanguagePickerScreen> createState() => _LanguagePickerScreenState();
}

class _LanguagePickerScreenState extends State<LanguagePickerScreen> {
  String _selected = 'en';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _selected = prefs.getString('app_language') ?? 'en');
  }

  Future<void> _select(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', code);
    setState(() => _selected = code);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            code == 'ms'
                ? 'Bahasa Malaysia akan digunakan dalam kemaskini akan datang.'
                : 'English selected.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        color: SphereColors.surfaceElev1,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () => context.canPop()
                              ? context.pop()
                              : context.go('/profile'),
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(LucideIcons.chevronLeft,
                                size: 20, color: SphereColors.onSurface),
                          ),
                        ),
                      ),
                      const SizedBox(width: SphereSpacing.x12),
                      Text(
                        'Language',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: SphereSpacing.x8),
                  Text(
                    'Select your preferred display language.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SphereColors.onSurfaceMuted,
                        ),
                  ),
                  const SizedBox(height: SphereSpacing.x32),
                  const SphereSectionLabel('Available languages'),
                  const SizedBox(height: SphereSpacing.x12),
                  Container(
                    decoration: BoxDecoration(
                      color: SphereColors.surfaceElev1,
                      borderRadius: SphereRadius.cardRect,
                      border: Border.all(color: SphereColors.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < _languages.length; i++) ...[
                          _LangOption(
                            code: _languages[i].$1,
                            label: _languages[i].$2,
                            badge: _languages[i].$3,
                            selected: _selected == _languages[i].$1,
                            onTap: () => _select(_languages[i].$1),
                          ),
                          if (i < _languages.length - 1)
                            const Divider(
                                color: SphereColors.borderSubtle, height: 1),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: SphereSpacing.x24),
                  Container(
                    padding: const EdgeInsets.all(SphereSpacing.x16),
                    decoration: BoxDecoration(
                      color: SphereColors.primary.withValues(alpha: 0.08),
                      borderRadius: SphereRadius.cardRect,
                      border: Border.all(
                          color: SphereColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.info,
                            size: 16, color: SphereColors.primary),
                        const SizedBox(width: SphereSpacing.x12),
                        Expanded(
                          child: Text(
                            'Full Bahasa Malaysia localisation is coming in the next update. Some UI elements will remain in English.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: SphereColors.primary),
                          ),
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
                    ? SphereColors.primary.withValues(alpha: 0.18)
                    : SphereColors.surfaceElev2,
                border: Border.all(
                  color: selected
                      ? SphereColors.primary.withValues(alpha: 0.5)
                      : SphereColors.borderSubtle,
                ),
              ),
              child: Text(
                badge,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: SphereSpacing.x12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SphereColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (selected)
              const Icon(LucideIcons.check,
                  size: 16, color: SphereColors.primary),
          ],
        ),
      ),
    );
  }
}
