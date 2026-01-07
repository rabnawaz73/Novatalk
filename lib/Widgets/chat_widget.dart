import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:hive/hive.dart';
import 'package:novatalk/Widgets/_drawer.dart';
import 'chat_history.dart';

class DashChatitle extends StatefulWidget {
  const DashChatitle({super.key});

  @override
  State<DashChatitle> createState() => _DashChatitleState();
}

class _DashChatitleState extends State<DashChatitle> {
  final Gemini gemini = Gemini.init(apiKey: dotenv.env['GEMINI_API_KEY']!);
  final ChatUser geminiUser = ChatUser(
    id: '2',
    firstName: 'Gemini',
  );


  late ChatUser currentUser;

  List<ChatMessage> chatMessages = [];
  final chatBox = Hive.box('chats');
  String currentChatId = '';
  bool isGeminiTyping = false;

  @override
  void initState() {
    super.initState();
    User? currentFirebaseUser = FirebaseAuth.instance.currentUser;

    if (currentFirebaseUser != null) {
      currentUser = ChatUser(
        id: currentFirebaseUser.uid,
        firstName: currentFirebaseUser.displayName ?? 'Guest User',
        lastName: currentFirebaseUser.email ?? "guest@example.com",
        profileImage: currentFirebaseUser.photoURL ?? 'assets/logo.png',
      );
    } else {
      currentUser = ChatUser(
        id: '0',
        firstName: 'Guest',
      );
    }
    _createNewChat();
  }

  Future<void> _createNewChat() async {
    setState(() {
      chatMessages = [];
      currentChatId = DateTime.now().toIso8601String();
    });
    chatBox.put(currentChatId, {
      'title': 'New Chat',
      'messages': [],
    });
  }

  Future<void> _openExistingChat(String chatId) async {
    final chatData = chatBox.get(chatId);
    if (chatData != null) {
      setState(() {
        currentChatId = chatId;
        chatMessages = (chatData['messages'] as List)
            .map((msg) => ChatMessage.fromJson(Map<String, dynamic>.from(msg)))
            .toList();
      });
    }
  }

  Future<void> _updateChatTitle(String title) async {
    final chatData = chatBox.get(currentChatId);
    if (chatData != null) {
      chatBox.put(currentChatId, {
        ...chatData,
        'title': title,
      });
    }
  }

  Future<void> _saveMessage(ChatMessage message) async {
    setState(() {
      chatMessages.insert(0, message);
    });
    final chatData = chatBox.get(currentChatId);
    final updatedMessages = [
      ...chatData['messages'],
      message.toJson(),
    ];
    chatBox.put(currentChatId, {
      ...chatData,
      'messages': updatedMessages,
    });
    if (chatMessages.length == 1) {
      await _updateChatTitle(message.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NovaTalk'),
        backgroundColor: Colors.indigo,
        centerTitle: true,
        elevation: 5,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: Icon(Icons.menu, color: Colors.indigo.shade100),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'new') {
                _createNewChat();
              } else if (value == 'history') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatHistory(onOpenChat: _openExistingChat),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'new', child: Text('New Chat')),
              const PopupMenuItem(
                  value: 'history', child: Text('Chat History')),
            ],
          ),
        ],
      ),
      drawer: CustomDrawer(
        currentUser: currentUser,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade100, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: DashChat(
          readOnly: false,
          messageOptions: const MessageOptions(
            showOtherUsersAvatar: false,
            showOtherUsersName: false,
          ),
          currentUser: currentUser,
          messages: chatMessages,
          typingUsers: isGeminiTyping ? [geminiUser] : [],
          inputOptions: InputOptions(
            inputDecoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Type your message...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          onSend: (message) {
            _saveMessage(message);
            _handleResponse(message.text);
          },
        ),
      ),
    );
  }

  Future<void> _handleResponse(String query) async {
    setState(() {
      isGeminiTyping = true;
    });

    String completeResponse = "";

    try {
      await for (final response
          in gemini.promptStream(parts: [Part.text(query)])) {
        String? responsePart = response?.output;
    
        if (responsePart != null && responsePart.isNotEmpty) {
          completeResponse += responsePart;
          containsCode(completeResponse);
          setState(() {
            isGeminiTyping = true;
          });
        }
      }
    } catch (e) {
      completeResponse = "Error occurred: $e";
    }

    final response = ChatMessage(
      text: completeResponse.isNotEmpty ? completeResponse : "No response",
      user: geminiUser,
      createdAt: DateTime.now(),
    );

    await _saveMessage(response);

    setState(() {
      isGeminiTyping = false;
    });
  }

  bool containsCode(String response) {
    // Check for code block delimiters
    if (response.contains('```') || response.contains('`')) {
      return true;
    }

    // Check for common programming syntax patterns
    final codePatterns = [
      RegExp(r'\bclass\b'), // Matches "class"
      RegExp(r'\bvoid\b'), // Matches "void"
      RegExp(r'\bfunction\b'), // Matches "function"
      RegExp(r'[{}();\[\]]'), // Matches common code symbols
      RegExp(r'//'), // Matches comments
      RegExp(r'^[\s]*[a-zA-Z]+\(.*\)',
          multiLine: true), // Matches function calls
    ];

    for (final pattern in codePatterns) {
      if (pattern.hasMatch(response)) {
        return true;
      }
    }

    return false;
  }
}
