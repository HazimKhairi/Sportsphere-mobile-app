import 'dart:io' show File;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_theme_ext.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../data/chat_persistence_repository.dart';
import '../domain/chat_message.dart';
import 'ai_chat_providers.dart';
import '../../../l10n/app_localizations.dart';

class SphereAiScreen extends ConsumerStatefulWidget {
  const SphereAiScreen({super.key});

  @override
  ConsumerState<SphereAiScreen> createState() => _SphereAiScreenState();
}

class _SphereAiScreenState extends ConsumerState<SphereAiScreen> {
  final _composer = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <ChatMessage>[];
  late String _threadId;
  bool _busy = false;
  bool _attaching = false;
  String? _uid;

  static const _suggestions = [
    'How can I improve my ball control?',
    'Plan my training for this week.',
    'Why is my streak important?',
    "Summary of today's session.",
  ];

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    // Day-keyed thread ID: same thread all day, new thread each day
    _threadId =
        'mob_${_uid}_${DateTime.now().millisecondsSinceEpoch ~/ 86400000}';
    // Load persisted thread
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repo = ref.read(chatPersistenceRepositoryProvider);
      final saved = await repo.loadThread(uid: _uid!);
      if (saved.isNotEmpty && mounted) {
        setState(() => _messages.addAll(saved));
      }
    });
  }

  @override
  void dispose() {
    _composer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _busy) return;
    _composer.clear();

    final user = ChatMessage(role: ChatRole.user, text: trimmed);
    final assistant = ChatMessage(
      role: ChatRole.assistant,
      text: '',
      isStreaming: true,
    );
    setState(() {
      _messages.add(user);
      _messages.add(assistant);
      _busy = true;
    });
    _jumpToBottom();

    // Build messages array from full conversation history (backend needs all turns).
    final messagesPayload = _messages
        .where((m) => !m.isStreaming || m.text.isNotEmpty)
        .map((m) => {
              'role': m.role == ChatRole.user ? 'user' : 'assistant',
              'text': m.text,
            })
        .toList();

    try {
      await for (final delta in ref
          .read(aiChatRepositoryProvider)
          .streamMessage(messages: messagesPayload, threadId: _threadId)) {
        if (!mounted) return;
        setState(() {
          assistant.text += delta;
        });
        _jumpToBottom();
      }
    } catch (e) {
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        setState(() {
          assistant.text = assistant.text.isEmpty
              ? l.connectionDropped
              : '${assistant.text}\n\n_Connection dropped._';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          assistant.isStreaming = false;
          _busy = false;
        });
        _jumpToBottom();
        // Persist after response completes
        final repo = ref.read(chatPersistenceRepositoryProvider);
        await repo.saveThread(uid: _uid!, messages: _messages);
      }
    }
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _clearChat() async {
    if (_uid == null) return;
    await ref.read(chatPersistenceRepositoryProvider).clearThread(uid: _uid!);
    setState(() {
      _messages.clear();
      _threadId = 'mob_${_uid}_${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  Future<void> _attachImage() async {
    if (_attaching || _busy) return;
    setState(() => _attaching = true);
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1280,
      );
      if (file == null || !mounted) return;

      // Upload to Firebase Storage
      final uid = _uid ?? 'anon';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = FirebaseStorage.instance
          .ref('chat-attachments/$uid/$timestamp.jpg');
      final bytes = await File(file.path).readAsBytes();
      await storageRef.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await storageRef.getDownloadURL();

      // Append URL to composer text
      if (mounted) {
        final current = _composer.text;
        _composer.text = current.isEmpty
            ? '[Image: $url]'
            : '$current\n[Image: $url]';
      }
    } catch (e) {
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.couldNotAttachImage)),
        );
      }
    } finally {
      if (mounted) setState(() => _attaching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.sc.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SphereSpacing.x24,
                SphereSpacing.x16,
                SphereSpacing.x24,
                SphereSpacing.x8,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.sc.primary.withValues(alpha: 0.18),
                      border: Border.all(
                        color: context.sc.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      LucideIcons.sparkles,
                      color: context.sc.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: SphereSpacing.x12),
                  Text(
                    'Sphere AI',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  Builder(
                    builder: (context) {
                      final l = AppLocalizations.of(context)!;
                      return IconButton(
                        icon: Icon(
                          LucideIcons.rotateCcw,
                          size: 18,
                          color: context.sc.onSurfaceMuted,
                        ),
                        tooltip: l.newChat,
                        onPressed: _clearChat,
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: _messages.isEmpty
                  ? _EmptyState(
                      suggestions: _suggestions,
                      onTap: _send,
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(
                        SphereSpacing.x16,
                        SphereSpacing.x8,
                        SphereSpacing.x16,
                        SphereSpacing.x16,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, i) {
                        final m = _messages[i];
                        return _ChatBubble(message: m);
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SphereSpacing.x16,
                vertical: SphereSpacing.x8,
              ),
              child: _Composer(
                controller: _composer,
                busy: _busy || _attaching,
                onSubmit: _send,
                onAttach: _attachImage,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.suggestions, required this.onTap});
  final List<String> suggestions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        SphereSpacing.x24,
        SphereSpacing.x16,
        SphereSpacing.x24,
        SphereSpacing.x16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ask anything about your game.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: context.sc.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: SphereSpacing.x8),
          Text(
            'I can help with drills, schedules, and what to work on next.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.sc.onSurfaceMuted,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: SphereSpacing.x32),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final s in suggestions)
                _SuggestionChip(label: s, onTap: () => onTap(s)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.sc.surfaceElev1,
      borderRadius: SphereRadius.pillRect,
      child: InkWell(
        onTap: onTap,
        borderRadius: SphereRadius.pillRect,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: SphereRadius.pillRect,
            border: Border.all(
              color: context.sc.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.onSurface,
                ),
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.sc.primary.withValues(alpha: 0.18),
                border: Border.all(
                  color: context.sc.primary.withValues(alpha: 0.4),
                ),
              ),
              child: Icon(
                LucideIcons.sparkles,
                size: 14,
                color: context.sc.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SphereSpacing.x16,
                vertical: SphereSpacing.x12,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? context.sc.primary
                    : context.sc.surfaceElev1,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(color: context.sc.borderSubtle),
              ),
              child: isUser
                  ? Text(
                      message.text,
                      style: TextStyle(
                        color: context.sc.onPrimary,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    )
                  : (message.text.isEmpty && message.isStreaming
                      ? const _TypingDots()
                      : MarkdownBody(
                          data: message.text +
                              (message.isStreaming ? ' ▍' : ''),
                          styleSheet: _markdownStyle(context),
                        )),
            ),
          ),
        ],
      ),
    );
  }

  MarkdownStyleSheet _markdownStyle(BuildContext context) {
    return MarkdownStyleSheet(
      p: TextStyle(
        color: context.sc.onSurface,
        fontSize: 14,
        height: 1.45,
      ),
      strong: TextStyle(
        color: context.sc.onSurface,
        fontWeight: FontWeight.w700,
      ),
      em: TextStyle(
        color: context.sc.onSurface,
        fontStyle: FontStyle.italic,
      ),
      a: TextStyle(
        color: context.sc.primary,
        decoration: TextDecoration.underline,
      ),
      h1: TextStyle(
        color: context.sc.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      h2: TextStyle(
        color: context.sc.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
      h3: TextStyle(
        color: context.sc.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
      code: TextStyle(
        color: context.sc.primary,
        fontFamily: 'Geist',
        backgroundColor: const Color(0xFF0A0A0A),
        fontSize: 13,
      ),
      blockSpacing: 8,
      listBullet: TextStyle(color: context.sc.primary),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        double dotOpacity(int i) {
          final phase = (t - i * 0.2) % 1.0;
          return 0.3 + 0.7 * (1 - (phase * 2 - 1).abs()).clamp(0.0, 1.0);
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++) ...[
              Opacity(
                opacity: dotOpacity(i),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.sc.primary,
                  ),
                ),
              ),
              if (i < 2) const SizedBox(width: 4),
            ],
          ],
        );
      },
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.busy,
    required this.onSubmit,
    this.onAttach,
  });
  final TextEditingController controller;
  final bool busy;
  final ValueChanged<String> onSubmit;
  final VoidCallback? onAttach;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: context.sc.surfaceElev2,
        borderRadius: SphereRadius.pillRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
      child: Row(
        children: [
          // Attach button
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: busy ? null : onAttach,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  LucideIcons.paperclip,
                  size: 18,
                  color: busy
                      ? context.sc.onSurfaceMuted.withValues(alpha: 0.4)
                      : context.sc.onSurfaceMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: onSubmit,
              style: TextStyle(color: context.sc.onSurface),
              decoration: InputDecoration(
                hintText: l.askSphereAi,
                hintStyle: TextStyle(color: context.sc.onSurfaceMuted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Material(
            color: busy
                ? context.sc.primary.withValues(alpha: 0.5)
                : context.sc.primary,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: busy ? null : () => onSubmit(controller.text),
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  LucideIcons.arrowUp,
                  color: context.sc.onPrimary,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
