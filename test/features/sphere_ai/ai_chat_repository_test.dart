import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sportsphere_mobile/features/sphere_ai/data/ai_chat_repository.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late AiChatRepository repo;

  setUp(() {
    dio = _MockDio();
    registerFallbackValue(Options());
    repo = AiChatRepository(dio: dio);
  });

  test('streamMessage parses SSE deltas + done event', () async {
    final lines = [
      'data: {"delta":"Hi "}\n',
      'data: {"delta":"there!"}\n',
      'data: {"event":"done"}\n',
    ];
    final stream = Stream<Uint8List>.fromIterable(
      lines.map((l) => Uint8List.fromList(utf8.encode(l))),
    );

    when(() => dio.post<ResponseBody>(
          '/api/ai/chat',
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => Response<ResponseBody>(
              requestOptions: RequestOptions(path: '/api/ai/chat'),
              statusCode: 200,
              data: ResponseBody(stream, 200),
            ));

    final deltas = <String>[];
    await for (final d in repo.streamMessage(
      message: 'hello',
      threadId: 'thread_1',
    )) {
      deltas.add(d);
    }

    expect(deltas, ['Hi ', 'there!']);
  });

  test('streamMessage posts body with message + threadId + surface', () async {
    final stream = Stream<Uint8List>.fromIterable([
      Uint8List.fromList(utf8.encode('data: {"event":"done"}\n')),
    ]);

    when(() => dio.post<ResponseBody>(
          '/api/ai/chat',
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => Response<ResponseBody>(
              requestOptions: RequestOptions(path: '/api/ai/chat'),
              statusCode: 200,
              data: ResponseBody(stream, 200),
            ));

    await repo.streamMessage(message: 'hi', threadId: 'tid').drain<void>();

    final captured = verify(() => dio.post<ResponseBody>(
          '/api/ai/chat',
          data: captureAny(named: 'data'),
          options: any(named: 'options'),
        )).captured.single as Map;
    expect(captured['message'], 'hi');
    expect(captured['threadId'], 'tid');
    expect(captured['surface'], 'club');
  });

  test('streamMessage handles chunks containing multiple events', () async {
    // One byte chunk with two events.
    final stream = Stream<Uint8List>.fromIterable([
      Uint8List.fromList(utf8.encode(
        'data: {"delta":"A"}\ndata: {"delta":"B"}\ndata: {"event":"done"}\n',
      )),
    ]);

    when(() => dio.post<ResponseBody>(
          '/api/ai/chat',
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => Response<ResponseBody>(
              requestOptions: RequestOptions(path: '/api/ai/chat'),
              statusCode: 200,
              data: ResponseBody(stream, 200),
            ));

    final deltas = await repo.streamMessage(
      message: 'x',
      threadId: 't',
    ).toList();
    expect(deltas, ['A', 'B']);
  });
}
