import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../home/presentation/staff_home_providers.dart';
import '../data/strength_repository.dart';
import '../domain/workout_template.dart';

part 'strength_providers.g.dart';

@riverpod
StrengthRepository strengthRepository(StrengthRepositoryRef ref) =>
    StrengthRepository();

@riverpod
Stream<List<WorkoutTemplate>> assignedWorkouts(AssignedWorkoutsRef ref) {
  final clubId = ref.watch(activeClubIdProvider).valueOrNull;
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (clubId == null || uid == null) return const Stream.empty();
  return ref
      .watch(strengthRepositoryProvider)
      .assignedTemplatesStream(clubId: clubId, playerId: uid);
}
