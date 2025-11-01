import 'package:flutter/material.dart';
import 'package:newscalendar/homepage.dart';
import 'package:newscalendar/screens/login_screen.dart';
import 'package:newscalendar/screens/offline_screen.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/network_service.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialize ConnectivityProvider with context
    final connectivityProvider = Provider.of<ConnectivityProvider>(
      context,
      listen: false,
    );
    connectivityProvider.initialize(context);

    // Check authentication status
    try {
      await Provider.of<AuthService>(context, listen: false).checkAuthStatus();
    } catch (e) {
      debugPrint('Error checking auth status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final connectivityProvider = Provider.of<ConnectivityProvider>(context);

    // Show offline screen if not online
    if (!connectivityProvider.isOnline) {
      return const OfflineScreen();
    }

    return Scaffold(body: _buildContent(authService));
  }

  Widget _buildContent(AuthService authService) {
    if (authService.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // If user is not authenticated, show login page
    if (!authService.isAuthenticated) {
      return const Login();
    }

    // User is authenticated, show homepage
    return Homepage(token: authService.token);
  }
}
