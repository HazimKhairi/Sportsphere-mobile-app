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

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'text': text,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        role: ChatRole.values.firstWhere((r) => r.name == json['role']),
        text: json['text'] as String,
      );
}
