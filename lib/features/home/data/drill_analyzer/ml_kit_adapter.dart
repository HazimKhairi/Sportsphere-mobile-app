import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart' as mlk;

import 'pose_snapshot.dart';

/// Maps the ML Kit PoseLandmarkType subset we care about to our enum.
const _landmarkMap = <mlk.PoseLandmarkType, PoseLandmark>{
  mlk.PoseLandmarkType.nose: PoseLandmark.nose,
  mlk.PoseLandmarkType.leftKnee: PoseLandmark.leftKnee,
  mlk.PoseLandmarkType.rightKnee: PoseLandmark.rightKnee,
  mlk.PoseLandmarkType.leftAnkle: PoseLandmark.leftAnkle,
  mlk.PoseLandmarkType.rightAnkle: PoseLandmark.rightAnkle,
  mlk.PoseLandmarkType.leftFootIndex: PoseLandmark.leftFootIndex,
  mlk.PoseLandmarkType.rightFootIndex: PoseLandmark.rightFootIndex,
};

/// Convert the first ML Kit Pose (single-pose detector mode) into our
/// internal PoseSnapshot. Returns null if no usable landmarks present.
PoseSnapshot? snapshotFromMlKit(List<mlk.Pose> poses, int nowMs) {
  if (poses.isEmpty) return null;
  final pose = poses.first;
  final out = <PoseLandmark, LandmarkPosition>{};
  for (final entry in _landmarkMap.entries) {
    final landmark = pose.landmarks[entry.key];
    if (landmark == null) continue;
    out[entry.value] = LandmarkPosition(
      x: landmark.x,
      y: landmark.y,
      confidence: landmark.likelihood,
    );
  }
  if (out.isEmpty) return null;
  return PoseSnapshot(timestampMs: nowMs, landmarks: out);
}
