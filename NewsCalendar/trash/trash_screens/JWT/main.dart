// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import '/screens/auth_screen.dart';
// import '../../JWT/services/auth_service.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: ".env");
//   final sharedPreferences = await SharedPreferences.getInstance();
//   final secureStorage = const FlutterSecureStorage();

//   runApp(
//     MultiProvider(
//       providers: [
//         Provider<SharedPreferences>(create: (_) => sharedPreferences),
//         Provider<FlutterSecureStorage>(create: (_) => secureStorage),
//         ChangeNotifierProvider(
//           create:
//               (_) => AuthService(
//                 sharedPreferences: sharedPreferences,
//                 secureStorage: secureStorage,
//               ),
//         ),
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
//       title: 'JWT Auth',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const AuthScreen(),
//     );
//   }
// }
