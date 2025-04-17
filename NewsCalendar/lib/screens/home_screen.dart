import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome ${user?['name'] ?? 'User'}!'),
            const SizedBox(height: 20),
            Text('Email: ${user?['email'] ?? ''}'),
          ],
        ),
      ),
    );
  }
}
