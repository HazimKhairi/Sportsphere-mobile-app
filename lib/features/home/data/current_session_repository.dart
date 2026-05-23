import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/sphere_config.dart';

part 'current_session_repository.g.dart';

class CurrentSessionInfo {
  const CurrentSessionInfo({
    required this.sessionId,
    required this.programName,
    required this.timeStart,
    this.location,
    this.coach,
  });
  final String sessionId;
  final String programName;
  final String timeStart;
  final String? location;
  final String? coach;
}

class CurrentSessionRepository {
  CurrentSessionRepository({Dio? dio})
      : _dio = dio ?? buildApiClient(baseUrl: SphereConfig.apiBaseUrl);
  final Dio _dio;

  Future<CurrentSessionInfo?> fetchCurrentSession() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/player-app/attendance/current-session',
      );
      final data = res.data;
      if (data == null) return null;
      final sessionId = data['sessionId'] as String?;
      if (sessionId == null || sessionId.isEmpty) return null;
      final program = data['program'] as Map<String, dynamic>? ?? {};
      final time = data['time'] as Map<String, dynamic>? ?? {};
      return CurrentSessionInfo(
        sessionId: sessionId,
        programName: program['name'] as String? ?? 'Training Session',
        timeStart: time['start'] as String? ?? '',
        location: data['location'] as String?,
        coach: data['coach'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

@Riverpod(keepAlive: true)
CurrentSessionRepository currentSessionRepository(Ref ref) =>
    CurrentSessionRepository();
