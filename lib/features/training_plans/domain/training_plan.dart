enum PlanFocus { technical, tactical, physical, rest }

extension PlanFocusX on PlanFocus {
  String get label {
    switch (this) {
      case PlanFocus.technical: return 'Technical';
      case PlanFocus.tactical:  return 'Tactical';
      case PlanFocus.physical:  return 'Physical';
      case PlanFocus.rest:      return 'Rest';
    }
  }

  static const _colors = {
    PlanFocus.technical: 0xFF37F513,
    PlanFocus.tactical:  0xFF3B82F6,
    PlanFocus.physical:  0xFFF97316,
    PlanFocus.rest:      0xFF64748B,
  };
  int get colorValue => _colors[this]!;
}

class PlanSession {
  const PlanSession({
    required this.id,
    required this.title,
    required this.dayOfWeek,
    required this.durationMinutes,
    required this.focus,
    this.notes,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final int dayOfWeek; // 1=Mon … 7=Sun
  final int durationMinutes;
  final PlanFocus focus;
  final String? notes;
  final bool isCompleted;

  factory PlanSession.fromDoc(String id, Map<String, dynamic> d) {
    PlanFocus focus;
    switch (d['focus'] as String? ?? '') {
      case 'tactical':  focus = PlanFocus.tactical; break;
      case 'physical':  focus = PlanFocus.physical; break;
      case 'rest':      focus = PlanFocus.rest; break;
      default:          focus = PlanFocus.technical;
    }
    return PlanSession(
      id: id,
      title: (d['title'] as String?) ?? 'Session',
      dayOfWeek: (d['dayOfWeek'] as int?) ?? 1,
      durationMinutes: (d['durationMinutes'] as int?) ?? 60,
      focus: focus,
      notes: d['notes'] as String?,
    );
  }
}

class PlanWeek {
  const PlanWeek({
    required this.id,
    required this.weekNumber,
    required this.title,
    required this.theme,
    required this.sessions,
  });

  final String id;
  final int weekNumber;
  final String title;
  final String theme;
  final List<PlanSession> sessions;
}

class TrainingPlan {
  const TrainingPlan({
    required this.id,
    required this.title,
    required this.totalWeeks,
    required this.currentWeek,
    required this.phase,
    this.description = '',
  });

  final String id;
  final String title;
  final int totalWeeks;
  final int currentWeek;
  final String phase; // 'preseason' | 'inseason' | 'offseason'
  final String description;

  factory TrainingPlan.fromDoc(String id, Map<String, dynamic> d) => TrainingPlan(
        id: id,
        title: (d['title'] as String?) ?? 'Training Plan',
        totalWeeks: (d['totalWeeks'] as int?) ?? 6,
        currentWeek: (d['currentWeek'] as int?) ?? 1,
        phase: (d['phase'] as String?) ?? 'inseason',
        description: (d['description'] as String?) ?? '',
      );
}
