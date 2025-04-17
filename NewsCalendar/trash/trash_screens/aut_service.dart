// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:jwt_decoder/jwt_decoder.dart';

// class AuthService with ChangeNotifier {
//   final SharedPreferences prefs;
//   String? _token;
//   bool _isAuthenticated = false;
//   bool _isLoading = true;

//   // Constructor that accepts SharedPreferences
//   AuthService({required this.prefs}) {
//     // Initialize by checking for an existing token
//     _token = prefs.getString('token');
//     _isAuthenticated = _token != null;
//     _isLoading = false;
//   }

//   bool get isAuthenticated => _isAuthenticated;
//   bool get isLoading => _isLoading;
//   String? get token => _token;

//   // Set authentication token
//   void setAuthToken(String token) {
//     _token = token;
//     _isAuthenticated = true;
//     prefs.setString('token', token);
//     notifyListeners();
//   }

//   // Check if user is authenticated on app startup
//   Future<void> checkAuthStatus() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       final storedToken = prefs.getString('token');

//       if (storedToken != null) {
//         // Verify token validity with the server
//         final isValid = await _verifyToken(storedToken);

//         if (isValid) {
//           _token = storedToken;
//           _isAuthenticated = true;
//           print('User authenticated from stored token');
//         } else {
//           // Token is invalid or expired
//           await prefs.remove('token');
//           await prefs.remove('userEmail');
//           print('Stored token is invalid or expired');
//         }
//       } else {
//         print('No token found in storage');
//       }
//     } catch (e) {
//       print('Error checking auth status: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Verify token with the server
//   Future<bool> _verifyToken(String token) async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://192.168.185.15:3000/verify-token'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       return response.statusCode == 200;
//     } catch (e) {
//       print('Token verification error: $e');
//       return false;
//     }
//   }

//   Future<void> logout() async {
//     try {
//       _token = null;
//       _isAuthenticated = false;

//       // Clear all auth-related preferences
//       await prefs.remove('token');
//       await prefs.remove('userEmail');

//       // Optional: Add any other cleanup you need here
//       notifyListeners();
//     } catch (e) {
//       print('Error during local logout cleanup: $e');
//       // Even if cleanup fails, ensure we're in logged out state
//       _token = null;
//       _isAuthenticated = false;
//       notifyListeners();
//       rethrow; // Only if you want calling code to handle this
//     }
//   }
// }
