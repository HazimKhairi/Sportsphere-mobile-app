import 'staff_next_session.dart';

class StaffDashboard {
  const StaffDashboard({
    required this.pendingApprovals,
    required this.sessionsToday,
    required this.rosterCount,
    this.nextSession,
  });
  final int pendingApprovals;
  final int sessionsToday;
  final int rosterCount;
  final StaffNextSession? nextSession;
}
