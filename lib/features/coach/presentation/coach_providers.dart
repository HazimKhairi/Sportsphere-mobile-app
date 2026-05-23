import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/coach_repository.dart';
import '../domain/coach_profile.dart';

part 'coach_providers.g.dart';

@riverpod
Future<List<CoachProfile>> myCoaches(Ref ref) async {
  return ref.read(coachRepositoryProvider).fetchMyCoaches();
}
