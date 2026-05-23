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
        id: _str(p['id']) ?? id,
        firstName: _str(p['firstName']) ?? '',
        lastName: _str(p['lastName']) ?? '',
        email: _str(p['email']) ?? '',
        phone: _str(p['phone']) ?? '',
        position: _str(p['position']) ?? '',
        teamName: _str(p['teamName']) ?? '',
        photoUrl: _str(p['photoUrl'] ?? p['passportPhotoUrl']),
        dateOfBirth: _str(p['dateOfBirth']),
        availability: _str(p['availability']),
        jerseyNumber: (p['jerseyNumber'] as num?)?.toInt(),
        parentName: _str(p['parentName']),
        parentPhone: _str(p['parentPhone']),
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

  Future<PlayerCard> createPlayer({
    required String clubId,
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
    String? position,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/players/mobile',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          if (email != null && email.isNotEmpty) 'email': email,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          if (position != null && position.isNotEmpty) 'position': position,
        },
        options: Options(headers: {'X-Club-Id': clubId}),
      );
      final data = res.data ?? const <String, dynamic>{};
      final p = (data['player'] as Map<String, dynamic>?) ?? data;
      return _fromJson(p);
    } on DioException catch (e) {
      throw RosterException(
        e.response?.data is Map
            ? (e.response!.data as Map)['error']?.toString() ??
                'Failed to create player'
            : 'Failed to create player',
        statusCode: e.response?.statusCode,
      );
    }
  }

  PlayerCard _fromJson(Map<String, dynamic> e) {
    return PlayerCard(
      id: _str(e['id']) ?? '',
      firstName: _str(e['firstName']) ?? '',
      lastName: _str(e['lastName']) ?? '',
      email: _str(e['email']) ?? '',
      phone: _str(e['phone']) ?? '',
      position: _str(e['position']) ?? '',
      teamName: _str(e['teamName']) ?? '',
      photoUrl: _str(e['photoUrl'] ?? e['passportPhotoUrl']),
      dateOfBirth: _str(e['dateOfBirth']),
    );
  }

  static String? _str(dynamic v) => v is String ? v : null;
}

class RosterException implements Exception {
  RosterException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'RosterException($statusCode): $message';
}
