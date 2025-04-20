// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class EditProfileScreen extends StatefulWidget {
//   final Map<String, dynamic>? userData;

//   const EditProfileScreen({Key? key, required this.userData}) : super(key: key);

//   @override
//   _EditProfileScreenState createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late TextEditingController _nameController;
//   late TextEditingController _phoneController;
//   late TextEditingController _emailController;
//   FocusNode _focusNode = FocusNode();
//   @override
//   void initState() {
//     super.initState();
//     _focusNode.canRequestFocus = false;
//     _nameController = TextEditingController(
//       text: widget.userData?['name'] ?? '',
//     );
//     _phoneController = TextEditingController(
//       text: widget.userData?['phone'] ?? '',
//     );
//     _emailController = TextEditingController(
//       text: _auth.currentUser?.email ?? '',
//     );
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }

//   Future<void> _updateProfile() async {
//     try {
//       await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
//         'name': _nameController.text,
//         'phone': _phoneController.text,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile updated successfully!')),
//       );

//       Navigator.pop(context); // Return to profile screen
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Edit Profile')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Name',
//                   border: OutlineInputBorder(),
//                 ),
//                 focusNode: _focusNode,
//                 onTap: () {
//                   setState(() {
//                     _focusNode.canRequestFocus = true;
//                   });
//                   FocusScope.of(context).requestFocus(_focusNode);
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _emailController,
//                 focusNode: _focusNode,
//                 onTap: () {
//                   setState(() {
//                     _focusNode.canRequestFocus = true;
//                   });
//                   FocusScope.of(context).requestFocus(_focusNode);
//                 },
//                 decoration: const InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//                   enabled: false, // Email shouldn't be editable directly
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _phoneController,
//                 decoration: const InputDecoration(
//                   labelText: 'Phone',
//                   border: OutlineInputBorder(),
//                 ),
//                 focusNode: _focusNode,
//                 onTap: () {
//                   setState(() {
//                     _focusNode.canRequestFocus = true;
//                   });
//                   FocusScope.of(context).requestFocus(_focusNode);
//                 },
//                 keyboardType: TextInputType.phone,
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _updateProfile,
//                 child: const Text('Save Changes'),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
