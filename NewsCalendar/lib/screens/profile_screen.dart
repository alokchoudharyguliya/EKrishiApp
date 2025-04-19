import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:newscalendar/constants/constants.dart';
import 'dart:convert';
import 'dart:io';
import 'edit_profile_screen.dart';
import '../main.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? getUserData() {
    return _userData;
  }

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String? _errorMessage;
  bool _isRefreshing = false;
  bool _isEditing = false;
  File? _selectedImageFile;
  File? _cachedImageFile;
  String? _selectedRole;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;

  // Role options
  final List<String> _roleOptions = ['student', 'faculty', 'other', 'admin'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _dobController = TextEditingController();
    _loadInitialData();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectProfileImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: ${e.toString()}')),
      );
    }
  }

  // Future<void> _loadInitialData() async {
  //   final userService = Provider.of<UserService>(context, listen: false);
  //   if (userService.cachedUserData != null) {
  //     setState(() {
  //       _userData = userService.cachedUserData;
  //       _updateControllers();
  //     });
  //     // Load cached image if available
  //     await _loadCachedProfileImage();
  //   }
  //   await _fetchUserData();
  // }

  Future<void> _loadInitialData() async {
    final userService = Provider.of<UserService>(context, listen: false);

    // First try to load from secure storage
    final secureData = await userService.getUserData();
    if (secureData != null) {
      setState(() {
        _userData = secureData;
        _updateControllers();
      });
    }

    // Then try to fetch fresh data from server
    await _fetchUserData();

    // Load cached image if available
    if (_userData?['photoUrl'] != null) {
      await _loadCachedProfileImage();
    }
  }

  Future<void> _loadCachedProfileImage() async {
    if (_userData?['photoUrl'] != null) {
      try {
        final file = await DefaultCacheManager().getSingleFile(
          _userData!['photoUrl'],
        );
        if (await file.exists()) {
          setState(() {
            _cachedImageFile = file;
          });
        }
      } catch (e) {
        print('Error loading cached image: $e');
      }
    }
  }

  void _updateControllers() {
    if (_userData != null) {
      _nameController.text = _userData!['name'] ?? '';
      _emailController.text = _userData!['email'] ?? '';
      _phoneController.text = _userData!['phone'] ?? '';
      _dobController.text = _userData!['dob'] ?? '';
      _selectedRole = _userData!['role'] ?? 'student';
    }
  }

  Future<void> _fetchUserData() async {
    if (!_isRefreshing) setState(() => _isLoading = true);
    _errorMessage = null;

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final userId = await userService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      final response = await http.post(
        Uri.parse('$BASE_URL/get-user'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newUserData = data['userData'][0];
        bool photoUrlChanged =
            _userData?['photoUrl'] != newUserData['photoUrl'];

        // This will automatically save to secure storage via UserService
        await userService.cacheUserData(newUserData);
        await _storage.write(key: 'userData', value: json.encode(newUserData));

        setState(() {
          _userData = newUserData;
          _updateControllers();
        });

        if (photoUrlChanged || _cachedImageFile == null) {
          if (newUserData['photoUrl'] != null) {
            await _cacheAndLoadProfileImage(newUserData['photoUrl']);
          }
        }
      } else {
        // Try to load from secure storage if API fails
        final secureData = await userService.getUserData();
        if (secureData != null) {
          setState(() {
            _userData = secureData;
            _updateControllers();
          });
        } else {
          setState(() {
            _errorMessage = 'Failed to load profile data';
          });
        }
      }
    } catch (e) {
      // Fall back to secure storage
      final userService = Provider.of<UserService>(context, listen: false);
      final secureData = await userService.getUserData();
      if (secureData != null) {
        setState(() {
          _userData = secureData;
          _updateControllers();
        });
      } else {
        setState(() {
          _errorMessage = 'Error loading profile: ${e.toString()}';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _cacheAndLoadProfileImage(String imageUrl) async {
    try {
      if (_cachedImageFile != null && await _cachedImageFile!.exists()) {
        await _cachedImageFile!.delete();
      }
      // print(imageUrl);
      final file = await DefaultCacheManager().getSingleFile(imageUrl);
      print(file.toString());
      if (await file.exists()) {
        setState(() {
          _cachedImageFile = file;
        });
        // print(_cachedImageFile);
      }
    } catch (e) {
      print('Error caching profile image: $e');
    }
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);
    _errorMessage = null;

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final userId = await userService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      final dio = Dio();
      // First create the basic form data
      final formData = FormData.fromMap({
        'userId': userId,
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'dob': _dobController.text,
        'role': _selectedRole,
      });

      // Add the image file if selected
      if (_selectedImageFile != null) {
        // Print debug information about the file
        print('Selected file path: ${_selectedImageFile!.path}');
        print('File exists: ${await _selectedImageFile!.exists()}');
        print('File size: ${await _selectedImageFile!.length()} bytes');

        // Create the multipart file
        final multipartFile = await MultipartFile.fromFile(
          _selectedImageFile!.path,
          filename:
              'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        );

        // Add to form data - using the same field name ('image') that your backend expects
        formData.files.add(MapEntry('image', multipartFile));

        // Debug print the form data files
        print('FormData files count: ${formData.files.length}');
      }

      // Debug print the complete form data
      print('Sending FormData with fields: ${formData.fields}');
      print('Sending FormData with files: ${formData.files.map((f) => f.key)}');

      final response = await dio
          .post(
            '$BASE_URL/save-user',
            data: formData,
            options: Options(
              contentType: 'multipart/form-data',
              headers: {
                "Content-Type": "multipart/form-data",
                "Accept": "application/json",
              },
            ),
            onSendProgress: (sent, total) {
              print(
                'Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%',
              );
            },
          )
          .timeout(const Duration(seconds: 30));

      print('Response received: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success']) {
        final updatedUserData = {
          ..._userData!,
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'dob': _dobController.text,
          'role': _selectedRole,
          if (response.data['photoUrl'] != null)
            'photoUrl': response.data['photoUrl'],
        };

        setState(() {
          _userData = updatedUserData;
          _selectedImageFile = null;
        });

        if (response.data['photoUrl'] != null) {
          await _cacheAndLoadProfileImage(response.data['photoUrl']);
        }

        userService.cacheUserData(updatedUserData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to save profile');
      }
    } catch (e) {
      print('Error in _saveProfileChanges: $e');
      setState(() {
        _errorMessage = 'Error saving profile: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEditing = false;
          _fetchUserData();
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _dobController.text.isNotEmpty
              ? DateTime.parse(_dobController.text)
              : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _selectedImageFile = null;
        _updateControllers();
      }
    });
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    TextInputType? keyboardType,
    bool isDateField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          isEditing
              ? isDateField
                  ? InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: Colors.grey[600],
                        ),
                      ),
                      child: Text(
                        controller.text.isNotEmpty
                            ? controller.text
                            : 'Select date',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              controller.text.isNotEmpty
                                  ? Colors.grey[800]
                                  : Colors.grey[500],
                        ),
                      ),
                    ),
                  )
                  : TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (label == 'Phone' && value!.isNotEmpty) {
                        if (value.length < 10) {
                          return 'Phone number must be at least 10 digits';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Only digits are allowed';
                        }
                      }
                      if (label == 'Email' && value!.isNotEmpty) {
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                      }
                      return null;
                    },
                  )
              : Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$label: ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        controller.text.isNotEmpty
                            ? controller.text
                            : 'Not provided',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              controller.text.isNotEmpty
                                  ? Colors.grey[800]
                                  : Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildProfileImageWidget() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: ClipOval(
        child:
            _selectedImageFile != null
                ? Image.file(
                  _selectedImageFile!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                )
                : _cachedImageFile != null
                ? Image.file(
                  _cachedImageFile!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                )
                : _userData?['photoUrl'] == null
                ? Container(
                  color: Colors.grey[100],
                  child: Icon(Icons.person, size: 60, color: Colors.grey[400]),
                )
                : Image.network(
                  _userData!['photoUrl'],
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[100],
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
      ),
    );
  }

  Widget _buildRoleField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                'Role',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          _isEditing
              ? DropdownButtonFormField<String>(
                value: _selectedRole ?? 'student',
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                dropdownColor: Colors.white,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                items:
                    _roleOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value[0].toUpperCase() + value.substring(1),
                        ),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                },
              )
              : Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Role: ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        (_userData?['role'] ?? 'Not provided')
                            .toString()
                            .toLowerCase()
                            .split(' ')
                            .map((s) => s[0].toUpperCase() + s.substring(1))
                            .join(' '),
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              (_userData?['role'] ?? '').isNotEmpty
                                  ? Colors.grey[800]
                                  : Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            color: Colors.blue[700],
            iconSize: 24,
            onPressed: _isEditing ? _saveProfileChanges : _toggleEdit,
          ),
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.close),
              color: Colors.grey[600],
              iconSize: 24,
              onPressed: _isLoading ? null : _toggleEdit,
            ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                ),
              )
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),

                  child: Text(
                    _errorMessage!,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            _buildProfileImageWidget(),
                            if (_isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue[700],
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed:
                                        _isLoading ? null : _selectProfileImage,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildEditableField(
                        label: 'Name',
                        controller: _nameController,
                        isEditing: _isEditing,
                      ),
                      const SizedBox(height: 12),
                      _buildEditableField(
                        label: 'Email',
                        controller: _emailController,
                        isEditing: _isEditing,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      _buildEditableField(
                        label: 'Phone',
                        controller: _phoneController,
                        isEditing: _isEditing,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _buildEditableField(
                        label: 'Date of Birth',
                        controller: _dobController,
                        isEditing: _isEditing,
                        isDateField: true,
                      ),
                      const SizedBox(height: 12),
                      _buildRoleField(),
                    ],
                  ),
                ),
              ),
    );
  }
}
