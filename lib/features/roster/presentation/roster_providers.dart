import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/club_id_interceptor.dart';
import '../../../core/config/sphere_config.dart';
import '../../home/presentation/staff_home_providers.dart';
import '../data/roster_repository.dart';

part 'roster_providers.g.dart';

/// Holds the list of players + pagination cursor.
class RosterState {
  const RosterState({required this.players, this.nextCursor});

  final List<PlayerCard> players;
  final String? nextCursor;
}

// Shared interceptor — kept alive so setClubId updates propagate immediately.
@Riverpod(keepAlive: true)
ClubIdInterceptor rosterClubIdInterceptor(RosterClubIdInterceptorRef ref) {
  return ClubIdInterceptor();
}

@Riverpod(keepAlive: true)
RosterRepository rosterRepository(RosterRepositoryRef ref) {
  final interceptor = ref.watch(rosterClubIdInterceptorProvider);
  return RosterRepository(
    dio: buildApiClient(
      baseUrl: SphereConfig.apiBaseUrl,
      clubIdInterceptor: interceptor,
    ),
  );
}

@riverpod
class RosterNotifier extends _$RosterNotifier {
  @override
  Future<RosterState> build() async {
    final clubId = ref.watch(activeClubIdProvider).valueOrNull;

    // Keep the interceptor in sync so X-Club-Id is always up to date.
    ref
        .read(rosterClubIdInterceptorProvider)
        .setClubId(clubId);

    if (clubId == null) return const RosterState(players: []);

    final page = await ref
        .read(rosterRepositoryProvider)
        .listPlayers(clubId: clubId);
    return RosterState(players: page.players, nextCursor: page.nextCursor);
  }

  Future<void> loadMore() async {
    final clubId = ref.read(activeClubIdProvider).valueOrNull;
    if (clubId == null) return;
    final current = state.valueOrNull;
    if (current == null) return;
    if (current.nextCursor == null) return;
    final page = await ref
        .read(rosterRepositoryProvider)
        .listPlayers(clubId: clubId, cursor: current.nextCursor);
    state = AsyncData(RosterState(
      players: [...current.players, ...page.players],
      nextCursor: page.nextCursor,
    ));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

@riverpod
String rosterSearchQuery(RosterSearchQueryRef ref) => '';

@riverpod
Future<PlayerDetail> playerDetail(PlayerDetailRef ref,
    {required String playerId}) {
  return ref.watch(rosterRepositoryProvider).getPlayer(id: playerId);
}
