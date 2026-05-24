import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../home/presentation/_widgets/sphere_entrance.dart';
import '../../home/presentation/_widgets/sphere_hero_gradient.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import '../domain/program.dart';
import 'programs_providers.dart';

class ProgramsListScreen extends ConsumerWidget {
  const ProgramsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final programsAsync = ref.watch(publishedProgramsProvider);

    return Stack(
      children: [
        const Positioned(top: 0, left: 0, right: 0, child: SphereHeroGradient()),
        SafeArea(
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
                SphereEntrance(
                  delayMs: 0,
                  child: Row(
                    children: [
                      _CircleIconButton(
                        icon: LucideIcons.chevronLeft,
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        },
                      ),
                      const SizedBox(width: SphereSpacing.x12),
                      Expanded(
                        child: Text(
                          l.programs,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: context.sc.onSurface,
                                height: 1.1,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SphereSpacing.x8),
                SphereEntrance(
                  delayMs: 80,
                  child: Text(
                    l.findSession,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                ),
                const SizedBox(height: SphereSpacing.x32),

                SphereEntrance(
                  delayMs: 140,
                  child: SphereSectionLabel(l.openForRegistration),
                ),
                const SizedBox(height: SphereSpacing.x16),

                programsAsync.when(
                  data: (programs) {
                    if (programs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(SphereSpacing.x20),
                        decoration: BoxDecoration(
                          color: context.sc.surfaceElev1,
                          borderRadius: SphereRadius.cardRect,
                          border: Border.all(color: context.sc.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nothing open right now',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: context.sc.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l.checkBackLater,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: context.sc.onSurfaceMuted,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (var i = 0; i < programs.length; i++) ...[
                          SphereEntrance(
                            delayMs: 200 + i * 50,
                            child: _ProgramCard(program: programs[i]),
                          ),
                          if (i < programs.length - 1)
                            const SizedBox(height: SphereSpacing.x12),
                        ],
                      ],
                    );
                  },
                  loading: () => Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(context.sc.primary),
                        ),
                      ),
                    ),
                  ),
                  error: (_, _) => Text(
                    l.noPrograms,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.program});
  final Program program;

  bool get _hasCover =>
      program.coverImageUrl != null && program.coverImageUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.sc.surfaceElev1,
      borderRadius: SphereRadius.cardRect,
      child: InkWell(
        onTap: () => context.push('/programs/${program.id}'),
        borderRadius: SphereRadius.cardRect,
        child: Container(
          decoration: BoxDecoration(
            color: context.sc.surfaceElev1,
            borderRadius: SphereRadius.cardRect,
            border: Border.all(color: context.sc.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: _CoverArt(program: program, hasCover: _hasCover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(SphereSpacing.x16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            program.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: context.sc.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: SphereSpacing.x8),
                        _PriceChip(text: program.displayPrice),
                      ],
                    ),
                    if (program.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        program.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.sc.onSurfaceMuted,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: SphereSpacing.x12),
                    Row(
                      children: [
                        if (program.capacity != null) ...[
                          Icon(
                            LucideIcons.users,
                            size: 14,
                            color: context.sc.onSurfaceMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${program.currentRegistrants}/${program.capacity}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: context.sc.onSurfaceMuted,
                                ),
                          ),
                          const Spacer(),
                        ] else
                          const Spacer(),
                        Icon(
                          LucideIcons.arrowRight,
                          size: 18,
                          color: context.sc.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverArt extends StatelessWidget {
  const _CoverArt({required this.program, required this.hasCover});
  final Program program;
  final bool hasCover;

  @override
  Widget build(BuildContext context) {
    if (hasCover) {
      return Image.network(
        program.coverImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _gradient(context),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _gradient(context),
      );
    }
    return _gradient(context);
  }

  Widget _gradient(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1F1F1F),
            Color(0xFF0F2A0F),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          LucideIcons.dumbbell,
          size: 48,
          color: context.sc.primary.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.sc.primary.withValues(alpha: 0.18),
        borderRadius: SphereRadius.pillRect,
        border: Border.all(color: context.sc.primary.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: context.sc.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.sc.surfaceElev1,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: context.sc.onSurface),
        ),
      ),
    );
  }
}
