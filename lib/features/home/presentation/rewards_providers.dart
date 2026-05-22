import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/sphere_config.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/rewards_repository.dart';
import '../domain/reward.dart';
import 'staff_home_providers.dart';

part 'rewards_providers.g.dart';

@Riverpod(keepAlive: true)
RewardsRepository rewardsRepository(RewardsRepositoryRef ref) {
  return RewardsRepository(
    dio: buildApiClient(baseUrl: SphereConfig.apiBaseUrl),
  );
}

@riverpod
Stream<List<Reward>> myRewardsCatalog(MyRewardsCatalogRef ref) {
  final clubId = ref.watch(activeClubIdProvider).valueOrNull;
  if (clubId == null) return Stream.value(const []);
  return ref.watch(rewardsRepositoryProvider).streamCatalog(clubId: clubId);
}

@riverpod
Stream<int> myPointsBalance(MyPointsBalanceRef ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value(0);
  return ref.watch(rewardsRepositoryProvider).pointsBalanceStream(
        playerId: user.uid,
      );
}
