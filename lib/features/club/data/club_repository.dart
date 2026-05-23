import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/sphere_config.dart';
import '../domain/club_info.dart';

part 'club_repository.g.dart';

class ClubRepository {
  ClubRepository({Dio? dio})
      : _dio = dio ?? buildApiClient(baseUrl: SphereConfig.apiBaseUrl);

  final Dio _dio;

  Future<ClubInfo?> fetchMyClub() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/club/mobile');
    final data = res.data?['club'] as Map<String, dynamic>?;
    if (data == null) return null;
    return ClubInfo.fromJson(data);
  }
}

@Riverpod(keepAlive: true)
ClubRepository clubRepository(Ref ref) => ClubRepository();
