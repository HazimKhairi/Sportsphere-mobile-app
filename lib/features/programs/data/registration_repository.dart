import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

import '../domain/registration_status.dart';

class RegistrationRepository {
  RegistrationRepository({
    FirebaseFirestore? firestore,
    required Dio dio,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _dio = dio;

  final FirebaseFirestore _db;
  final Dio _dio;

  Future<bool> isRegistered({
    required String clubId,
    required String programId,
    required String playerId,
  }) async {
    final doc = await _db
        .collection('clubs')
        .doc(clubId)
        .collection('programs')
        .doc(programId)
        .collection('registrants')
        .doc(playerId)
        .get();
    if (!doc.exists) return false;
    final status = doc.data()?['status'] as String?;
    final kind = RegistrationStatusKind.fromString(status);
    return kind == RegistrationStatusKind.active ||
        kind == RegistrationStatusKind.pending;
  }

  Future<RegistrationResult> confirmRegistration({
    required String programId,
    required String paymentIntentId,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/programs/register',
        data: {
          'programId': programId,
          'paymentIntentId': paymentIntentId,
        },
      );
      final data = res.data ?? const <String, dynamic>{};
      return RegistrationResult(
        registrationId: data['registrationId'] as String,
        status: RegistrationStatusKind.fromString(data['status'] as String?),
      );
    } on DioException catch (e) {
      throw RegistrationException(
        e.response?.data is Map
            ? (e.response!.data as Map)['error']?.toString() ?? 'Registration failed'
            : 'Registration failed',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
