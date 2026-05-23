import 'package:dio/dio.dart';

import '../domain/scouting_profile.dart';

class ScoutRepository {
  ScoutRepository({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<ScoutingProfile?> fetchMyProfile() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/scouting/profile');
    final data = res.data;
    if (data == null) return null;
    final profile = data['profile'];
    if (profile == null) return null;
    return ScoutingProfile.fromJson(profile as Map<String, dynamic>);
  }

  Future<ScoutingProfile> saveProfile(ScoutingProfile profile) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/api/scouting/profile',
      data: profile.toJson(),
    );
    final data = res.data;
    if (data == null) throw Exception('Empty response from server');
    return ScoutingProfile.fromJson(data['profile'] as Map<String, dynamic>);
  }

  Future<ScoutingProfile> setVisibility(String visibility) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/scouting/profile',
      data: {'visibility': visibility},
    );
    final data = res.data;
    if (data == null) throw Exception('Empty response');
    return ScoutingProfile.fromJson(data['profile'] as Map<String, dynamic>);
  }
}
