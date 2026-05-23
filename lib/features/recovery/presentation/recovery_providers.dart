import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/recovery_repository.dart';
import '../domain/recovery_content.dart';
import '../domain/recovery_log.dart';

part 'recovery_providers.g.dart';

@riverpod
RecoveryRepository recoveryRepository(RecoveryRepositoryRef ref) =>
    RecoveryRepository();

@riverpod
Stream<RecoveryLog?> todayRecoveryLog(TodayRecoveryLogRef ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(recoveryRepositoryProvider).todayLogStream(uid);
}

@riverpod
Stream<List<RecoveryLog>> recentRecoveryLogs(RecentRecoveryLogsRef ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(recoveryRepositoryProvider).recentLogsStream(uid);
}

@riverpod
Stream<List<RecoveryContent>> recoveryContent(RecoveryContentRef ref) {
  return ref.watch(recoveryRepositoryProvider).contentStream();
}

@riverpod
Stream<List<RecoveryContent>> nutritionContent(NutritionContentRef ref) {
  return ref
      .watch(recoveryRepositoryProvider)
      .contentStream(category: 'nutrition');
}
