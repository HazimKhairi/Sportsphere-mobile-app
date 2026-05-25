import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_field_background.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/presentation/_widgets/sphere_entrance.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import '../../home/presentation/staff_home_providers.dart';
import '../../roster/domain/player_card.dart';
import '../../roster/presentation/roster_providers.dart';
import '../../strength/domain/workout_template.dart';
import 'staff_training_providers.dart';

final _assignedIdsProviderFamily =
    StreamProvider.family<List<String>, String>((ref, templateId) {
  final clubId = ref.watch(activeClubIdProvider).valueOrNull;
  if (clubId == null) return const Stream.empty();
  return ref.watch(staffTrainingRepositoryProvider).assignedPlayerIdsStream(
        clubId: clubId,
        collection: 'workoutTemplates',
        docId: templateId,
      );
});

class WorkoutTemplateDetailScreen extends ConsumerWidget {
  const WorkoutTemplateDetailScreen({super.key, required this.templateId});

  final String templateId;

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String? clubId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteTemplate),
        content: const Text(
            'This action cannot be undone. The template will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (clubId == null) return;

    await ref.read(staffTrainingRepositoryProvider).deleteWorkoutTemplate(
          clubId: clubId,
          templateId: templateId,
        );
    ref.invalidate(staffWorkoutTemplatesProvider);

    if (context.mounted) {
      context.pop(); // close detail
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(staffWorkoutTemplatesProvider);
    final clubIdAsync = ref.watch(activeClubIdProvider);
    final rosterAsync = ref.watch(rosterNotifierProvider);
    final assignedIdsAsync =
        ref.watch(_assignedIdsProviderFamily(templateId));

    final clubId = clubIdAsync.valueOrNull;

    final template = templatesAsync.valueOrNull
        ?.where((t) => t.id == templateId)
        .cast<WorkoutTemplate?>()
        .firstWhere((_) => true, orElse: () => null);

    if (template == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(onPressed: () => context.pop()),
        ),
        body: const SphereFieldBackground(child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(template.title),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            onPressed: () => _confirmDelete(context, ref, clubId),
            color: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
      body: SphereFieldBackground(child: SafeArea(
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
              SphereEntrance(
                delayMs: 0,
                child: SphereSectionLabel(
                    AppLocalizations.of(context)!.exercises),
              ),
              const SizedBox(height: SphereSpacing.x12),
              if (template.exercises.isEmpty)
                Text(
                  'No exercises.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.sc.onSurfaceMuted,
                      ),
                )
              else
                ...template.exercises
                    .map((e) => _ExerciseRow(exercise: e)),
              const SizedBox(height: SphereSpacing.x32),
              const SphereEntrance(
                delayMs: 80,
                child: SphereSectionLabel('Assigned Players'),
              ),
              const SizedBox(height: SphereSpacing.x12),
              SphereEntrance(
                delayMs: 160,
                child: _AssignmentSection(
                  templateId: templateId,
                  clubId: clubId,
                  assignedIdsAsync: assignedIdsAsync,
                  rosterAsync: rosterAsync,
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.exercise});

  final TemplateExercise exercise;

  @override
  Widget build(BuildContext context) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.exerciseId,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: context.sc.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${exercise.sets} sets × ${exercise.reps} reps',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.sc.onSurfaceMuted,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '${exercise.restSeconds}s rest',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentSection extends ConsumerStatefulWidget {
  const _AssignmentSection({
    required this.templateId,
    required this.clubId,
    required this.assignedIdsAsync,
    required this.rosterAsync,
  });

  final String templateId;
  final String? clubId;
  final AsyncValue<List<String>> assignedIdsAsync;
  final AsyncValue<RosterState> rosterAsync;

  @override
  ConsumerState<_AssignmentSection> createState() => _AssignmentSectionState();
}

class _AssignmentSectionState extends ConsumerState<_AssignmentSection> {
  final Set<String> _pending = {};

  Future<void> _toggle(
      String playerId, bool currentlyAssigned) async {
    if (widget.clubId == null) return;
    if (_pending.contains(playerId)) return;

    setState(() => _pending.add(playerId));

    try {
      final repo = ref.read(staffTrainingRepositoryProvider);
      if (currentlyAssigned) {
        await repo.unassignWorkoutTemplate(
          clubId: widget.clubId!,
          templateId: widget.templateId,
          playerIds: [playerId],
        );
      } else {
        await repo.assignWorkoutTemplate(
          clubId: widget.clubId!,
          templateId: widget.templateId,
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
        AppLocalizations.of(context)!.couldNotLoadPlayers,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.sc.onSurfaceMuted,
            ),
      );
    }

    final players = widget.rosterAsync.valueOrNull?.players ?? [];
    final assignedIds = widget.assignedIdsAsync.valueOrNull ?? [];

    if (players.isEmpty) {
      return Text(
        AppLocalizations.of(context)!.noPlayers,
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
