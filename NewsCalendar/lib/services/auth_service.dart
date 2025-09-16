import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService with ChangeNotifier {
  final FlutterSecureStorage _storage;
  String? _token;
  bool _isLoading = true;
  bool _isAuthenticated = false;
  DateTime? _tokenExpiry;

  AuthService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get isTokenValid =>
      _token != null &&
      (_tokenExpiry == null || _tokenExpiry!.isAfter(DateTime.now()));

  Future<String?> getAuthToken() async {
    if (_token != null && isTokenValid) {
      return _token;
    }

    // If token is expired or not in memory, try to get from storage
    try {
      _token = await _storage.read(key: 'token');
      final expiryString = await _storage.read(key: 'token_expiry');

      if (expiryString != null) {
        _tokenExpiry = DateTime.parse(expiryString);
      }

      _isAuthenticated = _token != null && isTokenValid;
      notifyListeners();

      return _isAuthenticated ? _token : null;
    } catch (e) {
      _token = null;
      _tokenExpiry = null;
      _isAuthenticated = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      await getAuthToken(); // This will update all the necessary states

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _token = null;
      _tokenExpiry = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setAuthToken(String token, {Duration? expiresIn}) async {
    _token = token;
    _isAuthenticated = true;

    if (expiresIn != null) {
      _tokenExpiry = DateTime.now().add(expiresIn);
      await _storage.write(
        key: 'token_expiry',
        value: _tokenExpiry!.toIso8601String(),
      );
    }

    await _storage.write(key: 'token', value: token);
    notifyListeners();
  }

  Future<void> logout() async {
    await Future.wait([
      _storage.delete(key: 'token'),
      _storage.delete(key: 'token_expiry'),
      _storage.delete(key: 'userEmail'),
    ]);

    _token = null;
    _tokenExpiry = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
