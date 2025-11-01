import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newscalendar/utils/imports.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  Timer? _timer;
  BuildContext? _context;

  ConnectivityProvider() {
    // Don't start monitoring immediately - wait for context
  }

  // Initialize with context to access AuthService
  void initialize(BuildContext context) {
    _context = context;
    _startMonitoring();
  }

  Future<void> _performConnectivityCheck() async {
    final previous = _isOnline;
    
    // Try to get token if context is available and user is authenticated
    String? token;
    if (_context != null) {
      try {
        final authService = Provider.of<AuthService>(_context!, listen: false);
        token = await authService.getAuthToken();
      } catch (e) {
        // Token not available, proceed without it
        debugPrint('Could not get auth token for connectivity check: $e');
      }
    }

    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      // Add token to headers if available
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final res = await http
          .get(
            Uri.parse('$BASE_URL/ping'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 2));

      _isOnline = res.statusCode == 200;
    } catch (_) {
      _isOnline = false;
    }

    if (_isOnline != previous) {
      notifyListeners();
    }
  }

  void _startMonitoring({Duration interval = const Duration(seconds: 3)}) {
    _timer = Timer.periodic(interval, (_) async {
      await _performConnectivityCheck();
    });
    
    // Perform initial check
    _performConnectivityCheck();
  }

  // Manual connectivity check (for retry button)
  Future<void> checkConnectivity() async {
    await _performConnectivityCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
