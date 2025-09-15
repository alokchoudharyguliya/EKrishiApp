import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newscalendar/utils/imports.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  Timer? _timer;

  ConnectivityProvider() {
    _startMonitoring();
  }

  void _startMonitoring({Duration interval = const Duration(seconds: 2)}) {
    final previous = _isOnline;
    // final authService = Provider.of<AuthService>(context, listen: false);
    // final token = authService.token;
    final token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4MDJlNGEyOTZlY2Y1ZmFkODFmYjM2ZiIsImVtYWlsIjoiYWxva3NpbmdAZ21haWwuY29tIiwiaWF0IjoxNzQ1MzY2MjkyfQ.hWeBS4pBXRiE4NGHwMR1zBGGrxYzSVyBNQC9jCHvQF0";
    _timer = Timer.periodic(interval, (_) async {
      try {
        final res = await http
            .get(
              Uri.parse('$BASE_URL/ping'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${token}',
              },

              // body: jsonEncode(event.toJson()),
            )
            .timeout(Duration(seconds: 1));

        // print(res.body);
        _isOnline = res.statusCode == 200;
      } catch (_) {
        _isOnline = false;
      }

      if (_isOnline != previous) notifyListeners(); // Notify only on change
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
