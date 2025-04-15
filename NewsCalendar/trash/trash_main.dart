// // // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // // import 'package:table_calendar/table_calendar.dart';
// // // // // // // // // import 'nav_screen.dart'; // Import the NavScreen file
// // // // // // // // // import 'package:intl/intl.dart';

// // // // // // // // // class CalendarComponent extends StatefulWidget {
// // // // // // // // //   @override
// // // // // // // // //   _CalendarComponentState createState() => _CalendarComponentState();
// // // // // // // // // }

// // // // // // // // // class _CalendarComponentState extends State<CalendarComponent> {
// // // // // // // // //   late final ValueNotifier<List<DateTime>> _selectedEvents;
// // // // // // // // //   late final CalendarFormat _calendarFormat;
// // // // // // // // //   late DateTime _selectedDay = DateTime.now();
// // // // // // // // //   late DateTime _focusedDay = DateTime.now();
// // // // // // // // //   late final bool _showOverlay = false;
// // // // // // // // //   late final GlobalKey _calendarKey = GlobalKey();
// // // // // // // // //   late final OverlayEntry? _overlayEntry;

// // // // // // // // //   @override
// // // // // // // // //   void initState() {
// // // // // // // // //     super.initState();
// // // // // // // // //     _calendarFormat = CalendarFormat.month;
// // // // // // // // //     _selectedDay = DateTime.now();
// // // // // // // // //     _focusedDay = DateTime.now();
// // // // // // // // //     _selectedEvents = ValueNotifier([]);
// // // // // // // // //   }

// // // // // // // // //   @override
// // // // // // // // //   void dispose() {
// // // // // // // // //     _selectedEvents.dispose();
// // // // // // // // //     _overlayEntry?.remove();
// // // // // // // // //     super.dispose();
// // // // // // // // //   }

// // // // // // // // //   @override
// // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // //     return Scaffold(
// // // // // // // // //       appBar: AppBar(title: const Text('Calendar with Navigation')),
// // // // // // // // //       body: Center(
// // // // // // // // //         child: Column(
// // // // // // // // //           children: [
// // // // // // // // //             TableCalendar(
// // // // // // // // //               focusedDay: _focusedDay,
// // // // // // // // //               selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
// // // // // // // // //               onDaySelected: (selectedDay, focusedDay) {
// // // // // // // // //                 setState(() {
// // // // // // // // //                   _selectedDay = selectedDay;
// // // // // // // // //                   _focusedDay = focusedDay;
// // // // // // // // //                   // print("Hey");
// // // // // // // // //                 });
// // // // // // // // //                 // Remove existing overlay if any
// // // // // // // // //                 _overlayEntry?.remove();

// // // // // // // // //                 // Create and show new overlay
// // // // // // // // //                 _showDayOverlay(selectedDay);
// // // // // // // // //                 // Navigate to the new screen with the selected date
// // // // // // // // //                 // Navigator.push(
// // // // // // // // //                 //   context,
// // // // // // // // //                 //   MaterialPageRoute(
// // // // // // // // //                 //     builder: (context) => NavScreen(selectedDay: _selectedDay),
// // // // // // // // //                 //   ),
// // // // // // // // //                 // );
// // // // // // // // //               },
// // // // // // // // //               onPageChanged: (focusedDay) {
// // // // // // // // //                 _focusedDay = focusedDay;
// // // // // // // // //               },
// // // // // // // // //               firstDay: DateTime.utc(2020, 1, 1), // Required parameter
// // // // // // // // //               lastDay: DateTime.utc(2030, 12, 31), // Required parameter
// // // // // // // // //               calendarStyle: CalendarStyle(
// // // // // // // // //                 todayDecoration: BoxDecoration(
// // // // // // // // //                   color: Colors.blue,
// // // // // // // // //                   shape: BoxShape.rectangle,
// // // // // // // // //                 ),
// // // // // // // // //                 selectedDecoration: BoxDecoration(
// // // // // // // // //                   color: Colors.blueAccent,
// // // // // // // // //                   shape: BoxShape.rectangle,
// // // // // // // // //                 ),
// // // // // // // // //                 defaultDecoration: BoxDecoration(
// // // // // // // // //                   color: Colors.transparent,
// // // // // // // // //                   shape: BoxShape.rectangle,
// // // // // // // // //                   border: Border.all(color: Colors.black, width: 1),
// // // // // // // // //                 ),
// // // // // // // // //                 weekendDecoration: BoxDecoration(
// // // // // // // // //                   color: Colors.transparent,
// // // // // // // // //                   shape: BoxShape.rectangle,
// // // // // // // // //                   border: Border.all(color: Colors.black, width: 1),
// // // // // // // // //                 ),
// // // // // // // // //               ),
// // // // // // // // //               headerStyle: HeaderStyle(
// // // // // // // // //                 formatButtonVisible: false,
// // // // // // // // //                 titleCentered: true,
// // // // // // // // //               ),
// // // // // // // // //               calendarFormat: _calendarFormat,
// // // // // // // // //             ),
// // // // // // // // //           ],
// // // // // // // // //         ),
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }

// // // // // // // // //   void _showDayOverlay(DateTime selectedDay) {
// // // // // // // // //     final RenderBox renderBox =
// // // // // // // // //         _calendarKey.currentContext?.findRenderObject() as RenderBox;
// // // // // // // // //     final position = renderBox.localToGlobal(Offset.zero);

// // // // // // // // //     _overlayEntry = OverlayEntry(
// // // // // // // // //       builder:
// // // // // // // // //           (context) => Positioned(
// // // // // // // // //             left: position.dx + 50, // Adjust these values as needed
// // // // // // // // //             top: position.dy + 100, // Adjust these values as needed
// // // // // // // // //             child: Material(
// // // // // // // // //               elevation: 4.0,
// // // // // // // // //               child: Container(
// // // // // // // // //                 padding: EdgeInsets.all(16),
// // // // // // // // //                 width: 200,
// // // // // // // // //                 height: 150,
// // // // // // // // //                 decoration: BoxDecoration(
// // // // // // // // //                   color: Colors.white,
// // // // // // // // //                   borderRadius: BorderRadius.circular(8),
// // // // // // // // //                   boxShadow: [
// // // // // // // // //                     BoxShadow(
// // // // // // // // //                       color: Colors.black26,
// // // // // // // // //                       blurRadius: 10.0,
// // // // // // // // //                       spreadRadius: 2.0,
// // // // // // // // //                     ),
// // // // // // // // //                   ],
// // // // // // // // //                 ),
// // // // // // // // //                 child: Column(
// // // // // // // // //                   mainAxisSize: MainAxisSize.min,
// // // // // // // // //                   children: [
// // // // // // // // //                     Text(
// // // // // // // // //                       'Selected Day',
// // // // // // // // //                       style: TextStyle(fontWeight: FontWeight.bold),
// // // // // // // // //                     ),
// // // // // // // // //                     SizedBox(height: 8),
// // // // // // // // //                     Text(DateFormat.yMMMd().format(selectedDay)),
// // // // // // // // //                     SizedBox(height: 16),
// // // // // // // // //                     ElevatedButton(
// // // // // // // // //                       onPressed: () {
// // // // // // // // //                         _overlayEntry?.remove();
// // // // // // // // //                         _overlayEntry = null;
// // // // // // // // //                       },
// // // // // // // // //                       child: Text('Close'),
// // // // // // // // //                     ),
// // // // // // // // //                   ],
// // // // // // // // //                 ),
// // // // // // // // //               ),
// // // // // // // // //             ),
// // // // // // // // //           ),
// // // // // // // // //     );

// // // // // // // // //     Overlay.of(context).insert(_overlayEntry!);
// // // // // // // // //   }
// // // // // // // // // }

// // // // // // // // // void main() {
// // // // // // // // //   runApp(MaterialApp(home: CalendarComponent()));
// // // // // // // // // }

// // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // import 'package:table_calendar/table_calendar.dart';
// // // // // // // // import 'package:intl/intl.dart';

// // // // // // // // class CalendarComponent extends StatefulWidget {
// // // // // // // //   @override
// // // // // // // //   _CalendarComponentState createState() => _CalendarComponentState();
// // // // // // // // }

// // // // // // // // class _CalendarComponentState extends State<CalendarComponent> {
// // // // // // // //   late final ValueNotifier<List<DateTime>> _selectedEvents;
// // // // // // // //   CalendarFormat _calendarFormat = CalendarFormat.month;
// // // // // // // //   DateTime _selectedDay = DateTime.now();
// // // // // // // //   DateTime _focusedDay = DateTime.now();
// // // // // // // //   final GlobalKey _calendarKey = GlobalKey();
// // // // // // // //   OverlayEntry? _overlayEntry;

// // // // // // // //   @override
// // // // // // // //   void initState() {
// // // // // // // //     super.initState();
// // // // // // // //     _selectedEvents = ValueNotifier([]);
// // // // // // // //   }

// // // // // // // //   @override
// // // // // // // //   void dispose() {
// // // // // // // //     _selectedEvents.dispose();
// // // // // // // //     _overlayEntry?.remove();
// // // // // // // //     super.dispose();
// // // // // // // //   }

// // // // // // // //   @override
// // // // // // // //   Widget build(BuildContext context) {
// // // // // // // //     return Scaffold(
// // // // // // // //       appBar: AppBar(title: const Text('Calendar with Overlay')),
// // // // // // // //       body: Center(
// // // // // // // //         child: Column(
// // // // // // // //           children: [
// // // // // // // //             TableCalendar(
// // // // // // // //               key: _calendarKey, // Assign the key here
// // // // // // // //               focusedDay: _focusedDay,
// // // // // // // //               selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
// // // // // // // //               onDaySelected: (selectedDay, focusedDay) {
// // // // // // // //                 setState(() {
// // // // // // // //                   _selectedDay = selectedDay;
// // // // // // // //                   _focusedDay = focusedDay;
// // // // // // // //                 });

// // // // // // // //                 _showDayOverlay(selectedDay);
// // // // // // // //               },
// // // // // // // //               onPageChanged: (focusedDay) {
// // // // // // // //                 setState(() {
// // // // // // // //                   _focusedDay = focusedDay;
// // // // // // // //                 });
// // // // // // // //               },
// // // // // // // //               firstDay: DateTime.utc(2020, 1, 1),
// // // // // // // //               lastDay: DateTime.utc(2030, 12, 31),
// // // // // // // //               calendarStyle: CalendarStyle(
// // // // // // // //                 todayDecoration: BoxDecoration(
// // // // // // // //                   color: Colors.blue,
// // // // // // // //                   shape: BoxShape.rectangle,
// // // // // // // //                 ),
// // // // // // // //                 selectedDecoration: BoxDecoration(
// // // // // // // //                   color: Colors.blueAccent,
// // // // // // // //                   shape: BoxShape.rectangle,
// // // // // // // //                 ),
// // // // // // // //                 defaultDecoration: BoxDecoration(
// // // // // // // //                   color: Colors.transparent,
// // // // // // // //                   shape: BoxShape.rectangle,
// // // // // // // //                   border: Border.all(color: Colors.black, width: 1),
// // // // // // // //                 ),
// // // // // // // //                 weekendDecoration: BoxDecoration(
// // // // // // // //                   color: Colors.transparent,
// // // // // // // //                   shape: BoxShape.rectangle,
// // // // // // // //                   border: Border.all(color: Colors.black, width: 1),
// // // // // // // //                 ),
// // // // // // // //               ),
// // // // // // // //               headerStyle: HeaderStyle(
// // // // // // // //                 formatButtonVisible: false,
// // // // // // // //                 titleCentered: true,
// // // // // // // //               ),
// // // // // // // //               calendarFormat: _calendarFormat,
// // // // // // // //             ),
// // // // // // // //           ],
// // // // // // // //         ),
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }

// // // // // // // //   void _showDayOverlay(DateTime selectedDay) {
// // // // // // // //     // Remove existing overlay if any
// // // // // // // //     _overlayEntry?.remove();

// // // // // // // //     // Find the position of the calendar
// // // // // // // //     final renderBox =
// // // // // // // //         _calendarKey.currentContext?.findRenderObject() as RenderBox?;
// // // // // // // //     if (renderBox == null) return;

// // // // // // // //     final position = renderBox.localToGlobal(Offset.zero);

// // // // // // // //     _overlayEntry = OverlayEntry(
// // // // // // // //       builder: (context) {
// // // // // // // //         // Get screen size for responsive sizing
// // // // // // // //         final screenSize = MediaQuery.of(context).size;

// // // // // // // //         return Stack(
// // // // // // // //           children: [
// // // // // // // //             // Semi-transparent background
// // // // // // // //             GestureDetector(
// // // // // // // //               onTap: () {
// // // // // // // //                 _overlayEntry?.remove();
// // // // // // // //                 _overlayEntry = null;
// // // // // // // //               },
// // // // // // // //               child: Container(color: Colors.black.withOpacity(0.3)),
// // // // // // // //             ),
// // // // // // // //             // Center the overlay content
// // // // // // // //             Center(
// // // // // // // //               child: AnimatedContainer(
// // // // // // // //                 duration: const Duration(milliseconds: 300),
// // // // // // // //                 curve: Curves.easeInOut,
// // // // // // // //                 transform:
// // // // // // // //                     Matrix4.identity()
// // // // // // // //                       ..scale(_overlayEntry == null ? 0.9 : 1.0),
// // // // // // // //                 child: FadeTransition(
// // // // // // // //                   opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
// // // // // // // //                     CurvedAnimation(
// // // // // // // //                       parent: ModalRoute.of(context)!.animation!,
// // // // // // // //                       curve: Curves.easeInOut,
// // // // // // // //                     ),
// // // // // // // //                   ),
// // // // // // // //                   child: Material(
// // // // // // // //                     elevation: 8.0,
// // // // // // // //                     borderRadius: BorderRadius.circular(12),
// // // // // // // //                     child: Container(
// // // // // // // //                       width: screenSize.width * 0.8,
// // // // // // // //                       height: screenSize.height * 0.8,
// // // // // // // //                       padding: const EdgeInsets.all(20),
// // // // // // // //                       decoration: BoxDecoration(
// // // // // // // //                         color: Colors.white,
// // // // // // // //                         borderRadius: BorderRadius.circular(12),
// // // // // // // //                       ),
// // // // // // // //                       child: Column(
// // // // // // // //                         mainAxisAlignment: MainAxisAlignment.center,
// // // // // // // //                         children: [
// // // // // // // //                           Text(
// // // // // // // //                             'Selected Day',
// // // // // // // //                             style: TextStyle(
// // // // // // // //                               fontSize: 24,
// // // // // // // //                               fontWeight: FontWeight.bold,
// // // // // // // //                             ),
// // // // // // // //                           ),
// // // // // // // //                           SizedBox(height: 20),
// // // // // // // //                           Text(
// // // // // // // //                             DateFormat.yMMMMd().format(selectedDay),
// // // // // // // //                             style: TextStyle(fontSize: 18),
// // // // // // // //                           ),
// // // // // // // //                           SizedBox(height: 30),
// // // // // // // //                           ElevatedButton(
// // // // // // // //                             style: ElevatedButton.styleFrom(
// // // // // // // //                               padding: EdgeInsets.symmetric(
// // // // // // // //                                 horizontal: 30,
// // // // // // // //                                 vertical: 15,
// // // // // // // //                               ),
// // // // // // // //                             ),
// // // // // // // //                             onPressed: () {
// // // // // // // //                               _overlayEntry?.remove();
// // // // // // // //                               _overlayEntry = null;
// // // // // // // //                             },
// // // // // // // //                             child: Text(
// // // // // // // //                               'Close',
// // // // // // // //                               style: TextStyle(fontSize: 16),
// // // // // // // //                             ),
// // // // // // // //                           ),
// // // // // // // //                         ],
// // // // // // // //                       ),
// // // // // // // //                     ),
// // // // // // // //                   ),
// // // // // // // //                 ),
// // // // // // // //               ),
// // // // // // // //             ),
// // // // // // // //           ],
// // // // // // // //         );
// // // // // // // //       },
// // // // // // // //     );

// // // // // // // //     // Insert the overlay
// // // // // // // //     Overlay.of(context).insert(_overlayEntry!);
// // // // // // // //   }
// // // // // // // // }

// // // // // // // // void main() {
// // // // // // // //   runApp(MaterialApp(home: CalendarComponent()));
// // // // // // // // }

// // // // // // // import 'package:flutter/material.dart';
// // // // // // // import 'package:intl/intl.dart';
// // // // // // // import 'package:table_calendar/table_calendar.dart';

// // // // // // // void main() {
// // // // // // //   runApp(MyApp());
// // // // // // // }

// // // // // // // class MyApp extends StatelessWidget {
// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return MaterialApp(
// // // // // // //       title: 'Calendar App',
// // // // // // //       theme: ThemeData(
// // // // // // //         primarySwatch: Colors.blue,
// // // // // // //         visualDensity: VisualDensity.adaptivePlatformDensity,
// // // // // // //       ),
// // // // // // //       home: LoginPage(),
// // // // // // //       debugShowCheckedModeBanner: false,
// // // // // // //     );
// // // // // // //   }
// // // // // // // }

// // // // // // // class LoginPage extends StatefulWidget {
// // // // // // //   @override
// // // // // // //   _LoginPageState createState() => _LoginPageState();
// // // // // // // }

// // // // // // // class _LoginPageState extends State<LoginPage> {
// // // // // // //   final _formKey = GlobalKey<FormState>();
// // // // // // //   final _emailController = TextEditingController();
// // // // // // //   final _passwordController = TextEditingController();
// // // // // // //   bool _isLoading = false;

// // // // // // //   @override
// // // // // // //   void dispose() {
// // // // // // //     _emailController.dispose();
// // // // // // //     _passwordController.dispose();
// // // // // // //     super.dispose();
// // // // // // //   }

// // // // // // //   Future<void> _login() async {
// // // // // // //     if (_formKey.currentState!.validate()) {
// // // // // // //       setState(() => _isLoading = true);

// // // // // // //       // Simulate network delay
// // // // // // //       await Future.delayed(Duration(seconds: 2));

// // // // // // //       // In a real app, you would call your authentication API here
// // // // // // //       if (_emailController.text == 'user@example.com' &&
// // // // // // //           _passwordController.text == 'password123') {
// // // // // // //         Navigator.pushReplacement(
// // // // // // //           context,
// // // // // // //           MaterialPageRoute(builder: (context) => CalendarComponent()),
// // // // // // //         );
// // // // // // //       } else {
// // // // // // //         ScaffoldMessenger.of(
// // // // // // //           context,
// // // // // // //         ).showSnackBar(SnackBar(content: Text('Invalid credentials')));
// // // // // // //       }

// // // // // // //       setState(() => _isLoading = false);
// // // // // // //     }
// // // // // // //   }

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return Scaffold(
// // // // // // //       body: Center(
// // // // // // //         child: SingleChildScrollView(
// // // // // // //           padding: EdgeInsets.all(24),
// // // // // // //           child: Column(
// // // // // // //             mainAxisAlignment: MainAxisAlignment.center,
// // // // // // //             children: [
// // // // // // //               FlutterLogo(size: 100),
// // // // // // //               SizedBox(height: 40),
// // // // // // //               Text(
// // // // // // //                 'Welcome to Calendar App',
// // // // // // //                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// // // // // // //               ),
// // // // // // //               SizedBox(height: 20),
// // // // // // //               Form(
// // // // // // //                 key: _formKey,
// // // // // // //                 child: Column(
// // // // // // //                   children: [
// // // // // // //                     TextFormField(
// // // // // // //                       controller: _emailController,
// // // // // // //                       decoration: InputDecoration(
// // // // // // //                         labelText: 'Email',
// // // // // // //                         prefixIcon: Icon(Icons.email),
// // // // // // //                         border: OutlineInputBorder(),
// // // // // // //                       ),
// // // // // // //                       keyboardType: TextInputType.emailAddress,
// // // // // // //                       validator: (value) {
// // // // // // //                         if (value == null || value.isEmpty) {
// // // // // // //                           return 'Please enter your email';
// // // // // // //                         }
// // // // // // //                         if (!value.contains('@')) {
// // // // // // //                           return 'Please enter a valid email';
// // // // // // //                         }
// // // // // // //                         return null;
// // // // // // //                       },
// // // // // // //                     ),
// // // // // // //                     SizedBox(height: 16),
// // // // // // //                     TextFormField(
// // // // // // //                       controller: _passwordController,
// // // // // // //                       decoration: InputDecoration(
// // // // // // //                         labelText: 'Password',
// // // // // // //                         prefixIcon: Icon(Icons.lock),
// // // // // // //                         border: OutlineInputBorder(),
// // // // // // //                       ),
// // // // // // //                       obscureText: true,
// // // // // // //                       validator: (value) {
// // // // // // //                         if (value == null || value.isEmpty) {
// // // // // // //                           return 'Please enter your password';
// // // // // // //                         }
// // // // // // //                         if (value.length < 6) {
// // // // // // //                           return 'Password must be at least 6 characters';
// // // // // // //                         }
// // // // // // //                         return null;
// // // // // // //                       },
// // // // // // //                     ),
// // // // // // //                     SizedBox(height: 24),
// // // // // // //                     SizedBox(
// // // // // // //                       width: double.infinity,
// // // // // // //                       height: 50,
// // // // // // //                       child: ElevatedButton(
// // // // // // //                         onPressed: _isLoading ? null : _login,
// // // // // // //                         child:
// // // // // // //                             _isLoading
// // // // // // //                                 ? CircularProgressIndicator(color: Colors.white)
// // // // // // //                                 : Text('LOGIN'),
// // // // // // //                       ),
// // // // // // //                     ),
// // // // // // //                   ],
// // // // // // //                 ),
// // // // // // //               ),
// // // // // // //               SizedBox(height: 20),
// // // // // // //               TextButton(
// // // // // // //                 onPressed: () {
// // // // // // //                   // Forgot password functionality
// // // // // // //                 },
// // // // // // //                 child: Text('Forgot Password?'),
// // // // // // //               ),
// // // // // // //               SizedBox(height: 10),
// // // // // // //               Row(
// // // // // // //                 mainAxisAlignment: MainAxisAlignment.center,
// // // // // // //                 children: [
// // // // // // //                   Text("Don't have an account?"),
// // // // // // //                   TextButton(
// // // // // // //                     onPressed: () {
// // // // // // //                       // Navigate to sign up page
// // // // // // //                     },
// // // // // // //                     child: Text('Sign Up'),
// // // // // // //                   ),
// // // // // // //                 ],
// // // // // // //               ),
// // // // // // //             ],
// // // // // // //           ),
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }

// // // // // // // class CalendarComponent extends StatefulWidget {
// // // // // // //   @override
// // // // // // //   _CalendarComponentState createState() => _CalendarComponentState();
// // // // // // // }

// // // // // // // class _CalendarComponentState extends State<CalendarComponent> {
// // // // // // //   late final ValueNotifier<List<DateTime>> _selectedEvents;
// // // // // // //   CalendarFormat _calendarFormat = CalendarFormat.month;
// // // // // // //   DateTime _selectedDay = DateTime.now();
// // // // // // //   DateTime _focusedDay = DateTime.now();
// // // // // // //   final GlobalKey _calendarKey = GlobalKey();
// // // // // // //   OverlayEntry? _overlayEntry;
// // // // // // //   AnimationController? _animationController;

// // // // // // //   @override
// // // // // // //   void initState() {
// // // // // // //     super.initState();
// // // // // // //     _selectedEvents = ValueNotifier([]);
// // // // // // //   }

// // // // // // //   @override
// // // // // // //   void dispose() {
// // // // // // //     _selectedEvents.dispose();
// // // // // // //     _removeOverlay();
// // // // // // //     _animationController?.dispose();
// // // // // // //     super.dispose();
// // // // // // //   }

// // // // // // //   void _removeOverlay() {
// // // // // // //     _overlayEntry?.remove();
// // // // // // //     _overlayEntry = null;
// // // // // // //     _animationController?.dispose();
// // // // // // //     _animationController = null;
// // // // // // //   }

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return Scaffold(
// // // // // // //       appBar: AppBar(title: const Text('Calendar with Overlay')),
// // // // // // //       body: Center(
// // // // // // //         child: Column(
// // // // // // //           children: [
// // // // // // //             TableCalendar(
// // // // // // //               key: _calendarKey,
// // // // // // //               focusedDay: _focusedDay,
// // // // // // //               selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
// // // // // // //               onDaySelected: (selectedDay, focusedDay) {
// // // // // // //                 setState(() {
// // // // // // //                   _selectedDay = selectedDay;
// // // // // // //                   _focusedDay = focusedDay;
// // // // // // //                 });
// // // // // // //                 _showDayOverlay(selectedDay, context);
// // // // // // //               },
// // // // // // //               onPageChanged: (focusedDay) {
// // // // // // //                 setState(() {
// // // // // // //                   _focusedDay = focusedDay;
// // // // // // //                 });
// // // // // // //               },
// // // // // // //               firstDay: DateTime.utc(2020, 1, 1),
// // // // // // //               lastDay: DateTime.utc(2030, 12, 31),
// // // // // // //               calendarStyle: CalendarStyle(
// // // // // // //                 todayDecoration: BoxDecoration(
// // // // // // //                   color: Colors.blue,
// // // // // // //                   shape: BoxShape.rectangle,
// // // // // // //                 ),
// // // // // // //                 selectedDecoration: BoxDecoration(
// // // // // // //                   color: Colors.blueAccent,
// // // // // // //                   shape: BoxShape.rectangle,
// // // // // // //                 ),
// // // // // // //                 defaultDecoration: BoxDecoration(
// // // // // // //                   color: Colors.transparent,
// // // // // // //                   shape: BoxShape.rectangle,
// // // // // // //                   border: Border.all(color: Colors.black, width: 1),
// // // // // // //                 ),
// // // // // // //                 weekendDecoration: BoxDecoration(
// // // // // // //                   color: Colors.transparent,
// // // // // // //                   shape: BoxShape.rectangle,
// // // // // // //                   border: Border.all(color: Colors.black, width: 1),
// // // // // // //                 ),
// // // // // // //               ),
// // // // // // //               headerStyle: HeaderStyle(
// // // // // // //                 formatButtonVisible: false,
// // // // // // //                 titleCentered: true,
// // // // // // //               ),
// // // // // // //               calendarFormat: _calendarFormat,
// // // // // // //             ),
// // // // // // //           ],
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }

// // // // // // //   void _showDayOverlay(DateTime selectedDay, BuildContext context) {
// // // // // // //     _removeOverlay(); // Remove any existing overlay

// // // // // // //     _animationController = AnimationController(
// // // // // // //       duration: const Duration(milliseconds: 300),
// // // // // // //       vsync: Navigator.of(context),
// // // // // // //     );

// // // // // // //     final screenSize = MediaQuery.of(context).size;

// // // // // // //     _overlayEntry = OverlayEntry(
// // // // // // //       builder: (context) {
// // // // // // //         return Stack(
// // // // // // //           children: [
// // // // // // //             // Semi-transparent background
// // // // // // //             GestureDetector(
// // // // // // //               onTap: _removeOverlay,
// // // // // // //               child: Container(
// // // // // // //                 color: Colors.black.withOpacity(0.3),
// // // // // // //                 width: screenSize.width,
// // // // // // //                 height: screenSize.height,
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //             // Animated overlay content
// // // // // // //             Center(
// // // // // // //               child: ScaleTransition(
// // // // // // //                 scale: CurvedAnimation(
// // // // // // //                   parent: _animationController!,
// // // // // // //                   curve: Curves.easeOutBack,
// // // // // // //                 ),
// // // // // // //                 child: FadeTransition(
// // // // // // //                   opacity: _animationController!,
// // // // // // //                   child: Material(
// // // // // // //                     elevation: 8.0,
// // // // // // //                     borderRadius: BorderRadius.circular(12),
// // // // // // //                     child: Container(
// // // // // // //                       width: screenSize.width * 0.8,
// // // // // // //                       height: screenSize.height * 0.8,
// // // // // // //                       padding: const EdgeInsets.all(20),
// // // // // // //                       decoration: BoxDecoration(
// // // // // // //                         color: Colors.white,
// // // // // // //                         borderRadius: BorderRadius.circular(12),
// // // // // // //                       ),
// // // // // // //                       child: Column(
// // // // // // //                         mainAxisAlignment: MainAxisAlignment.center,
// // // // // // //                         children: [
// // // // // // //                           Text(
// // // // // // //                             'Selected Day',
// // // // // // //                             style: TextStyle(
// // // // // // //                               fontSize: 24,
// // // // // // //                               fontWeight: FontWeight.bold,
// // // // // // //                             ),
// // // // // // //                           ),
// // // // // // //                           SizedBox(height: 20),
// // // // // // //                           Text(
// // // // // // //                             DateFormat.yMMMMd().format(selectedDay),
// // // // // // //                             style: TextStyle(fontSize: 18),
// // // // // // //                           ),
// // // // // // //                           SizedBox(height: 30),
// // // // // // //                           ElevatedButton(
// // // // // // //                             style: ElevatedButton.styleFrom(
// // // // // // //                               padding: EdgeInsets.symmetric(
// // // // // // //                                 horizontal: 30,
// // // // // // //                                 vertical: 15,
// // // // // // //                               ),
// // // // // // //                             ),
// // // // // // //                             onPressed: _removeOverlay,
// // // // // // //                             child: Text(
// // // // // // //                               'Close',
// // // // // // //                               style: TextStyle(fontSize: 16),
// // // // // // //                             ),
// // // // // // //                           ),
// // // // // // //                         ],
// // // // // // //                       ),
// // // // // // //                     ),
// // // // // // //                   ),
// // // // // // //                 ),
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //           ],
// // // // // // //         );
// // // // // // //       },
// // // // // // //     );

// // // // // // //     Overlay.of(context).insert(_overlayEntry!);
// // // // // // //     _animationController!.forward();
// // // // // // //   }
// // // // // // // }

// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'screens/login_screen.dart';
// // // // // // import 'package:firebase_core/firebase_core.dart';
// // // // // // import 'firebase_options.dart';
// // // // // // import 'firebase_test.dart';

// // // // // // void main() async {
// // // // // //   FirebaseTester.testAuth(); // Temporary - remove after verification
// // // // // //   // WidgetsFlutterBinding.ensureInitialized();
// // // // // //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
// // // // // //   runApp(MyApp());
// // // // // // }

// // // // // // class MyApp extends StatelessWidget {
// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return MaterialApp(
// // // // // //       title: 'Calendar App',
// // // // // //       theme: ThemeData(
// // // // // //         primarySwatch: Colors.blue,
// // // // // //         visualDensity: VisualDensity.adaptivePlatformDensity,
// // // // // //       ),
// // // // // //       home: LoginScreen(),
// // // // // //       debugShowCheckedModeBanner: false,
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:firebase_core/firebase_core.dart';
// // // // // import 'firebase_options.dart';
// // // // // import 'firebase_test.dart';
// // // // // import 'package:cloud_firestore/cloud_firestore.dart';

// // // // // void main() async {
// // // // //   WidgetsFlutterBinding.ensureInitialized();

// // // // //   try {
// // // // //     // Initialize Firebase
// // // // //     await Firebase.initializeApp(
// // // // //       options: DefaultFirebaseOptions.currentPlatform,
// // // // //     );

// // // // //     // Run connection tests
// // // // //     await FirebaseTester.testAuth();

// // // // //     runApp(MyApp());
// // // // //   } catch (e) {
// // // // //     runApp(FirebaseErrorScreen(error: e.toString()));
// // // // //   }
// // // // // }

// // // // // class MyApp extends StatelessWidget {
// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return MaterialApp(
// // // // //       title: 'Calendar App',
// // // // //       theme: ThemeData(primarySwatch: Colors.blue),
// // // // //       // home: LoginScreen(),
// // // // //       debugShowCheckedModeBanner: false,
// // // // //     );
// // // // //   }
// // // // // }

// // // // // class DatabaseService {
// // // // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// // // // //   Future<void> addEvent(DateTime date, String eventDetails) async {
// // // // //     await _firestore.collection('events').add({
// // // // //       'date': date,
// // // // //       'details': eventDetails,
// // // // //       'createdAt': FieldValue.serverTimestamp(),
// // // // //     });
// // // // //   }

// // // // //   Stream<QuerySnapshot> getEvents(DateTime day) {
// // // // //     return _firestore
// // // // //         .collection('events')
// // // // //         .where('date', isEqualTo: day)
// // // // //         .snapshots();
// // // // //   }
// // // // // }

// // // // import 'package:flutter/material.dart';
// // // // import 'package:firebase_database/firebase_database.dart';
// // // // import 'package:firebase_core/firebase_core.dart';

// // // // void main() async {
// // // //   WidgetsFlutterBinding.ensureInitialized();
// // // //   await Firebase.initializeApp();
// // // //   runApp(BookApp());
// // // // }

// // // // class BookApp extends StatelessWidget {
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return MaterialApp(
// // // //       title: 'Favorite Books',
// // // //       theme: ThemeData(primarySwatch: Colors.blue),
// // // //       home: BookListScreen(),
// // // //     );
// // // //   }
// // // // }

// // // // class BookListScreen extends StatefulWidget {
// // // //   @override
// // // //   _BookListScreenState createState() => _BookListScreenState();
// // // // }

// // // // class _BookListScreenState extends State<BookListScreen> {
// // // //   // Form controllers
// // // //   final TextEditingController _titleController = TextEditingController();
// // // //   final TextEditingController _authorController = TextEditingController();
// // // //   final TextEditingController _yearController = TextEditingController();

// // // //   // Reference to our Firebase database
// // // //   final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('books');

// // // //   @override
// // // //   void dispose() {
// // // //     _titleController.dispose();
// // // //     _authorController.dispose();
// // // //     _yearController.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   // Function to add a book to Firebase
// // // //   Future<void> _addBook() async {
// // // //     try {
// // // //       // Get form values
// // // //       final String title = _titleController.text.trim();
// // // //       final String author = _authorController.text.trim();
// // // //       final String year = _yearController.text.trim();

// // // //       if (title.isEmpty || author.isEmpty || year.isEmpty) {
// // // //         ScaffoldMessenger.of(
// // // //           context,
// // // //         ).showSnackBar(SnackBar(content: Text('Please fill all fields')));
// // // //         return;
// // // //       }

// // // //       // Create a new book entry
// // // //       final newBookRef = _databaseRef.push();
// // // //       await newBookRef.set({
// // // //         'title': title,
// // // //         'author': author,
// // // //         'year': year,
// // // //         'createdAt': ServerValue.timestamp,
// // // //       });

// // // //       // Clear form
// // // //       _titleController.clear();
// // // //       _authorController.clear();
// // // //       _yearController.clear();

// // // //       // Show success message
// // // //       ScaffoldMessenger.of(
// // // //         context,
// // // //       ).showSnackBar(SnackBar(content: Text('Book added successfully!')));
// // // //     } catch (e) {
// // // //       ScaffoldMessenger.of(
// // // //         context,
// // // //       ).showSnackBar(SnackBar(content: Text('Error adding book: $e')));
// // // //     }
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(title: Text('Add Favorite Book')),
// // // //       body: Padding(
// // // //         padding: const EdgeInsets.all(16.0),
// // // //         child: Column(
// // // //           children: [
// // // //             TextField(
// // // //               controller: _titleController,
// // // //               decoration: InputDecoration(
// // // //                 labelText: 'Book Title',
// // // //                 border: OutlineInputBorder(),
// // // //               ),
// // // //             ),
// // // //             SizedBox(height: 16),
// // // //             TextField(
// // // //               controller: _authorController,
// // // //               decoration: InputDecoration(
// // // //                 labelText: 'Author',
// // // //                 border: OutlineInputBorder(),
// // // //               ),
// // // //             ),
// // // //             SizedBox(height: 16),
// // // //             TextField(
// // // //               controller: _yearController,
// // // //               decoration: InputDecoration(
// // // //                 labelText: 'Publication Year',
// // // //                 border: OutlineInputBorder(),
// // // //               ),
// // // //               keyboardType: TextInputType.number,
// // // //             ),
// // // //             SizedBox(height: 24),
// // // //             ElevatedButton(
// // // //               onPressed: _addBook,
// // // //               child: Text('Add Book to Firebase'),
// // // //               style: ElevatedButton.styleFrom(
// // // //                 minimumSize: Size(double.infinity, 50),
// // // //               ),
// // // //             ),
// // // //             SizedBox(height: 24),
// // // //             Expanded(
// // // //               child: StreamBuilder<DatabaseEvent>(
// // // //                 stream: _databaseRef.onValue,
// // // //                 builder: (context, snapshot) {
// // // //                   if (snapshot.hasData &&
// // // //                       snapshot.data!.snapshot.value != null) {
// // // //                     // Convert the data from Firebase to a Map
// // // //                     final booksMap = Map<String, dynamic>.from(
// // // //                       snapshot.data!.snapshot.value as Map,
// // // //                     );

// // // //                     // Convert the Map to a List of books
// // // //                     final booksList =
// // // //                         booksMap.entries.map((entry) {
// // // //                           return MapEntry(
// // // //                             entry.key,
// // // //                             Map<String, dynamic>.from(entry.value),
// // // //                           );
// // // //                         }).toList();

// // // //                     return ListView.builder(
// // // //                       itemCount: booksList.length,
// // // //                       itemBuilder: (context, index) {
// // // //                         final book = booksList[index].value;
// // // //                         return ListTile(
// // // //                           title: Text(book['title']),
// // // //                           subtitle: Text('${book['author']} (${book['year']})'),
// // // //                         );
// // // //                       },
// // // //                     );
// // // //                   } else if (snapshot.hasError) {
// // // //                     return Center(child: Text('Error loading books'));
// // // //                   } else {
// // // //                     return Center(child: Text('No books added yet'));
// // // //                   }
// // // //                 },
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // import 'package:flutter/material.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:firebase_core/firebase_core.dart';

// // // void main() async {
// // //   WidgetsFlutterBinding.ensureInitialized();
// // //   await Firebase.initializeApp();
// // //   runApp(AuthApp());
// // // }

// // // class AuthApp extends StatelessWidget {
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       title: 'Firebase Auth Demo',
// // //       theme: ThemeData(primarySwatch: Colors.blue),
// // //       home: RegistrationScreen(),
// // //     );
// // //   }
// // // }

// // // class RegistrationScreen extends StatefulWidget {
// // //   @override
// // //   _RegistrationScreenState createState() => _RegistrationScreenState();
// // // }

// // // class _RegistrationScreenState extends State<RegistrationScreen> {
// // //   final _formKey = GlobalKey<FormState>();
// // //   final _emailController = TextEditingController();
// // //   final _passwordController = TextEditingController();
// // //   final _confirmPasswordController = TextEditingController();

// // //   bool _isLoading = false;
// // //   String? _errorMessage;

// // //   @override
// // //   void dispose() {
// // //     _emailController.dispose();
// // //     _passwordController.dispose();
// // //     _confirmPasswordController.dispose();
// // //     super.dispose();
// // //   }

// // //   Future<void> _registerUser() async {
// // //     if (!_formKey.currentState!.validate()) return;

// // //     setState(() {
// // //       _isLoading = true;
// // //       _errorMessage = null;
// // //     });

// // //     try {
// // //       final email = _emailController.text.trim();
// // //       final password = _passwordController.text.trim();

// // //       // Create user with Firebase Auth
// // //       UserCredential userCredential = await FirebaseAuth.instance
// // //           .createUserWithEmailAndPassword(email: email, password: password);

// // //       // Optional: Send email verification
// // //       await userCredential.user?.sendEmailVerification();

// // //       // Show success message
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(
// // //           content: Text('Registration successful! Verification email sent.'),
// // //           backgroundColor: Colors.green,
// // //         ),
// // //       );

// // //       // Clear form
// // //       _emailController.clear();
// // //       _passwordController.clear();
// // //       _confirmPasswordController.clear();
// // //     } on FirebaseAuthException catch (e) {
// // //       setState(() {
// // //         _errorMessage = _getErrorMessage(e.code);
// // //       });
// // //     } catch (e) {
// // //       setState(() {
// // //         _errorMessage = 'An unexpected error occurred';
// // //       });
// // //     } finally {
// // //       setState(() {
// // //         _isLoading = false;
// // //       });
// // //     }
// // //   }

// // //   String _getErrorMessage(String code) {
// // //     switch (code) {
// // //       case 'email-already-in-use':
// // //         return 'This email is already registered';
// // //       case 'invalid-email':
// // //         return 'Please enter a valid email';
// // //       case 'operation-not-allowed':
// // //         return 'Email/password accounts are not enabled';
// // //       case 'weak-password':
// // //         return 'Password is too weak';
// // //       default:
// // //         return 'Registration failed';
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: Text('User Registration')),
// // //       body: Padding(
// // //         padding: const EdgeInsets.all(16.0),
// // //         child: Form(
// // //           key: _formKey,
// // //           child: Column(
// // //             children: [
// // //               TextFormField(
// // //                 controller: _emailController,
// // //                 decoration: InputDecoration(
// // //                   labelText: 'Email',
// // //                   border: OutlineInputBorder(),
// // //                   prefixIcon: Icon(Icons.email),
// // //                 ),
// // //                 keyboardType: TextInputType.emailAddress,
// // //                 validator: (value) {
// // //                   if (value == null || value.isEmpty) {
// // //                     return 'Please enter your email';
// // //                   }
// // //                   if (!RegExp(
// // //                     r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
// // //                   ).hasMatch(value)) {
// // //                     return 'Please enter a valid email';
// // //                   }
// // //                   return null;
// // //                 },
// // //               ),
// // //               SizedBox(height: 16),
// // //               TextFormField(
// // //                 controller: _passwordController,
// // //                 decoration: InputDecoration(
// // //                   labelText: 'Password',
// // //                   border: OutlineInputBorder(),
// // //                   prefixIcon: Icon(Icons.lock),
// // //                 ),
// // //                 obscureText: true,
// // //                 validator: (value) {
// // //                   if (value == null || value.isEmpty) {
// // //                     return 'Please enter a password';
// // //                   }
// // //                   if (value.length < 6) {
// // //                     return 'Password must be at least 6 characters';
// // //                   }
// // //                   return null;
// // //                 },
// // //               ),
// // //               SizedBox(height: 16),
// // //               TextFormField(
// // //                 controller: _confirmPasswordController,
// // //                 decoration: InputDecoration(
// // //                   labelText: 'Confirm Password',
// // //                   border: OutlineInputBorder(),
// // //                   prefixIcon: Icon(Icons.lock),
// // //                 ),
// // //                 obscureText: true,
// // //                 validator: (value) {
// // //                   if (value != _passwordController.text) {
// // //                     return 'Passwords do not match';
// // //                   }
// // //                   return null;
// // //                 },
// // //               ),
// // //               SizedBox(height: 24),
// // //               if (_errorMessage != null)
// // //                 Text(_errorMessage!, style: TextStyle(color: Colors.red)),
// // //               SizedBox(height: 16),
// // //               SizedBox(
// // //                 width: double.infinity,
// // //                 child: ElevatedButton(
// // //                   onPressed: _isLoading ? null : _registerUser,
// // //                   child:
// // //                       _isLoading
// // //                           ? CircularProgressIndicator(color: Colors.white)
// // //                           : Text('Register'),
// // //                   style: ElevatedButton.styleFrom(
// // //                     padding: EdgeInsets.symmetric(vertical: 16),
// // //                   ),
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
