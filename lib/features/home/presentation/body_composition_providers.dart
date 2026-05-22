import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/body_composition_repository.dart';
import '../domain/body_composition_entry.dart';

part 'body_composition_providers.g.dart';

@Riverpod(keepAlive: true)
BodyCompositionRepository bodyCompositionRepository(
  BodyCompositionRepositoryRef ref,
) {
  return BodyCompositionRepository();
}

@riverpod
Stream<List<BodyCompositionEntry>> myBodyComposition(
  MyBodyCompositionRef ref,
) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  return ref.watch(bodyCompositionRepositoryProvider).streamForPlayer(
        playerId: user.uid,
      );
}
