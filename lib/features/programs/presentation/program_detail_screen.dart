import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import '../domain/program.dart';
import 'program_detail_providers.dart';

class ProgramDetailScreen extends ConsumerWidget {
  const ProgramDetailScreen({super.key, required this.programId});
  final String programId;

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/programs');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(programDetailProvider(programId: programId));
    return Scaffold(
      backgroundColor: SphereColors.surface,
      body: detailAsync.when(
        data: (program) {
          if (program == null) return _NotFound(onBack: () => _back(context));
          return _Content(
            program: program,
            formatDate: _formatDate,
            onBack: () => _back(context),
            onRegister: () {
              // TODO C3: replace with payment-method bottom sheet flow
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment flow lands in C3.')),
              );
            },
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

class _Content extends StatelessWidget {
  const _Content({
    required this.program,
    required this.formatDate,
    required this.onBack,
    required this.onRegister,
  });
  final Program program;
  final String Function(DateTime) formatDate;
  final VoidCallback onBack;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
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
            child: ElevatedButton.icon(
              onPressed: onRegister,
              icon: const Icon(LucideIcons.userPlus, size: 18),
              label: const Text('Register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SphereColors.primary,
                foregroundColor: SphereColors.onPrimary,
                shape: const RoundedRectangleBorder(
                  borderRadius: SphereRadius.pillRect,
                ),
                elevation: 0,
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
