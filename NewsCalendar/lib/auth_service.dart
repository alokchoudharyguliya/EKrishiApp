// // class AuthService {
// //   final FirebaseAuth _auth = FirebaseAuth.instance;

// //   Future<User?> signUpWithEmail(String email, String password) async {
// //     try {
// //       UserCredential result = await _auth.createUserWithEmailAndPassword(
// //         email: email,
// //         password: password,
// //       );
// //       return result.user;
// //     } catch (e) {
// //       print("SignUp Error: $e");
// //       return null;
// //     }
// //   }
// // }

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthService with ChangeNotifier {
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   late SharedPreferences _prefs;

//   // Initialize SharedPreferences
//   Future<void> init() async {
//     _prefs = await SharedPreferences.getInstance();
//   }

//   // Get current user
//   // User? get currentUser => _firebaseAuth.currentUser;
//   User? get currentUser {
//     try {
//       return _firebaseAuth.currentUser;
//     } catch (e) {
//       print('Error getting current user: $e');
//       return null;
//     }
//   }

//   // Check if user is logged in
//   bool get isLoggedIn => currentUser != null;

//   // Get auth token
//   Future<String?> getToken() async {
//     return await currentUser?.getIdToken();
//   }

//   // Sign up with email and password
//   Future<User?> signUp(String email, String password) async {
//     try {
//       UserCredential credential = await _firebaseAuth
//           .createUserWithEmailAndPassword(email: email, password: password);

//       // Save login state
//       await _prefs.setBool('isLoggedIn', true);
//       await _prefs.setString('email', email);

//       notifyListeners();
//       return credential.user;
//     } on FirebaseAuthException catch (e) {
//       throw _handleAuthException(e);
//     }
//   }

//   // // Sign in with email and password
//   // Future<User?> signIn(String email, String password) async {
//   //   try {
//   //     UserCredential credential = await _firebaseAuth
//   //         .signInWithEmailAndPassword(email: email, password: password);

//   //     // Save login state
//   //     await _prefs.setBool('isLoggedIn', true);
//   //     await _prefs.setString('email', email);

//   //     notifyListeners();
//   //     return credential.user;
//   //   } on FirebaseAuthException catch (e) {
//   //     throw _handleAuthException(e);
//   //   }
//   // }
//   Future<User?> signIn(String email, String password) async {
//     try {
//       UserCredential credential = await _firebaseAuth
//           .signInWithEmailAndPassword(email: email, password: password);

//       // Explicitly get the user rather than relying on credential.user
//       User? user = _firebaseAuth.currentUser;

//       if (user != null) {
//         await _prefs.setBool('isLoggedIn', true);
//         await _prefs.setString('email', email);
//         notifyListeners();
//         return user;
//       }
//       return null;
//     } on FirebaseAuthException catch (e) {
//       throw _handleAuthException(e);
//     }
//   }

//   // Sign out
//   Future<void> signOut() async {
//     await _firebaseAuth.signOut();

//     // Clear saved login state
//     await _prefs.setBool('isLoggedIn', false);
//     await _prefs.remove('email');

//     notifyListeners();
//   }

//   // Check if user is logged in from SharedPreferences
//   Future<bool> checkLoginStatus() async {
//     await init();
//     bool isLoggedIn = _prefs.getBool('isLoggedIn') ?? false;

//     // If SharedPreferences says user is logged in but Firebase doesn't have a user,
//     // sign out to keep them in sync
//     if (isLoggedIn && _firebaseAuth.currentUser == null) {
//       await _prefs.setBool('isLoggedIn', false);
//       return false;
//     }

//     return isLoggedIn;
//   }

//   // Handle Firebase auth exceptions
//   String _handleAuthException(FirebaseAuthException e) {
//     switch (e.code) {
//       case 'invalid-email':
//         return 'The email address is badly formatted.';
//       case 'user-disabled':
//         return 'This user has been disabled.';
//       case 'user-not-found':
//         return 'No user found with this email.';
//       case 'wrong-password':
//         return 'Wrong password provided.';
//       case 'email-already-in-use':
//         return 'The email address is already in use.';
//       case 'operation-not-allowed':
//         return 'Email/password accounts are not enabled.';
//       case 'weak-password':
//         return 'The password is too weak.';
//       default:
//         return 'An unknown error occurred.';
//     }
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  late SharedPreferences _prefs;
  bool _initialized = false;

  AuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Initialize SharedPreferences and Firebase Auth
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      // Force a current user check to initialize auth state
      await _firebaseAuth.authStateChanges().first;
      _initialized = true;
    } catch (e) {
      print('Initialization error: $e');
      rethrow;
    }
  }

  // Get current user with null check and error handling
  User? get currentUser {
    if (!_initialized) return null;
    try {
      return _firebaseAuth.currentUser;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  bool get isLoggedIn => currentUser != null;

  Future<String?> getToken() async {
    if (!_initialized) return null;
    try {
      return await currentUser?.getIdToken();
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  Future<User?> signUp(String email, String password) async {
    if (!_initialized) await init();
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Use the user from auth instance rather than credential
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _prefs.setBool('isLoggedIn', true);
        await _prefs.setString('email', email);
        notifyListeners();
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      print('Sign up error: $e');
      throw 'Failed to sign up. Please try again.';
    }
  }

  Future<User?> signIn(String email, String password) async {
    if (!_initialized) await init();
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user directly from auth instance
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _prefs.setBool('isLoggedIn', true);
        await _prefs.setString('email', email);
        notifyListeners();
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // throw ('Sign in error: $e');
      throw 'Failed to sign in. Please try again.';
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _prefs.setBool('isLoggedIn', false);
      await _prefs.remove('email');
      notifyListeners();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  Future<bool> checkLoginStatus() async {
    if (!_initialized) await init();
    try {
      final isLoggedIn = _prefs.getBool('isLoggedIn') ?? false;

      // Verify the auth state matches the preference
      if (isLoggedIn) {
        await _firebaseAuth.authStateChanges().first;
        if (_firebaseAuth.currentUser == null) {
          await _prefs.setBool('isLoggedIn', false);
          return false;
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Check login status error: $e');
      return false;
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The email address is already in use.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An unknown error occurred: ${e.message}';
    }
  }
}
