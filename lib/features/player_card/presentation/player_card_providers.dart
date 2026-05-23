import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/sphere_config.dart';
import '../data/player_card_repository.dart';
import '../domain/player_card_data.dart';

part 'player_card_providers.g.dart';

@Riverpod(keepAlive: true)
PlayerCardRepository playerCardRepository(PlayerCardRepositoryRef ref) {
  return PlayerCardRepository(
    dio: buildApiClient(baseUrl: SphereConfig.apiBaseUrl),
  );
}

@riverpod
Future<({PlayerCardData card, TrainingSummary? summary})> playerCard(
    PlayerCardRef ref) {
  return ref.watch(playerCardRepositoryProvider).fetchCard();
}
