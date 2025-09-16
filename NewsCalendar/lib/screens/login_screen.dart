import 'package:flutter/material.dart';
import '../utils/imports.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var myToken;
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;
  FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    final authForm = Provider.of<AuthFormProvider>(context, listen: false);
    email.text = authForm.email;
    password.text = authForm.password;

    _focusNode.canRequestFocus = false;
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var bytes = utf8.encode(password.text.trim());
      var hashedPassword = sha256.convert(bytes).toString();

      final loginData = {
        'email': email.text.trim(),
        'password': hashedPassword,
      };

      final response = await http.post(
        Uri.parse('$BASE_URL/login'),
        body: json.encode(loginData),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final myToken = responseData['token'];
        final userId =
            responseData["user"]['_id']; // Make sure your API returns this
        final userData = responseData['user'];
        // Store authentication data
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.setAuthToken(myToken);

        // Store user data using UserService
        final userService = Provider.of<UserService>(context, listen: false);
        await userService.setUserId(userId);
        await userService.cacheUserData(userData);
        await FlutterSecureStorage().write(
          key: 'userEmail',
          value: email.text.trim(),
        );

        Provider.of<AuthFormProvider>(context, listen: false).clear();
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _errorMessage = responseData['message'] ?? 'Login failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Kar")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: email,
                onChanged: (value) {
                  Provider.of<AuthFormProvider>(
                    context,
                    listen: false,
                  ).updateEmail(value);
                },
                focusNode: _focusNode,
                onTap: () {
                  setState(() {
                    _focusNode.canRequestFocus = true;
                  });
                  FocusScope.of(context).requestFocus(_focusNode);
                },
                decoration: const InputDecoration(
                  hintText: "Enter Email",
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: password,
                onChanged: (value) {
                  Provider.of<AuthFormProvider>(
                    context,
                    listen: false,
                  ).updatePassword(value);
                },
                // focusNode: _focusNode,
                onTap: () {
                  // setState(() {`
                  // _focusNode.canRequestFocus = true;
                  // });
                  // FocusScope.of(context).requestFocus(_focusNode);
                },
                decoration: InputDecoration(
                  hintText: "Enter Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed:
                      () => {
                        // resetPassword
                      },
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: signIn,
                    child: const Text('Login'),
                  ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signup');
                },
                child: const Text('Don\'t have an account? Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
