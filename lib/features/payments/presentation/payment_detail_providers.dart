import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/payment_record.dart';
import 'payment_history_providers.dart';

part 'payment_detail_providers.g.dart';

@riverpod
Future<PaymentRecord?> paymentDetail(
  PaymentDetailRef ref, {
  required String paymentId,
}) async {
  return ref.read(paymentHistoryRepositoryProvider).byId(paymentId);
}
