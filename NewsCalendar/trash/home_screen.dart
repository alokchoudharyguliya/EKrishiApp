// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../auth_service.dart';

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final authService = Provider.of<AuthService>(context);
//     final user = authService.currentUser;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Home'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () async {
//               await authService.signOut();
//               Navigator.pushReplacementNamed(context, '/login');
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Welcome ${user?.email ?? 'User'}!'),
//             SizedBox(height: 20),
//             Text('You are successfully logged in'),
//           ],
//         ),
//       ),
//     );
//   }
// }
