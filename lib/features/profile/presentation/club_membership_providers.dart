import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/sphere_config.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/club_membership_repository.dart';
import '../domain/club_membership.dart';

part 'club_membership_providers.g.dart';

@Riverpod(keepAlive: true)
ClubMembershipRepository clubMembershipRepository(
  ClubMembershipRepositoryRef ref,
) {
  return ClubMembershipRepository(
    dio: buildApiClient(baseUrl: SphereConfig.apiBaseUrl),
  );
}

@riverpod
Future<List<ClubMembership>> myClubMemberships(MyClubMembershipsRef ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const [];
  return ref.read(clubMembershipRepositoryProvider).listMemberships(
        userId: user.uid,
      );
}
