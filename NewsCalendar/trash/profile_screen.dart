// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:newscalendar/constants/constants.dart';
// import 'dart:convert';
// import 'edit_profile_screen.dart';
// import 'package:newscalendar/main.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({Key? key}) : super(key: key);

//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   Map<String, dynamic>? _userData;
//   bool _isLoading = true;
//   String? _errorMessage;
//   bool _isRefreshing = false;
//   @override
//   void initState() {
//     super.initState();
//     // _fetchUserData();
//     _loadInitialData();
//   }

//   Future<void> _loadInitialData() async {
//     // First try to load from cache if available
//     final userService = Provider.of<UserService>(context, listen: false);
//     if (userService.cachedUserData != null) {
//       setState(() {
//         _userData = userService.cachedUserData;
//       });
//     }

//     // Then fetch fresh data
//     await _fetchUserData();
//   }

//   Future<void> _fetchUserData() async {
//     if (!_isRefreshing) setState(() => _isLoading = true);
//     _errorMessage = null;
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final userService = Provider.of<UserService>(context, listen: false);
//       final userId = await userService.getUserId();
//       print(userId);
//       if (userId == null) throw Exception('User not logged in');
//       // TODO: Replace with your Express backend endpoint

//       final response = await http.post(
//         Uri.parse('$BASE_URL/get-user'), // Updated endpoint
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'userId': userId}),
//       );
//       print(response.statusCode);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print(data);
//         userService.cacheUserData(data['userData'][0]); // Cache the data
//         setState(() {
//           _userData = data['userData'][0];
//         });
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to load profile data';
//         });
//       }
//       // */
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error loading profile: ${e.toString()}';
//         _isLoading = false;
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//         _isRefreshing = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             onPressed: () {
//               if (_userData != null) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder:
//                         (context) => EditProfileScreen(userData: _userData!),
//                   ),
//                 ).then((_) => _fetchUserData()); // Refresh after editing
//               }
//             },
//           ),
//         ],
//       ),
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : _errorMessage != null
//               ? Center(child: Text(_errorMessage!))
//               : Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     CircleAvatar(
//                       radius: 50,
//                       backgroundImage:
//                           _userData!['photoUrl'] != null
//                               ? NetworkImage(_userData!['photoUrl'])
//                               : null,
//                       child:
//                           _userData!['photoUrl'] == null
//                               ? const Icon(Icons.person, size: 50)
//                               : null,
//                     ),
//                     const SizedBox(height: 20),
//                     Text(
//                       'Name: ${_userData!['name'] ?? 'Not provided'}',
//                       style: const TextStyle(fontSize: 18),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       'Email: ${_userData!['email'] ?? 'Not provided'}',
//                       style: const TextStyle(fontSize: 18),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       'Phone: ${_userData!['phone'] ?? 'Not provided'}',
//                       style: const TextStyle(fontSize: 18),
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }
// }
