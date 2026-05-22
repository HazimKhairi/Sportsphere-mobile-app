import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../home/presentation/staff_home_providers.dart';
import '../domain/training_session.dart';
import 'schedule_providers.dart';

part 'session_detail_providers.g.dart';

@riverpod
Future<TrainingSession?> sessionDetail(
  SessionDetailRef ref, {
  required String sessionId,
}) async {
  final clubId = ref.watch(activeClubIdProvider).valueOrNull;
  if (clubId == null) return null;
  return ref.read(scheduleRepositoryProvider).sessionById(
        clubId: clubId,
        sessionId: sessionId,
      );
}
