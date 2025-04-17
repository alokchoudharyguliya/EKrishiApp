import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService with ChangeNotifier {
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;

  String? _token;
  Map<String, dynamic>? _user;
  String? _error;

  AuthService({required this.sharedPreferences, required this.secureStorage});

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  Future<void> initialize() async {
    _token = await secureStorage.read(key: 'token');
    if (_token != null) {
      await fetchUser();
    }
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'password': password}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        _token = responseData['token'];
        _user = {
          'id': responseData['_id'],
          'name': responseData['name'],
          'email': responseData['email'],
        };
        await secureStorage.write(key: 'token', value: _token);
        notifyListeners();
      } else {
        _error = responseData['message'] ?? 'Registration failed';
        notifyListeners();
      }
    } catch (e) {
      _error = 'An error occurred during registration';
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        _token = responseData['token'];
        _user = {
          'id': responseData['_id'],
          'name': responseData['name'],
          'email': responseData['email'],
        };
        await secureStorage.write(key: 'token', value: _token);
        notifyListeners();
      } else {
        _error = responseData['message'] ?? 'Login failed';
        notifyListeners();
      }
    } catch (e) {
      _error = 'An error occurred during login';
      notifyListeners();
    }
  }

  Future<void> fetchUser() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        _user = {
          'id': responseData['_id'],
          'name': responseData['name'],
          'email': responseData['email'],
        };
        notifyListeners();
      } else {
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }

  Future<void> logout() async {
    await secureStorage.delete(key: 'token');
    _token = null;
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
