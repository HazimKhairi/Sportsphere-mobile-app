enum ChatRole { user, assistant }

class ChatMessage {
  ChatMessage({
    required this.role,
    required this.text,
    this.isStreaming = false,
  });
  final ChatRole role;
  String text;
  bool isStreaming;
}
