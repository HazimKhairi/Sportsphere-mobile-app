import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/sphere_config.dart';
import '../data/drill_session_repository.dart';

part 'drill_session_providers.g.dart';

@Riverpod(keepAlive: true)
DrillSessionRepository drillSessionRepository(
  DrillSessionRepositoryRef ref,
) {
  return DrillSessionRepository(
    dio: buildApiClient(baseUrl: SphereConfig.apiBaseUrl),
  );
}
