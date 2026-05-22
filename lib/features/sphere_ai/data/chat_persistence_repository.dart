import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/chat_message.dart';

part 'chat_persistence_repository.g.dart';

class ChatPersistenceRepository {
  static String _key(String uid) => 'sphere_ai_thread_$uid';

  Future<void> saveThread({
    required String uid,
    required List<ChatMessage> messages,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // Only persist completed messages (not streaming ones)
    final completed = messages.where((m) => !m.isStreaming).toList();
    final json = jsonEncode(completed.map((m) => m.toJson()).toList());
    await prefs.setString(_key(uid), json);
  }

  Future<List<ChatMessage>> loadThread({required String uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(uid));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearThread({required String uid}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(uid));
  }
}

@Riverpod(keepAlive: true)
ChatPersistenceRepository chatPersistenceRepository(Ref ref) =>
    ChatPersistenceRepository();
