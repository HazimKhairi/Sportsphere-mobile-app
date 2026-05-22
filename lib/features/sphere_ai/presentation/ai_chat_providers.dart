import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/sphere_config.dart';
import '../data/ai_chat_repository.dart';

part 'ai_chat_providers.g.dart';

@Riverpod(keepAlive: true)
AiChatRepository aiChatRepository(AiChatRepositoryRef ref) {
  return AiChatRepository(
    dio: buildApiClient(baseUrl: SphereConfig.apiBaseUrl),
  );
}
