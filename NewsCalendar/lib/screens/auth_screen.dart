import 'package:flutter/material.dart';
import 'package:newscalendar/screens/login_screen.dart';
import '/screens/register_screen.dart';
import 'package:provider/provider.dart';
import '/services/auth_service.dart';
import 'home_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return authService.isAuthenticated
        ? const HomeScreen()
        : DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('JWT Authentication'),
              bottom: const TabBar(
                tabs: [Tab(text: 'Login'), Tab(text: 'Register')],
              ),
            ),
            body: const TabBarView(children: [Login(), RegisterScreen()]),
          ),
        );
  }
}
