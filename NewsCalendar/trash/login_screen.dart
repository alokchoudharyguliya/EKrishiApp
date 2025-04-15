// // import 'package:flutter/material.dart';
// // import './calendar_screen.dart';
// // import './signup_screen.dart';

// // class LoginScreen extends StatefulWidget {
// //   @override
// //   _LoginScreenState createState() => _LoginScreenState();
// // }

// // class _LoginScreenState extends State<LoginScreen> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _emailController = TextEditingController();
// //   final _passwordController = TextEditingController();
// //   bool _isLoading = false;

// //   @override
// //   void dispose() {
// //     _emailController.dispose();
// //     _passwordController.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _login() async {
// //     if (_formKey.currentState!.validate()) {
// //       setState(() => _isLoading = true);

// //       // Simulate network delay
// //       await Future.delayed(Duration(seconds: 2));

// //       // In a real app, you would call your authentication API here
// //       if (_emailController.text == 'user@example.com' &&
// //           _passwordController.text == 'password123') {
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(builder: (context) => CalendarScreen()),
// //         );
// //       } else {
// //         ScaffoldMessenger.of(
// //           context,
// //         ).showSnackBar(SnackBar(content: Text('Invalid credentials')));
// //       }

// //       setState(() => _isLoading = false);
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Center(
// //         child: SingleChildScrollView(
// //           padding: EdgeInsets.all(24),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               FlutterLogo(size: 100),
// //               SizedBox(height: 40),
// //               Text(
// //                 'Welcome to Calendar App',
// //                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// //               ),
// //               SizedBox(height: 20),
// //               Form(
// //                 key: _formKey,
// //                 child: Column(
// //                   children: [
// //                     TextFormField(
// //                       controller: _emailController,
// //                       decoration: InputDecoration(
// //                         labelText: 'Email',
// //                         prefixIcon: Icon(Icons.email),
// //                         border: OutlineInputBorder(),
// //                       ),
// //                       keyboardType: TextInputType.emailAddress,
// //                       validator: (value) {
// //                         if (value == null || value.isEmpty) {
// //                           return 'Please enter your email';
// //                         }
// //                         if (!value.contains('@')) {
// //                           return 'Please enter a valid email';
// //                         }
// //                         return null;
// //                       },
// //                     ),
// //                     SizedBox(height: 16),
// //                     TextFormField(
// //                       controller: _passwordController,
// //                       decoration: InputDecoration(
// //                         labelText: 'Password',
// //                         prefixIcon: Icon(Icons.lock),
// //                         border: OutlineInputBorder(),
// //                       ),
// //                       obscureText: true,
// //                       validator: (value) {
// //                         if (value == null || value.isEmpty) {
// //                           return 'Please enter your password';
// //                         }
// //                         if (value.length < 6) {
// //                           return 'Password must be at least 6 characters';
// //                         }
// //                         return null;
// //                       },
// //                     ),
// //                     SizedBox(height: 24),
// //                     SizedBox(
// //                       width: double.infinity,
// //                       height: 50,
// //                       child: ElevatedButton(
// //                         onPressed: _isLoading ? null : _login,
// //                         child:
// //                             _isLoading
// //                                 ? CircularProgressIndicator(color: Colors.white)
// //                                 : Text('LOGIN'),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               SizedBox(height: 20),
// //               TextButton(
// //                 onPressed: () {
// //                   // Forgot password functionality
// //                 },
// //                 child: Text('Forgot Password?'),
// //               ),
// //               SizedBox(height: 10),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   Text("Don't have an account?"),
// //                   TextButton(
// //                     onPressed: () {
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(builder: (context) => SignupScreen()),
// //                       );
// //                     },
// //                     child: Text('Sign Up'),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../auth_service.dart';

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//   String? _errorMessage;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       await Provider.of<AuthService>(
//         context,
//         listen: false,
//       ).signIn(_emailController.text.trim(), _passwordController.text.trim());

//       Navigator.pushReplacementNamed(context, '/home');
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(labelText: 'Email'),
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(labelText: 'Password'),
//                 obscureText: true,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your password';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 24),
//               if (_errorMessage != null)
//                 Text(_errorMessage!, style: TextStyle(color: Colors.red)),
//               SizedBox(height: 16),
//               _isLoading
//                   ? CircularProgressIndicator()
//                   : ElevatedButton(onPressed: _login, child: Text('Login')),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/signup');
//                 },
//                 child: Text('Don\'t have an account? Sign up'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
