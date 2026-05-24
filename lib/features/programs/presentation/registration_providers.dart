import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../home/presentation/staff_home_providers.dart';
import '../data/registration_repository.dart';

part 'registration_providers.g.dart';

@Riverpod(keepAlive: true)
RegistrationRepository registrationRepository(RegistrationRepositoryRef ref) {
  return RegistrationRepository();
}

@riverpod
Future<bool> isRegisteredFor(IsRegisteredForRef ref, {required String programId}) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  final clubId = ref.watch(activeClubIdProvider).valueOrNull;
  if (user == null || clubId == null) return false;
  return ref.read(registrationRepositoryProvider).isRegistered(
        clubId: clubId,
        programId: programId,
        playerId: user.uid,
      );
}
