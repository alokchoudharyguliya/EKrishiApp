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
