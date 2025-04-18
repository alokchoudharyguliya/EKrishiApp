// // // import 'package:flutter/material.dart';
// // // import 'package:provider/provider.dart';
// // // import 'package:http/http.dart' as http;
// // // import 'package:newscalendar/constants/constants.dart';
// // // import 'dart:convert';
// // // import 'edit_profile_screen.dart';
// // // import 'package:newscalendar/main.dart';

// // // class ProfileScreen extends StatefulWidget {
// // //   const ProfileScreen({Key? key}) : super(key: key);

// // //   @override
// // //   _ProfileScreenState createState() => _ProfileScreenState();
// // // }

// // // class _ProfileScreenState extends State<ProfileScreen> {
// // //   Map<String, dynamic>? _userData;
// // //   bool _isLoading = true;
// // //   String? _errorMessage;
// // //   bool _isRefreshing = false;
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     // _fetchUserData();
// // //     _loadInitialData();
// // //   }

// // //   Future<void> _loadInitialData() async {
// // //     // First try to load from cache if available
// // //     final userService = Provider.of<UserService>(context, listen: false);
// // //     if (userService.cachedUserData != null) {
// // //       setState(() {
// // //         _userData = userService.cachedUserData;
// // //       });
// // //     }

// // //     // Then fetch fresh data
// // //     await _fetchUserData();
// // //   }

// // //   Future<void> _fetchUserData() async {
// // //     if (!_isRefreshing) setState(() => _isLoading = true);
// // //     _errorMessage = null;
// // //     setState(() {
// // //       _isLoading = true;
// // //       _errorMessage = null;
// // //     });

// // //     try {
// // //       final userService = Provider.of<UserService>(context, listen: false);
// // //       final userId = await userService.getUserId();
// // //       print(userId);
// // //       if (userId == null) throw Exception('User not logged in');
// // //       // TODO: Replace with your Express backend endpoint

// // //       final response = await http.post(
// // //         Uri.parse('$BASE_URL/get-user'), // Updated endpoint
// // //         headers: {'Content-Type': 'application/json'},
// // //         body: json.encode({'userId': userId}),
// // //       );
// // //       print(response.statusCode);
// // //       if (response.statusCode == 200) {
// // //         final data = json.decode(response.body);
// // //         print(data);
// // //         userService.cacheUserData(data['userData'][0]); // Cache the data
// // //         setState(() {
// // //           _userData = data['userData'][0];
// // //         });
// // //       } else {
// // //         setState(() {
// // //           _errorMessage = 'Failed to load profile data';
// // //         });
// // //       }
// // //       // */
// // //     } catch (e) {
// // //       setState(() {
// // //         _errorMessage = 'Error loading profile: ${e.toString()}';
// // //         _isLoading = false;
// // //       });
// // //     } finally {
// // //       setState(() {
// // //         _isLoading = false;
// // //         _isRefreshing = false;
// // //       });
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text('Profile'),
// // //         actions: [
// // //           IconButton(
// // //             icon: const Icon(Icons.edit),
// // //             onPressed: () {
// // //               if (_userData != null) {
// // //                 Navigator.push(
// // //                   context,
// // //                   MaterialPageRoute(
// // //                     builder:
// // //                         (context) => EditProfileScreen(userData: _userData!),
// // //                   ),
// // //                 ).then((_) => _fetchUserData()); // Refresh after editing
// // //               }
// // //             },
// // //           ),
// // //         ],
// // //       ),
// // //       body:
// // //           _isLoading
// // //               ? const Center(child: CircularProgressIndicator())
// // //               : _errorMessage != null
// // //               ? Center(child: Text(_errorMessage!))
// // //               : Padding(
// // //                 padding: const EdgeInsets.all(16.0),
// // //                 child: Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                   children: [
// // //                     CircleAvatar(
// // //                       radius: 50,
// // //                       backgroundImage:
// // //                           _userData!['photoUrl'] != null
// // //                               ? NetworkImage(_userData!['photoUrl'])
// // //                               : null,
// // //                       child:
// // //                           _userData!['photoUrl'] == null
// // //                               ? const Icon(Icons.person, size: 50)
// // //                               : null,
// // //                     ),
// // //                     const SizedBox(height: 20),
// // //                     Text(
// // //                       'Name: ${_userData!['name'] ?? 'Not provided'}',
// // //                       style: const TextStyle(fontSize: 18),
// // //                     ),
// // //                     const SizedBox(height: 10),
// // //                     Text(
// // //                       'Email: ${_userData!['email'] ?? 'Not provided'}',
// // //                       style: const TextStyle(fontSize: 18),
// // //                     ),
// // //                     const SizedBox(height: 10),
// // //                     Text(
// // //                       'Phone: ${_userData!['phone'] ?? 'Not provided'}',
// // //                       style: const TextStyle(fontSize: 18),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //     );
// // //   }
// // // }
// // import 'package:image_picker/image_picker.dart';
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:newscalendar/constants/constants.dart';
// // import 'dart:convert';
// // import 'edit_profile_screen.dart';
// // import 'package:newscalendar/main.dart';

// // class ProfileScreen extends StatefulWidget {
// //   const ProfileScreen({Key? key}) : super(key: key);

// //   @override
// //   _ProfileScreenState createState() => _ProfileScreenState();
// // }

// // class _ProfileScreenState extends State<ProfileScreen> {
// //   Map<String, dynamic>? _userData;
// //   bool _isLoading = true;
// //   String? _errorMessage;
// //   bool _isRefreshing = false;
// //   bool _isEditing = false;

// //   // Controllers for editable fields
// //   late TextEditingController _nameController;
// //   late TextEditingController _emailController;
// //   late TextEditingController _phoneController;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _nameController = TextEditingController();
// //     _emailController = TextEditingController();
// //     _phoneController = TextEditingController();
// //     _loadInitialData();
// //   }

// //   @override
// //   void dispose() {
// //     _nameController.dispose();
// //     _emailController.dispose();
// //     _phoneController.dispose();
// //     super.dispose();
// //   }

// //   // Add this method to your _ProfileScreenState class
// //   Future<void> _updateProfilePhoto() async {
// //     try {
// //       final picker = ImagePicker();
// //       final pickedFile = await picker.pickImage(
// //         source: ImageSource.gallery,
// //         maxWidth: 800,
// //         maxHeight: 800,
// //         imageQuality: 85,
// //       );

// //       if (pickedFile == null) return;

// //       // Show cropping screen
// //       // final croppedFile = await Navigator.push<CroppedFile>(
// //       //   context,
// //       // MaterialPageRoute(
// //       // builder: (context) => ImageCropperPage(imageFile: pickedFile),
// //       // ),
// //       // );

// //       // if (croppedFile == null) return;

// //       setState(() => _isLoading = true);

// //       final userService = Provider.of<UserService>(context, listen: false);
// //       final userId = await userService.getUserId();
// //       if (userId == null) throw Exception('User not logged in');

// //       // Read the cropped file bytes
// //       final fileBytes = await croppedFile.readAsBytes();
// //       final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

// //       // Create multipart request
// //       var request = http.MultipartRequest(
// //         'POST',
// //         Uri.parse('$BASE_URL/upload-profile-photo'),
// //       );

// //       // Add fields
// //       request.fields['userId'] = userId;

// //       // Add image file
// //       request.files.add(
// //         http.MultipartFile.fromBytes('photo', fileBytes, filename: fileName),
// //       );

// //       // Send request
// //       final response = await request.send();

// //       if (response.statusCode == 200) {
// //         final responseData = await response.stream.bytesToString();
// //         final jsonResponse = json.decode(responseData);

// //         if (jsonResponse['success']) {
// //           final photoUrl = jsonResponse['photoUrl'];

// //           // Update local state and cache
// //           final updatedUserData = {..._userData!, 'photoUrl': photoUrl};

// //           setState(() {
// //             _userData = updatedUserData;
// //           });
// //           userService.cacheUserData(updatedUserData);

// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(content: Text('Profile photo updated successfully')),
// //           );
// //         }
// //       } else {
// //         throw Exception('Failed to upload photo: ${response.statusCode}');
// //       }
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error updating photo: ${e.toString()}')),
// //       );
// //     } finally {
// //       setState(() => _isLoading = false);
// //     }
// //   }

// //   Future<void> _loadInitialData() async {
// //     final userService = Provider.of<UserService>(context, listen: false);
// //     if (userService.cachedUserData != null) {
// //       setState(() {
// //         _userData = userService.cachedUserData;
// //         _updateControllers();
// //       });
// //     }
// //     await _fetchUserData();
// //   }

// //   void _updateControllers() {
// //     if (_userData != null) {
// //       _nameController.text = _userData!['name'] ?? '';
// //       _emailController.text = _userData!['email'] ?? '';
// //       _phoneController.text = _userData!['phone'] ?? '';
// //     }
// //   }

// //   Future<void> _fetchUserData() async {
// //     if (!_isRefreshing) setState(() => _isLoading = true);
// //     _errorMessage = null;

// //     try {
// //       final userService = Provider.of<UserService>(context, listen: false);
// //       final userId = await userService.getUserId();
// //       if (userId == null) throw Exception('User not logged in');

// //       final response = await http.post(
// //         Uri.parse('$BASE_URL/get-user'),
// //         headers: {'Content-Type': 'application/json'},
// //         body: json.encode({'userId': userId}),
// //       );

// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);
// //         userService.cacheUserData(data['userData'][0]);
// //         setState(() {
// //           _userData = data['userData'][0];
// //           _updateControllers();
// //         });
// //       } else {
// //         setState(() {
// //           _errorMessage = 'Failed to load profile data';
// //         });
// //       }
// //     } catch (e) {
// //       setState(() {
// //         _errorMessage = 'Error loading profile: ${e.toString()}';
// //       });
// //     } finally {
// //       setState(() {
// //         _isLoading = false;
// //         _isRefreshing = false;
// //       });
// //     }
// //   }

// //   Future<void> _saveProfileChanges() async {
// //     setState(() => _isLoading = true);
// //     _errorMessage = null;

// //     try {
// //       final userService = Provider.of<UserService>(context, listen: false);
// //       final userId = await userService.getUserId();

// //       if (userId == null) throw Exception('User not logged in');

// //       final updatedUserData = {
// //         ..._userData!,
// //         'name': _nameController.text,
// //         'email': _emailController.text,
// //         'phone': _phoneController.text,
// //       };

// //       final response = await http.post(
// //         Uri.parse('$BASE_URL/save-user'),
// //         headers: {'Content-Type': 'application/json'},
// //         body: json.encode({'userId': userId, 'userData': updatedUserData}),
// //       );

// //       if (response.statusCode == 200) {
// //         final responseData = json.decode(response.body);

// //         setState(() {
// //           _userData = updatedUserData;
// //         });
// //         userService.cacheUserData(updatedUserData);

// //         ScaffoldMessenger.of(
// //           context,
// //         ).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
// //       } else {
// //         throw Exception('Failed to save profile: ${response.statusCode}');
// //       }
// //     } catch (e) {
// //       setState(() {
// //         _errorMessage = 'Error saving profile: ${e.toString()}';
// //       });
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error saving profile: ${e.toString()}')),
// //       );
// //     } finally {
// //       setState(() {
// //         _isLoading = false;
// //         _isEditing = false;
// //       });
// //     }
// //   }

// //   void _toggleEdit() {
// //     setState(() {
// //       _isEditing = !_isEditing;
// //       if (!_isEditing) {
// //         _updateControllers();
// //       }
// //     });
// //   }

// //   Widget _buildEditableField({
// //     required String label,
// //     required TextEditingController controller,
// //     required bool isEditing,
// //     TextInputType? keyboardType,
// //   }) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 8.0),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           if (isEditing)
// //             Text(
// //               label,
// //               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
// //             ),
// //           const SizedBox(height: 4),
// //           isEditing
// //               ? TextFormField(
// //                 controller: controller,
// //                 keyboardType: keyboardType,
// //                 decoration: InputDecoration(
// //                   border: OutlineInputBorder(),
// //                   contentPadding: EdgeInsets.symmetric(
// //                     vertical: 12,
// //                     horizontal: 12,
// //                   ),
// //                 ),
// //               )
// //               : Padding(
// //                 padding: const EdgeInsets.symmetric(vertical: 8.0),
// //                 child: Row(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       '$label: ',
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.grey[700],
// //                       ),
// //                     ),
// //                     Expanded(
// //                       child: Text(
// //                         controller.text.isNotEmpty
// //                             ? controller.text
// //                             : 'Not provided',
// //                         style: TextStyle(fontSize: 16),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //         ],
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Profile'),
// //         actions: [
// //           IconButton(
// //             icon: Icon(_isEditing ? Icons.save : Icons.edit),
// //             onPressed: _isLoading ? _saveProfileChanges : _toggleEdit,
// //           ),
// //         ],
// //       ),
// //       body:
// //           _isLoading
// //               ? const Center(child: CircularProgressIndicator())
// //               : _errorMessage != null
// //               ? Center(child: Text(_errorMessage!))
// //               : SingleChildScrollView(
// //                 padding: const EdgeInsets.all(16.0),
// //                 child: Column(
// //                   children: [
// //                     Center(
// //                       child: Stack(
// //                         children: [
// //                           CircleAvatar(
// //                             radius: 60,
// //                             backgroundImage:
// //                                 _userData!['photoUrl'] != null
// //                                     ? NetworkImage(_userData!['photoUrl'])
// //                                     : null,
// //                             child:
// //                                 _userData!['photoUrl'] == null
// //                                     ? const Icon(Icons.person, size: 60)
// //                                     : null,
// //                           ),
// //                           if (_isEditing)
// //                             Positioned(
// //                               bottom: 0,
// //                               right: 0,
// //                               child: Container(
// //                                 decoration: BoxDecoration(
// //                                   color: Colors.blue,
// //                                   shape: BoxShape.circle,
// //                                 ),
// //                                 child: IconButton(
// //                                   icon: Icon(
// //                                     Icons.camera_alt,
// //                                     color: Colors.white,
// //                                   ),
// //                                   onPressed:
// //                                       _isLoading ? null : _updateProfilePhoto,
// //                                 ),
// //                               ),
// //                             ),
// //                         ],
// //                       ),
// //                     ),
// //                     const SizedBox(height: 24),
// //                     _buildEditableField(
// //                       label: 'Name',
// //                       controller: _nameController,
// //                       isEditing: _isEditing,
// //                     ),
// //                     _buildEditableField(
// //                       label: 'Email',
// //                       controller: _emailController,
// //                       isEditing: _isEditing,
// //                       keyboardType: TextInputType.emailAddress,
// //                     ),
// //                     _buildEditableField(
// //                       label: 'Phone',
// //                       controller: _phoneController,
// //                       isEditing: _isEditing,
// //                       keyboardType: TextInputType.phone,
// //                     ),
// //                     if (!_isEditing)
// //                       Padding(
// //                         padding: const EdgeInsets.only(top: 24.0),
// //                         child: ElevatedButton(
// //                           onPressed: () {
// //                             Navigator.push(
// //                               context,
// //                               MaterialPageRoute(
// //                                 builder:
// //                                     (context) =>
// //                                         EditProfileScreen(userData: _userData!),
// //                               ),
// //                             ).then((_) => _fetchUserData());
// //                           },
// //                           child: Text('Advanced Edit'),
// //                         ),
// //                       ),
// //                   ],
// //                 ),
// //               ),
// //     );
// //   }
// // }

// import 'package:image_picker/image_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:newscalendar/constants/constants.dart';
// import 'dart:convert';
// import 'dart:io';
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
//   bool _isEditing = false;
//   File? _selectedImageFile;
//   String? _tempImagePath;

//   // Controllers for editable fields
//   late TextEditingController _nameController;
//   late TextEditingController _emailController;
//   late TextEditingController _phoneController;

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController();
//     _emailController = TextEditingController();
//     _phoneController = TextEditingController();
//     _loadInitialData();
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     // Clean up temporary image file if exists
//     if (_tempImagePath != null && _selectedImageFile == null) {
//       try {
//         File(_tempImagePath!).deleteSync();
//       } catch (e) {
//         debugPrint('Error deleting temp image: $e');
//       }
//     }
//     super.dispose();
//   }

//   Future<void> _selectProfileImage() async {
//     try {
//       final picker = ImagePicker();
//       final pickedFile = await picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 800,
//         maxHeight: 800,
//         imageQuality: 85,
//       );

//       if (pickedFile == null) return;

//       // Store the temporary image path in case we need to clean up
//       _tempImagePath = pickedFile.path;

//       // Store the selected image file
//       setState(() {
//         _selectedImageFile = File(pickedFile.path);
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error selecting image: ${e.toString()}')),
//       );
//     }
//   }

//   Future<void> _loadInitialData() async {
//     final userService = Provider.of<UserService>(context, listen: false);
//     if (userService.cachedUserData != null) {
//       setState(() {
//         _userData = userService.cachedUserData;
//         _updateControllers();
//       });
//     }
//     await _fetchUserData();
//   }

//   void _updateControllers() {
//     if (_userData != null) {
//       _nameController.text = _userData!['name'] ?? '';
//       _emailController.text = _userData!['email'] ?? '';
//       _phoneController.text = _userData!['phone'] ?? '';
//     }
//   }

//   Future<void> _fetchUserData() async {
//     if (!_isRefreshing) setState(() => _isLoading = true);
//     _errorMessage = null;

//     try {
//       final userService = Provider.of<UserService>(context, listen: false);
//       final userId = await userService.getUserId();
//       if (userId == null) throw Exception('User not logged in');

//       final response = await http.post(
//         Uri.parse('$BASE_URL/get-user'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'userId': userId}),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         userService.cacheUserData(data['userData'][0]);
//         setState(() {
//           _userData = data['userData'][0];
//           _updateControllers();
//         });
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to load profile data';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error loading profile: ${e.toString()}';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//         _isRefreshing = false;
//       });
//     }
//   }

//   Future<void> _saveProfileChanges() async {
//     setState(() => _isLoading = true);
//     _errorMessage = null;

//     try {
//       final userService = Provider.of<UserService>(context, listen: false);
//       final userId = await userService.getUserId();

//       if (userId == null) throw Exception('User not logged in');

//       // Create multipart request
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$BASE_URL/save-user'),
//       );

//       // Add text fields
//       request.fields['userId'] = userId;
//       request.fields['name'] = _nameController.text;
//       request.fields['email'] = _emailController.text;
//       request.fields['phone'] = _phoneController.text;

//       // Add image file if selected
//       if (_selectedImageFile != null) {
//         final file = await http.MultipartFile.fromPath(
//           'image',
//           _selectedImageFile!.path,
//           filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
//         );
//         request.files.add(file);
//       }

//       // Send request
//       final response = await request.send();
//       final responseData = await response.stream.bytesToString();
//       final jsonResponse = json.decode(responseData);

//       if (response.statusCode == 200 && jsonResponse['success']) {
//         // Update local state with new data
//         final updatedUserData = {
//           ..._userData!,
//           'name': _nameController.text,
//           'email': _emailController.text,
//           'phone': _phoneController.text,
//           if (jsonResponse['photoUrl'] != null)
//             'photoUrl': jsonResponse['photoUrl'],
//         };

//         setState(() {
//           _userData = updatedUserData;
//           _selectedImageFile =
//               null; // Clear the selected image after successful upload
//           _tempImagePath = null; // No need to clean up anymore
//         });

//         // Update cache
//         userService.cacheUserData(updatedUserData);

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Profile updated successfully')),
//         );
//       } else {
//         throw Exception(jsonResponse['message'] ?? 'Failed to save profile');
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error saving profile: ${e.toString()}';
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error saving profile: ${e.toString()}')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//         _isEditing = false;
//       });
//     }
//   }

//   void _toggleEdit() {
//     setState(() {
//       _isEditing = !_isEditing;
//       if (!_isEditing) {
//         // Cancel image selection if editing is cancelled
//         _selectedImageFile = null;
//         _updateControllers();
//       }
//     });
//   }

//   Widget _buildEditableField({
//     required String label,
//     required TextEditingController controller,
//     required bool isEditing,
//     TextInputType? keyboardType,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (isEditing)
//             Text(
//               label,
//               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//             ),
//           const SizedBox(height: 4),
//           isEditing
//               ? TextFormField(
//                 controller: controller,
//                 keyboardType: keyboardType,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(),
//                   contentPadding: EdgeInsets.symmetric(
//                     vertical: 12,
//                     horizontal: 12,
//                   ),
//                 ),
//               )
//               : Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '$label: ',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                     Expanded(
//                       child: Text(
//                         controller.text.isNotEmpty
//                             ? controller.text
//                             : 'Not provided',
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         actions: [
//           IconButton(
//             icon: Icon(_isEditing ? Icons.save : Icons.edit),
//             onPressed: _isEditing ? _saveProfileChanges : _toggleEdit,
//           ),
//           if (_isEditing)
//             IconButton(
//               icon: Icon(Icons.close),
//               onPressed: _isLoading ? null : _toggleEdit,
//             ),
//         ],
//       ),
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : _errorMessage != null
//               ? Center(child: Text(_errorMessage!))
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     Center(
//                       child: Stack(
//                         children: [
//                           CircleAvatar(
//                             radius: 60,
//                             backgroundImage:
//                                 _selectedImageFile != null
//                                     ? FileImage(_selectedImageFile!)
//                                     : _userData!['photoUrl'] != null
//                                     ? NetworkImage(_userData!['photoUrl'])
//                                     : null,
//                             child:
//                                 _selectedImageFile == null &&
//                                         _userData!['photoUrl'] == null
//                                     ? const Icon(Icons.person, size: 60)
//                                     : null,
//                           ),
//                           if (_isEditing)
//                             Positioned(
//                               bottom: 0,
//                               right: 0,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.blue,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: IconButton(
//                                   icon: Icon(
//                                     Icons.camera_alt,
//                                     color: Colors.white,
//                                   ),
//                                   onPressed:
//                                       _isLoading ? null : _selectProfileImage,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     _buildEditableField(
//                       label: 'Name',
//                       controller: _nameController,
//                       isEditing: _isEditing,
//                     ),
//                     _buildEditableField(
//                       label: 'Email',
//                       controller: _emailController,
//                       isEditing: _isEditing,
//                       keyboardType: TextInputType.emailAddress,
//                     ),
//                     _buildEditableField(
//                       label: 'Phone',
//                       controller: _phoneController,
//                       isEditing: _isEditing,
//                       keyboardType: TextInputType.phone,
//                     ),
//                     if (!_isEditing)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 24.0),
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder:
//                                     (context) =>
//                                         EditProfileScreen(userData: _userData!),
//                               ),
//                             ).then((_) => _fetchUserData());
//                           },
//                           child: Text('Advanced Edit'),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//     );
//   }
// }
