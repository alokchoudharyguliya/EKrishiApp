// import 'package:flutter/material.dart';
// import 'package:newscalendar/screens/calendar_screen.dart';
// import '/screens/profile_screen.dart';
// import 'package:newscalendar/screens/settings.dart';
// import 'package:newscalendar/wrapper.dart';
// import 'package:provider/provider.dart';
// import 'auth_service.dart';
// import './homepage.dart';
// import './screens/signup_screen.dart';
// // import 'package:firebase_core/firebase_core.dart';
// import './screens/upload.dart';
// import './screens/login_screen.dart';
// import 'auth_form_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize shared preferences
//   final prefs = await SharedPreferences.getInstance();

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => AuthService(prefs: prefs)),
//         ChangeNotifierProvider(create: (context) => AuthFormProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'App Name',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const Wrapper(),
//       routes: {
//         '/login': (context) => const Login(),
//         '/signup': (context) => SignupScreen(),
//         '/home': (context) => const Homepage(),
//         '/calendar': (context) => FullScreenCalendar(),
//         '/upload-schedule': (context) => ImageUploadScreen(),
//         '/profile': (context) => const ProfileScreen(),
//         '/settings': (context) => SettingsPage(),
//       },
//     );
//   }
// }
