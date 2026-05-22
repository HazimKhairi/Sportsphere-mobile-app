import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sportsphere_mobile/features/programs/data/registration_repository.dart';
import 'package:sportsphere_mobile/features/programs/domain/registration_status.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  group('isRegistered', () {
    test('returns true when registrants/{playerId} doc exists with active status', () async {
      final fs = FakeFirebaseFirestore();
      await fs
          .collection('clubs')
          .doc('club_1')
          .collection('programs')
          .doc('prog_1')
          .collection('registrants')
          .doc('player_1')
          .set({'status': 'active', 'paidAt': Timestamp.now()});

      final repo = RegistrationRepository(
        firestore: fs,
        dio: _MockDio(),
      );

      final result = await repo.isRegistered(
        clubId: 'club_1',
        programId: 'prog_1',
        playerId: 'player_1',
      );
      expect(result, true);
    });

    test('returns false when registrant doc missing', () async {
      final fs = FakeFirebaseFirestore();
      final repo = RegistrationRepository(
        firestore: fs,
        dio: _MockDio(),
      );
      final result = await repo.isRegistered(
        clubId: 'club_1',
        programId: 'prog_1',
        playerId: 'no_one',
      );
      expect(result, false);
    });

    test('returns false when status is cancelled', () async {
      final fs = FakeFirebaseFirestore();
      await fs
          .collection('clubs')
          .doc('club_1')
          .collection('programs')
          .doc('prog_1')
          .collection('registrants')
          .doc('player_1')
          .set({'status': 'cancelled'});

      final repo = RegistrationRepository(
        firestore: fs,
        dio: _MockDio(),
      );
      final result = await repo.isRegistered(
        clubId: 'club_1',
        programId: 'prog_1',
        playerId: 'player_1',
      );
      expect(result, false);
    });
  });

  group('confirmRegistration', () {
    test('POSTs to /api/programs/register with payload', () async {
      final dio = _MockDio();
      registerFallbackValue(Options());
      when(() => dio.post<Map<String, dynamic>>(
            '/api/programs/register',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/api/programs/register'),
                statusCode: 200,
                data: {'registrationId': 'reg_abc', 'status': 'active'},
              ));

      final repo = RegistrationRepository(
        firestore: FakeFirebaseFirestore(),
        dio: dio,
      );

      final result = await repo.confirmRegistration(
        programId: 'prog_1',
        paymentIntentId: 'pi_abc',
      );

      expect(result.registrationId, 'reg_abc');
      expect(result.status, RegistrationStatusKind.active);
      verify(() => dio.post<Map<String, dynamic>>(
            '/api/programs/register',
            data: {
              'programId': 'prog_1',
              'paymentIntentId': 'pi_abc',
            },
          )).called(1);
    });

    test('throws RegistrationException on 4xx', () async {
      final dio = _MockDio();
      registerFallbackValue(Options());
      when(() => dio.post<Map<String, dynamic>>(
            '/api/programs/register',
            data: any(named: 'data'),
          )).thenThrow(DioException(
            requestOptions: RequestOptions(path: '/api/programs/register'),
            response: Response(
              requestOptions: RequestOptions(path: '/api/programs/register'),
              statusCode: 409,
              data: {'error': 'Already registered'},
            ),
            type: DioExceptionType.badResponse,
          ));

      final repo = RegistrationRepository(
        firestore: FakeFirebaseFirestore(),
        dio: dio,
      );

      expect(
        () => repo.confirmRegistration(programId: 'p', paymentIntentId: 'pi'),
        throwsA(isA<RegistrationException>()),
      );
    });
  });
}
