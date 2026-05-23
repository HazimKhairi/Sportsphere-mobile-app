import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../home/presentation/_widgets/sphere_avatar_stack.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import '../domain/training_session.dart';
import 'session_detail_providers.dart';

class SessionDetailScreen extends ConsumerStatefulWidget {
  const SessionDetailScreen({super.key, required this.sessionId});
  final String sessionId;

  @override
  ConsumerState<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _countdown(DateTime start) {
    final diff = start.difference(DateTime.now());
    if (diff.isNegative) {
      final mins = (-diff).inMinutes;
      if (mins < 60) return 'Started $mins min ago';
      return 'Started ${(mins / 60).floor()}h ago';
    }
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    if (h == 0) return 'Starts in ${m}m';
    return 'Starts in ${h}h ${m}m';
  }

  String _formattedDate(DateTime dt) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final h12 = dt.hour == 0
        ? 12
        : dt.hour > 12
            ? dt.hour - 12
            : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '${weekdays[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} · $h12:$m $period';
  }

  String _statusFor(DateTime start) {
    final diff = start.difference(DateTime.now());
    if (diff.isNegative && diff.inMinutes.abs() < 120) return 'In progress';
    if (diff.isNegative) return 'Ended';
    if (diff.inHours < 24) return 'Today';
    if (diff.inHours < 48) return 'Tomorrow';
    return 'Upcoming';
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/schedule');
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(
      sessionDetailProvider(sessionId: widget.sessionId),
    );

    return Scaffold(
      backgroundColor: context.sc.surface,
      body: SafeArea(
        bottom: false,
        child: detailAsync.when(
          data: (session) {
            if (session == null) {
              return _NotFound(onBack: () => _back(context));
            }
            return _Content(
              session: session,
              countdown: _countdown(session.startTime),
              formattedDate: _formattedDate(session.startTime),
              status: _statusFor(session.startTime),
              onBack: () => _back(context),
              onCheckIn: () => context.push('/qr-scan/${session.id}'),
            );
          },
          loading: () => Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(context.sc.primary),
              ),
            ),
          ),
          error: (_, _) => _NotFound(onBack: () => _back(context)),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.session,
    required this.countdown,
    required this.formattedDate,
    required this.status,
    required this.onBack,
    required this.onCheckIn,
  });

  final TrainingSession session;
  final String countdown;
  final String formattedDate;
  final String status;
  final VoidCallback onBack;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    final attendees = session.attendees;
    return Stack(
      children: [
        Padding(
          // Reserve space for nav bar (90) + sticky CTA (~72)
          padding: const EdgeInsets.only(bottom: 170),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              SphereSpacing.x16,
              SphereSpacing.x8,
              SphereSpacing.x16,
              SphereSpacing.x24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _CircleIconButton(icon: LucideIcons.chevronLeft, onTap: onBack),
                    const SizedBox(width: SphereSpacing.x12),
                    Text(
                      'Session',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: context.sc.onSurfaceMuted,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: SphereSpacing.x16),

                Container(
                  padding: const EdgeInsets.all(SphereSpacing.x20),
                  decoration: BoxDecoration(
                    color: context.sc.surfaceElev1,
                    borderRadius: SphereRadius.cardRect,
                    border: Border.all(color: context.sc.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.clock, size: 14, color: context.sc.primary),
                          const SizedBox(width: 6),
                          Text(
                            countdown,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: context.sc.primary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SphereSpacing.x12),
                      Text(
                        session.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: context.sc.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.sc.onSurfaceMuted,
                            ),
                      ),
                      if (session.location.isNotEmpty) ...[
                        const SizedBox(height: SphereSpacing.x12),
                        Row(
                          children: [
                            Icon(LucideIcons.mapPin, size: 14, color: context.sc.onSurfaceMuted),
                            const SizedBox(width: 6),
                            Text(
                              session.location,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: context.sc.onSurface,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: SphereSpacing.x24),
                const SphereSectionLabel('Details'),
                const SizedBox(height: SphereSpacing.x12),
                _DetailRows(
                  rows: [
                    ('Players expected', '${attendees.length}'),
                    ('Status', status),
                  ],
                ),

                if (attendees.isNotEmpty) ...[
                  const SizedBox(height: SphereSpacing.x24),
                  const SphereSectionLabel('Players'),
                  const SizedBox(height: SphereSpacing.x12),
                  Container(
                    padding: const EdgeInsets.all(SphereSpacing.x16),
                    decoration: BoxDecoration(
                      color: context.sc.surfaceElev1,
                      borderRadius: SphereRadius.cardRect,
                      border: Border.all(color: context.sc.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        SphereAvatarStack(total: attendees.length),
                        const SizedBox(width: SphereSpacing.x12),
                        Expanded(
                          child: Text(
                            attendees.length == 1
                                ? '1 player expected'
                                : '${attendees.length} players expected',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: context.sc.onSurface,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        Positioned(
          left: SphereSpacing.x16,
          right: SphereSpacing.x16,
          bottom: 110, // sits above the floating navbar (which lives ~20px from screen bottom, ~70px tall)
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onCheckIn,
              icon: const Icon(LucideIcons.qrCode, size: 18),
              label: const Text('QR Check-in'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.sc.primary,
                foregroundColor: context.sc.onPrimary,
                shape: const RoundedRectangleBorder(borderRadius: SphereRadius.pillRect),
                elevation: 0,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRows extends StatelessWidget {
  const _DetailRows({required this.rows});
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SphereSpacing.x16, vertical: 8),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rows[i].$1,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.sc.onSurfaceMuted,
                          ),
                    ),
                  ),
                  Text(
                    rows[i].$2,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.sc.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              Divider(color: context.sc.borderSubtle, height: 1),
          ],
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.sc.surfaceElev1,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: context.sc.onSurface),
        ),
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SphereSpacing.x24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CircleIconButton(icon: LucideIcons.chevronLeft, onTap: onBack),
          const SizedBox(height: SphereSpacing.x32),
          Text(
            'Session not found',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: SphereSpacing.x8),
          Text(
            'This session may have been removed or you no longer have access.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.sc.onSurfaceMuted,
                ),
          ),
        ],
      ),
    );
  }
}
