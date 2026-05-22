import 'pose_snapshot.dart';
import 'drill_mode.dart';

/// Thresholds ported VERBATIM from web drill analyzer
/// (see `feedback-daily-rotation-seed-pattern` + `drill-analyzer-shipped-2026-05-17`).
class DrillThresholds {
  const DrillThresholds({
    this.confidence = 0.30,
    this.sustainedFrames = 2,
    this.riseDelta = 12.0,
    this.startMotionMs = 1500,
  });

  /// Minimum landmark confidence to consider a frame valid.
  final double confidence;

  /// Number of consecutive frames the trigger must hold to count as a rep.
  final int sustainedFrames;

  /// For kneeLine: how far the knee must rise above the baseline to trigger.
  final double riseDelta;

  /// Player must produce ANY motion within this window or session aborts to idle.
  final int startMotionMs;
}

enum RunnerState { idle, awaitingMotion, counting, done }

class DrillModeRunner {
  DrillModeRunner({
    required this.mode,
    DrillThresholds? thresholds,
    int? targetReps,
  })  : thresholds = thresholds ?? const DrillThresholds(),
        _targetReps = targetReps;

  final DrillMode mode;
  final DrillThresholds thresholds;
  final int? _targetReps;

  RunnerState _state = RunnerState.idle;
  int _reps = 0;
  int? _startedAtMs;

  // Mode-specific bookkeeping
  double? _kneeBaselineY;
  int _kneeAboveFrames = 0;
  bool _kneeArmed = true;

  bool _tapDown = false;
  int _tapDownFrames = 0;

  double? _lateralMidlineX;
  int _lateralLastSide = 0; // -1 left, +1 right, 0 unset
  int _lateralSideFrames = 0;

  int? _contactStartMs;
  int _contactAccumMs = 0;

  RunnerState get state => _state;
  int get reps => _reps;

  /// Resets all bookkeeping. Call when restarting a session.
  void reset() {
    _state = RunnerState.idle;
    _reps = 0;
    _startedAtMs = null;
    _kneeBaselineY = null;
    _kneeAboveFrames = 0;
    _kneeArmed = true;
    _tapDown = false;
    _tapDownFrames = 0;
    _lateralMidlineX = null;
    _lateralLastSide = 0;
    _lateralSideFrames = 0;
    _contactStartMs = null;
    _contactAccumMs = 0;
  }

  /// Begin a session. Player has `startMotionMs` to produce motion.
  void start(int nowMs) {
    reset();
    _state = RunnerState.awaitingMotion;
    _startedAtMs = nowMs;
  }

  /// Manually end (e.g. user taps Done).
  void finish() {
    _state = RunnerState.done;
  }

  /// Feed a pose snapshot. No-op when state is idle / done.
  /// Returns true if a rep was counted this frame.
  bool feed(PoseSnapshot snap) {
    if (_state == RunnerState.idle || _state == RunnerState.done) return false;

    // Discard low-confidence frames entirely.
    final usable = _hasUsableLandmarks(snap);
    if (!usable) {
      _maybeTimeoutMotion(snap.timestampMs);
      return false;
    }
    // First usable frame → transition to counting.
    if (_state == RunnerState.awaitingMotion) {
      _state = RunnerState.counting;
    }

    final before = _reps;
    switch (mode) {
      case DrillMode.kneeLine:
        _feedKneeLine(snap);
      case DrillMode.tap:
        _feedTap(snap);
      case DrillMode.lateral:
        _feedLateral(snap);
      case DrillMode.sustainedContact:
        _feedSustainedContact(snap);
    }

    final target = _targetReps;
    if (target != null && _reps >= target) {
      _state = RunnerState.done;
    }

    return _reps > before;
  }

  void _maybeTimeoutMotion(int nowMs) {
    if (_state != RunnerState.awaitingMotion) return;
    final started = _startedAtMs;
    if (started == null) return;
    if (nowMs - started > thresholds.startMotionMs) {
      _state = RunnerState.idle;
    }
  }

  bool _hasUsableLandmarks(PoseSnapshot snap) {
    switch (mode) {
      case DrillMode.kneeLine:
        return _conf(snap, PoseLandmark.rightKnee) ||
            _conf(snap, PoseLandmark.leftKnee);
      case DrillMode.tap:
      case DrillMode.lateral:
        return _conf(snap, PoseLandmark.rightFootIndex) ||
            _conf(snap, PoseLandmark.leftFootIndex) ||
            _conf(snap, PoseLandmark.rightAnkle) ||
            _conf(snap, PoseLandmark.leftAnkle);
      case DrillMode.sustainedContact:
        return _conf(snap, PoseLandmark.rightFootIndex) ||
            _conf(snap, PoseLandmark.leftFootIndex);
    }
  }

  bool _conf(PoseSnapshot snap, PoseLandmark lm) {
    final p = snap.landmarks[lm];
    return p != null && p.confidence >= thresholds.confidence;
  }

  // ─── Knee line (juggle) ────────────────────────────────────────────────
  void _feedKneeLine(PoseSnapshot snap) {
    final knee = snap.landmarks[PoseLandmark.rightKnee] ??
        snap.landmarks[PoseLandmark.leftKnee];
    if (knee == null || knee.confidence < thresholds.confidence) return;

    _kneeBaselineY ??= knee.y;
    final baseline = _kneeBaselineY!;
    // Image coordinates have y increasing downward, so "rise" = baseline - y.
    final rise = baseline - knee.y;

    if (rise >= thresholds.riseDelta) {
      _kneeAboveFrames += 1;
      if (_kneeArmed && _kneeAboveFrames >= thresholds.sustainedFrames) {
        _reps += 1;
        _kneeArmed = false;
      }
    } else {
      // Knee dropped back; re-arm.
      _kneeAboveFrames = 0;
      _kneeArmed = true;
    }
  }

  // ─── Tap (toe taps, back vee) ──────────────────────────────────────────
  void _feedTap(PoseSnapshot snap) {
    // A "tap" is a quick foot-down → foot-up cycle. Crudely: when the foot
    // y stays in the lowest 10% of recent range for `sustainedFrames`, count
    // a down-stroke; release when it lifts. We approximate this by tracking
    // a foot-down flag.
    final foot = snap.landmarks[PoseLandmark.rightFootIndex] ??
        snap.landmarks[PoseLandmark.leftFootIndex] ??
        snap.landmarks[PoseLandmark.rightAnkle] ??
        snap.landmarks[PoseLandmark.leftAnkle];
    if (foot == null || foot.confidence < thresholds.confidence) return;

    _kneeBaselineY ??= foot.y; // reuse baseline field for foot
    final baseline = _kneeBaselineY!;
    final drop = foot.y - baseline; // positive = below baseline

    if (drop > thresholds.riseDelta / 2) {
      _tapDownFrames += 1;
      if (!_tapDown && _tapDownFrames >= thresholds.sustainedFrames) {
        _tapDown = true;
        _reps += 1;
      }
    } else {
      _tapDownFrames = 0;
      _tapDown = false;
    }
  }

  // ─── Lateral (tic-toc, inside-outside) ─────────────────────────────────
  void _feedLateral(PoseSnapshot snap) {
    final foot = snap.landmarks[PoseLandmark.rightFootIndex] ??
        snap.landmarks[PoseLandmark.leftFootIndex] ??
        snap.landmarks[PoseLandmark.rightAnkle] ??
        snap.landmarks[PoseLandmark.leftAnkle];
    if (foot == null || foot.confidence < thresholds.confidence) return;

    _lateralMidlineX ??= foot.x;
    final mid = _lateralMidlineX!;
    final side = foot.x < mid - thresholds.riseDelta
        ? -1
        : foot.x > mid + thresholds.riseDelta
            ? 1
            : 0;

    if (side == 0) {
      _lateralSideFrames = 0;
      return;
    }
    if (side == _lateralLastSide) {
      // Same side — keep streak.
      _lateralSideFrames += 1;
      return;
    }
    // Side flipped.
    _lateralSideFrames += 1;
    if (_lateralSideFrames >= thresholds.sustainedFrames) {
      _reps += 1;
      _lateralLastSide = side;
      _lateralSideFrames = 0;
    }
  }

  // ─── Sustained contact (sole rolls) ─────────────────────────────────────
  void _feedSustainedContact(PoseSnapshot snap) {
    final foot = snap.landmarks[PoseLandmark.rightFootIndex] ??
        snap.landmarks[PoseLandmark.leftFootIndex];
    if (foot == null || foot.confidence < thresholds.confidence) return;

    _contactStartMs ??= snap.timestampMs;
    final start = _contactStartMs!;
    _contactAccumMs = snap.timestampMs - start;

    // Each 1000ms of sustained contact = 1 rep.
    final newReps = _contactAccumMs ~/ 1000;
    if (newReps > _reps) {
      _reps = newReps;
    }
  }
}
