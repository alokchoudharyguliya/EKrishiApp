// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import '../auth_service.dart';
// // import 'package:provider/provider.dart';

// // class Login extends StatefulWidget {
// //   const Login({super.key});

// //   @override
// //   State<Login> createState() => _LoginState();
// // }

// // class _LoginState extends State<Login> {
// //   final _formKey = GlobalKey<FormState>();
// //   TextEditingController email = TextEditingController();
// //   TextEditingController password = TextEditingController();
// //   String? _errorMessage;
// //   bool _isLoading = false;
// //   @override
// //   void dispose() {
// //     email.dispose();
// //     password.dispose();
// //     super.dispose();
// //   }

// //   singin() async {
// //     setState(() {
// //       _isLoading = true;
// //       _errorMessage = null;
// //     });
// //     try {
// //       await FirebaseAuth.instance
// //           .signInWithEmailAndPassword(
// //             email: email.text,
// //             password: password.text,
// //           )
// //           .then((value) => Navigator.pushReplacementNamed(context, '/home'));
// //     } catch (e) {
// //       setState(() {
// //         _errorMessage = e.toString();
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text("Login")),
// //       body: Padding(
// //         padding: const EdgeInsets.all(20.0),
// //         child: Column(
// //           children: [
// //             TextFormField(
// //               controller: email,
// //               decoration: InputDecoration(hintText: "Enter Email"),
// //               keyboardType: TextInputType.emailAddress,
// //               validator: (value) {
// //                 if (value == null || value.isEmpty) {
// //                   return 'Please enter your email';
// //                 }
// //                 return null;
// //               },
// //             ),
// //             SizedBox(height: 16),
// //             TextFormField(
// //               controller: password,
// //               decoration: InputDecoration(hintText: "Enter Password"),
// //               obscureText: true,
// //               validator: (value) {
// //                 if (value == null || value.isEmpty) {
// //                   return 'Please enter your password';
// //                 }
// //                 return null;
// //               },
// //             ),
// //             SizedBox(height: 24),
// //             if (_errorMessage != null)
// //               Text(_errorMessage!, style: TextStyle(color: Colors.red)),
// //             SizedBox(height: 16),
// //             _isLoading
// //                 ? CircularProgressIndicator()
// //                 : ElevatedButton(
// //                   onPressed:
// //                       (
// //                       // () => {print("Eh")}),
// //                       () => {singin()}),
// //                   child: Text('Login'),
// //                 ),
// //             TextButton(
// //               onPressed: () {
// //                 Navigator.pushReplacementNamed(context, '/signup');
// //               },
// //               child: Text('Don\'t have an account? Sign up'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'auth_form_provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '../auth_service.dart';
// import 'package:provider/provider.dart';
// import 'auth_form_provider.dart';

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
//       await FirebaseAuth.instance
//           .signInWithEmailAndPassword(
//             email: email.text.trim(),
//             password: password.text.trim(),
//           )
//           .then((value) {
//             Provider.of<AuthFormProvider>(context, listen: false).clear();
//             Navigator.pushReplacementNamed(context, '/home');
//           });
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
//         case 'user-not-found':
//         case 'invalid-credential':
//         case 'wrong-password':
//           errorMessage = 'Invalid email or password.';
//           break;
//         case 'user-disabled':
//           errorMessage = 'This account has been disabled.';
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
//         _errorMessage = 'An unexpected error occurred.';
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
//       await FirebaseAuth.instance.sendPasswordResetEmail(
//         email: email.text.trim(),
//       );
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
//       appBar: AppBar(title: const Text("Login")),
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
