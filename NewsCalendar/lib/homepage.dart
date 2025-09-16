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

class Homepage extends StatefulWidget {
  final String? token;
  const Homepage({@required this.token, Key? key}) : super(key: key);
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final List<Widget> _pages = [
    // Home page content will be built in build()
    Container(),
    FarmCCTV(),
    NewsPage(),
  ];
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? userEmail;
  final DateTime _today = DateTime.now();
  String? authToken;
  File? _cachedImageFile;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
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
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('Error during logout: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _showWeatherDetails(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                    value: '32°C',
                  ),
                  WeatherDetailRow(
                    icon: Icons.water_drop,
                    color: Colors.blue,
                    label: 'Humidity',
                    value: '68%',
                  ),
                  WeatherDetailRow(
                    icon: Icons.wind_power,
                    color: Colors.teal,
                    label: 'Wind Speed',
                    value: '12 km/h',
                  ),
                  WeatherDetailRow(
                    icon: Icons.sunny,
                    color: Colors.yellow[700]!,
                    label: 'Sunlight',
                    value: '8 hrs',
                  ),
                  WeatherDetailRow(
                    icon: Icons.location_on,
                    color: Colors.red,
                    label: 'Location',
                    value: 'Your GPS',
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
          ),
    );
  }

  // Helper widget for weather detail rows
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
          height: MediaQuery.of(context).size.height * 0.5,
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
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: Colors.white),
                label: const Text(
                  'Close',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
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
      future: userService.getUserData(),
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
              icon: Icon(
                Icons.menu,
                color: Colors.white,
                semanticLabel: 'Open menu',
              ),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
            actions: [
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
                    color: Theme.of(context).colorScheme.primary,
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
                        ),
                      ),
                      Text(
                        userData['email'] ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
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
                        Text(
                          'Welcome, ${userData['name'] ?? "User"}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        // Agriculture icons card with button boundaries
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: GridView.count(
                              shrinkWrap: true,
                              crossAxisCount: 4,
                              mainAxisSpacing: 15,
                              crossAxisSpacing: 15,
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(
                                      color: Colors.green,
                                      width: 1.5,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () {},
                                  child: Icon(
                                    Icons.agriculture,
                                    size: 20,
                                    color: Colors.green,
                                  ),
                                ),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
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
                                        builder: (_) => DoctorContactScreen(),
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
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(
                                      color: Colors.blue,
                                      width: 1.5,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/irrigation');
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
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(
                                      color: Colors.orange,
                                      width: 1.5,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () {},
                                  child: Icon(
                                    Icons.thermostat,
                                    size: 20,
                                    color: Colors.orange,
                                  ),
                                ),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(
                                      color: Colors.teal,
                                      width: 1.5,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () {},
                                  child: Icon(
                                    Icons.eco,
                                    size: 20,
                                    color: Colors.teal,
                                  ),
                                ),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(
                                      color: Colors.red,
                                      width: 1.5,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () {},
                                  child: Icon(
                                    Icons.bug_report,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                ),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
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
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(
                                      color: Colors.amber,
                                      width: 1.5,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () {},
                                  child: Icon(
                                    Icons.sunny,
                                    size: 20,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Weather forecast card
                        // Card(
                        // elevation: 3,
                        // shape: RoundedRectangleBorder(
                        //   borderRadius: BorderRadius.circular(16),
                        // ),
                        // child:
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
                                      'Cane Area': '16 Sep 2025',
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
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 35,
                              vertical: 15,
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () => _showDateBottomSheet(context),
                          icon: Icon(Icons.calendar_today, color: Colors.white),
                          label: const Text(
                            'View Detailed Date',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
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
                        FloatingActionButton.extended(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          onPressed:
                              () => Navigator.pushNamed(context, '/calendar'),
                          icon: Icon(
                            Icons.calendar_view_day_rounded,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Open Calendar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
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
