import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Replace with your Express backend endpoint

      final response = await http.get(
        Uri.parse('https://your-express-api.com/user/profile'),
        headers: {
          // 'Authorization': 'Bearer YOUR_AUTH_TOKEN', // Add if using JWT
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _userData = data;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load profile data';
        });
      }
      // */

      // Mock data for demonstration - remove in production
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      setState(() {
        _userData = {
          'name': 'John Doe',
          'email': 'john@example.com',
          'phone': '123-456-7890',
          'photoUrl': null,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              if (_userData != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditProfileScreen(userData: _userData!),
                  ),
                ).then((_) => _fetchUserData()); // Refresh after editing
              }
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _userData!['photoUrl'] != null
                              ? NetworkImage(_userData!['photoUrl'])
                              : null,
                      child:
                          _userData!['photoUrl'] == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Name: ${_userData!['name'] ?? 'Not provided'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Email: ${_userData!['email'] ?? 'Not provided'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Phone: ${_userData!['phone'] ?? 'Not provided'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
    );
  }
}
