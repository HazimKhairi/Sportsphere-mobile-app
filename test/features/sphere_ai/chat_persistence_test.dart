import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportsphere_mobile/features/sphere_ai/data/chat_persistence_repository.dart';
import 'package:sportsphere_mobile/features/sphere_ai/domain/chat_message.dart';

void main() {
  group('ChatPersistenceRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('saveThread stores messages as JSON', () async {
      final repo = ChatPersistenceRepository();
      final messages = [
        ChatMessage(role: ChatRole.user, text: 'Hello'),
        ChatMessage(role: ChatRole.assistant, text: 'Hi there!'),
      ];

      await repo.saveThread(uid: 'user1', messages: messages);

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('sphere_ai_thread_user1');
      expect(raw, isNotNull);
      final decoded = jsonDecode(raw!) as List;
      expect(decoded.length, 2);
      expect(decoded[0]['text'], 'Hello');
    });

    test('loadThread returns empty list when no saved thread', () async {
      final repo = ChatPersistenceRepository();
      final messages = await repo.loadThread(uid: 'no_user');
      expect(messages, isEmpty);
    });

    test('loadThread restores messages from JSON', () async {
      final repo = ChatPersistenceRepository();
      final messages = [
        ChatMessage(role: ChatRole.user, text: 'Test message'),
        ChatMessage(role: ChatRole.assistant, text: 'Test reply'),
      ];
      await repo.saveThread(uid: 'user2', messages: messages);

      final loaded = await repo.loadThread(uid: 'user2');
      expect(loaded.length, 2);
      expect(loaded[0].text, 'Test message');
      expect(loaded[0].role, ChatRole.user);
      expect(loaded[1].role, ChatRole.assistant);
    });

    test('clearThread removes saved data', () async {
      final repo = ChatPersistenceRepository();
      final messages = [ChatMessage(role: ChatRole.user, text: 'Hi')];
      await repo.saveThread(uid: 'user3', messages: messages);
      await repo.clearThread(uid: 'user3');

      final loaded = await repo.loadThread(uid: 'user3');
      expect(loaded, isEmpty);
    });
  });
}
