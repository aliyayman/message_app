// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:message_app/chat_repo.dart';
import 'package:message_app/chat_state.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';



class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  final int senderId;
  final int recipientId;
  StompClient? _stompClient;

  ChatCubit({
    required ChatRepository repository,
    required this.senderId,
    required this.recipientId,
  })  : _repository = repository,
        super(ChatState(messages: [], isConnected: false));

  void connect() {
    _stompClient = _repository.createStompClient(
      onConnect: _onConnect,
      onError: (error) {
        print("WebSocket Error: $error");
        emit(state.copyWith(isConnected: false));
      },
    );

    _stompClient?.activate();
  }

  void _onConnect(StompFrame frame) {
    print("Connected to STOMP");
    emit(state.copyWith(isConnected: true));

    _stompClient?.subscribe(
      destination: '/user/${senderId}_$recipientId/queue/messages',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          final data = Map<String, dynamic>.from(jsonDecode(frame.body!));
          emit(state.copyWith(messages: [...state.messages, data]));
        }
      },
    );

    _stompClient?.subscribe(
      destination: '/topic/messages',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          final data = Map<String, dynamic>.from(jsonDecode(frame.body!));
          emit(state.copyWith(messages: [...state.messages, data]));
        }
      },
    );
  }

  void sendMessage(String content) {
    if (content.isNotEmpty) {
      final message = {
        "senderId": senderId,
        "recipientId": recipientId,
        "content": content,
        "status": false
      };

      _repository.sendMessage(_stompClient, '/app/chat', message);
    }
  }

  void disconnect() {
    _stompClient?.deactivate();
    emit(state.copyWith(isConnected: false));
  }
}
