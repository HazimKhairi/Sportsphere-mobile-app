import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../l10n/app_localizations.dart';
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
    final l = AppLocalizations.of(context)!;
    final sessionsAsync = ref.watch(monthSessionsProvider(focusedMonth: _focusedDay));

    return Scaffold(
      backgroundColor: context.sc.surface,
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
                  l.schedule,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: SphereSpacing.x16),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.sc.surfaceElev1,
                    borderRadius: SphereRadius.cardRect,
                    border: Border.all(color: context.sc.borderSubtle),
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
        leftChevronIcon: Icon(LucideIcons.chevronLeft, color: context.sc.onSurface),
        rightChevronIcon: Icon(LucideIcons.chevronRight, color: context.sc.onSurface),
        titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: context.sc.onSurface,
              fontWeight: FontWeight.w700,
            ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: context.sc.onSurfaceMuted, fontSize: 11),
        weekendStyle: TextStyle(color: context.sc.onSurfaceMuted, fontSize: 11),
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle: TextStyle(color: context.sc.onSurface),
        weekendTextStyle: TextStyle(color: context.sc.onSurface),
        outsideTextStyle: TextStyle(color: context.sc.onSurfaceMuted),
        todayDecoration: BoxDecoration(
          color: context.sc.primary.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(color: context.sc.primary),
        ),
        todayTextStyle: TextStyle(color: context.sc.primary, fontWeight: FontWeight.w700),
        selectedDecoration: BoxDecoration(
          color: context.sc.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: TextStyle(
          color: context.sc.onPrimary,
          fontWeight: FontWeight.w700,
        ),
        markerDecoration: BoxDecoration(
          color: context.sc.primary,
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
              color: context.sc.surfaceElev1,
              borderRadius: SphereRadius.cardRect,
              border: Border.all(color: context.sc.borderSubtle),
            ),
            child: Text(
              AppLocalizations.of(context)!.noSessionsToday,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.sc.onSurfaceMuted,
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
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(context.sc.primary),
            ),
          ),
        ),
      ),
      error: (e, _) => Text(
        "Couldn’t load sessions. $e",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.sc.onSurfaceMuted,
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
      color: context.sc.surfaceElev1,
      borderRadius: SphereRadius.cardRect,
      child: InkWell(
        onTap: () => GoRouter.of(context).push('/schedule/session/${session.id}'),
        borderRadius: SphereRadius.cardRect,
        child: Container(
          padding: const EdgeInsets.all(SphereSpacing.x16),
          decoration: BoxDecoration(
            border: Border.all(color: context.sc.borderSubtle),
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
                  color: context.sc.primary.withValues(alpha: 0.12),
                ),
                child: Icon(
                  LucideIcons.calendar,
                  color: context.sc.primary,
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
                            color: context.sc.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatTime(session.startTime)} · ${session.location}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.sc.onSurfaceMuted,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.arrowRight, color: context.sc.primary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
