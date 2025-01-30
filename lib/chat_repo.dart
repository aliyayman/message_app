import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatRepository {
  final String serverUrl = 'ws://54.77.20.243:1223/ws/websocket';
  final apiKey = dotenv.get('WS_URL', fallback: 'DEFAULT_KEY');

  StompClient createStompClient({
    required Function(StompFrame) onConnect,
    required Function(dynamic) onError,
  }) {
    return StompClient(
      config: StompConfig(
        url: apiKey,
        onConnect: onConnect,
        onWebSocketError: onError,
        stompConnectHeaders: {},
        webSocketConnectHeaders: {},
      ),
    );
  }

  void sendMessage(StompClient? client, String destination, Map<String, dynamic> message) {
    if (client?.isActive == true) {
      client?.send(
        destination: destination,
        body: jsonEncode(message),
      );
    }
  }
}
