import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/check_in_repository.dart';

part 'check_in_providers.g.dart';

@Riverpod(keepAlive: true)
CheckInRepository checkInRepository(CheckInRepositoryRef ref) {
  return CheckInRepository(
    dio: buildApiClient(baseUrl: 'https://sprtsphr.app'),
  );
}
