import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/sphere_config.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/nutrition_repository.dart';

part 'nutrition_providers.g.dart';

@riverpod
NutritionRepository nutritionRepository(NutritionRepositoryRef ref) {
  return NutritionRepository(
    dio: buildApiClient(baseUrl: SphereConfig.apiBaseUrl),
  );
}

@riverpod
Stream<List<NutritionLog>> todayNutritionLogs(TodayNutritionLogsRef ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(nutritionRepositoryProvider).todayLogsStream(uid);
}

@riverpod
DailySummary todayNutritionSummary(TodayNutritionSummaryRef ref) {
  final logs = ref.watch(todayNutritionLogsProvider).valueOrNull ?? [];
  final today = _todayStr();
  return DailySummary.fromLogs(today, logs);
}

@riverpod
Stream<List<NutritionLog>> recentNutritionLogs(RecentNutritionLogsRef ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(nutritionRepositoryProvider).recentLogsStream(uid);
}

String _todayStr() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}
