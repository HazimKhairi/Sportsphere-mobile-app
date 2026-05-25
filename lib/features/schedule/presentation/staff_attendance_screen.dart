import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/sphere_field_background.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/presentation/staff_home_providers.dart';
import '../data/attendance_repository.dart';

class StaffAttendanceScreen extends ConsumerStatefulWidget {
  const StaffAttendanceScreen({
    super.key,
    required this.sessionId,
    required this.clubId,
    required this.sessionName,
  });

  final String sessionId;
  final String clubId;
  final String sessionName;

  @override
  ConsumerState<StaffAttendanceScreen> createState() =>
      _StaffAttendanceScreenState();
}

class _StaffAttendanceScreenState extends ConsumerState<StaffAttendanceScreen> {
  final _repo = AttendanceRepository();
  String _clubId = '';

  List<PlayerAttendanceRecord>? _roster;
  Set<String> _presentIds = {};
  StreamSubscription<Set<String>>? _sub;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // widget.clubId may arrive empty if activeClubIdProvider hasn't resolved yet
    _clubId = widget.clubId;
    if (_clubId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _clubId = ref.read(activeClubIdProvider).valueOrNull ?? '';
        _init();
      });
    } else {
      _init();
    }
  }

  void _init() {
    _loadRoster();
    _sub = _repo
        .attendeesStream(clubId: _clubId, sessionId: widget.sessionId)
        .listen((ids) {
      if (mounted) setState(() => _presentIds = ids);
    });
  }

  Future<void> _loadRoster() async {
    if (_clubId.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final roster = await _repo.getRoster(
        clubId: _clubId,
        sessionId: widget.sessionId,
      );
      if (mounted) {
        setState(() {
          _roster = roster;
          _presentIds = roster
              .where((r) => r.isPresent)
              .map((r) => r.playerId)
              .toSet();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(PlayerAttendanceRecord record, bool markPresent) async {
    await _repo.toggleAttendance(
      clubId: _clubId,
      sessionId: widget.sessionId,
      playerId: record.playerId,
      markPresent: markPresent,
    );
  }

  Color _avatarColor(String name) {
    final hue = (name.codeUnits.fold(0, (a, b) => a + b) % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.55, 0.45).toColor();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;
    final roster = _roster;
    final presentCount = _presentIds.length;
    final totalCount = roster?.length ?? 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SphereFieldBackground(child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: SphereSpacing.x16, vertical: SphereSpacing.x12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: sc.onSurface,
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/schedule');
                      }
                    },
                  ),
                  const SizedBox(width: SphereSpacing.x8),
                  Expanded(
                    child: Text(
                      'Attendance · ${widget.sessionName}',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: sc.onSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: SphereSpacing.x16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey('$presentCount/$totalCount'),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: SphereSpacing.x16,
                    vertical: SphereSpacing.x12,
                  ),
                  decoration: BoxDecoration(
                    color: sc.surfaceElev1,
                    borderRadius: SphereRadius.cardRect,
                    border: Border.all(color: sc.borderSubtle),
                  ),
                  child: Text(
                    '$presentCount / $totalCount present',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: sc.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: SphereSpacing.x12),
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(color: sc.primary))
                  : roster == null || roster.isEmpty
                      ? Center(
                          child: Text(
                            AppLocalizations.of(context)!.noPlayersFound,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: sc.onSurfaceMuted),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: SphereSpacing.x16),
                          itemCount: roster.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: SphereSpacing.x8),
                          itemBuilder: (context, i) {
                            final record = roster[i];
                            final isPresent =
                                _presentIds.contains(record.playerId);
                            final initial = record.displayName.isNotEmpty
                                ? record.displayName[0].toUpperCase()
                                : '?';
                            final avatarColor = _avatarColor(record.displayName);

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SphereSpacing.x12,
                                vertical: SphereSpacing.x12,
                              ),
                              decoration: BoxDecoration(
                                color: sc.surfaceElev1,
                                borderRadius: SphereRadius.cardRect,
                                border: Border.all(color: sc.borderSubtle),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: avatarColor,
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: SphereSpacing.x12),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            record.displayName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: record.isMember
                                                      ? sc.onSurface
                                                      : sc.onSurfaceMuted,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (!record.isMember) ...[
                                          const SizedBox(
                                              width: SphereSpacing.x8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Unpaid',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    color: Colors.orange,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: isPresent,
                                    activeThumbColor: sc.success,
                                    onChanged: (val) => _toggle(record, val),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      )),
    );
  }
}
