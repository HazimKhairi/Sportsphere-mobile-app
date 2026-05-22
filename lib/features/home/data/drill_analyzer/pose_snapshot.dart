/// Subset of MediaPipe / ML Kit landmark types relevant to the drills we
/// analyze. Indexed enum names match ML Kit naming.
enum PoseLandmark {
  nose,
  leftKnee,
  rightKnee,
  leftAnkle,
  rightAnkle,
  leftFootIndex,
  rightFootIndex,
}

class LandmarkPosition {
  const LandmarkPosition({
    required this.x,
    required this.y,
    required this.confidence,
  });

  /// In normalized [0, 1] image coordinates, OR raw pixels — DrillModeRunner
  /// is unit-agnostic but caller must be consistent within a session.
  final double x;
  final double y;

  /// 0.0–1.0. Below CONF threshold we skip the frame.
  final double confidence;
}

class PoseSnapshot {
  const PoseSnapshot({
    required this.timestampMs,
    required this.landmarks,
  });

  /// Milliseconds since epoch (or any monotonic source — runner only
  /// computes deltas).
  final int timestampMs;

  /// Sparse map — only the landmarks we care about for the active drill.
  final Map<PoseLandmark, LandmarkPosition> landmarks;
}
