import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/sphere_config.dart';
import '../data/points_repository.dart';
import '../domain/points_summary.dart';

part 'points_providers.g.dart';

@Riverpod(keepAlive: true)
PointsRepository pointsRepository(PointsRepositoryRef ref) {
  return PointsRepository(
    dio: buildApiClient(baseUrl: SphereConfig.apiBaseUrl),
  );
}

@riverpod
Future<PointsSummary> pointsSummary(PointsSummaryRef ref) {
  return ref.watch(pointsRepositoryProvider).fetchSummary();
}
