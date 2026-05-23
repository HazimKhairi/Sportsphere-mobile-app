import 'dart:async';

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

  /// Sends a chat message and returns the reply as a single-item stream.
  /// Backend returns JSON { reply, suggestedPrompts, ... } — not SSE.
  Stream<String> streamMessage({
    required List<Map<String, String>> messages,
    required String threadId,
    String surface = 'club',
  }) async* {
    final Response<Map<String, dynamic>> res;
    try {
      res = await _dio.post<Map<String, dynamic>>(
        '/api/ai/chat',
        data: <String, dynamic>{
          'messages': messages,
          'threadId': threadId,
          'surface': surface,
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 3),
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

    final reply = body['reply'];
    if (reply is String && reply.isNotEmpty) {
      yield reply;
    } else {
      throw AiChatException('Empty response from Sphere AI');
    }
  }
}
