import 'package:flutter/material.dart';
import './utils/imports.dart';
// import 'models/events.dart' as eventModel;
import './screens/splash_screen.dart';
import './screens/irrigation_screen.dart';
import './screens/direct_camera_stream_screen.dart';

ThemeData _buildTheme(AppSettings settings, bool isDarkMode) {
  return isDarkMode
      ? ThemeData.dark().copyWith(
        primaryColor: Color(0xFF66BB6A),
        textTheme: GoogleFonts.bitterTextTheme(
          ThemeData.dark().textTheme.copyWith(
            bodyLarge: TextStyle(fontSize: settings.fontSizeValue),
            bodyMedium: TextStyle(fontSize: settings.fontSizeValue - 2),
          ),
        ),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF66BB6A),
          secondary: Color(0xFF2D5016),
          surface: Color(0xFF3E2723),
          background: Color(0xFF3E2723),
          surfaceVariant: Colors.grey[800]!,
          onPrimary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white70,
          outline: Colors.grey[600]!,
          primaryContainer: Color(0xFF2D5016),
        ),
        extensions: <ThemeExtension<dynamic>>[
          CalendarColors(
            // Dark mode colors
            pastEventBackground: Color(0xFF424242),
            otherUserBackground: Color(0xFF2D5016),
            userBackground: Color(0xFFE65100).withOpacity(0.2),
            selectedEventBackground: Color(0xFF66BB6A),
            todayEventBackground: Color(0xFF4CAF50).withOpacity(0.3),
            differentMonthBackground: Color(0xFF616161),

            pastEventFont: Color(0xFFBDBDBD),
            otherUserFont: Color(0xFF81C784),
            userFont: Color(0xFFFFA726),
            selectedEventFont: Colors.white,
            todayEventFont: Color(0xFF66BB6A),
            differentMonthFont: Color(0xFF9E9E9E),

            // Light mode versions
            pastEventBackgroundDark: Color(0xFFEEEEEE),
            otherUserBackgroundDark: Color(0xFFE8F5E9),
            userBackgroundDark: Color(0xFFFFF3E0),
            selectedEventBackgroundDark: Color(0xFF4CAF50).withOpacity(0.3),
            todayEventBackgroundDark: Color(0xFFE8F5E9),
            differentMonthBackgroundDark: Color(0xFFFAFAFA),

            pastEventFontDark: Color(0xFF9E9E9E),
            otherUserFontDark: Color(0xFF2E7D32),
            userFontDark: Color(0xFFE65100),
            selectedEventFontDark: Colors.white,
            todayEventFontDark: Color(0xFF2D5016),
            differentMonthFontDark: Color(0xFFBDBDBD),
          ),
        ],
        cardTheme: CardTheme(
          color: Color(0xFF3E2723),
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
            backgroundColor: Color(0xFF66BB6A),
            foregroundColor: Colors.white,
          ),
        ),
      )
      : ThemeData(
        colorScheme: ColorScheme.light(
          primary: Color(0xFF2D5016),
          secondary: Color(0xFF4CAF50),
          surface: Colors.white,
          background: Color(0xFFF5F5DC),
          surfaceVariant: Colors.grey[100]!,
          onPrimary: Colors.white,
          onSurface: Colors.black87,
          onBackground: Colors.black54,
          outline: Colors.grey[300]!,
          primaryContainer: Color(0xFFE8F5E9),
        ),
        extensions: <ThemeExtension<dynamic>>[
          CalendarColors(
            // Light mode colors
            pastEventBackground: Color(0xFFEEEEEE),
            otherUserBackground: Color(0xFFE8F5E9),
            userBackground: Color(0xFFFFF3E0),
            selectedEventBackground: Color(0xFFC8E6C9),
            todayEventBackground: Color(0xFFE8F5E9),
            differentMonthBackground: Color(0xFFFAFAFA),

            pastEventFont: Color(0xFF9E9E9E),
            otherUserFont: Color(0xFF2E7D32),
            userFont: Color(0xFFE65100),
            selectedEventFont: const Color.fromARGB(255, 0, 0, 0),
            todayEventFont: Color(0xFF2D5016),
            differentMonthFont: Color(0xFFBDBDBD),

            // Dark mode versions
            pastEventBackgroundDark: Color(0xFF3E2723),
            otherUserBackgroundDark: Color(0xFF1B5E20),
            userBackgroundDark: Color(0xFFE65100).withOpacity(0.2),
            selectedEventBackgroundDark: Color(0xFF66BB6A).withOpacity(0.3),
            todayEventBackgroundDark: Color(0xFF4CAF50).withOpacity(0.3),
            differentMonthBackgroundDark: Color(0xFF616161),

            pastEventFontDark: Color(0xFFBDBDBD),
            otherUserFontDark: Color(0xFF81C784),
            userFontDark: Color(0xFFFFA726),
            selectedEventFontDark: Colors.white,
            todayEventFontDark: Color(0xFF66BB6A),
            differentMonthFontDark: Color(0xFF9E9E9E),
          ),
        ],
        primarySwatch: Colors.green,
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
            backgroundColor: Color(0xFF4CAF50),
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF5F5DC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF2D5016),
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = FlutterSecureStorage();
  // await Hive.initFlutter();
  // Hive.registerAdapter(eventModel.EventAdapter());
  // // Initialize Hive
  // await Hive.deleteBoxFromDisk('events');
  // await Hive.deleteBoxFromDisk('pending_operation');
  // await Hive.openBox<eventModel.Event>('events');
  // await Hive.openBox<eventModel.Event>('pending-operations');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(
          create: (context) => AuthService(storage: storage),
        ),
        ChangeNotifierProvider(
          create: (context) => AppSettings()..loadPreferences(),
        ),
        ChangeNotifierProvider(create: (context) => AuthFormProvider()),
        Provider(create: (_) => UserService()),
        // Provider(create: (context) => HiveLocalDbService()),
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
        theme: _buildTheme(settings, false), // define the themes
        darkTheme: _buildTheme(settings, true), // dark theme
        title: 'App Name',
        themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light, // define initial Theme
        home: const Wrapper(),
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash', // route for splash screen
        routes: { // the screen routes
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const Login(),
          '/signup': (context) => SignupScreen(),
          '/home': (context) {
            final authService = Provider.of<AuthService>(context, listen: false);
            return Homepage(token: authService.token);
          },
          '/irrigation': (context) => const IrrigationScreen(),
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
          '/direct-camera-stream': (context) => const DirectCameraStreamScreen(),
        },
      ),
    );
  }
}
