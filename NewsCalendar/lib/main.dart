import 'package:flutter/material.dart';
import 'package:newscalendar/constants/constants.dart';
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
import 'services/sync_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../color/color.dart';
import './services/websocket_service.dart';
import 'package:hive/hive.dart';
import 'event.adapter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:newscalendar/event.adapter.dart';
import 'services/local_db_service.dart';

ThemeData _buildTheme(AppSettings settings, bool isDarkMode) {
  return isDarkMode
      ? ThemeData.dark().copyWith(
        useMaterial3: true,
        primaryColor: Colors.blue,
        textTheme: GoogleFonts.bitterTextTheme(
          ThemeData.dark().textTheme.copyWith(
            bodyLarge: TextStyle(fontSize: settings.fontSizeValue),
            bodyMedium: TextStyle(fontSize: settings.fontSizeValue - 2),
          ),
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.blue!,
          secondary: Colors.amber[200]!,
          surface: Colors.grey[900]!,
          background: Colors.grey[850]!,
          surfaceVariant: Colors.grey[800]!,
          onPrimary: Colors.black,
          onSurface: Colors.white,
          onBackground: Colors.white70,
          outline: Colors.grey[600]!,
          primaryContainer: Color(0xFF0D47A1),
        ),
        extensions: <ThemeExtension<dynamic>>[
          CalendarColors(
            // Dark mode colors
            pastEventBackground: Color(0xFF424242),
            otherUserBackground: Color(0xFF1B5E20),
            userBackground: Color(0xFFE65100).withOpacity(0.2),
            selectedEventBackground: Color(0xFF0D47A1),
            todayEventBackground: Color(0xFF1E88E5).withOpacity(0.2),
            differentMonthBackground: Color(0xFF616161),

            pastEventFont: Color(0xFFBDBDBD),
            otherUserFont: Color(0xFF81C784),
            userFont: Color(0xFFFFA726),
            selectedEventFont: const Color.fromARGB(255, 0, 0, 0),
            todayEventFont: Color(0xFF64B5F6),
            differentMonthFont: Color(0xFF9E9E9E),

            // Light mode versions
            pastEventBackgroundDark: Color(0xFFEEEEEE),
            otherUserBackgroundDark: Color(0xFFE8F5E9),
            userBackgroundDark: Color(0xFFFFF3E0),
            selectedEventBackgroundDark: Color(0xFFBBDEFB),
            todayEventBackgroundDark: Color(0xFFE3F2FD),
            differentMonthBackgroundDark: Color(0xFFFAFAFA),

            pastEventFontDark: Color(0xFF9E9E9E),
            otherUserFontDark: Color(0xFF2E7D32),
            userFontDark: Color(0xFFE65100),
            selectedEventFontDark: Colors.white,
            todayEventFontDark: Color(0xFF0D47A1),
            differentMonthFontDark: Color(0xFFBDBDBD),
          ),
        ],
        cardTheme: CardTheme(
          color: Colors.grey[900]!,
          elevation: 2,
          margin: EdgeInsets.all(4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[600]!),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.black,
          ),
        ),
      )
      : ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.deepPurple,
          secondary: Colors.amber,
          surface: Colors.white,
          background: Colors.grey[50]!,
          surfaceVariant: Colors.grey[100]!,
          onPrimary: Colors.white,
          onSurface: Colors.black87,
          onBackground: Colors.black54,
          outline: Colors.grey[300]!,
          primaryContainer: Color(0xFFE3F2FD),
        ),
        extensions: <ThemeExtension<dynamic>>[
          CalendarColors(
            // Light mode colors
            pastEventBackground: Color(0xFFEEEEEE),
            otherUserBackground: Color(0xFFE8F5E9),
            userBackground: Color(0xFFFFF3E0),
            selectedEventBackground: Color(0xFFBBDEFB),
            todayEventBackground: Color(0xFFE3F2FD),
            differentMonthBackground: Color(0xFFFAFAFA),

            pastEventFont: Color(0xFF9E9E9E),
            otherUserFont: Color(0xFF2E7D32),
            userFont: Color(0xFFE65100),
            selectedEventFont: const Color.fromARGB(255, 0, 0, 0),
            todayEventFont: Color(0xFF0D47A1),
            differentMonthFont: Color(0xFFBDBDBD),

            // Dark mode versions
            pastEventBackgroundDark: Color(0xFF424242),
            otherUserBackgroundDark: Color(0xFF1B5E20),
            userBackgroundDark: Color(0xFFE65100).withOpacity(0.2),
            selectedEventBackgroundDark: Color(0xFF0D47A1),
            todayEventBackgroundDark: Color(0xFF1E88E5).withOpacity(0.2),
            differentMonthBackgroundDark: Color(0xFF616161),

            pastEventFontDark: Color(0xFFBDBDBD),
            otherUserFontDark: Color(0xFF81C784),
            userFontDark: Color(0xFFFFA726),
            selectedEventFontDark: Colors.white,
            todayEventFontDark: Color(0xFF64B5F6),
            differentMonthFontDark: Color(0xFF9E9E9E),
          ),
        ],
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.bitterTextTheme(
          ThemeData.light().textTheme.copyWith(
            bodyLarge: TextStyle(fontSize: settings.fontSizeValue),
            bodyMedium: TextStyle(fontSize: settings.fontSizeValue - 2),
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          margin: EdgeInsets.all(4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
}

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

  Future<void> clearUserData() async {
    await _storage.delete(key: 'userId');
    await _storage.delete(key: 'userEmail');
    await _storage.delete(key: 'userData');
    // await _storage.delete(key: 'cachedProfilePhoto');
    notifyListeners();
  }
}

class AppSettings extends ChangeNotifier {
  String _theme = 'Light';
  String _calendarView = 'Week';
  String _fontSize = 'Medium';

  String get theme => _theme;
  String get calendarView => _calendarView;
  String get fontSize => _fontSize;

  bool get isDarkMode => _theme == 'Dark';

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
        return 14;
    }
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _theme = prefs.getString('theme') ?? 'Light';
    _fontSize = prefs.getString('fontSize') ?? 'Medium';
    notifyListeners();
  }

  Future<void> setTheme(String theme) async {
    _theme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
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

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(EventAdapter());

  // Open Hive boxes
  await Hive.openBox('events');
  await Hive.openBox('sync_meta');
  await Hive.openBox('pending_operations');
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => HiveLocalDbService()),
        Provider<WebSocketService>(
          create:
              (context) => WebSocketService(
                apiBaseUrl: 'ws://$BASE_URL/',
                authService: Provider.of<AuthService>(context, listen: false),
              ),
        ),
        ChangeNotifierProvider(
          create:
              (context) => SyncService(
                localDb: Provider.of<HiveLocalDbService>(
                  context,
                  listen: false,
                ),
                webSocket: Provider.of<WebSocketService>(
                  context,
                  listen: false,
                ),
              ),
        ),
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
        theme: _buildTheme(settings, false),
        darkTheme: _buildTheme(settings, true),
        title: 'App Name',
        themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        // theme: ThemeData(
        //   colorScheme: ColorScheme.light(
        //     primary: Colors.deepPurple,
        //     secondary: Colors.amber,
        //     surface: Colors.white,
        //     background: Colors.grey[50]!,
        //     onPrimary: Colors.white,
        //     onSurface: Colors.black87,
        //     primaryContainer: Color(0xFFE3F2FD),
        //   ),
        //   extensions: <ThemeExtension<dynamic>>[
        //     CalendarColors(
        //       // Light mode background colors
        //       pastEventBackground: Color(0xFFEEEEEE),
        //       otherUserBackground: Color(0xFFE8F5E9), // Light green
        //       userBackground: Color(0xFFFFF3E0), // Light orange
        //       selectedEventBackground: Color(0xFFBBDEFB), // Light blue
        //       todayEventBackground: Color(0xFFE3F2FD), // Light blue
        //       differentMonthBackground: Color(0xFFFAFAFA), // Very light gray
        //       // Light mode text colors
        //       pastEventFont: Color(0xFF9E9E9E), // Gray
        //       otherUserFont: Color(0xFF2E7D32), // Dark green
        //       userFont: Color(0xFFE65100), // Dark orange
        //       selectedEventFont: Colors.white,
        //       todayEventFont: Color(0xFF0D47A1), // Dark blue
        //       differentMonthFont: Color(0xFFBDBDBD), // Light gray
        //       // Dark mode background colors
        //       pastEventBackgroundDark: Color(0xFF424242),
        //       otherUserBackgroundDark: Color(0xFF1B5E20), // Dark green
        //       userBackgroundDark: Color(
        //         0xFFE65100,
        //       ).withOpacity(0.2), // Semi-transparent orange
        //       selectedEventBackgroundDark: Color(0xFF0D47A1), // Dark blue
        //       todayEventBackgroundDark: Color(
        //         0xFF1E88E5,
        //       ).withOpacity(0.2), // Semi-transparent blue
        //       differentMonthBackgroundDark: Color(0xFF616161), // Dark gray
        //       // Dark mode text colors
        //       pastEventFontDark: Color(0xFFBDBDBD), // Light gray
        //       otherUserFontDark: Color(0xFF81C784), // Light green
        //       userFontDark: Color(0xFFFFA726), // Light orange
        //       selectedEventFontDark: Colors.white,
        //       todayEventFontDark: Color(0xFF64B5F6), // Light blue
        //       differentMonthFontDark: Color(0xFF9E9E9E), // Medium gray
        //     ),
        //   ],
        //   primarySwatch: Colors.blue,
        //   visualDensity: VisualDensity.adaptivePlatformDensity,
        //   textTheme: GoogleFonts.bitterTextTheme(
        //     ThemeData.light().textTheme.copyWith(
        //       bodyLarge: TextStyle(fontSize: settings.fontSizeValue),
        //       bodyMedium: TextStyle(fontSize: settings.fontSizeValue - 2),
        //     ),
        //   ),
        // ),

        // darkTheme: ThemeData.dark().copyWith(
        //   primaryColor: Colors.blue,
        //   textTheme: GoogleFonts.bitterTextTheme(
        //     ThemeData.dark().textTheme.copyWith(
        //       bodyLarge: TextStyle(fontSize: settings.fontSizeValue),
        //       bodyMedium: TextStyle(fontSize: settings.fontSizeValue - 2),
        //     ),
        //   ),
        //   colorScheme: ColorScheme.dark(
        //     primary: Colors.deepPurple[300]!,
        //     secondary: Colors.amber[200]!,
        //     surface: Colors.grey[900]!,
        //     onPrimary: Colors.black,
        //     primaryContainer: Color(0xFF0D47A1),
        //   ),
        //   extensions: <ThemeExtension<dynamic>>[
        //     CalendarColors(
        //       // Dark mode colors (primary)
        //       pastEventBackground: Color(0xFF424242),
        //       otherUserBackground: Color(0xFF1B5E20),
        //       userBackground: Color(0xFFE65100).withOpacity(0.2),
        //       selectedEventBackground: Color(0xFF0D47A1),
        //       todayEventBackground: Color(0xFF1E88E5).withOpacity(0.2),
        //       differentMonthBackground: Color(0xFF616161),

        //       pastEventFont: Color(0xFFBDBDBD),
        //       otherUserFont: Color(0xFF81C784),
        //       userFont: Color(0xFFFFA726),
        //       selectedEventFont: Colors.white,
        //       todayEventFont: Color(0xFF64B5F6),
        //       differentMonthFont: Color(0xFF9E9E9E),

        //       // Light mode versions (not used in dark theme but required by class)
        //       pastEventBackgroundDark: Color(0xFFEEEEEE),
        //       otherUserBackgroundDark: Color(0xFFE8F5E9),
        //       userBackgroundDark: Color(0xFFFFF3E0),
        //       selectedEventBackgroundDark: Color(0xFFBBDEFB),
        //       todayEventBackgroundDark: Color(0xFFE3F2FD),
        //       differentMonthBackgroundDark: Color(0xFFFAFAFA),

        //       pastEventFontDark: Color(0xFF9E9E9E),
        //       otherUserFontDark: Color(0xFF2E7D32),
        //       userFontDark: Color(0xFFE65100),
        //       selectedEventFontDark: Colors.white,
        //       todayEventFontDark: Color(0xFF0D47A1),
        //       differentMonthFontDark: Color(0xFFBDBDBD),
        //     ),
        //   ],
        // ),
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
                onThemeChanged: (theme) {
                  settings.setTheme(theme);
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
