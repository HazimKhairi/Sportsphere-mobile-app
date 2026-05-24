import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../home/presentation/staff_home_providers.dart';
import '../../strength/domain/workout_template.dart';
import '../../training_plans/domain/training_plan.dart';
import '../data/staff_training_repository.dart';

part 'staff_training_providers.g.dart';

@Riverpod(keepAlive: true)
StaffTrainingRepository staffTrainingRepository(StaffTrainingRepositoryRef ref) {
  return StaffTrainingRepository();
}

@riverpod
Stream<List<WorkoutTemplate>> staffWorkoutTemplates(StaffWorkoutTemplatesRef ref) {
  final clubId = ref.watch(activeClubIdProvider).valueOrNull;
  if (clubId == null) return const Stream.empty();
  return ref.watch(staffTrainingRepositoryProvider).workoutTemplatesStream(clubId);
}

@riverpod
Stream<List<TrainingPlan>> staffTrainingPlans(StaffTrainingPlansRef ref) {
  final clubId = ref.watch(activeClubIdProvider).valueOrNull;
  if (clubId == null) return const Stream.empty();
  return ref.watch(staffTrainingRepositoryProvider).trainingPlansStream(clubId);
}
