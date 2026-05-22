import 'package:dio/dio.dart';

import '../domain/player_card.dart';
import '../domain/player_detail.dart';

export '../domain/player_card.dart';
export '../domain/player_detail.dart';

class RosterPage {
  const RosterPage({required this.players, this.nextCursor});

  final List<PlayerCard> players;
  final String? nextCursor;
}

class RosterRepository {
  RosterRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<RosterPage> listPlayers({
    required String clubId,
    String? cursor,
    int limit = 25,
  }) async {
    try {
      final params = <String, dynamic>{'limit': limit};
      if (cursor != null) params['cursor'] = cursor;

      final res = await _dio.get<Map<String, dynamic>>(
        '/api/players/mobile',
        queryParameters: params,
        options: Options(headers: {'X-Club-Id': clubId}),
      );
      final data = res.data ?? const <String, dynamic>{};
      final rawList = data['players'] as List<dynamic>? ?? [];
      final players = rawList
          .whereType<Map<String, dynamic>>()
          .map(_fromJson)
          .toList();
      return RosterPage(
        players: players,
        nextCursor: data['nextCursor'] as String?,
      );
    } on DioException catch (e) {
      throw RosterException(
        e.response?.data is Map
            ? (e.response!.data as Map)['error']?.toString() ??
                'Failed to load roster'
            : 'Failed to load roster',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<PlayerDetail> getPlayer({required String id}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/players/$id');
      final data = res.data ?? const <String, dynamic>{};
      final p = (data['player'] as Map<String, dynamic>?) ?? data;
      return PlayerDetail(
        id: p['id'] as String? ?? id,
        firstName: p['firstName'] as String? ?? '',
        lastName: p['lastName'] as String? ?? '',
        email: p['email'] as String? ?? '',
        phone: p['phone'] as String? ?? '',
        position: p['position'] as String? ?? '',
        teamName: p['teamName'] as String? ?? '',
        photoUrl: p['photoUrl'] as String? ?? p['passportPhotoUrl'] as String?,
        dateOfBirth: p['dateOfBirth'] as String?,
        availability: p['availability'] as String?,
        jerseyNumber: (p['jerseyNumber'] as num?)?.toInt(),
        parentName: p['parentName'] as String?,
        parentPhone: p['parentPhone'] as String?,
      );
    } on DioException catch (e) {
      throw RosterException(
        e.response?.data is Map
            ? (e.response!.data as Map)['error']?.toString() ??
                'Player not found'
            : 'Player not found',
        statusCode: e.response?.statusCode,
      );
    }
  }

  PlayerCard _fromJson(Map<String, dynamic> e) {
    return PlayerCard(
      id: e['id'] as String? ?? '',
      firstName: e['firstName'] as String? ?? '',
      lastName: e['lastName'] as String? ?? '',
      email: e['email'] as String? ?? '',
      phone: e['phone'] as String? ?? '',
      position: e['position'] as String? ?? '',
      teamName: e['teamName'] as String? ?? '',
      photoUrl: e['photoUrl'] as String?,
      dateOfBirth: e['dateOfBirth'] as String?,
    );
  }
}

class RosterException implements Exception {
  RosterException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'RosterException($statusCode): $message';
}
