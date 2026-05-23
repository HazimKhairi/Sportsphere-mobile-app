import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/current_session_repository.dart';

part 'current_session_providers.g.dart';

@riverpod
Future<CurrentSessionInfo?> currentSession(Ref ref) async {
  return ref.read(currentSessionRepositoryProvider).fetchCurrentSession();
}
