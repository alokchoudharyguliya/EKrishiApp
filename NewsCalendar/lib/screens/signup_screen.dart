// import 'package:flutter/material.dart';
// import 'calendar_screen.dart';

// class SignupScreen extends StatefulWidget {
//   @override
//   _SignupScreenState createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final email = TextEditingController();
//   final password = TextEditingController();
//   final confirmPassword = TextEditingController();
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     email.dispose();
//     password.dispose();
//     confirmPassword.dispose();
//     super.dispose();
//   }

//   Future<void> _signup() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isLoading = true);

//       // Simulate network delay
//       await Future.delayed(Duration(seconds: 2));

//       // In a real app, you would call your signup API here
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => CalendarScreen()),
//       );

//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Sign Up')),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               FlutterLogo(size: 80),
//               SizedBox(height: 30),
//               Text(
//                 'Create Account',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 20),
//               Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: _nameController,
//                       decoration: InputDecoration(
//                         labelText: 'Full Name',
//                         prefixIcon: Icon(Icons.person),
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your name';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 16),
//                     TextFormField(
//                       controller: email,
//                       decoration: InputDecoration(
//                         labelText: 'Email',
//                         prefixIcon: Icon(Icons.email),
//                         border: OutlineInputBorder(),
//                       ),
//                       keyboardType: TextInputType.emailAddress,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your email';
//                         }
//                         if (!value.contains('@')) {
//                           return 'Please enter a valid email';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 16),
//                     TextFormField(
//                       controller: password,
//                       decoration: InputDecoration(
//                         labelText: 'Password',
//                         prefixIcon: Icon(Icons.lock),
//                         border: OutlineInputBorder(),
//                       ),
//                       obscureText: true,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your password';
//                         }
//                         if (value.length < 6) {
//                           return 'Password must be at least 6 characters';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 16),
//                     TextFormField(
//                       controller: confirmPassword,
//                       decoration: InputDecoration(
//                         labelText: 'Confirm Password',
//                         prefixIcon: Icon(Icons.lock),
//                         border: OutlineInputBorder(),
//                       ),
//                       obscureText: true,
//                       validator: (value) {
//                         if (value != password.text) {
//                           return 'Passwords do not match';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 24),
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _signup,
//                         child:
//                             _isLoading
//                                 ? CircularProgressIndicator(color: Colors.white)
//                                 : Text('SIGN UP'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 20),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text('Already have an account? Login'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  // ... other imports

  signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (password.text != confirmPassword.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Encrypt the password (using SHA-256 for demonstration, consider better encryption for production)
      var bytes = utf8.encode(password.text); // data being hashed
      var encryptedPassword = sha256.convert(bytes).toString();

      // Prepare user data
      final userData = {
        'email': email.text,
        'password': encryptedPassword,
        'name': 'Alok',
      };

      // 'name': name.text, // assuming you have a name field
      // Make POST request to your Node.js endpoint
      final response = await http.post(
        Uri.parse('https://localhost:3000/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Success - user created in Firebase and Firestore
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Handle error from your backend
        setState(() {
          _errorMessage = responseData['message'] ?? 'Signup failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
      print(e);
    }
  }
  // signup() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   if (password.text != confirmPassword.text) {
  //     setState(() {
  //       _errorMessage = 'Passwords do not match';
  //     });
  //     return;
  //   }

  //   setState(() {
  //     _isLoading = true;
  //     _errorMessage = null;
  //   });

  //   try {
  //     await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //       email: email.text,
  //       password: password.text,
  //     );
  //     Navigator.pushReplacementNamed(context, '/home');
  //   } on FirebaseAuthException catch (e) {
  //     // setState(() {
  //     //   _errorMessage = e.toString() + "ABC";
  //     //   _isLoading = false;
  //     // });
  //     if (e.code == 'weak-password') {
  //       print('The password provided is too weak.');
  //     } else if (e.code == 'email-already-in-use') {
  //       print('The account already exists for that email.');
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // signup() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   if (password.text != confirmPassword.text) {
  //     setState(() {
  //       _errorMessage = 'Passwords do not match';
  //     });
  //     return;
  //   }

  //   setState(() {
  //     _isLoading = true;
  //     _errorMessage = null;
  //   });

  //   try {
  //     final credential = await FirebaseAuth.instance
  //         .createUserWithEmailAndPassword(
  //           email: email.text.trim(),
  //           password: password.text.trim(),
  //         );

  //     if (credential.user != null) {
  //       Navigator.pushReplacementNamed(context, '/home');
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     setState(() {
  //       _errorMessage = e.message ?? 'Signup failed';
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       // _errorMessage = 'An unexpected error occurred';
  //       _isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: email,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: password,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: confirmPassword,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              if (_errorMessage != null)
                Text(_errorMessage!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 16),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: (() => {signup()}),
                    child: Text('Sign Up'),
                  ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
