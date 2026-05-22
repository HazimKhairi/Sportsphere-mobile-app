import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/sphere_config.dart';
import '../../home/presentation/staff_home_providers.dart';
import '../data/approvals_repository.dart';
import '../domain/pending_payment.dart';

part 'approvals_providers.g.dart';

@Riverpod(keepAlive: true)
ApprovalsRepository approvalsRepository(ApprovalsRepositoryRef ref) {
  return ApprovalsRepository(
    dio: buildApiClient(baseUrl: SphereConfig.apiBaseUrl),
  );
}

@riverpod
class ApprovalsNotifier extends _$ApprovalsNotifier {
  @override
  Future<List<PendingPayment>> build() async {
    final clubId = ref.watch(activeClubIdProvider).valueOrNull;
    if (clubId == null) return [];
    return ref
        .read(approvalsRepositoryProvider)
        .fetchPending(clubId: clubId);
  }

  Future<void> approve(String paymentId) async {
    final clubId = ref.read(activeClubIdProvider).valueOrNull;
    if (clubId == null) return;
    await ref.read(approvalsRepositoryProvider).approve(
          paymentId: paymentId,
          clubId: clubId,
        );
    // Optimistic: remove from list
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((p) => p.id != paymentId).toList());
  }

  Future<void> reject(String paymentId, String reason) async {
    final clubId = ref.read(activeClubIdProvider).valueOrNull;
    if (clubId == null) return;
    await ref.read(approvalsRepositoryProvider).reject(
          paymentId: paymentId,
          clubId: clubId,
          reason: reason,
        );
    // Optimistic: remove from list
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((p) => p.id != paymentId).toList());
  }
}
