import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/sphere_config.dart';
import '../data/drill_completion_repository.dart';
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

@Riverpod(keepAlive: true)
DrillCompletionRepository drillCompletionRepository(
  DrillCompletionRepositoryRef ref,
) {
  return DrillCompletionRepository(
    dio: buildApiClient(baseUrl: SphereConfig.apiBaseUrl),
  );
}
