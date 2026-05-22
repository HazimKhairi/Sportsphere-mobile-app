import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/active_club_repository.dart';
import '../data/staff_home_repository.dart';
import '../domain/staff_next_session.dart';

part 'staff_home_providers.g.dart';

@Riverpod(keepAlive: true)
ActiveClubRepository activeClubRepository(ActiveClubRepositoryRef ref) {
  return ActiveClubRepository();
}

@Riverpod(keepAlive: true)
StaffHomeRepository staffHomeRepository(StaffHomeRepositoryRef ref) {
  return StaffHomeRepository();
}

@riverpod
Stream<String?> activeClubId(ActiveClubIdRef ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref
      .watch(activeClubRepositoryProvider)
      .activeClubIdStream(userId: user.uid);
}

@riverpod
Stream<int> staffPendingApprovals(StaffPendingApprovalsRef ref) {
  final clubId = ref.watch(activeClubIdProvider).valueOrNull;
  if (clubId == null) return Stream.value(0);
  return ref
      .watch(staffHomeRepositoryProvider)
      .pendingApprovalsCountStream(clubId: clubId);
}

@riverpod
Stream<StaffNextSession?> staffNextSession(StaffNextSessionRef ref) {
  final clubId = ref.watch(activeClubIdProvider).valueOrNull;
  if (clubId == null) return Stream.value(null);
  return ref.watch(staffHomeRepositoryProvider).nextSessionStream(
        clubId: clubId,
        after: DateTime.now(),
      );
}

@riverpod
Stream<int> staffSessionsToday(StaffSessionsTodayRef ref) {
  final clubId = ref.watch(activeClubIdProvider).valueOrNull;
  if (clubId == null) return Stream.value(0);
  return ref.watch(staffHomeRepositoryProvider).sessionsTodayCountStream(
        clubId: clubId,
        today: DateTime.now(),
      );
}

@riverpod
Stream<int> staffRosterCount(StaffRosterCountRef ref) {
  final clubId = ref.watch(activeClubIdProvider).valueOrNull;
  if (clubId == null) return Stream.value(0);
  return ref
      .watch(staffHomeRepositoryProvider)
      .rosterCountStream(clubId: clubId);
}
