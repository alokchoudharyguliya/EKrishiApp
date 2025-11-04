import 'package:newscalendar/widgets/carousel.dart';
import 'package:newscalendar/widgets/news_page.dart';
import 'package:newscalendar/widgets/price_list_card.dart';
import './screens/doctor_contact_screen.dart';
import './utils/imports.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './widgets/weather_detail_row.dart';
import './widgets/farm_cctv.dart';
import './widgets/custom_bottom_nav_bar.dart';
import './widgets/invoice_tile.dart';
import './widgets/weather_day.dart';
import './screens/ai_crop_assistance_screen.dart';
import './screens/equipment_markeplace_screen.dart';
import './screens/login_screen.dart';
import './screens/chatbot_screen.dart';
import './screens/supplies_marketplace_screen.dart';
import './screens/bookmarked_news_screen.dart';
import './services/weather_service.dart';
import './models/weather.dart';

class Homepage extends StatefulWidget {
  final String? token;
  const Homepage({@required this.token, Key? key}) : super(key: key);
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  final List<Widget> _pages = [
    // Home page content will be built in build()
    Container(),
    FarmCCTV(),
    NewsPage(),
    ChatbotScreen(),
  ];
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? userEmail;
  final DateTime _today = DateTime.now();
  String? authToken;
  File? _cachedImageFile;
  FocusNode _focusNode = FocusNode();

  // Animation controllers for homepage animations
  late AnimationController _welcomeController;
  late AnimationController _cardsController;
  late Animation<double> _welcomeFadeAnimation;
  late Animation<Offset> _welcomeSlideAnimation;
  late Animation<double> _cardsFadeAnimation;
  late Animation<Offset> _cardsSlideAnimation;

  @override
  void initState() {
    super.initState();
    authToken = widget.token;
    _focusNode.canRequestFocus = false;

    // Initialize animations
    _welcomeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Welcome animations
    _welcomeFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _welcomeController, curve: Curves.easeIn),
    );
    _welcomeSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _welcomeController, curve: Curves.easeOutCubic),
    );

    // Cards animations
    _cardsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _cardsController, curve: Curves.easeIn));
    _cardsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _cardsController, curve: Curves.easeOutCubic),
    );

    // Start animations
    _welcomeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _cardsController.forward();
    });

    // Schedule checkAuthStatus to run after build phase completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AuthService>(context, listen: false).checkAuthStatus();
      }
    });
  }

  @override
  void dispose() {
    _welcomeController.dispose();
    _cardsController.dispose();
    _focusNode.dispose();
    super.dispose();
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
      if (mounted) {
        _clearProfileImageCache();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false, // This removes all previous routes
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      // if (mounted) {
      //   Navigator.pushReplacementNamed(context, '/login');
      // }
    }
  }

  void _showWeatherDetails(BuildContext context) {
    final weatherService = WeatherService();

    showDialog(
      context: context,
      builder:
          (context) => FutureBuilder<Weather>(
            future: weatherService.getCurrentWeather(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: [
                      Icon(Icons.wb_sunny, color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Today\'s Weather Details',
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Fetching weather data...'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                );
              }

              if (snapshot.hasError) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Weather Error',
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          snapshot.error.toString().replaceAll(
                            'Exception: ',
                            '',
                          ),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                );
              }

              if (!snapshot.hasData) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: [
                      Icon(Icons.wb_sunny, color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Today\'s Weather Details',
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  content: const SizedBox(
                    width: double.infinity,
                    child: Text('No weather data available'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                );
              }

              final weather = snapshot.data!;
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(Icons.wb_sunny, color: Colors.amber, size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Today\'s Weather Details',
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WeatherDetailRow(
                        icon: Icons.thermostat,
                        color: Colors.orange,
                        label: 'Temperature',
                        value: weather.temperatureString,
                      ),
                      WeatherDetailRow(
                        icon: Icons.water_drop,
                        color: Colors.blue,
                        label: 'Humidity',
                        value: weather.humidityString,
                      ),
                      WeatherDetailRow(
                        icon: Icons.wind_power,
                        color: Colors.teal,
                        label: 'Wind Speed',
                        value: weather.windSpeedString,
                      ),
                      WeatherDetailRow(
                        icon: Icons.sunny,
                        color: Colors.yellow[700]!,
                        label: 'Sunlight',
                        value: weather.sunlightString,
                      ),
                      WeatherDetailRow(
                        icon: Icons.location_on,
                        color: Colors.red,
                        label: 'Location',
                        value: weather.location,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    final isOnline = context.watch<ConnectivityProvider>().isOnline;
    return FutureBuilder(
      future: userService.getUserData(),
      builder: (context, snapshot) {
        Map<String, dynamic> userData = {};
        if (snapshot.hasData) {
          userData = snapshot.data as Map<String, dynamic>;
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF87CEEB), // Sky blue
                    Color(0xFF90EE90), // Light green
                  ],
                ),
              ),
            ),
            title: const Text(
              "Home",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.white,
                semanticLabel: 'Open menu',
              ),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
            actions: [
              // Language switch button - COMMENTED OUT
              // PopupMenuButton<String>(
              //   icon: const Icon(Icons.language, color: Colors.white),
              //   onSelected: (String lang) {
              //     // Implement your language change logic here
              //     // For example, using Provider or setState
              //     // setState(() => _selectedLanguage = lang);
              //     // context.read<LocaleProvider>().setLocale(Locale(lang));
              //   },
              //   itemBuilder:
              //       (context) => [
              //         const PopupMenuItem(value: 'en', child: Text('English')),
              //         const PopupMenuItem(value: 'hi', child: Text('हिन्दी')),
              //         const PopupMenuItem(value: 'mr', child: Text('मराठी')),
              //         // Add more languages as needed
              //       ],
              // ),
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                  semanticLabel: 'Logout',
                ),
                onPressed: signout,
              ),
              Icon(
                isOnline ? Icons.wifi : Icons.wifi_off,
                color: isOnline ? Colors.green : Colors.red,
                semanticLabel: isOnline ? 'Online' : 'Offline',
              ),
            ],
          ),
          endDrawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF8B4513), // Brown (soil)
                        Color(0xFF228B22), // Green (crops)
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userData['name'] ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 4,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        userData['email'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 3,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
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
                  leading: const Icon(Icons.bookmark),
                  title: const Text('Bookmarked News'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BookmarkedNewsScreen(),
                      ),
                    );
                  },
                ),
                // ListTile(
                //   leading: const Icon(Icons.shopping_bag),
                //   title: const Text('Supplies Marketplace'),
                //   onTap: () {
                //     Navigator.pop(context);
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (_) => const SuppliesMarketplaceScreen(),
                //       ),
                //     );
                //   },
                // ),
                // ListTile(
                //   leading: const Icon(Icons.settings),
                //   title: const Text('Settings'),
                //   onTap: () {
                //     Navigator.pushNamed(context, '/settings');
                //   },
                // ),
                // ListTile(
                //   leading: const Icon(Icons.upload_rounded),
                //   title: const Text('Upload Academic Schedule'),
                //   onTap: () {
                //     Navigator.pushNamed(context, '/upload-schedule');
                //   },
                // ),
                // ListTile(
                //   leading: const Icon(Icons.videocam),
                //   title: const Text('Direct Camera Stream'),
                //   onTap: () {
                //     Navigator.pop(context);
                //     Navigator.pushNamed(context, '/direct-camera-stream');
                //   },
                // ),
                // ListTile(
                //   leading: const Icon(Icons.help),
                //   title: const Text('Help & Support'),
                //   onTap: () {
                //     Navigator.pop(context);
                //   },
                // ),
              ],
            ),
          ),
          body:
              _currentIndex == 0
                  ? SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SlidingCarousel(),
                        const SizedBox(height: 20),
                        // Animated welcome message
                        SlideTransition(
                          position: _welcomeSlideAnimation,
                          child: FadeTransition(
                            opacity: _welcomeFadeAnimation,
                            child: Text(
                              'Welcome, ${userData['name'] ?? "User"}',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Animated agriculture icons card
                        SlideTransition(
                          position: _cardsSlideAnimation,
                          child: FadeTransition(
                            opacity: _cardsFadeAnimation,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF90EE90), // Light green
                                    Color(0xFF2E7D32), // Darker green
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: GridView.count(
                                  shrinkWrap: true,
                                  crossAxisCount: 5,
                                  mainAxisSpacing: 15,
                                  crossAxisSpacing: 10,
                                  physics: NeverScrollableScrollPhysics(),
                                  childAspectRatio: 1.0,
                                  children: [
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: Colors.green,
                                          width: 1.5,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    const EquipmentMarketplaceScreen(),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.agriculture,
                                        size: 20,
                                        color: Colors.green,
                                      ),
                                    ),
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: Colors.orange,
                                          width: 1.5,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    const SuppliesMarketplaceScreen(),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.shopping_bag,
                                        size: 20,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: Colors.brown,
                                          width: 1.5,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => DoctorContactScreen(),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.medical_information,
                                        size: 20,
                                        color: Colors.brown,
                                      ),
                                    ),
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: Colors.blue,
                                          width: 1.5,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/irrigation',
                                        );
                                      },
                                      child: Icon(
                                        Icons.water_drop,
                                        size: 20,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: Colors.green,
                                          width: 1.5,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    const AICropAssistantScreen(),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.spa,
                                        size: 20,
                                        color: Colors.green,
                                      ),
                                    ),
                                    // OutlinedButton(
                                    //   style: OutlinedButton.styleFrom(
                                    //     shape: RoundedRectangleBorder(
                                    //       borderRadius: BorderRadius.circular(12),
                                    //     ),
                                    //     side: BorderSide(
                                    //       color: Colors.red,
                                    //       width: 1.5,
                                    //     ),
                                    //     padding: EdgeInsets.zero,
                                    //   ),
                                    //   onPressed: () {
                                    //     Navigator.pushNamed(
                                    //       context,
                                    //       '/direct-camera-stream',
                                    //     );
                                    //   },
                                    //   child: Icon(
                                    //     Icons.videocam,
                                    //     size: 20,
                                    //     color: Colors.red,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal: 8.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.cloud, color: Colors.blueGrey),
                                  const SizedBox(width: 8),
                                  Text(
                                    'This Week\'s Weather Forecast',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start, // <-- Aligns all columns to the top
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  // Present day (Mon) is clickable and visually differentiated
                                  GestureDetector(
                                    onTap: () => _showWeatherDetails(context),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Mon',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.amber,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        CircleAvatar(
                                          backgroundColor: Colors.amber
                                              .withOpacity(0.25),
                                          child: Icon(
                                            Icons.wb_sunny,
                                            color: Colors.amber,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        // The 'Today' label is positioned lower to appear as if it slides below the icon
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2.0,
                                          ), // Adjust this value for alignment
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Today',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Color.fromARGB(
                                                  255,
                                                  72,
                                                  55,
                                                  35,
                                                ),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Other days
                                  WeatherDay(
                                    day: 'Tue',
                                    icon: Icons.cloud,
                                    color: Colors.blueGrey,
                                  ),
                                  WeatherDay(
                                    day: 'Wed',
                                    icon: Icons.grain,
                                    color: Colors.green,
                                  ),
                                  WeatherDay(
                                    day: 'Thu',
                                    icon: Icons.water_drop,
                                    color: Colors.blue,
                                  ),
                                  WeatherDay(
                                    day: 'Fri',
                                    icon: Icons.wb_cloudy,
                                    color: Colors.grey,
                                  ),
                                  WeatherDay(
                                    day: 'Sat',
                                    icon: Icons.bolt,
                                    color: Colors.orange,
                                  ),
                                  WeatherDay(
                                    day: 'Sun',
                                    icon: Icons.ac_unit,
                                    color: Colors.lightBlue,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Add this widget below the weather forecast section in your build method
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: SizedBox(
                              child: GridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                mainAxisSpacing: 9,
                                crossAxisSpacing: 9,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio:
                                    0.8, // Adjust this ratio as needed
                                children: [
                                  InvoiceTile(
                                    title: 'Calendar',
                                    features: {
                                      'Cane Area': '4 Nov 2025',
                                      'Effective Cane Area': '₹2,500',
                                      'Basic Quota': 'Paid',
                                      'Total Bonding': 'Fertilizer',
                                      'Total Purchy': '-',
                                    },
                                  ),
                                  InvoiceTile(
                                    title: 'Supply Tickets',
                                    features: {
                                      'Total Issued': '14 Sep 2025',
                                      'Total Wieghted': '₹1,200',
                                      'Expired': 'Pending',
                                      'Cancelled': 'Seeds',
                                      'Valid for Supply': '2 days',
                                    },
                                  ),
                                  InvoiceTile(
                                    title: 'Sugarcane Receipt',
                                    features: {
                                      'Date': '10 Sep 2025',
                                      'Amount': '₹3,000',
                                      'Status': 'Paid',
                                      'Last Supply Date': 'Equipment',
                                      'Last Supply Wt (Qtl.)': '-',
                                    },
                                  ),
                                  InvoiceTile(
                                    title: 'Payments',
                                    features: {
                                      'Date': '8 Sep 2025',
                                      'Last Payment On': '8 Sep 2025',
                                      'Amount': '₹800',
                                      'Bank Name': 'Overdue',
                                      'Loan Balance': 'Pesticide',
                                      'Loan Deduction': '5 days',
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // ),
                        const SizedBox(height: 30),
                        // ElevatedButton.icon(
                        //   style: ElevatedButton.styleFrom(
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 35,
                        //       vertical: 15,
                        //     ),
                        //     backgroundColor:
                        //         Theme.of(context).colorScheme.primary,
                        //   ),
                        //   onPressed: () => _showDateBottomSheet(context),
                        //   icon: Icon(Icons.calendar_today, color: Colors.white),
                        //   label: const Text(
                        //     'View Detailed Date',
                        //     style: TextStyle(fontSize: 16, color: Colors.white),
                        //   ),
                        // ),
                        PriceListCard(
                          mandiName: 'Lucknow Mandi',
                          date: '16 Sep 2025',
                          cropPrices: {
                            'Wheat': '₹2200/qtl',
                            'Rice': '₹1850/qtl',
                            'Sugarcane': '₹340/qtl',
                            'Maize': '₹1600/qtl',
                            'Mustard': '₹5400/qtl',
                            'Potato': '₹1200/qtl',
                          },
                        ),
                        const SizedBox(height: 20),
                        // COMMENTED OUT: Calendar button - will be added later
                        // FloatingActionButton.extended(
                        //   backgroundColor:
                        //       Theme.of(context).colorScheme.primary,
                        //   onPressed:
                        //       () => Navigator.pushNamed(context, '/calendar'),
                        //   icon: Icon(
                        //     Icons.calendar_view_day_rounded,
                        //     color: Colors.white,
                        //   ),
                        //   label: const Text(
                        //     'Open Calendar',
                        //     style: TextStyle(color: Colors.white),
                        //   ),
                        // ),
                      ],
                    ),
                  )
                  : _pages[_currentIndex],
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTabSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        );
      },
    );
  }
}
