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
