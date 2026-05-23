import 'package:dio/dio.dart';

import '../domain/player_card_data.dart';

class PlayerCardRepository {
  PlayerCardRepository({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<({PlayerCardData card, TrainingSummary? summary})> fetchCard() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/player-app/card');
    final body = res.data ?? {};
    final card = PlayerCardData.fromJson(body['card'] as Map<String, dynamic>? ?? {});
    final summaryJson = body['trainingSummary'] as Map<String, dynamic>?;
    final summary = summaryJson != null ? TrainingSummary.fromJson(summaryJson) : null;
    return (card: card, summary: summary);
  }

  /// Returns the player's Firestore doc ID, needed for photo upload.
  Future<String?> fetchPlayerId() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/player-app/profile');
      final profile = res.data?['profile'] as Map<String, dynamic>?;
      return profile?['playerId'] as String?;
    } catch (_) {
      return null;
    }
  }
}
