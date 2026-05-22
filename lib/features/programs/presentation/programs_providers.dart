import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../home/presentation/staff_home_providers.dart';
import '../data/programs_repository.dart';
import '../domain/program.dart';

part 'programs_providers.g.dart';

@Riverpod(keepAlive: true)
ProgramsRepository programsRepository(ProgramsRepositoryRef ref) {
  return ProgramsRepository();
}

@riverpod
Stream<List<Program>> publishedPrograms(PublishedProgramsRef ref) {
  final clubId = ref.watch(activeClubIdProvider).valueOrNull;
  if (clubId == null) return Stream.value(const []);
  return ref
      .watch(programsRepositoryProvider)
      .publishedProgramsStream(clubId: clubId);
}
