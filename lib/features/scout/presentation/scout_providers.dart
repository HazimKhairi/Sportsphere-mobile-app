import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/sphere_config.dart';
import '../data/scout_repository.dart';
import '../domain/scouting_profile.dart';

part 'scout_providers.g.dart';

@Riverpod(keepAlive: true)
ScoutRepository scoutRepository(ScoutRepositoryRef ref) {
  return ScoutRepository(
    dio: buildApiClient(baseUrl: SphereConfig.apiBaseUrl),
  );
}

@riverpod
class ScoutProfileNotifier extends _$ScoutProfileNotifier {
  @override
  Future<ScoutingProfile?> build() async {
    return ref.read(scoutRepositoryProvider).fetchMyProfile();
  }

  Future<void> save(ScoutingProfile profile) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(scoutRepositoryProvider).saveProfile(profile),
    );
  }

  Future<void> toggleVisibility() async {
    final current = state.valueOrNull;
    if (current == null) return;
    final next = current.isOpen ? 'hidden' : 'open';
    state = const AsyncLoading();
    try {
      final saved = await ref
          .read(scoutRepositoryProvider)
          .saveProfile(current.copyWith(visibility: next));
      state = AsyncData(saved);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(scoutRepositoryProvider).fetchMyProfile(),
    );
  }
}
