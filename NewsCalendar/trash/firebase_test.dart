// // import 'package:firebase_auth/firebase_auth.dart';

// // class FirebaseTester {
// //   static Future<void> testAuth() async {
// //     try {
// //       // Test anonymous auth (no credentials needed)
// //       UserCredential user = await FirebaseAuth.instance.signInAnonymously();
// //       print("Firebase working! User ID: ${user.user?.uid}");
// //       await user.user?.delete(); // Cleanup
// //     } catch (e) {
// //       print("Firebase FAILED: $e");
// //     }
// //   }
// // }

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// static Future<void> basicConnectionTest() async {
//   try {
//     // Just test initialization
//     await Firebase.initializeApp();
//     debugPrint("✅ Basic Firebase connection working");
    
//     // Test Firestore if needed
//     final doc = FirebaseFirestore.instance.doc('test/connection');
//     await doc.set({'test': DateTime.now()});
//     await doc.delete();
//     debugPrint("✅ Firestore connection working");
//   } catch (e) {
//     debugPrint("❌ Connection failed: ${e.toString()}");
//     rethrow;
//   }
// }


// // class FirebaseTester {
// //   static Future<void> testAuth() async {
// //     try {
// //       debugPrint("🔥 Testing Firebase connection...");

// //       // Test 1: Check Firebase initialization
// //       if (Firebase.apps.isEmpty) {
// //         debugPrint("❌ Firebase not initialized");
// //         return;
// //       }
// //       debugPrint("✅ Firebase initialized successfully");

// //       // Test 2: Anonymous authentication
// //       debugPrint("🔑 Testing anonymous auth...");
// //       UserCredential user = await FirebaseAuth.instance.signInAnonymously();

// //       debugPrint("✅ Auth successful! UID: ${user.user?.uid}");
// //       debugPrint("📛 User isAnonymous: ${user.user?.isAnonymous}");

// //       // Test 3: Sign out
// //       await FirebaseAuth.instance.signOut();
// //       debugPrint("✅ Signed out successfully");

// //       // Test 4: Verify sign out
// //       if (FirebaseAuth.instance.currentUser == null) {
// //         debugPrint("✅ Current user is null (expected after signout)");
// //       }
// //     } catch (e) {
// //       debugPrint("❌ FIREBASE TEST FAILED: ${e.toString()}");
// //       rethrow;
// //     }
// //   }
// // }
