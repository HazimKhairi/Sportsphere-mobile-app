import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/sphere_config.dart';
import '../data/payment_intent_repository.dart';

part 'payment_intent_providers.g.dart';

@Riverpod(keepAlive: true)
PaymentIntentRepository paymentIntentRepository(PaymentIntentRepositoryRef ref) {
  return PaymentIntentRepository(
    dio: buildApiClient(baseUrl: SphereConfig.apiBaseUrl),
  );
}
