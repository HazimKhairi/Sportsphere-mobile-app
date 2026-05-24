import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../home/presentation/_widgets/sphere_entrance.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import '../../home/presentation/staff_home_providers.dart';
import '../../roster/domain/player_card.dart';
import '../../roster/presentation/roster_providers.dart';
import '../../training_plans/domain/training_plan.dart';
import 'staff_training_providers.dart';

final _assignedIdsForPlanFamily =
    StreamProvider.family<List<String>, String>((ref, planId) {
  final clubId = ref.watch(activeClubIdProvider).valueOrNull;
  if (clubId == null) return const Stream.empty();
  return ref.watch(staffTrainingRepositoryProvider).assignedPlayerIdsStream(
        clubId: clubId,
        collection: 'training_plans',
        docId: planId,
      );
});

class TrainingPlanDetailScreen extends ConsumerWidget {
  const TrainingPlanDetailScreen({super.key, required this.planId});

  final String planId;

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String? clubId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete plan?'),
        content: const Text(
            'This action cannot be undone. The plan will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (clubId == null) return;

    await ref.read(staffTrainingRepositoryProvider).deleteTrainingPlan(
          clubId: clubId,
          planId: planId,
        );
    ref.invalidate(staffTrainingPlansProvider);

    if (context.mounted) {
      context.pop(); // close detail
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(staffTrainingPlansProvider);
    final clubIdAsync = ref.watch(activeClubIdProvider);
    final rosterAsync = ref.watch(rosterNotifierProvider);
    final assignedIdsAsync = ref.watch(_assignedIdsForPlanFamily(planId));

    final clubId = clubIdAsync.valueOrNull;

    final plan = plansAsync.valueOrNull
        ?.where((p) => p.id == planId)
        .cast<TrainingPlan?>()
        .firstWhere((_) => true, orElse: () => null);

    if (plan == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
        ),
        body: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(plan.title),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            onPressed: () => _confirmDelete(context, ref, clubId),
            color: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            SphereSpacing.x24,
            SphereSpacing.x8,
            SphereSpacing.x24,
            SphereSpacing.bottomNavSafe,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SphereEntrance(
                delayMs: 0,
                child: SphereSectionLabel('Details'),
              ),
              const SizedBox(height: SphereSpacing.x12),
              SphereEntrance(
                delayMs: 40,
                child: _PlanInfoCard(plan: plan),
              ),
              const SizedBox(height: SphereSpacing.x32),
              const SphereEntrance(
                delayMs: 80,
                child: SphereSectionLabel('Assigned Players'),
              ),
              const SizedBox(height: SphereSpacing.x12),
              SphereEntrance(
                delayMs: 160,
                child: _AssignmentSection(
                  planId: planId,
                  clubId: clubId,
                  assignedIdsAsync: assignedIdsAsync,
                  rosterAsync: rosterAsync,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanInfoCard extends StatelessWidget {
  const _PlanInfoCard({required this.plan});

  final TrainingPlan plan;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              _PhaseBadge(phase: plan.phase),
              const Spacer(),
              Text(
                'Week ${plan.currentWeek} of ${plan.totalWeeks}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.sc.onSurfaceMuted,
                    ),
              ),
            ],
          ),
          if (plan.description.isNotEmpty) ...[
            const SizedBox(height: SphereSpacing.x12),
            Text(
              plan.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.sc.onSurface,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PhaseBadge extends StatelessWidget {
  const _PhaseBadge({required this.phase});

  final String phase;

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF3B82F6);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SphereSpacing.x8, vertical: 3),
      decoration: BoxDecoration(
        color: blue.withValues(alpha: 0.15),
        border: Border.all(color: blue.withValues(alpha: 0.4)),
        borderRadius: SphereRadius.pillRect,
      ),
      child: Text(
        phase.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: blue,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _AssignmentSection extends ConsumerStatefulWidget {
  const _AssignmentSection({
    required this.planId,
    required this.clubId,
    required this.assignedIdsAsync,
    required this.rosterAsync,
  });

  final String planId;
  final String? clubId;
  final AsyncValue<List<String>> assignedIdsAsync;
  final AsyncValue<RosterState> rosterAsync;

  @override
  ConsumerState<_AssignmentSection> createState() => _AssignmentSectionState();
}

class _AssignmentSectionState extends ConsumerState<_AssignmentSection> {
  final Set<String> _pending = {};

  Future<void> _toggle(String playerId, bool currentlyAssigned) async {
    if (widget.clubId == null) return;
    if (_pending.contains(playerId)) return;

    setState(() => _pending.add(playerId));

    try {
      final repo = ref.read(staffTrainingRepositoryProvider);
      if (currentlyAssigned) {
        await repo.unassignTrainingPlan(
          clubId: widget.clubId!,
          planId: widget.planId,
          playerIds: [playerId],
        );
      } else {
        await repo.assignTrainingPlan(
          clubId: widget.clubId!,
          planId: widget.planId,
          playerIds: [playerId],
        );
      }
    } finally {
      if (mounted) setState(() => _pending.remove(playerId));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rosterAsync.isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (widget.rosterAsync.hasError) {
      return Text(
        'Could not load players.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.sc.onSurfaceMuted,
            ),
      );
    }

    final players = widget.rosterAsync.valueOrNull?.players ?? [];
    final assignedIds = widget.assignedIdsAsync.valueOrNull ?? [];

    if (players.isEmpty) {
      return Text(
        'No players in roster.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.sc.onSurfaceMuted,
            ),
      );
    }

    return Column(
      children: players
          .map((p) => _PlayerAssignRow(
                player: p,
                isAssigned: assignedIds.contains(p.id),
                isPending: _pending.contains(p.id),
                onToggle: (val) => _toggle(p.id, assignedIds.contains(p.id)),
              ))
          .toList(),
    );
  }
}

class _PlayerAssignRow extends StatelessWidget {
  const _PlayerAssignRow({
    required this.player,
    required this.isAssigned,
    required this.isPending,
    required this.onToggle,
  });

  final PlayerCard player;
  final bool isAssigned;
  final bool isPending;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(player);

    return Container(
      margin: const EdgeInsets.only(bottom: SphereSpacing.x8),
      padding: const EdgeInsets.symmetric(
          horizontal: SphereSpacing.x16, vertical: SphereSpacing.x12),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: player.photoUrl != null
                ? NetworkImage(player.photoUrl!)
                : null,
            backgroundColor: context.sc.primary.withValues(alpha: 0.15),
            child: player.photoUrl == null
                ? Text(
                    initials,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: context.sc.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: SphereSpacing.x12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.fullName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: context.sc.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (player.position.isNotEmpty)
                  Text(
                    player.position,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
              ],
            ),
          ),
          isPending
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Checkbox(
                  value: isAssigned,
                  onChanged: (val) => onToggle(val ?? false),
                ),
        ],
      ),
    );
  }

  String _initials(PlayerCard p) {
    final parts = p.fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
  }
}
