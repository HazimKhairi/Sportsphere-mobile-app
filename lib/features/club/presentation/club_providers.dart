import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/club_repository.dart';
import '../domain/club_info.dart';

part 'club_providers.g.dart';

@riverpod
Future<ClubInfo?> myClub(Ref ref) async {
  return ref.read(clubRepositoryProvider).fetchMyClub();
}
