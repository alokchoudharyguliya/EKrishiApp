import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Monitors network state
class ConnectivityService with ChangeNotifier {
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  Future<void> init() async {
    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
      notifyListeners();
    });
  }
}
