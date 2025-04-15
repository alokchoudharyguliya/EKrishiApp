import 'package:flutter/material.dart';
import 'package:newscalendar/screens/calendar_screen.dart';
import 'package:newscalendar/screens/edit_prodile_screen.dart';
import 'package:newscalendar/screens/profile_screen.dart';
import 'package:newscalendar/screens/settings.dart';
import 'package:newscalendar/wrapper.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'screens/login.dart';
import './homepage.dart';
import './screens/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import './screens/upload.dart';
// import '../firebase_options.dart';
import './screens/settings.dart';

void main() async {
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(create: (context) => AuthService(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Wrapper(),
      // home: FutureBuilder(
      //   future:
      //       Provider.of<AuthService>(context, listen: false).checkLoginStatus(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.done) {
      //       return snapshot.data == true ? HomeScreen() : LoginScreen();
      //     }
      //     return Scaffold(body: Center(child: CircularProgressIndicator()));
      //   },
      // ),
      routes: {
        '/login': (context) => Login(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => Homepage(),
        '/calendar': (context) => FullScreenCalendar(),
        '/upload-schedule': (context) => ImageUploadScreen(),
        // '/edit-profile': (context) => EditProfileScreen(userData: userData),
        '/profile': (context) => ProfileScreen(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}
