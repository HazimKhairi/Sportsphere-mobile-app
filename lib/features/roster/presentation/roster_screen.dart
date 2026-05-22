import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../domain/player_card.dart';
import 'roster_providers.dart';

class RosterScreen extends ConsumerStatefulWidget {
  const RosterScreen({super.key});

  @override
  ConsumerState<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends ConsumerState<RosterScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final rosterAsync = ref.watch(rosterNotifierProvider);

    return Scaffold(
      backgroundColor: SphereColors.surface,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                SphereSpacing.x24,
                SphereSpacing.x16,
                SphereSpacing.x24,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Roster',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(color: SphereColors.onSurface),
                        ),
                      ),
                      rosterAsync.whenOrNull(
                        data: (state) {
                          final count = state.players.length;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SphereSpacing.x12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: SphereColors.primary
                                  .withValues(alpha: 0.15),
                              borderRadius: SphereRadius.pillRect,
                            ),
                            child: Text(
                              '$count',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: SphereColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          );
                        },
                      ) ??
                          const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your club members',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SphereColors.onSurfaceMuted,
                        ),
                  ),
                  const SizedBox(height: SphereSpacing.x16),
                  _SearchBar(
                    onChanged: (q) => setState(() => _searchQuery = q),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: SphereSpacing.x12),
          Expanded(
            child: rosterAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: SphereColors.primary,
                ),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: SphereSpacing.x24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Could not load roster.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: SphereColors.onSurfaceMuted,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: SphereSpacing.x16),
                      TextButton(
                        onPressed: () =>
                            ref.refresh(rosterNotifierProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (state) {
                final query = _searchQuery.toLowerCase();
                final filtered = query.isEmpty
                    ? state.players
                    : state.players.where((p) {
                        return p.fullName.toLowerCase().contains(query) ||
                            p.position.toLowerCase().contains(query);
                      }).toList();

                if (filtered.isEmpty && query.isNotEmpty) {
                  return Center(
                    child: Text(
                      "No results for '$_searchQuery'.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: SphereColors.onSurfaceMuted,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No players in your club yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: SphereColors.onSurfaceMuted,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return _PlayerList(
                  players: filtered,
                  nextCursor: state.nextCursor,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: SphereColors.primary,
        foregroundColor: Colors.black,
        child: const Icon(LucideIcons.userPlus),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SphereColors.surfaceElev1,
        borderRadius: SphereRadius.pillRect,
        border: Border.all(color: SphereColors.borderSubtle),
      ),
      padding: const EdgeInsets.symmetric(horizontal: SphereSpacing.x16, vertical: 4),
      child: Row(
        children: [
          const Icon(
            LucideIcons.search,
            size: 16,
            color: SphereColors.onSurfaceMuted,
          ),
          const SizedBox(width: SphereSpacing.x8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Search players...',
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: SphereSpacing.x12),
                hintStyle: TextStyle(color: SphereColors.onSurfaceMuted),
              ),
              style: const TextStyle(color: SphereColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerList extends ConsumerWidget {
  const _PlayerList({required this.players, this.nextCursor});

  final List<PlayerCard> players;
  final String? nextCursor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: players.length + (nextCursor != null ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == players.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: SphereSpacing.x16),
            child: Center(
              child: TextButton(
                onPressed: () =>
                    ref.read(rosterNotifierProvider.notifier).loadMore(),
                child: const Text('Load more'),
              ),
            ),
          );
        }
        return _PlayerRow(player: players[i]);
      },
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player});

  final PlayerCard player;

  @override
  Widget build(BuildContext context) {
    final photoUrl = player.photoUrl;
    final initials =
        '${player.firstName.isNotEmpty ? player.firstName[0] : ''}'
        '${player.lastName.isNotEmpty ? player.lastName[0] : ''}'
            .toUpperCase();

    final subtitle = [player.position, player.teamName]
        .where((s) => s.isNotEmpty)
        .join(' · ');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: SphereSpacing.x24,
        vertical: SphereSpacing.x8,
      ),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: SphereColors.primary.withValues(alpha: 0.18),
        foregroundImage:
            photoUrl != null ? NetworkImage(photoUrl) : null,
        child: photoUrl == null
            ? Text(
                initials,
                style: const TextStyle(
                  color: SphereColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
      ),
      title: Text(
        player.fullName,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: SphereColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SphereColors.onSurfaceMuted,
                  ),
            )
          : null,
      trailing: const Icon(
        LucideIcons.chevronRight,
        size: 16,
        color: SphereColors.onSurfaceMuted,
      ),
      onTap: () => context.push('/staff/roster/${player.id}'),
    );
  }
}
