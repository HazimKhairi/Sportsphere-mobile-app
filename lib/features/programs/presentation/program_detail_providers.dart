import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../home/presentation/staff_home_providers.dart';
import '../domain/program.dart';
import 'programs_providers.dart';

part 'program_detail_providers.g.dart';

@riverpod
Future<Program?> programDetail(
  ProgramDetailRef ref, {
  required String programId,
}) async {
  final clubId = ref.watch(activeClubIdProvider).valueOrNull;
  if (clubId == null) return null;
  return ref.read(programsRepositoryProvider).programById(
        clubId: clubId,
        programId: programId,
      );
}
