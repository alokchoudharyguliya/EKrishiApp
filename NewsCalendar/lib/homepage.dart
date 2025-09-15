import 'package:newscalendar/widgets/carousel.dart';

import './utils/imports.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Homepage extends StatefulWidget {
  final String? token;
  const Homepage({@required this.token, Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? userEmail;
  final DateTime _today = DateTime.now();
  String? authToken;
  File? _cachedImageFile;
  FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    // Initialize authToken from widget.token
    authToken = widget.token;
    Provider.of<AuthService>(context, listen: false).checkAuthStatus();
    _focusNode.canRequestFocus = false;
  }

  Future<void> _clearProfileImageCache() async {
    if (_cachedImageFile != null && await _cachedImageFile!.exists()) {
      await _cachedImageFile!.delete();
      setState(() {
        _cachedImageFile = null;
      });
    }
  }

  Future<void> signout() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userService = Provider.of<UserService>(context, listen: false);

      // Attempt server logout if we have a token
      if (authService.token != null) {
        try {
          final response = await http.post(
            Uri.parse('$BASE_URL/logout'),
            headers: {
              'Authorization': 'Bearer ${authService.token}',
              'Content-Type': 'application/json',
            },
          );

          if (response.statusCode != 200) {
            print('Server logout failed, but proceeding with client cleanup');
          }
        } catch (e) {
          print('Error contacting logout endpoint: $e');
        }
      }

      await authService.logout();
      await userService.clearUserData();
      // Navigate to login screen
      if (mounted) {
        _clearProfileImageCache();
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('Error during logout: $e');
      // Ensure we still clean up and navigate even if something fails
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _showDateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Today is',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                DateFormat.yMMMMEEEEd().format(_today),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    final isOnline = context.watch<ConnectivityProvider>().isOnline;
    return FutureBuilder(
      future:
          userService
              .getUserData(), // This will rebuild when notifyListeners() is called
      builder: (context, snapshot) {
        Map<String, dynamic> userData = {};
        if (snapshot.hasData) {
          userData = snapshot.data as Map<String, dynamic>;
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text("Home"),
            leading: IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: signout,
              ),
              Icon(
                isOnline ? Icons.wifi : Icons.wifi_off,
                color: isOnline ? Colors.green : Colors.red,
              ),
            ],
          ),
          endDrawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text(
                    'Menu Options',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.upload_rounded),
                  title: const Text('Upload Academic Schedule'),
                  onTap: () {
                    Navigator.pushNamed(context, '/upload-schedule');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Calendar'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/calendar');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          body: Center(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlidingCarousel(),
                Text(
                  'Welcome, ${userData['name'] ?? "User"}',
                ), // Show email or fallback
                const SizedBox(height: 20),
                Text(
                  'Today is ${DateFormat.MMMMEEEEd().format(_today)}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 15,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => _showDateBottomSheet(context),
                  child: const Text(
                    'View Detailed Date',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                FloatingActionButton(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  onPressed: () => Navigator.pushNamed(context, '/calendar'),
                  child: Icon(
                    Icons.calendar_view_day_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
