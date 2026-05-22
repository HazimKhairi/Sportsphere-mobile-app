import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/activity_repository.dart';
import '../data/drill_repository.dart';
import '../data/player_home_repository.dart';
import '../domain/activity_item.dart';
import '../domain/player_streak.dart';
import '../domain/today_drill.dart';

part 'player_home_providers.g.dart';

@Riverpod(keepAlive: true)
PlayerHomeRepository playerHomeRepository(PlayerHomeRepositoryRef ref) {
  return PlayerHomeRepository();
}

@Riverpod(keepAlive: true)
DrillRepository drillRepository(DrillRepositoryRef ref) {
  return DrillRepository();
}

@Riverpod(keepAlive: true)
ActivityRepository activityRepository(ActivityRepositoryRef ref) {
  return ActivityRepository();
}

@riverpod
Stream<PlayerStreak> playerStreak(PlayerStreakRef ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) {
    return const Stream.empty();
  }
  return ref.watch(playerHomeRepositoryProvider).streakStream(playerId: user.uid);
}

@riverpod
Future<TodayDrill?> todayDrill(TodayDrillRef ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;
  return ref.read(drillRepositoryProvider).todayDrillFor(
        playerId: user.uid,
        date: DateTime.now(),
      );
}

@riverpod
Stream<List<ActivityItem>> activityTimeline(ActivityTimelineRef ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) {
    return const Stream.empty();
  }
  return ref.watch(activityRepositoryProvider).timelineStream(userId: user.uid);
}
