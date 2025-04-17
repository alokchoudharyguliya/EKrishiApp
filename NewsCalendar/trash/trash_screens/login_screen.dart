// import '../auth_form_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../auth_form_provider.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:crypto/crypto.dart';

// class Login extends StatefulWidget {
//   const Login({super.key});

//   @override
//   State<Login> createState() => _LoginState();
// }

// class _LoginState extends State<Login> {
//   final _formKey = GlobalKey<FormState>();
//   TextEditingController email = TextEditingController();
//   TextEditingController password = TextEditingController();
//   String? _errorMessage;
//   bool _isLoading = false;
//   bool _obscurePassword = true; // For show/hide password

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
//     super.dispose();
//   }

//   Future<void> singin() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       // TODO: Replace with Express backend API call
//       // Example structure:

//       var bytes = utf8.encode(password.text.trim());
//       var hashedPassword = sha256.convert(bytes).toString();

//       // Prepare login data for your Express backend
//       final loginData = {
//         'email': email.text.trim(),
//         'password': hashedPassword,
//       };
//       final response = await http.post(
//         Uri.parse('http://192.168.185.15:3000/login'),
//         body: json.encode(loginData),
//         headers: {'Content-Type': 'application/json'},
//       );
//       print("Hey");
//       final responseData = json.decode(response.body);
//       print("Yes");
//       if (response.statusCode == 200) {
//         //   print("Passed");
//         Provider.of<AuthFormProvider>(context, listen: false).clear();
//         Navigator.pushReplacementNamed(context, '/home');
//       } else {
//         setState(() {
//           _errorMessage = responseData['message'] ?? 'Login failed';
//           _isLoading = false;
//         });
//       }

//       // Remove this Firebase code:
//       /* Firebase Auth code to be replaced
//       await FirebaseAuth.instance
//           .signInWithEmailAndPassword(
//             email: email.text.trim(),
//             password: password.text.trim(),
//           )
//           .then((value) {
//             Provider.of<AuthFormProvider>(context, listen: false).clear();
//             Navigator.pushReplacementNamed(context, '/home');
//           });
//       */

//       // TODO: Handle your Express backend response
//       setState(() {
//         _isLoading = false;
//       });
//     } catch (e) {
//       // TODO: Update error handling for your Express API
//       setState(() {
//         _errorMessage = 'An unexpected error occurred: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> resetPassword() async {
//     if (email.text.isEmpty || !email.text.contains('@')) {
//       setState(() {
//         _errorMessage = 'Please enter a valid email address to reset password.';
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       // TODO: Replace with Express backend password reset API call

//       final response = await http.post(
//         Uri.parse('https://your-express-api.com/reset-password'),
//         body: jsonEncode({'email': email.text.trim()}),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _errorMessage = 'Password reset email sent. Check your inbox.';
//         });
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to send reset email. Please try again.';
//         });
//       }

//       // Remove Firebase code:
//       /* Firebase code to be replaced
//       await FirebaseAuth.instance.sendPasswordResetEmail(
//         email: email.text.trim(),
//       );
//       */

//       setState(() {
//         _errorMessage = 'Password reset email sent. Check your inbox.';
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to send reset email. Please try again.';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Login Kar")),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: email,
//                 onChanged: (value) {
//                   Provider.of<AuthFormProvider>(
//                     context,
//                     listen: false,
//                   ).updateEmail(value);
//                 },
//                 decoration: const InputDecoration(
//                   hintText: "Enter Email",
//                   prefixIcon: Icon(Icons.email),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   if (!RegExp(
//                     r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//                   ).hasMatch(value)) {
//                     return 'Please enter a valid email';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: password,
//                 onChanged: (value) {
//                   Provider.of<AuthFormProvider>(
//                     context,
//                     listen: false,
//                   ).updatePassword(value);
//                 },
//                 decoration: InputDecoration(
//                   hintText: "Enter Password",
//                   prefixIcon: const Icon(Icons.lock),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscurePassword
//                           ? Icons.visibility
//                           : Icons.visibility_off,
//                       color: Colors.grey,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _obscurePassword = !_obscurePassword;
//                       });
//                     },
//                   ),
//                 ),
//                 obscureText: _obscurePassword,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your password';
//                   }
//                   if (value.length < 8) {
//                     return 'Password must be at least 8 characters';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 8),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: resetPassword,
//                   child: const Text('Forgot Password?'),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               if (_errorMessage != null)
//                 Text(
//                   _errorMessage!,
//                   style: const TextStyle(color: Colors.red),
//                   textAlign: TextAlign.center,
//                 ),
//               const SizedBox(height: 16),
//               _isLoading
//                   ? const CircularProgressIndicator()
//                   : ElevatedButton(
//                     onPressed: singin,
//                     child: const Text('Login'),
//                   ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushReplacementNamed(context, '/signup');
//                 },
//                 child: const Text('Don\'t have an account? Sign up'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
