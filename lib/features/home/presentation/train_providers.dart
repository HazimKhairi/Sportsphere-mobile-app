import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/drill.dart';
import 'player_home_providers.dart';

part 'train_providers.g.dart';

@riverpod
Stream<List<Drill>> allDrills(AllDrillsRef ref) {
  return ref.watch(drillRepositoryProvider).listDrillsStream();
}
