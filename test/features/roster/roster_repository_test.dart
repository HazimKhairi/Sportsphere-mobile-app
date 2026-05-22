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

  // ---------------------------------------------------------------------------
  // createPlayer
  // ---------------------------------------------------------------------------

  test('createPlayer success', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/players/mobile',
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/api/players/mobile'),
              statusCode: 201,
              data: {
                'player': {
                  'id': 'new1',
                  'firstName': 'Ahmad',
                  'lastName': 'Zulkifli',
                  'email': 'ahmad@example.com',
                  'phone': '+601123456789',
                  'position': 'Midfielder',
                  'teamName': '',
                  'photoUrl': null,
                  'dateOfBirth': null,
                }
              },
            ));

    final result = await repo.createPlayer(
      clubId: 'club123',
      firstName: 'Ahmad',
      lastName: 'Zulkifli',
      email: 'ahmad@example.com',
    );

    expect(result.fullName, 'Ahmad Zulkifli');
    expect(result.id, 'new1');
  });

  test('createPlayer sends X-Club-Id header', () async {
    Options? capturedOptions;

    when(() => dio.post<Map<String, dynamic>>(
          '/api/players/mobile',
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((invocation) async {
      capturedOptions = invocation.namedArguments[#options] as Options;
      return Response(
        requestOptions: RequestOptions(path: '/api/players/mobile'),
        statusCode: 201,
        data: {
          'player': {
            'id': 'x',
            'firstName': 'A',
            'lastName': 'B',
            'email': '',
            'phone': '',
            'position': '',
            'teamName': '',
            'photoUrl': null,
            'dateOfBirth': null,
          }
        },
      );
    });

    await repo.createPlayer(
      clubId: 'club123',
      firstName: 'A',
      lastName: 'B',
    );

    expect(capturedOptions, isNotNull);
    expect(capturedOptions!.headers, isNotNull);
    expect(capturedOptions!.headers!['X-Club-Id'], 'club123');
  });

  test('createPlayer propagates RosterException on 400', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/players/mobile',
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/players/mobile'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/players/mobile'),
            statusCode: 400,
            data: {'error': 'Email already exists'},
          ),
          type: DioExceptionType.badResponse,
        ));

    expect(
      () => repo.createPlayer(
        clubId: 'club123',
        firstName: 'A',
        lastName: 'B',
        email: 'dup@example.com',
      ),
      throwsA(isA<RosterException>()),
    );
  });

  test('getPlayer success', () async {
    when(() => dio.get<Map<String, dynamic>>(
          '/api/players/abc',
        )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/api/players/abc'),
              statusCode: 200,
              data: {
                'player': {
                  'id': 'abc',
                  'firstName': 'Ahmad',
                  'lastName': 'Zulkifli',
                  'email': 'ahmad@example.com',
                  'phone': '+601123456789',
                  'position': 'Midfielder',
                  'teamName': 'U12 Team A',
                  'photoUrl': null,
                  'dateOfBirth': '2012-03-15',
                  'availability': 'injured',
                  'jerseyNumber': 10,
                  'parentName': 'Zulkifli Hamid',
                  'parentPhone': '+601198765432',
                }
              },
            ));

    final detail = await repo.getPlayer(id: 'abc');

    expect(detail.fullName, 'Ahmad Zulkifli');
    expect(detail.availability, 'injured');
    expect(detail.jerseyNumber, 10);
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
