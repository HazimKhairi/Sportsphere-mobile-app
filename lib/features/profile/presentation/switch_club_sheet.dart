import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../home/presentation/staff_home_providers.dart';
import 'club_membership_providers.dart';

class SwitchClubSheet extends ConsumerStatefulWidget {
  const SwitchClubSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const SwitchClubSheet(),
    );
  }

  @override
  ConsumerState<SwitchClubSheet> createState() => _SwitchClubSheetState();
}

class _SwitchClubSheetState extends ConsumerState<SwitchClubSheet> {
  String? _busyClubId;

  @override
  Widget build(BuildContext context) {
    final memberships = ref.watch(myClubMembershipsProvider);
    final activeClubId = ref.watch(activeClubIdProvider).valueOrNull;

    return Container(
      decoration: const BoxDecoration(
        color: SphereColors.surfaceElev2,
        borderRadius: SphereRadius.sheetTop,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SphereSpacing.x24,
            SphereSpacing.x16,
            SphereSpacing.x24,
            SphereSpacing.x24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: SphereSpacing.x16),
                  decoration: BoxDecoration(
                    color: SphereColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Switch club',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Pick the club you want active.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SphereColors.onSurfaceMuted,
                    ),
              ),
              const SizedBox(height: SphereSpacing.x24),

              memberships.when(
                data: (list) {
                  if (list.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'You are not in any clubs yet.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: SphereColors.onSurfaceMuted,
                            ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final m in list) ...[
                        _ClubRow(
                          clubName: m.clubName,
                          role: m.role,
                          selected: m.clubId == activeClubId,
                          busy: _busyClubId == m.clubId,
                          onTap: () => _switchTo(m.clubId),
                        ),
                        const SizedBox(height: SphereSpacing.x8),
                      ],
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(SphereColors.primary),
                      ),
                    ),
                  ),
                ),
                error: (_, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Couldn’t load your clubs.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SphereColors.onSurfaceMuted,
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

  Future<void> _switchTo(String clubId) async {
    setState(() => _busyClubId = clubId);
    try {
      await ref
          .read(clubMembershipRepositoryProvider)
          .setActiveClub(clubId: clubId);
      // Invalidate streams so home rebuilds with new active club.
      ref.invalidate(activeClubIdProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Couldn’t switch club: $e')),
        );
        setState(() => _busyClubId = null);
      }
    }
  }
}

class _ClubRow extends StatelessWidget {
  const _ClubRow({
    required this.clubName,
    required this.role,
    required this.selected,
    required this.busy,
    required this.onTap,
  });

  final String clubName;
  final String role;
  final bool selected;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? SphereColors.primary.withValues(alpha: 0.12)
          : SphereColors.surfaceElev1,
      borderRadius: SphereRadius.cardRect,
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: SphereRadius.cardRect,
        child: Container(
          padding: const EdgeInsets.all(SphereSpacing.x16),
          decoration: BoxDecoration(
            borderRadius: SphereRadius.cardRect,
            border: Border.all(
              color: selected
                  ? SphereColors.primary.withValues(alpha: 0.5)
                  : SphereColors.borderSubtle,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SphereColors.primary.withValues(alpha: 0.18),
                ),
                child: const Icon(
                  LucideIcons.building2,
                  size: 18,
                  color: SphereColors.primary,
                ),
              ),
              const SizedBox(width: SphereSpacing.x12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clubName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: SphereColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SphereColors.onSurfaceMuted,
                            letterSpacing: 0.6,
                          ),
                    ),
                  ],
                ),
              ),
              if (busy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(SphereColors.primary),
                  ),
                )
              else if (selected)
                const Icon(
                  LucideIcons.check,
                  size: 18,
                  color: SphereColors.primary,
                )
              else
                const Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: SphereColors.onSurfaceMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
