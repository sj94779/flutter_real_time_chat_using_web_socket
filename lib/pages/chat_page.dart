import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:websocket/services/auth_service.dart';
import 'login_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late WebSocketChannel channel;
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];

  void _connect(String token) {
    final uri = Uri.parse('ws://localhost:8080/?token=$token');
    channel = WebSocketChannel.connect(uri);

    channel.stream.listen((event) {
      final data = jsonDecode(event);
      setState(() {
        _messages.add("[${data['username']}] ${data['text']}");
      });
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      channel.sink.add(_controller.text);
      _controller.clear();
    }
  }

  void _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

  @override
  void initState() {
    super.initState();
    AuthService.getToken().then((token) {
      if (token != null) {
        _connect(token);
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout)],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (_, index) => ListTile(title: Text(_messages[index])),
            ),
          ),
          Row(
            children: [
              Expanded(child: TextField(controller: _controller)),
              IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
            ],
          )
        ],
      ),
    );
  }
}
