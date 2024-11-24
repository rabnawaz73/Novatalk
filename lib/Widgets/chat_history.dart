import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ChatHistory extends StatelessWidget {
  final Function(String chatId) onOpenChat;

  const ChatHistory({super.key, required this.onOpenChat});

  @override
  Widget build(BuildContext context) {
    final chatBox = Hive.box('chats');
    final chatKeys = chatBox.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Chat History")),
      body: chatKeys.isEmpty
          ? const Center(child: Text("No chat history found"))
          : ListView.builder(
              itemCount: chatKeys.length,
              itemBuilder: (context, index) {
                final chatId = chatKeys[index];
                final chatData = chatBox.get(chatId);
                return ListTile(
                  title: Text(chatData['title'] ?? "Untitled Chat"),
                  subtitle: Text("Chat ID: $chatId"),
                  onTap: () {
                    onOpenChat(chatId);
                    Navigator.pop(context); // Close history screen
                  },
                );
              },
            ),
    );
  }
}
