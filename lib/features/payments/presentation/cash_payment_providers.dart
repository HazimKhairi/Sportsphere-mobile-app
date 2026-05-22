import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/sphere_config.dart';
import '../data/cash_payment_repository.dart';

part 'cash_payment_providers.g.dart';

@Riverpod(keepAlive: true)
CashPaymentRepository cashPaymentRepository(CashPaymentRepositoryRef ref) {
  return CashPaymentRepository(
    dio: buildApiClient(baseUrl: SphereConfig.apiBaseUrl),
  );
}
