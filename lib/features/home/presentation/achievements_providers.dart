import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/achievements_repository.dart';
import '../domain/achievement.dart';

part 'achievements_providers.g.dart';

@Riverpod(keepAlive: true)
AchievementsRepository achievementsRepository(
  AchievementsRepositoryRef ref,
) {
  return AchievementsRepository();
}

@riverpod
Stream<List<Achievement>> myAchievements(MyAchievementsRef ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  return ref.watch(achievementsRepositoryProvider).streamForPlayer(
        playerId: user.uid,
      );
}
