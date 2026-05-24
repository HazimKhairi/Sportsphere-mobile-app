import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import 'role_providers.dart';

class RolePickScreen extends ConsumerWidget {
  const RolePickScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.sc.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SphereSpacing.x24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: SphereSpacing.x8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleIconButton(
                    icon: LucideIcons.chevronLeft,
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/onboarding');
                      }
                    },
                  ),
                  SizedBox(
                    height: 28,
                    child: Image.asset(
                      'assets/brand/sphere_wordmark.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SphereSpacing.x32),
              Text(
                AppLocalizations.of(context)!.pickYourRole,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: context.sc.onSurface,
                    ),
              ),
              const SizedBox(height: SphereSpacing.x8),
              Text(
                'You can switch this later in Settings.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.sc.onSurfaceMuted,
                    ),
              ),
              const SizedBox(height: SphereSpacing.x32),
              _RoleHeroCard(
                icon: LucideIcons.user,
                title: AppLocalizations.of(context)!.player,
                subtitle: AppLocalizations.of(context)!.playerDescription,
                onTap: () async {
                  await ref
                      .read(selectedRoleProvider.notifier)
                      .set(AppRole.player);
                  if (context.mounted) context.go('/auth/login');
                },
              ),
              const SizedBox(height: SphereSpacing.x16),
              _RoleHeroCard(
                icon: LucideIcons.userCog,
                title: AppLocalizations.of(context)!.staff,
                subtitle: AppLocalizations.of(context)!.staffDescription,
                onTap: () async {
                  await ref
                      .read(selectedRoleProvider.notifier)
                      .set(AppRole.staff);
                  if (context.mounted) context.go('/auth/login');
                },
              ),
              const Spacer(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: SphereSpacing.x16),
                  child: Text(
                    'Welcome to your academy.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                ),
              ),
            ],
          ),
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
      color: context.sc.surfaceElev1.withValues(alpha: 0.85),
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

class _RoleHeroCard extends StatefulWidget {
  const _RoleHeroCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<_RoleHeroCard> createState() => _RoleHeroCardState();
}

class _RoleHeroCardState extends State<_RoleHeroCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(SphereSpacing.x20),
        decoration: BoxDecoration(
          color: _pressed
              ? context.sc.surfaceElev2
              : context.sc.surfaceElev1,
          borderRadius: SphereRadius.cardRect,
          border: Border.all(
            color: _pressed
                ? context.sc.primary.withValues(alpha: 0.4)
                : context.sc.borderSubtle,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _RoleIconBadge(icon: widget.icon),
            const SizedBox(width: SphereSpacing.x16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: context.sc.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SphereSpacing.x8),
            Icon(
              LucideIcons.arrowRight,
              size: 22,
              color: context.sc.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleIconBadge extends StatelessWidget {
  const _RoleIconBadge({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.sc.primary.withValues(alpha: 0.12),
        border: Border.all(
          color: context.sc.primary.withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      child: Icon(icon, size: 30, color: context.sc.primary),
    );
  }
}
