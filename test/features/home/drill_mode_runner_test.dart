import 'package:flutter_test/flutter_test.dart';
import 'package:sportsphere_mobile/features/home/data/drill_analyzer/drill_mode.dart';
import 'package:sportsphere_mobile/features/home/data/drill_analyzer/drill_mode_runner.dart';
import 'package:sportsphere_mobile/features/home/data/drill_analyzer/pose_snapshot.dart';

PoseSnapshot snap({
  required int t,
  double rightKneeY = 100,
  double rightKneeX = 50,
  double rightFootY = 200,
  double rightFootX = 50,
  double conf = 0.9,
}) {
  return PoseSnapshot(
    timestampMs: t,
    landmarks: {
      PoseLandmark.rightKnee:
          LandmarkPosition(x: rightKneeX, y: rightKneeY, confidence: conf),
      PoseLandmark.rightFootIndex:
          LandmarkPosition(x: rightFootX, y: rightFootY, confidence: conf),
      PoseLandmark.rightAnkle:
          LandmarkPosition(x: rightFootX, y: rightFootY, confidence: conf),
    },
  );
}

void main() {
  group('DrillMode.forCategory', () {
    test('maps each documented category', () {
      expect(DrillMode.forCategory('juggle'), DrillMode.kneeLine);
      expect(DrillMode.forCategory('toe_taps'), DrillMode.tap);
      expect(DrillMode.forCategory('back_vee'), DrillMode.tap);
      expect(DrillMode.forCategory('tic_toc'), DrillMode.lateral);
      expect(DrillMode.forCategory('inside_outside'), DrillMode.lateral);
      expect(DrillMode.forCategory('sole_rolls'), DrillMode.sustainedContact);
      expect(DrillMode.forCategory('unknown'), DrillMode.kneeLine);
    });
  });

  group('DrillModeRunner.kneeLine', () {
    test('starts in idle, transitions to awaitingMotion on start', () {
      final r = DrillModeRunner(mode: DrillMode.kneeLine);
      expect(r.state, RunnerState.idle);
      r.start(0);
      expect(r.state, RunnerState.awaitingMotion);
    });

    test('counts a knee rise above threshold sustained for 2 frames', () {
      final r = DrillModeRunner(mode: DrillMode.kneeLine);
      r.start(0);
      // First valid frame establishes baseline at y=100, transitions to counting.
      expect(r.feed(snap(t: 100, rightKneeY: 100)), false);
      expect(r.state, RunnerState.counting);
      // Knee rises 15 px (>= rise threshold 12) — frame 1.
      expect(r.feed(snap(t: 130, rightKneeY: 85)), false);
      // Frame 2 still above — rep counted.
      expect(r.feed(snap(t: 160, rightKneeY: 85)), true);
      expect(r.reps, 1);
    });

    test('does not double-count without re-arm', () {
      final r = DrillModeRunner(mode: DrillMode.kneeLine);
      r.start(0);
      r.feed(snap(t: 100, rightKneeY: 100));
      r.feed(snap(t: 130, rightKneeY: 85));
      r.feed(snap(t: 160, rightKneeY: 85)); // 1 rep
      r.feed(snap(t: 190, rightKneeY: 85)); // still above, but armed=false
      expect(r.reps, 1);
    });

    test('re-arms after knee drops back below baseline', () {
      final r = DrillModeRunner(mode: DrillMode.kneeLine);
      r.start(0);
      r.feed(snap(t: 100, rightKneeY: 100));
      r.feed(snap(t: 130, rightKneeY: 85));
      r.feed(snap(t: 160, rightKneeY: 85)); // 1 rep
      r.feed(snap(t: 200, rightKneeY: 100)); // drop → re-arm
      r.feed(snap(t: 230, rightKneeY: 85));
      r.feed(snap(t: 260, rightKneeY: 85)); // 2 reps
      expect(r.reps, 2);
    });

    test('drops low-confidence frames', () {
      final r = DrillModeRunner(mode: DrillMode.kneeLine);
      r.start(0);
      r.feed(snap(t: 100, rightKneeY: 100, conf: 0.1)); // below 0.30
      expect(r.state, RunnerState.awaitingMotion);
    });

    test('times out to idle if no motion within startMotionMs', () {
      final r = DrillModeRunner(mode: DrillMode.kneeLine);
      r.start(0);
      r.feed(snap(t: 1700, rightKneeY: 100, conf: 0.1));
      expect(r.state, RunnerState.idle);
    });

    test('targetReps caps the rep count + transitions to done', () {
      final r = DrillModeRunner(mode: DrillMode.kneeLine, targetReps: 1);
      r.start(0);
      r.feed(snap(t: 100, rightKneeY: 100));
      r.feed(snap(t: 130, rightKneeY: 85));
      r.feed(snap(t: 160, rightKneeY: 85));
      expect(r.reps, 1);
      expect(r.state, RunnerState.done);
    });
  });

  group('DrillModeRunner smoke (tap / lateral / sustainedContact)', () {
    test('tap counts a foot-down + sustained', () {
      final r = DrillModeRunner(mode: DrillMode.tap);
      r.start(0);
      r.feed(snap(t: 100, rightFootY: 100));
      r.feed(snap(t: 130, rightFootY: 115)); // drop 15 > 6
      r.feed(snap(t: 160, rightFootY: 115));
      expect(r.reps, 1);
    });

    test('lateral counts side switch sustained', () {
      final r = DrillModeRunner(mode: DrillMode.lateral);
      r.start(0);
      r.feed(snap(t: 100, rightFootX: 50));
      r.feed(snap(t: 130, rightFootX: 70)); // right side
      r.feed(snap(t: 160, rightFootX: 30)); // flip to left
      r.feed(snap(t: 190, rightFootX: 30));
      expect(r.reps, greaterThanOrEqualTo(1));
    });

    test('sustainedContact counts seconds of held contact', () {
      final r = DrillModeRunner(mode: DrillMode.sustainedContact);
      r.start(0);
      r.feed(snap(t: 0));
      r.feed(snap(t: 500));
      r.feed(snap(t: 1100)); // 1.1s elapsed → 1 rep
      expect(r.reps, 1);
      r.feed(snap(t: 2050)); // 2.05s elapsed → 2 reps
      expect(r.reps, 2);
    });
  });

  group('reset', () {
    test('clears state + reps', () {
      final r = DrillModeRunner(mode: DrillMode.kneeLine);
      r.start(0);
      r.feed(snap(t: 100, rightKneeY: 100));
      r.feed(snap(t: 130, rightKneeY: 85));
      r.feed(snap(t: 160, rightKneeY: 85));
      expect(r.reps, 1);
      r.reset();
      expect(r.reps, 0);
      expect(r.state, RunnerState.idle);
    });
  });
}
