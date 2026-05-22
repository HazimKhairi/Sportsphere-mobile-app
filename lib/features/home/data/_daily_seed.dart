/// djb2 hash for deterministic, distribution-friendly string-to-int.
/// Returns a non-negative int (masked to 31 bits).
int djb2(String s) {
  var hash = 5381;
  for (final c in s.codeUnits) {
    hash = ((hash << 5) + hash + c) & 0x7FFFFFFF;
  }
  return hash;
}

/// Fisher-Yates shuffle driven by a deterministic linear congruential generator.
/// Same `seed` always yields the same output order.
/// Returns a new list (input not mutated).
List<T> shuffleSeeded<T>(List<T> input, {required int seed}) {
  final list = List<T>.of(input);
  var state = seed | 1; // avoid zero state collapsing
  for (var i = list.length - 1; i > 0; i--) {
    // Park-Miller LCG step
    state = (state * 48271) & 0x7FFFFFFF;
    final j = state % (i + 1);
    final tmp = list[i];
    list[i] = list[j];
    list[j] = tmp;
  }
  return list;
}

/// Convenience: build "YYYY-M-D|playerId" string for the seed input.
String dailySeedKey({required DateTime date, required String playerId}) {
  return '${date.year}-${date.month}-${date.day}|$playerId';
}
