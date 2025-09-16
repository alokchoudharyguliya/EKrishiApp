import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/imports.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http_parser/http_parser.dart';
import '../widgets/profile_image_widget.dart';
import '../widgets/editable_field.dart';

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
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  FocusNode _focusNode = FocusNode();
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
    // _fetchUserData();
    _focusNode.canRequestFocus = false;
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
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
    final authService = Provider.of<AuthService>(context, listen: false);
    var token = authService.token;
    token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4MDE2ZmM4MWM1YmIwN2U5MTQ3MTMzYyIsImVtYWlsIjoiYWxva3NpbmdAZ21haWwuY29tIiwiaWF0IjoxNzQ0OTc2NDMxfQ.mPX5kQz6Ppujvz8-MCiiPinK_B6k_7T_WNJ1sri_DeE";
    // print(token);
    if (!_isRefreshing) setState(() => _isLoading = true);
    _errorMessage = null;
    print("HEYHEYHEYHEY");
    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final userId = await userService.getUserId();
      if (userId == null) throw Exception('User not logged in');
      print(token);
      final response = await http.post(
        Uri.parse('$BASE_URL/get-user'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${token}",
        },
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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    _errorMessage = null;

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final userId = await userService.getUserId();
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.token;
      if (userId == null) throw Exception('User not logged in');

      final dio = Dio();
      final formData = FormData.fromMap({
        'userId': userId,
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'dob': _dobController.text,
        'role': _selectedRole,
      });

      if (_selectedImageFile != null) {
        print('Selected file path: ${_selectedImageFile!.path}');
        print('File exists: ${await _selectedImageFile!.exists()}');
        print('File size: ${await _selectedImageFile!.length()} bytes');

        final multipartFile = await MultipartFile.fromFile(
          _selectedImageFile!.path,
          filename: '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        );
        formData.files.add(MapEntry('image', multipartFile));
      }

      print('Sending FormData with fields: ${formData.fields}');
      print('Sending FormData with files: ${formData.files.map((f) => f.key)}');

      final response = await dio
          .post(
            '$BASE_URL/save-user',
            data: formData,
            options: Options(
              contentType: 'multipart/form-data',
              headers: {"Authorization": "Bearer ${token}"},
            ),
          )
          .timeout(const Duration(seconds: 60));

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
      setState(() => _errorMessage = 'Error saving profile: ${e.toString()}');
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

  Widget _buildRoleField() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
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
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant,
                ),
                dropdownColor: colorScheme.surface,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
                items:
                    _roleOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value[0].toUpperCase() + value.substring(1),
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
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
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Role: ',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface.withOpacity(0.7),
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
                        style: textTheme.bodyLarge?.copyWith(
                          color:
                              (_userData?['role'] ?? '').isNotEmpty
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurface.withOpacity(0.5),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            color: Colors.white,
            iconSize: 24,
            onPressed: _isEditing ? _saveProfileChanges : _toggleEdit,
          ),
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.close),
              color: Colors.white,
              iconSize: 24,
              onPressed: _isLoading ? null : _toggleEdit,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ProfileImageWidget(
                      selectedImageFile: _selectedImageFile,
                      cachedImageFile: _cachedImageFile,
                      photoUrl: _userData?['photoUrl'],
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
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
                              color: colorScheme.onPrimary,
                              size: 20,
                            ),
                            onPressed: _isLoading ? null : _selectProfileImage,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              EditableField(
                label: 'Name',
                controller: _nameController,
                isEditing: _isEditing,
              ),
              const SizedBox(height: 12),
              EditableField(
                label: 'Email',
                controller: _emailController,
                isEditing: _isEditing,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              EditableField(
                label: 'Phone',
                controller: _phoneController,
                isEditing: _isEditing,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              EditableField(
                label: 'Date of Birth',
                controller: _dobController,
                isEditing: _isEditing,
                isDateField: true,
                onDateTap: () => _selectDate(context),
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
