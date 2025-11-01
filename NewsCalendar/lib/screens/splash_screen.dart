import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Check authentication status first
    try {
      await Provider.of<AuthService>(context, listen: false).checkAuthStatus();
    } catch (e) {
      debugPrint('Error checking auth status: $e');
    }

    // Wait for splash screen display (minimum 2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Navigate to Wrapper which handles authentication routing
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Wrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo or animation here
            Icon(Icons.calendar_today, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'CyberCalendar',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 10),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
