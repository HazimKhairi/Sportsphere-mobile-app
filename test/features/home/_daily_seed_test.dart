import 'package:flutter_test/flutter_test.dart';
import 'package:sportsphere_mobile/features/home/data/_daily_seed.dart';

void main() {
  group('djb2', () {
    test('returns a non-negative int', () {
      expect(djb2('abc'), greaterThanOrEqualTo(0));
    });
    test('is deterministic', () {
      expect(djb2('abc'), equals(djb2('abc')));
    });
    test('differs for different inputs', () {
      expect(djb2('abc'), isNot(equals(djb2('abd'))));
    });
  });

  group('shuffleSeeded', () {
    test('produces same order for same seed', () {
      final a = shuffleSeeded([1, 2, 3, 4, 5], seed: 42);
      final b = shuffleSeeded([1, 2, 3, 4, 5], seed: 42);
      expect(a, equals(b));
    });
    test('produces different order for different seed', () {
      final a = shuffleSeeded([1, 2, 3, 4, 5], seed: 42);
      final b = shuffleSeeded([1, 2, 3, 4, 5], seed: 99);
      expect(a, isNot(equals(b)));
    });
    test('preserves elements', () {
      final shuffled = shuffleSeeded([1, 2, 3, 4, 5], seed: 7);
      expect(shuffled..sort(), [1, 2, 3, 4, 5]);
    });
  });
}
