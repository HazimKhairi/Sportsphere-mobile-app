import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sportsphere_mobile/features/roster/data/roster_repository.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late RosterRepository repo;

  setUp(() {
    dio = _MockDio();
    registerFallbackValue(Options());
    repo = RosterRepository(dio: dio);
  });

  test('listPlayers success', () async {
    when(() => dio.get<Map<String, dynamic>>(
          '/api/players/mobile',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/api/players/mobile'),
              statusCode: 200,
              data: {
                'players': [
                  {
                    'id': 'player1',
                    'firstName': 'Ahmad',
                    'lastName': 'Zulkifli',
                    'email': 'ahmad@example.com',
                    'phone': '+601123456789',
                    'position': 'Midfielder',
                    'teamName': 'U12 Team A',
                    'photoUrl': null,
                    'dateOfBirth': '2012-03-15',
                  }
                ],
                'nextCursor': 'lastDocId',
              },
            ));

    final page = await repo.listPlayers(clubId: 'club123');

    expect(page.players.length, 1);
    expect(page.players[0].fullName, 'Ahmad Zulkifli');
    expect(page.nextCursor, 'lastDocId');
  });

  test('listPlayers passes cursor', () async {
    final captured = <Map<String, dynamic>>[];

    when(() => dio.get<Map<String, dynamic>>(
          '/api/players/mobile',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        )).thenAnswer((invocation) async {
      final params = invocation.namedArguments[#queryParameters]
          as Map<String, dynamic>;
      captured.add(Map<String, dynamic>.from(params));
      return Response(
        requestOptions: RequestOptions(path: '/api/players/mobile'),
        statusCode: 200,
        data: <String, dynamic>{'players': <dynamic>[], 'nextCursor': null},
      );
    });

    await repo.listPlayers(clubId: 'club123', cursor: 'abc');

    expect(captured.length, 1);
    expect(captured[0]['cursor'], 'abc');
    expect(captured[0]['limit'], 25);
  });

  test('listPlayers propagates DioException', () async {
    when(() => dio.get<Map<String, dynamic>>(
          '/api/players/mobile',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/players/mobile'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/players/mobile'),
            statusCode: 401,
            data: {'error': 'Unauthorized'},
          ),
          type: DioExceptionType.badResponse,
        ));

    expect(
      () => repo.listPlayers(clubId: 'club123'),
      throwsA(isA<RosterException>()),
    );
  });

  test('listPlayers passes X-Club-Id header', () async {
    Options? capturedOptions;

    when(() => dio.get<Map<String, dynamic>>(
          '/api/players/mobile',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        )).thenAnswer((invocation) async {
      capturedOptions =
          invocation.namedArguments[#options] as Options;
      return Response(
        requestOptions: RequestOptions(path: '/api/players/mobile'),
        statusCode: 200,
        data: <String, dynamic>{'players': <dynamic>[], 'nextCursor': null},
      );
    });

    await repo.listPlayers(clubId: 'club123');

    expect(capturedOptions, isNotNull);
    expect(capturedOptions!.headers, isNotNull);
    expect(capturedOptions!.headers!['X-Club-Id'], 'club123');
  });
}
