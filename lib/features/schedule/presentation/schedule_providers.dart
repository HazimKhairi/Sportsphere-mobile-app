import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../home/presentation/staff_home_providers.dart';
import '../../role_pick/presentation/role_providers.dart';
import '../data/schedule_repository.dart';
import '../domain/training_session.dart';

part 'schedule_providers.g.dart';

@Riverpod(keepAlive: true)
ScheduleRepository scheduleRepository(ScheduleRepositoryRef ref) {
  return ScheduleRepository();
}

/// Sessions for the visible calendar month (and a 1-month buffer either side
/// so paging is instant).
@riverpod
Stream<List<TrainingSession>> monthSessions(
  MonthSessionsRef ref, {
  required DateTime focusedMonth,
}) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  final clubId = ref.watch(activeClubIdProvider).valueOrNull;
  final role = ref.watch(selectedRoleProvider);
  if (user == null || clubId == null) {
    return const Stream.empty();
  }

  // Range: first day of previous month → first day of next-next month.
  final from = DateTime(focusedMonth.year, focusedMonth.month - 1, 1);
  final to = DateTime(focusedMonth.year, focusedMonth.month + 2, 1);

  final repo = ref.watch(scheduleRepositoryProvider);
  if (role == AppRole.staff) {
    return repo.clubSessionsStream(clubId: clubId, from: from, to: to);
  }
  return repo.playerSessionsStream(
    clubId: clubId,
    playerId: user.uid,
    from: from,
    to: to,
  );
}
