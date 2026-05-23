import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class ActiveWorkoutState {
  const ActiveWorkoutState({
    this.currentExerciseIndex = 0,
    this.sets = const [],
    this.isResting = false,
    this.restSecondsLeft = 0,
  });

  final int currentExerciseIndex;
  final List<Map<String, dynamic>> sets;
  final bool isResting;
  final int restSecondsLeft;

  ActiveWorkoutState copyWith({
    int? currentExerciseIndex,
    List<Map<String, dynamic>>? sets,
    bool? isResting,
    int? restSecondsLeft,
  }) =>
      ActiveWorkoutState(
        currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
        sets: sets ?? this.sets,
        isResting: isResting ?? this.isResting,
        restSecondsLeft: restSecondsLeft ?? this.restSecondsLeft,
      );
}

class ActiveWorkoutNotifier extends StateNotifier<ActiveWorkoutState> {
  ActiveWorkoutNotifier() : super(const ActiveWorkoutState());

  void logSet({required String exerciseId, required int reps, required double weightKg}) {
    final newSet = {'exerciseId': exerciseId, 'reps': reps, 'weightKg': weightKg};
    state = state.copyWith(sets: [...state.sets, newSet]);
  }

  void nextExercise() {
    state = state.copyWith(
      currentExerciseIndex: state.currentExerciseIndex + 1,
    );
  }

  void startRest(int seconds) {
    state = state.copyWith(isResting: true, restSecondsLeft: seconds);
  }

  void endRest() {
    state = state.copyWith(isResting: false, restSecondsLeft: 0);
  }

  void tickRest() {
    if (state.restSecondsLeft > 0) {
      state = state.copyWith(restSecondsLeft: state.restSecondsLeft - 1);
    } else {
      endRest();
    }
  }
}

final activeWorkoutProvider =
    StateNotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState>(
  (_) => ActiveWorkoutNotifier(),
);
