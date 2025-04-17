import 'package:flutter/material.dart';
import 'package:newscalendar/screens/calendar_screen.dart';
import '/screens/profile_screen.dart';
import 'package:newscalendar/screens/settings.dart';
import 'package:newscalendar/wrapper.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import './homepage.dart';
import './screens/signup_screen.dart';
import './screens/upload.dart';
import './screens/login_screen.dart';
import 'auth_form_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<String?> getUserId() async {
    return await _storage.read(key: 'userId');
  }

  Future<void> setUserId(String userId) async {
    await _storage.write(key: 'userId', value: userId);
  }

  Future<void> clearUserData() async {
    await _storage.delete(key: 'userId');
    await _storage.delete(key: 'userEmail');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = FlutterSecureStorage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthService(storage: storage),
        ),
        Provider(create: (_) => UserService()), // Add this
        ChangeNotifierProvider(create: (context) => AuthFormProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Wrapper(),
      routes: {
        '/login': (context) => const Login(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => const Homepage(),
        '/calendar': (context) => FullScreenCalendar(),
        '/upload-schedule': (context) => ImageUploadScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}
