// import 'package:crypto/crypto.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../auth_service.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:firebase_auth/firebase_auth.dart';
// import 'auth_form_provider.dart';

// class SignupScreen extends StatefulWidget {
//   @override
//   _SignupScreenState createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final email = TextEditingController();
//   final password = TextEditingController();
//   final confirmPassword = TextEditingController();
//   bool _isLoading = false;
//   String? _errorMessage;
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;

//   @override
//   void initState() {
//     super.initState();
//     // Pre-fill email from provider
//     final authForm = Provider.of<AuthFormProvider>(context, listen: false);
//     email.text = authForm.email;
//     password.text = authForm.password;
//   }

//   @override
//   void dispose() {
//     email.dispose();
//     password.dispose();
//     confirmPassword.dispose();
//     super.dispose();
//   }

//   Future<void> signup() async {
//     if (!_formKey.currentState!.validate()) return;

//     if (password.text != confirmPassword.text) {
//       setState(() {
//         _errorMessage = 'Passwords do not match';
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       // Encrypt the password (using SHA-256 for demonstration)
//       var bytes = utf8.encode(password.text);
//       var encryptedPassword = sha256.convert(bytes).toString();

//       // Prepare user data
//       final userData = {
//         'email': email.text.trim(),
//         'password': encryptedPassword,
//         // 'name': 'Alok',
//       };

//       // Make POST request to your Node.js endpoint
//       // final response = await http.post(
//       //   Uri.parse('https://localhost:3000/signup'),
//       //   headers: {'Content-Type': 'application/json'},
//       //   body: json.encode(userData),
//       // );

//       // final responseData = json.decode(response.body);

//       // if (response.statusCode == 200) {
//       //   Navigator.pushReplacementNamed(context, '/home');
//       // } else {

//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: email.text,
//         password: password.text,
//       );
//       Navigator.pushReplacementNamed(context, '/home');
//       setState(() {
//         // _errorMessage = responseData['message'] ?? 'Signup failed';
//         _isLoading = false;
//       });
//     } on FirebaseAuthException catch (e) {
//       setState(() {
//         // _errorMessage = e.toString() + "ABC";
//         _isLoading = false;
//       });
//       String errorMessage;
//       print(e.code);
//       switch (e.code) {
//         case 'invalid-email':
//           errorMessage = 'The email address is badly formatted.';
//           break;
//         case 'email-already-in-use':
//           errorMessage = 'An account already exists for that email.';
//           break;
//         case 'weak-password':
//           errorMessage = 'The password is too weak.';
//           break;
//         case 'network-request-failed':
//           errorMessage = 'Connect to Internet.';
//           break;
//         default:
//           errorMessage = 'An error occurred. Please try again.';
//       }
//       setState(() {
//         _errorMessage = errorMessage;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'An error occurred. Please try again.';
//         _isLoading = false;
//       });
//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Sign Up')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 TextFormField(
//                   controller: email,
//                   onChanged: (value) {
//                     Provider.of<AuthFormProvider>(
//                       context,
//                       listen: false,
//                     ).updateEmail(value);
//                   },
//                   decoration: const InputDecoration(
//                     labelText: 'Email',
//                     prefixIcon: Icon(Icons.email),
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     if (!RegExp(
//                       r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//                     ).hasMatch(value)) {
//                       return 'Please enter a valid email';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: password,
//                   onChanged: (value) {
//                     Provider.of<AuthFormProvider>(
//                       context,
//                       listen: false,
//                     ).updatePassword(value);
//                   },
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     prefixIcon: const Icon(Icons.lock),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword
//                             ? Icons.visibility
//                             : Icons.visibility_off,
//                         color: Colors.grey,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword = !_obscurePassword;
//                         });
//                       },
//                     ),
//                   ),
//                   obscureText: _obscurePassword,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your password';
//                     }
//                     if (value.length < 8) {
//                       return 'Password must be at least 8 characters';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: confirmPassword,
//                   decoration: InputDecoration(
//                     labelText: 'Confirm Password',
//                     prefixIcon: const Icon(Icons.lock),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscureConfirmPassword
//                             ? Icons.visibility
//                             : Icons.visibility_off,
//                         color: Colors.grey,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscureConfirmPassword = !_obscureConfirmPassword;
//                         });
//                       },
//                     ),
//                   ),
//                   obscureText: _obscureConfirmPassword,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please confirm your password';
//                     }
//                     if (value != password.text) {
//                       return 'Passwords do not match';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 if (_errorMessage != null)
//                   Text(
//                     _errorMessage!,
//                     style: const TextStyle(color: Colors.red),
//                     textAlign: TextAlign.center,
//                   ),
//                 const SizedBox(height: 16),
//                 _isLoading
//                     ? const CircularProgressIndicator()
//                     : ElevatedButton(
//                       onPressed: signup,
//                       style: ElevatedButton.styleFrom(
//                         minimumSize: const Size(double.infinity, 50),
//                       ),
//                       child: const Text('Sign Up'),
//                     ),
//                 TextButton(
//                   onPressed: () {
//                     // Provider.of<AuthFormProvider>(
//                     //   context,
//                     //   listen: false,
//                     // ).clear();
//                     Navigator.pushReplacementNamed(context, '/login');
//                   },
//                   child: const Text('Already have an account? Login'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
