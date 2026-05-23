import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/sphere_config.dart';
import '../domain/coach_profile.dart';

part 'coach_repository.g.dart';

class CoachRepository {
  CoachRepository({Dio? dio})
      : _dio = dio ?? buildApiClient(baseUrl: SphereConfig.apiBaseUrl);

  final Dio _dio;

  Future<List<CoachProfile>> fetchMyCoaches() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/player-app/coaches');
    final list = res.data?['coaches'] as List<dynamic>? ?? [];
    return list
        .map((e) => CoachProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

@Riverpod(keepAlive: true)
CoachRepository coachRepository(Ref ref) => CoachRepository();
