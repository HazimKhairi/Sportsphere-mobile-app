import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/payment_history_repository.dart';
import '../domain/payment_record.dart';

part 'payment_history_providers.g.dart';

@Riverpod(keepAlive: true)
PaymentHistoryRepository paymentHistoryRepository(
  PaymentHistoryRepositoryRef ref,
) {
  return PaymentHistoryRepository();
}

@riverpod
Stream<List<PaymentRecord>> myPaymentHistory(MyPaymentHistoryRef ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  return ref.watch(paymentHistoryRepositoryProvider).streamForPlayer(
        playerId: user.uid,
      );
}
