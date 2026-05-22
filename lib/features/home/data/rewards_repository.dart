import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

import '../domain/redemption_result.dart';
import '../domain/reward.dart';
import '../domain/voucher.dart';

class RewardsRepository {
  RewardsRepository({
    FirebaseFirestore? firestore,
    required Dio dio,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _dio = dio;

  final FirebaseFirestore _db;
  final Dio _dio;

  Stream<List<Reward>> streamCatalog({required String clubId}) {
    return _db
        .collection('clubs')
        .doc(clubId)
        .collection('rewards')
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .where((d) {
            final active = d.data()['active'];
            return active != false; // default active if missing
          })
          .map(_fromDoc)
          .toList();
      list.sort((a, b) => a.costPoints.compareTo(b.costPoints));
      return list;
    });
  }

  Stream<int> pointsBalanceStream({required String playerId}) {
    return _db.collection('players').doc(playerId).snapshots().map((snap) {
      final data = snap.data() ?? const <String, dynamic>{};
      return (data['points'] as int?) ?? 0;
    });
  }

  Future<RedemptionResult> redeem({required String rewardId}) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/player-app/rewards/redeem',
        data: {'rewardId': rewardId},
      );
      final data = res.data ?? const <String, dynamic>{};
      DateTime? expires;
      final raw = data['expiresAt'];
      if (raw is String) {
        expires = DateTime.tryParse(raw);
      }
      return RedemptionResult(
        code: data['code'] as String,
        remainingPoints: (data['remainingPoints'] as int?) ?? 0,
        expiresAt: expires,
      );
    } on DioException catch (e) {
      throw RewardsException(
        e.response?.data is Map
            ? (e.response!.data as Map)['error']?.toString() ??
                'Redeem failed'
            : 'Redeem failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<Voucher>> fetchMyVouchers() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/player-app/rewards/my-vouchers',
      );
      final data = res.data ?? const <String, dynamic>{};
      final rawList = data['vouchers'] as List<dynamic>? ?? [];
      return rawList
          .whereType<Map<String, dynamic>>()
          .map((e) => Voucher(
                id: e['id'] as String? ?? '',
                code: e['code'] as String? ?? '',
                rewardName: e['rewardName'] as String? ?? '',
                discountValue: e['discountValue'] as String? ?? '',
                expiresAt:
                    DateTime.tryParse(e['expiresAt'] as String? ?? '') ??
                        DateTime(0),
                status: e['status'] as String? ?? 'active',
              ))
          .toList();
    } on DioException catch (e) {
      throw RewardsException(
        e.response?.data is Map
            ? (e.response!.data as Map)['error']?.toString() ??
                'Failed to load vouchers'
            : 'Failed to load vouchers',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Reward _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Reward(
      id: doc.id,
      name: (data['name'] as String?)?.isNotEmpty == true
          ? data['name'] as String
          : 'Reward',
      description: (data['description'] as String?) ?? '',
      costPoints: (data['cost'] as int?) ?? 0,
      iconName: data['iconName'] as String?,
      stock: data['stock'] as int?,
      active: (data['active'] as bool?) ?? true,
    );
  }
}
