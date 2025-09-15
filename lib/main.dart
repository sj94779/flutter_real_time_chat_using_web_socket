import 'package:flutter/material.dart';
import 'package:websocket/pages/chat_page.dart';
import 'package:websocket/pages/login_page.dart';
import 'package:websocket/services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _startScreen() async {
    final token = await AuthService.getToken();
    return token != null ? const ChatPage() : const LoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder(
        future: _startScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data!;
          }
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }
}


