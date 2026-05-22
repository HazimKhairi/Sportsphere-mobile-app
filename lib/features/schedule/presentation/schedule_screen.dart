import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../domain/training_session.dart';
import 'schedule_providers.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatTime(DateTime dt) {
    final h = dt.hour == 0
        ? 12
        : dt.hour > 12
            ? dt.hour - 12
            : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(monthSessionsProvider(focusedMonth: _focusedDay));

    return Scaffold(
      backgroundColor: SphereColors.surface,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SphereSpacing.x24,
                  SphereSpacing.x16,
                  SphereSpacing.x24,
                  SphereSpacing.x8,
                ),
                child: Text(
                  'Schedule',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: SphereSpacing.x16),
                child: Container(
                  decoration: BoxDecoration(
                    color: SphereColors.surfaceElev1,
                    borderRadius: SphereRadius.cardRect,
                    border: Border.all(color: SphereColors.borderSubtle),
                  ),
                  padding: const EdgeInsets.all(SphereSpacing.x8),
                  child: sessionsAsync.when(
                    data: (sessions) => _buildCalendar(sessions),
                    loading: () => _buildCalendar(const []),
                    error: (_, _) => _buildCalendar(const []),
                  ),
                ),
              ),
              const SizedBox(height: SphereSpacing.x24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: SphereSpacing.x24),
                child: _DaySessionsList(
                  selectedDay: _selectedDay,
                  asyncSessions: sessionsAsync,
                  formatTime: _formatTime,
                  sameDay: _sameDay,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(List<TrainingSession> sessions) {
    final byDay = <DateTime, List<TrainingSession>>{};
    for (final s in sessions) {
      final key = DateTime(s.startTime.year, s.startTime.month, s.startTime.day);
      byDay.putIfAbsent(key, () => []).add(s);
    }

    return TableCalendar<TrainingSession>(
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2024, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      selectedDayPredicate: (day) => _sameDay(day, _selectedDay),
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        });
      },
      onPageChanged: (focused) => setState(() => _focusedDay = focused),
      calendarFormat: _format,
      onFormatChanged: (f) => setState(() => _format = f),
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
        CalendarFormat.twoWeeks: '2 wks',
        CalendarFormat.week: 'Week',
      },
      eventLoader: (day) {
        final key = DateTime(day.year, day.month, day.day);
        return byDay[key] ?? const [];
      },
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        leftChevronIcon: const Icon(LucideIcons.chevronLeft, color: SphereColors.onSurface),
        rightChevronIcon: const Icon(LucideIcons.chevronRight, color: SphereColors.onSurface),
        titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: SphereColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: SphereColors.onSurfaceMuted, fontSize: 11),
        weekendStyle: TextStyle(color: SphereColors.onSurfaceMuted, fontSize: 11),
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle: const TextStyle(color: SphereColors.onSurface),
        weekendTextStyle: const TextStyle(color: SphereColors.onSurface),
        outsideTextStyle: const TextStyle(color: SphereColors.onSurfaceMuted),
        todayDecoration: BoxDecoration(
          color: SphereColors.primary.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(color: SphereColors.primary),
        ),
        todayTextStyle: const TextStyle(color: SphereColors.primary, fontWeight: FontWeight.w700),
        selectedDecoration: const BoxDecoration(
          color: SphereColors.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          color: SphereColors.onPrimary,
          fontWeight: FontWeight.w700,
        ),
        markerDecoration: const BoxDecoration(
          color: SphereColors.primary,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
      ),
    );
  }
}

class _DaySessionsList extends StatelessWidget {
  const _DaySessionsList({
    required this.selectedDay,
    required this.asyncSessions,
    required this.formatTime,
    required this.sameDay,
  });

  final DateTime selectedDay;
  final AsyncValue<List<TrainingSession>> asyncSessions;
  final String Function(DateTime) formatTime;
  final bool Function(DateTime, DateTime) sameDay;

  @override
  Widget build(BuildContext context) {
    return asyncSessions.when(
      data: (sessions) {
        final dayList = sessions.where((s) => sameDay(s.startTime, selectedDay)).toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
        if (dayList.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(SphereSpacing.x20),
            decoration: BoxDecoration(
              color: SphereColors.surfaceElev1,
              borderRadius: SphereRadius.cardRect,
              border: Border.all(color: SphereColors.borderSubtle),
            ),
            child: Text(
              'No sessions on this day.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SphereColors.onSurfaceMuted,
                  ),
            ),
          );
        }
        return Column(
          children: [
            for (final s in dayList) ...[
              _SessionRow(session: s, formatTime: formatTime),
              const SizedBox(height: SphereSpacing.x12),
            ],
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(SphereColors.primary),
            ),
          ),
        ),
      ),
      error: (_, _) => Text(
        'Couldn’t load sessions.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SphereColors.onSurfaceMuted,
            ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session, required this.formatTime});
  final TrainingSession session;
  final String Function(DateTime) formatTime;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SphereColors.surfaceElev1,
      borderRadius: SphereRadius.cardRect,
      child: InkWell(
        onTap: () => GoRouter.of(context).push('/schedule/session/${session.id}'),
        borderRadius: SphereRadius.cardRect,
        child: Container(
          padding: const EdgeInsets.all(SphereSpacing.x16),
          decoration: BoxDecoration(
            border: Border.all(color: SphereColors.borderSubtle),
            borderRadius: SphereRadius.cardRect,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SphereColors.primary.withValues(alpha: 0.12),
                ),
                child: const Icon(
                  LucideIcons.calendar,
                  color: SphereColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: SphereSpacing.x12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: SphereColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatTime(session.startTime)} · ${session.location}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SphereColors.onSurfaceMuted,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.arrowRight, color: SphereColors.primary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
