class ChatState {
  final List<Map<String, dynamic>> messages;
  final bool isConnected;

  ChatState({
    required this.messages,
    required this.isConnected,
  });

  ChatState copyWith({List<Map<String, dynamic>>? messages, bool? isConnected}) {
    return ChatState(
      messages: messages ?? this.messages,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}