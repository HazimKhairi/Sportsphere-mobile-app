import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../home/presentation/staff_home_providers.dart';
import '../data/training_plans_repository.dart';
import '../domain/training_plan.dart';

part 'training_plans_providers.g.dart';

@riverpod
TrainingPlansRepository trainingPlansRepository(TrainingPlansRepositoryRef ref) =>
    TrainingPlansRepository();

@riverpod
Stream<List<TrainingPlan>> assignedPlans(AssignedPlansRef ref) {
  final clubId = ref.watch(activeClubIdProvider).valueOrNull;
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (clubId == null || uid == null) return const Stream.empty();
  return ref
      .watch(trainingPlansRepositoryProvider)
      .assignedPlansStream(clubId: clubId, playerId: uid);
}

@riverpod
Future<List<PlanWeek>> planWeeks(PlanWeeksRef ref, String planId) async {
  final clubId = ref.watch(activeClubIdProvider).valueOrNull;
  if (clubId == null) return [];
  return ref
      .watch(trainingPlansRepositoryProvider)
      .weeksForPlan(clubId: clubId, planId: planId);
}
