import 'package:flutter/material.dart';
import 'package:websocket/pages/login_page.dart';
import 'package:websocket/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  void _register() async {
    final success = await AuthService.register(_username.text, _password.text);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful. Please login.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User already exists')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _username, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _register, child: const Text('Register')),
          ],
        ),
      ),
    );
  }
}
