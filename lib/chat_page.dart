import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:message_app/chat_repo.dart';
import 'package:message_app/chat_state.dart';
import 'chat_cubit.dart';

class ChatPage extends StatelessWidget {
  final int senderId = 5;
  final int recipientId = 1;
  final TextEditingController _messageController = TextEditingController();

  ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(
        repository: ChatRepository(),
        senderId: senderId,
        recipientId: recipientId,
      )..connect(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("STOMP Chat"),
          actions: [
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                return Container(
                  margin: const EdgeInsets.all(16),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: state.isConnected ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  return ListView.builder(
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isMe = message["senderId"] == senderId;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[300] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(message["content"]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state.isConnected
                            ? () {
                                context.read<ChatCubit>().sendMessage(_messageController.text);
                                _messageController.clear();
                              }
                            : null,
                        child: const Text("Send"),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
