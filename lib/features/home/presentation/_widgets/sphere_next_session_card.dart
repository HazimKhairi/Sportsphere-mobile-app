import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../app/theme/sphere_colors.dart';
import '../../../../app/theme/sphere_radius.dart';
import '../../../../app/theme/sphere_spacing.dart';
import '../../domain/staff_next_session.dart';

class SphereNextSessionCard extends StatefulWidget {
  const SphereNextSessionCard({
    super.key,
    this.session,
    this.loading = false,
    this.onCheckIn,
  });
  final StaffNextSession? session;
  final bool loading;
  final VoidCallback? onCheckIn;

  @override
  State<SphereNextSessionCard> createState() => _SphereNextSessionCardState();
}

class _SphereNextSessionCardState extends State<SphereNextSessionCard> {
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
    if (diff.isNegative) return 'Starts now';
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    if (h == 0) return 'Starts in ${m}m';
    return 'Starts in ${h}h ${m}m';
  }

  String _formatTime(DateTime t) {
    final hour24 = t.hour;
    final hour12 = hour24 == 0
        ? 12
        : (hour24 > 12 ? hour24 - 12 : hour24);
    final minute = t.minute.toString().padLeft(2, '0');
    final suffix = hour24 >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SphereSpacing.x20),
      decoration: BoxDecoration(
        color: SphereColors.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: SphereColors.borderSubtle),
      ),
      child: widget.loading
          ? _buildLoading(context)
          : (widget.session == null
              ? _buildEmpty(context)
              : _buildSession(context, widget.session!)),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.clock,
                size: 14, color: SphereColors.onSurfaceMuted),
            const SizedBox(width: 6),
            Text(
              'Loading…',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SphereColors.onSurfaceMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
            ),
          ],
        ),
        const SizedBox(height: SphereSpacing.x12),
        Text(
          '--',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: SphereColors.onSurfaceMuted,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Fetching your next session…',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: SphereColors.onSurfaceMuted,
              ),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.calendar,
                size: 14, color: SphereColors.onSurfaceMuted),
            const SizedBox(width: 6),
            Text(
              'No schedule',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SphereColors.onSurfaceMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
            ),
          ],
        ),
        const SizedBox(height: SphereSpacing.x12),
        Text(
          'No upcoming sessions',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: SphereColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Check back later.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: SphereColors.onSurfaceMuted,
              ),
        ),
      ],
    );
  }

  Widget _buildSession(BuildContext context, StaffNextSession session) {
    final locationLine = session.location.isEmpty
        ? _formatTime(session.startTime)
        : '${_formatTime(session.startTime)} · ${session.location}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.clock,
                size: 14, color: SphereColors.primary),
            const SizedBox(width: 6),
            Text(
              _countdown(session.startTime),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SphereColors.primary,
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
                color: SphereColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(LucideIcons.mapPin,
                size: 14, color: SphereColors.onSurfaceMuted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                locationLine,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SphereColors.onSurfaceMuted,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: SphereSpacing.x20),
        SizedBox(
          height: 48,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.onCheckIn,
            icon: const Icon(LucideIcons.qrCode, size: 18),
            label: const Text('QR Check-in'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SphereColors.primary,
              foregroundColor: SphereColors.onPrimary,
              shape: const RoundedRectangleBorder(
                  borderRadius: SphereRadius.pillRect),
            ),
          ),
        ),
      ],
    );
  }
}
