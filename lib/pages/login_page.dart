import 'package:flutter/material.dart';
import 'package:websocket/pages/chat_page.dart';
import 'package:websocket/pages/register_page.dart';
import 'package:websocket/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  void _login() async {
    final success = await AuthService.login(_username.text, _password.text);
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChatPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _username, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
              child: const Text('Register instead'),
            ),
          ],
        ),
      ),
    );
  }
}
