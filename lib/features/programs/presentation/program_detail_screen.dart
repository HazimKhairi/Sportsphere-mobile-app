import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../coach/domain/coach_profile.dart';
import '../../coach/presentation/coach_providers.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import '../../payments/presentation/payment_method_sheet.dart';
import '../../payments/presentation/stripe_checkout_flow.dart';
import '../domain/program.dart';
import 'program_detail_providers.dart';
import 'registration_providers.dart';

class ProgramDetailScreen extends ConsumerStatefulWidget {
  const ProgramDetailScreen({super.key, required this.programId});
  final String programId;

  @override
  ConsumerState<ProgramDetailScreen> createState() =>
      _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends ConsumerState<ProgramDetailScreen> {
  bool _busy = false;

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/programs');
    }
  }

  Future<void> _register(Program program) async {
    setState(() => _busy = true);
    final method = await PaymentMethodSheet.show(context);
    if (!mounted) return;
    if (method == null) {
      setState(() => _busy = false);
      return;
    }
    if (method == PaymentMethod.cash) {
      if (!mounted) return;
      unawaited(context.push('/payment/cash/${program.id}'));
      setState(() => _busy = false);
      return;
    }
    // Card flow
    await runStripeCheckout(
      context: context,
      ref: ref,
      programId: program.id,
      amountCents: program.basePriceCents,
      currency: program.currency,
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync =
        ref.watch(programDetailProvider(programId: widget.programId));
    return Scaffold(
      backgroundColor: SphereColors.surface,
      body: detailAsync.when(
        data: (program) {
          if (program == null) return _NotFound(onBack: () => _back(context));
          final alreadyRegistered = ref
                  .watch(isRegisteredForProvider(programId: program.id))
                  .valueOrNull ??
              false;
          return _Content(
            program: program,
            formatDate: _formatDate,
            onBack: () => _back(context),
            onRegister: _busy ? null : () => _register(program),
            busy: _busy,
            alreadyRegistered: alreadyRegistered,
          );
        },
        loading: () => const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(SphereColors.primary),
            ),
          ),
        ),
        error: (_, _) => _NotFound(onBack: () => _back(context)),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({
    required this.program,
    required this.formatDate,
    required this.onBack,
    required this.onRegister,
    this.busy = false,
    this.alreadyRegistered = false,
  });
  final Program program;
  final String Function(DateTime) formatDate;
  final VoidCallback onBack;
  final VoidCallback? onRegister;
  final bool busy;
  final bool alreadyRegistered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachesAsync = ref.watch(myCoachesProvider);
    final hasCover =
        program.coverImageUrl != null && program.coverImageUrl!.isNotEmpty;
    return Stack(
      children: [
        // Hero image
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 280,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasCover)
                Image.network(
                  program.coverImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _gradient(),
                )
              else
                _gradient(),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      SphereColors.surface.withValues(alpha: 0.55),
                      Colors.transparent,
                      SphereColors.surface,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Back button overlay
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(SphereSpacing.x16),
            child: _CircleIconButton(
              icon: LucideIcons.chevronLeft,
              onTap: onBack,
            ),
          ),
        ),

        // Scrollable content
        Padding(
          padding: const EdgeInsets.only(bottom: 170),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 220),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SphereSpacing.x24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(SphereSpacing.x20),
                    decoration: BoxDecoration(
                      color: SphereColors.surfaceElev1,
                      borderRadius: SphereRadius.cardRect,
                      border: Border.all(color: SphereColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                SphereColors.primary.withValues(alpha: 0.18),
                            borderRadius: SphereRadius.pillRect,
                            border: Border.all(
                              color: SphereColors.primary
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            program.displayPrice,
                            style: const TextStyle(
                              color: SphereColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: SphereSpacing.x12),
                        Text(
                          program.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: SphereColors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        if (program.description.isNotEmpty) ...[
                          const SizedBox(height: SphereSpacing.x12),
                          Text(
                            program.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: SphereColors.onSurfaceMuted,
                                  height: 1.4,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: SphereSpacing.x24),
                  const SphereSectionLabel('Details'),
                  const SizedBox(height: SphereSpacing.x12),
                  _DetailRows(
                    rows: [
                      if (program.capacity != null)
                        (
                          'Capacity',
                          '${program.currentRegistrants}/${program.capacity}',
                        ),
                      if (program.registrationStart != null)
                        (
                          'Registration opens',
                          formatDate(program.registrationStart!),
                        ),
                      if (program.registrationEnd != null)
                        (
                          'Registration closes',
                          formatDate(program.registrationEnd!),
                        ),
                      ('Currency', program.currency),
                    ],
                  ),
                  const SizedBox(height: SphereSpacing.x16),

                  // Meet the Coaches
                  coachesAsync.when(
                    data: (coaches) {
                      if (coaches.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SphereSectionLabel('Meet the Coaches'),
                          const SizedBox(height: SphereSpacing.x12),
                          ...coaches.map(
                            (coach) => Padding(
                              padding: const EdgeInsets.only(bottom: SphereSpacing.x12),
                              child: _CoachCard(
                                coach: coach,
                                onTap: () => context.push(
                                  '/coach/${coach.id}',
                                  extra: coach,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, s) => const SizedBox.shrink(),
                  ),

                  // About the Club
                  const SizedBox(height: SphereSpacing.x8),
                  _AboutClubBanner(
                    onTap: () => context.push('/club'),
                  ),
                  const SizedBox(height: SphereSpacing.x16),
                ],
              ),
            ),
          ),
        ),

        // Sticky Register CTA
        Positioned(
          left: SphereSpacing.x16,
          right: SphereSpacing.x16,
          bottom: 110,
          child: SizedBox(
            height: 52,
            child: alreadyRegistered
                ? Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: SphereColors.primary.withValues(alpha: 0.18),
                      borderRadius: SphereRadius.pillRect,
                      border: Border.all(
                        color: SphereColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.check,
                            size: 18, color: SphereColors.primary),
                        SizedBox(width: 8),
                        Text(
                          "You're in",
                          style: TextStyle(
                            color: SphereColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: busy ? null : onRegister,
                    icon: busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(SphereColors.onPrimary),
                            ),
                          )
                        : const Icon(LucideIcons.userPlus, size: 18),
                    label: Text(busy ? 'Starting...' : 'Register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SphereColors.primary,
                      foregroundColor: SphereColors.onPrimary,
                      shape: const RoundedRectangleBorder(
                        borderRadius: SphereRadius.pillRect,
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _gradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F1F1F), Color(0xFF0F2A0F)],
        ),
      ),
      child: Center(
        child: Icon(
          LucideIcons.dumbbell,
          size: 80,
          color: SphereColors.primary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _DetailRows extends StatelessWidget {
  const _DetailRows({required this.rows});
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SphereSpacing.x16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: SphereColors.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: SphereColors.borderSubtle),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rows[i].$1,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: SphereColors.onSurfaceMuted,
                          ),
                    ),
                  ),
                  Text(
                    rows[i].$2,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SphereColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              const Divider(color: SphereColors.borderSubtle, height: 1),
          ],
        ],
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
      color: SphereColors.surfaceElev1.withValues(alpha: 0.85),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: SphereColors.onSurface),
        ),
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({required this.coach, required this.onTap});
  final CoachProfile coach;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials = coach.name.trim().isEmpty
        ? '?'
        : coach.name.trim().split(RegExp(r'\s+')).let((parts) =>
            parts.length == 1
                ? parts.first[0].toUpperCase()
                : '${parts.first[0]}${parts.last[0]}'.toUpperCase());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(SphereSpacing.x16),
        decoration: BoxDecoration(
          color: SphereColors.surfaceElev1,
          borderRadius: SphereRadius.cardRect,
          border: Border.all(color: SphereColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SphereColors.primary.withValues(alpha: 0.15),
              ),
              clipBehavior: Clip.antiAlias,
              child: coach.photoUrl != null && coach.photoUrl!.isNotEmpty
                  ? Image.network(
                      coach.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, e, s) => Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: SphereColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: SphereColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: SphereSpacing.x12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coach.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: SphereColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    coach.role,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SphereColors.onSurfaceMuted,
                        ),
                  ),
                  if (coach.yearsExperience != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${coach.yearsExperience} yrs experience'
                      '${coach.certificationsCount > 0 ? ' · ${coach.certificationsCount} cert${coach.certificationsCount > 1 ? 's' : ''}' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SphereColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 16, color: SphereColors.onSurfaceMuted),
          ],
        ),
      ),
    );
  }
}

class _AboutClubBanner extends StatelessWidget {
  const _AboutClubBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(SphereSpacing.x16),
        decoration: BoxDecoration(
          color: SphereColors.surfaceElev1,
          borderRadius: SphereRadius.cardRect,
          border: Border.all(color: SphereColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SphereColors.primary.withValues(alpha: 0.12),
              ),
              child: const Icon(LucideIcons.shield, size: 20, color: SphereColors.primary),
            ),
            const SizedBox(width: SphereSpacing.x12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About the Club',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: SphereColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    'View certifications, contact details and more',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SphereColors.onSurfaceMuted,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 16, color: SphereColors.onSurfaceMuted),
          ],
        ),
      ),
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(SphereSpacing.x24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CircleIconButton(icon: LucideIcons.chevronLeft, onTap: onBack),
            const SizedBox(height: SphereSpacing.x32),
            Text(
              'Program not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: SphereSpacing.x8),
            Text(
              'This program may have been removed or you no longer have access.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SphereColors.onSurfaceMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
