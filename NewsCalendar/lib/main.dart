import 'package:flutter/material.dart';
import 'package:newscalendar/screens/calendar_screen.dart';
import 'package:newscalendar/screens/profile_screen.dart';
import 'package:newscalendar/screens/settings.dart';
import 'package:newscalendar/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import './homepage.dart';
import './screens/signup_screen.dart';
import './screens/upload.dart';
import './screens/login_screen.dart';
import 'auth_form_provider.dart';
import 'dart:convert';

class UserService with ChangeNotifier {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  Map<String, dynamic>? cachedUserData;

  Future<String?> getUserId() async {
    return await _storage.read(key: 'userId');
  }

  Future<void> setUserId(String userId) async {
    await _storage.write(key: 'userId', value: userId);
  }

  Future<void> cacheUserData(Map<String, dynamic> data) async {
    cachedUserData = data;
    await _saveUserDataToSecureStorage(data); // Save to secure storage
    notifyListeners();
  }

  Future<void> _saveUserDataToSecureStorage(
    Map<String, dynamic> userData,
  ) async {
    try {
      await _storage.write(key: 'userData', value: json.encode(userData));
    } catch (e) {
      print('Error saving to secure storage: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    // First check memory cache
    if (cachedUserData != null) return cachedUserData;

    // If not in cache, check secure storage
    final userDataString = await _storage.read(key: 'userData');
    // print("${userDataString}---------------------");
    if (userDataString != null) {
      cachedUserData = jsonDecode(userDataString); // Convert back to Map
      return jsonDecode(userDataString);
    }
    return null; // No data available
  }

  // Future<void> cacheProfilePhoto(String localPath) async {
  //   await _storage.write(key: 'cachedProfilePhoto', value: localPath);
  // }

  // Future<void> getProfilePhoto(String localPath) async {
  //   await _storage.read(key: 'cachedProfilePhoto');
  // }

  Future<void> clearUserData() async {
    await _storage.delete(key: 'userId');
    await _storage.delete(key: 'userEmail');
    await _storage.delete(key: 'userData');
    // await _storage.delete(key: 'cachedProfilePhoto');
    notifyListeners();
  }
}

class AppSettings extends ChangeNotifier {
  bool _darkMode = false;
  String _calendarView = 'Week';
  String _fontSize = 'Medium';

  bool get darkMode => _darkMode;
  String get calendarView => _calendarView;
  String get fontSize => _fontSize;

  double get fontSizeValue {
    switch (_fontSize) {
      case 'Small':
        return 12;
      case 'Medium':
        return 14;
      case 'Large':
        return 16;
      case 'Extra Large':
        return 18;
      default:
        return 200;
    }
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool('darkMode') ?? false;
    _fontSize = prefs.getString('fontSize') ?? 'Medium';
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> setFontSize(String size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontSize', size);
    notifyListeners();
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
        Provider(create: (_) => UserService()),
        ChangeNotifierProvider(
          create: (context) => AppSettings()..loadPreferences(),
        ),
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
    final settings = Provider.of<AppSettings>(context);

    return ChangeNotifierProvider(
      create: (context) => UserService(),
      child: MaterialApp(
        title: 'App Name',
        themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: TextTheme(
            bodyLarge: TextStyle(fontSize: settings.fontSizeValue),
            bodyMedium: TextStyle(fontSize: settings.fontSizeValue - 2),
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          primaryColor: Colors.blue,
          textTheme: TextTheme(
            bodyLarge: TextStyle(fontSize: settings.fontSizeValue),
            bodyMedium: TextStyle(fontSize: settings.fontSizeValue - 2),
          ),
        ),
        home: const Wrapper(),
        routes: {
          '/login': (context) => const Login(),
          '/signup': (context) => SignupScreen(),
          '/home': (context) => const Homepage(),
          '/calendar': (context) => FullScreenCalendar(),
          '/upload-schedule': (context) => ImageUploadScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/settings':
              (context) => SettingsPage(
                onThemeChanged: (isDark) {
                  settings.setDarkMode(isDark);
                },
                onFontSizeChanged: (size) {
                  settings.setFontSize(size);
                },
              ),
        },
      ),
    );
  }
}
