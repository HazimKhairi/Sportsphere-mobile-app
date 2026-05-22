import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

class AiChatException implements Exception {
  AiChatException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => 'AiChatException($statusCode): $message';
}

class AiChatRepository {
  AiChatRepository({required Dio dio}) : _dio = dio;
  final Dio _dio;

  /// Streams incremental text deltas as the assistant responds.
  /// Emits ONLY content deltas (not raw SSE events). Completes when the
  /// server emits `{"event":"done"}`.
  Stream<String> streamMessage({
    required String message,
    required String threadId,
    String surface = 'club',
  }) async* {
    final Response<ResponseBody> res;
    try {
      res = await _dio.post<ResponseBody>(
        '/api/ai/chat',
        data: <String, dynamic>{
          'message': message,
          'threadId': threadId,
          'surface': surface,
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: const {'Accept': 'text/event-stream'},
        ),
      );
    } on DioException catch (e) {
      throw AiChatException(
        e.message ?? 'Sphere AI request failed',
        statusCode: e.response?.statusCode,
      );
    }

    final body = res.data;
    if (body == null) return;

    var buffer = '';
    await for (final chunk in body.stream) {
      buffer += utf8.decode(chunk, allowMalformed: true);
      // Split on newlines; keep the trailing incomplete line in buffer.
      final lines = buffer.split('\n');
      buffer = lines.removeLast();
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || !trimmed.startsWith('data:')) continue;
        final jsonStr = trimmed.substring(5).trim();
        if (jsonStr.isEmpty) continue;
        try {
          final obj = jsonDecode(jsonStr);
          if (obj is Map) {
            if (obj['event'] == 'done') return;
            final delta = obj['delta'];
            if (delta is String && delta.isNotEmpty) {
              yield delta;
            }
          }
        } catch (_) {
          // Ignore malformed lines.
        }
      }
    }
  }
}
