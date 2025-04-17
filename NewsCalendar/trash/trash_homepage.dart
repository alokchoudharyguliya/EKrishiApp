// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import './auth_service.dart';

// class Homepage extends StatefulWidget {
//   const Homepage({super.key});

//   @override
//   State<Homepage> createState() => _HomepageState();
// }

// class _HomepageState extends State<Homepage> {
//   signout() async {
//     await FirebaseAuth.instance
//         .signOut()
//         .then((value) => {Navigator.pushReplacementNamed(context, '/login')})
//         .catchError((err) => {throw err});
//   }

//   final user = FirebaseAuth.instance.currentUser;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Home"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () async {
//               await signout();
//               Navigator.pushReplacementNamed(context, '/login');
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           children: [
//             Text('${user!.email}'),
//             FloatingActionButton(
//               onPressed: (() => {Navigator.pushNamed(context, '/calendar')}),
//               child: Icon(Icons.calendar_view_day_rounded),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import './screens/profile_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import './auth_service.dart';
// import './screens/settings.dart';
// import './screens/auth_form_provider.dart';

// class Homepage extends StatefulWidget {
//   const Homepage({super.key});

//   @override
//   State<Homepage> createState() => _HomepageState();
// }

// class _HomepageState extends State<Homepage> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   final user = FirebaseAuth.instance.currentUser;
//   final DateTime _today = DateTime.now();

//   signout() async {
//     await FirebaseAuth.instance
//         .signOut()
//         .then((value) => {Navigator.pushReplacementNamed(context, '/login')})
//         .catchError((err) => {throw err});
//   }

//   void _showDateBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           height: MediaQuery.of(context).size.height * 0.8,
//           width: MediaQuery.of(context).size.width * 0.9,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Today is',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Theme.of(context).primaryColor,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 DateFormat.yMMMMEEEEd().format(_today),
//                 style: const TextStyle(fontSize: 20),
//               ),
//               const SizedBox(height: 30),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 30,
//                     vertical: 15,
//                   ),
//                   backgroundColor: Theme.of(context).primaryColor,
//                 ),
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Close', style: TextStyle(fontSize: 16)),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//         //   title: const Text("Home"),
//         //   leading: IconButton(
//         //     icon: const Icon(Icons.menu),
//         //     onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
//         //   ),
//         //   actions: [
//         //     IconButton(
//         //       icon: const Icon(Icons.logout),
//         //       onPressed: () async {
//         //         await signout();
//         //         Navigator.pushReplacementNamed(context, '/login');
//         //       },
//         //     ),
//         //   ],
//         // ),
//         // endDrawer: Drawer(
//         //   child: ListView(
//         //     padding: EdgeInsets.zero,
//         //     children: [
//         //       DrawerHeader(
//         //         decoration: BoxDecoration(color: Theme.of(context).primaryColor),
//         //         child: Text(
//         //           'Menu Options',
//         //           style: TextStyle(color: Colors.white, fontSize: 24),
//         //         ),
//         //       ),
//         //       ListTile(
//         //         leading: const Icon(Icons.home),
//         //         title: const Text('Home'),
//         //         onTap: () {
//         //           Navigator.pop(context);
//         //         },
//         //       ),
//         //       ListTile(
//         //         leading: const Icon(Icons.person),
//         //         title: const Text('Profile'),
//         //         onTap: () {
//         //           Navigator.pushReplacement(
//         //             context,
//         //             MaterialPageRoute(builder: (context) => ProfileScreen()),
//         //           );
//         //           // Navigator.pop(context);
//         //         },
//         //       ),
//         //       ListTile(
//         //         leading: const Icon(Icons.settings),
//         //         title: const Text('Settings'),
//         //         onTap: () {
//         //           Navigator.pushNamed(context, '/settings');
//         //         },
//         //       ),
//         //       ListTile(
//         //         leading: const Icon(Icons.upload_rounded),
//         //         title: const Text('Upload Academic Schedule'),
//         //         onTap: () {
//         //           Navigator.pushNamed(context, '/upload-schedule');
//         //         },
//         //       ),
//         //       ListTile(
//         //         leading: const Icon(Icons.calendar_today),
//         //         title: const Text('Calendar'),
//         //         onTap: () {
//         //           Navigator.pop(context);
//         //           Navigator.pushNamed(context, '/calendar');
//         //         },
//         //       ),
//         //       ListTile(
//         //         leading: const Icon(Icons.help),
//         //         title: const Text('Help & Support'),
//         //         onTap: () {
//         //           Navigator.pop(context);
//         //         },
//         //       ),
//         //     ],
//         //   ),
//         // ),
//         // body: Center(
//         //   child: Column(
//         //     mainAxisAlignment: MainAxisAlignment.center,
//         //     children: [
//         //       Text('Welcome, ${user!.email}'),
//         //       const SizedBox(height: 20),
//         //       Text(
//         //         'Today is ${DateFormat.MMMMEEEEd().format(_today)}',
//         //         style: const TextStyle(fontSize: 18),
//         //       ),
//         //       const SizedBox(height: 30),
//         //       ElevatedButton(
//         //         style: ElevatedButton.styleFrom(
//         //           padding: const EdgeInsets.symmetric(
//         //             horizontal: 35,
//         //             vertical: 15,
//         //           ),
//         //           backgroundColor: Theme.of(context).primaryColor,
//         //         ),
//         //         onPressed: () => _showDateBottomSheet(context),
//         //         child: const Text(
//         //           'View Detailed Date',
//         //           style: TextStyle(fontSize: 16, color: Colors.white),
//         //         ),
//         //       ),
//         //       const SizedBox(height: 20),
//         //       FloatingActionButton(
//         //         onPressed: () => Navigator.pushNamed(context, '/calendar'),
//         //         child: const Icon(Icons.calendar_view_day_rounded),
//         //       ),
//         //     ],
//         //   ),
//         // ),
//       ),
//     );
//   }
// }
