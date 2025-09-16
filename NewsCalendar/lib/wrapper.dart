import 'package:flutter/material.dart';
import 'package:newscalendar/homepage.dart';
import 'package:newscalendar/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      await Provider.of<AuthService>(context, listen: false).checkAuthStatus();
    } catch (e) {
      debugPrint('Error checking auth status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(body: _buildContent(authService));
  }

  Widget _buildContent(AuthService authService) {
    if (authService.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return authService.isAuthenticated
        ? Homepage(token: authService.token)
        : const Login();
  }
}
