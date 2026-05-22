import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/drill.dart';
import 'player_home_providers.dart';

part 'drill_detail_providers.g.dart';

@riverpod
Future<Drill?> drillDetail(
  DrillDetailRef ref, {
  required String drillId,
}) async {
  return ref.read(drillRepositoryProvider).drillById(drillId);
}
