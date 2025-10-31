import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:newscalendar/utils/imports.dart';

class EquipmentMarketplaceScreen extends StatefulWidget {
  const EquipmentMarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<EquipmentMarketplaceScreen> createState() =>
      _EquipmentMarketplaceScreenState();
}

class _EquipmentMarketplaceScreenState extends State<EquipmentMarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  final List<Map<String, dynamic>> _equipmentList = [];
  final List<Map<String, dynamic>> _myTools = [];
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrentUser().then((_) => _fetchEquipment());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final userId = await userService.getUserId();
      setState(() {
        _currentUserId = userId;
      });
    } catch (_) {
      setState(() {
        _currentUserId = null;
      });
    }
  }

  void _refreshMyTools() {
    _myTools
      ..clear()
      ..addAll(
        _equipmentList.where(
          (e) =>
              _currentUserId != null &&
              e['ownerId']?.toString() == _currentUserId,
        ),
      );
    setState(() {});
  }

  Future<void> _fetchEquipment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final dio = Dio();
      // print("HEY");
      final response = await dio.get('$BASE_URL/api/equipment');
      print(response);
      if (response.statusCode == 200 && response.data['success'] == true) {
        print("HEY");
        final List data = response.data['data'] as List;
        _equipmentList
          ..clear()
          ..addAll(
            data.map(
              (e) => {
                'id': e['_id'],
                'name': e['name'] ?? '',
                'description': e['description'] ?? '',
                'price': e['price']?.toString() ?? '0',
                'image': e['imageUrl'] ?? '',
                'contact': e['contact'] ?? '',
                'location': e['location'] ?? '',
                'ownerId': e['owner']?.toString() ?? '',
                'isAvailable': e['isAvailable'] == true,
              },
            ),
          );
        setState(() {
          _isLoading = false;
        });
        _refreshMyTools();
      } else {
        throw Exception('Failed to load equipment');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load equipment. Please try again.';
      });
    }
  }

  Future<void> _launchCaller(String phone) async {
    // Clean phone number: remove spaces, keep + and digits
    final String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri url = Uri(scheme: 'tel', path: cleanPhone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch dialer')),
        );
      }
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final String phoneNumber = phone.replaceAll('+', '').replaceAll(' ', '');
    final Uri url = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp')),
        );
      }
    }
  }

  void _showAddToolDialog({Map<String, dynamic>? tool}) {
    final nameController = TextEditingController(text: tool?['name'] ?? '');
    final descriptionController = TextEditingController(
      text: tool?['description'] ?? '',
    );
    final priceController = TextEditingController(
      text: tool?['price']?.toString().replaceAll('₹', '') ?? '',
    );
    final contactController = TextEditingController(
      text: tool?['contact'] ?? '',
    );
    final locationController = TextEditingController(
      text: tool?['location'] ?? '',
    );
    bool isAvailable = tool?['isAvailable'] ?? true;

    // State for image picker
    File? selectedImageFile;
    String? existingImageUrl;

    // If editing, preserve existing image URL
    if (tool != null && tool['image'] != null) {
      existingImageUrl = tool['image'];
    }

    final isEditing = tool != null;
    final String? editingId = tool?['id']?.toString();

    final ImagePicker _picker = ImagePicker();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text(isEditing ? 'Edit Tool' : 'Add New Tool'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Tool Name*',
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description*',
                          ),
                          maxLines: 2,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price* (e.g. 1000/day)',
                            prefixText: '₹',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: contactController,
                          decoration: const InputDecoration(
                            labelText: 'Contact Number*',
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location*',
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Equipment Image',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        // Image preview or placeholder
                        GestureDetector(
                          onTap: () async {
                            // Show options to pick from gallery or camera
                            if (!context.mounted) return;
                            showModalBottomSheet(
                              context: context,
                              builder:
                                  (context) => SafeArea(
                                    child: Wrap(
                                      children: [
                                        ListTile(
                                          leading: const Icon(
                                            Icons.photo_library,
                                          ),
                                          title: const Text(
                                            'Pick from Gallery',
                                          ),
                                          onTap: () async {
                                            Navigator.pop(context);
                                            try {
                                              final XFile? image = await _picker
                                                  .pickImage(
                                                    source: ImageSource.gallery,
                                                    maxWidth: 1920,
                                                    maxHeight: 1080,
                                                    imageQuality: 85,
                                                  );
                                              if (image != null) {
                                                selectedImageFile = File(
                                                  image.path,
                                                );
                                                existingImageUrl = null;
                                                setDialogState(() {});
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Error picking image: $e',
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(
                                            Icons.photo_camera,
                                          ),
                                          title: const Text('Take a Photo'),
                                          onTap: () async {
                                            Navigator.pop(context);
                                            try {
                                              final XFile? image = await _picker
                                                  .pickImage(
                                                    source: ImageSource.camera,
                                                    maxWidth: 1920,
                                                    maxHeight: 1080,
                                                    imageQuality: 85,
                                                  );
                                              if (image != null) {
                                                selectedImageFile = File(
                                                  image.path,
                                                );
                                                existingImageUrl = null;
                                                setDialogState(() {});
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Error picking image: $e',
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                        if (selectedImageFile != null ||
                                            existingImageUrl != null)
                                          ListTile(
                                            leading: const Icon(Icons.delete),
                                            title: const Text('Remove Image'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              selectedImageFile = null;
                                              existingImageUrl = null;
                                              setDialogState(() {});
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                            );
                          },
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:
                                selectedImageFile != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        selectedImageFile!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : existingImageUrl != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        existingImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Center(
                                                  child: Icon(
                                                    Icons.image,
                                                    size: 50,
                                                  ),
                                                ),
                                      ),
                                    )
                                    : const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Tap to add image',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text('Available for rent:'),
                            const SizedBox(width: 10),
                            Switch(
                              value: isAvailable,
                              onChanged: (value) {
                                isAvailable = value;
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Client-side validation before closing dialog
                        final name = nameController.text.trim();
                        final description = descriptionController.text.trim();
                        final price = priceController.text.trim();
                        final contact = contactController.text.trim();
                        final location = locationController.text.trim();

                        // Validate name
                        if (name.isEmpty) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Name is required'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }
                        if (name.length < 2) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Name must be at least 2 characters long',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }
                        if (name.length > 120) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Name cannot exceed 120 characters',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }

                        // Validate description
                        if (description.isEmpty) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Description is required'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }
                        if (description.length > 2000) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Description cannot exceed 2000 characters',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }

                        // Validate price
                        if (price.isEmpty) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Price is required'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }
                        final parsedPrice = double.tryParse(price);
                        if (parsedPrice == null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Price must be a valid number'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }
                        if (parsedPrice < 0) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Price must be a non-negative number (0 for free)',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }

                        // Validate contact
                        if (contact.isEmpty) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Contact number is required'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }
                        final contactDigitsOnly = contact.replaceAll(
                          RegExp(r'[^\d]'),
                          '',
                        );
                        if (contactDigitsOnly.isEmpty ||
                            !RegExp(r'^\d+$').hasMatch(contactDigitsOnly)) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Contact number must contain only digits',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }
                        if (contactDigitsOnly.length < 10) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Contact number must be exactly 10 digits (e.g., 9876543210)',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }
                        if (contactDigitsOnly.length > 10) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Contact number must be exactly 10 digits',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }

                        // Validate location
                        if (location.isEmpty) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Location is required'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }
                        if (location.length > 200) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Location cannot exceed 200 characters',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }

                        // Show loading indicator
                        if (context.mounted) {
                          Navigator.pop(context); // Close dialog first
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder:
                                (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                          );
                        }

                        bool dialogClosed = false;
                        try {
                          // Prepare form data for multipart submission (use validated values)
                          final formData = FormData.fromMap({
                            'name': name,
                            'description': description,
                            'price': price,
                            'contact':
                                contactDigitsOnly, // Use digits-only version
                            'location': location,
                            'isAvailable': isAvailable.toString(),
                          });

                          // Add image if selected
                          if (selectedImageFile != null) {
                            final multipartFile = await MultipartFile.fromFile(
                              selectedImageFile!.path,
                              filename:
                                  'equipment_${DateTime.now().millisecondsSinceEpoch}.jpg',
                            );
                            formData.files.add(
                              MapEntry('image', multipartFile),
                            );
                          }
                          final dio = Dio();
                          final authService = Provider.of<AuthService>(
                            context,
                            listen: false,
                          );
                          final token = await authService.getAuthToken();
                          late Response response;
                          if (isEditing && editingId != null) {
                            response = await dio.put(
                              '$BASE_URL/api/equipment/$editingId',
                              data: formData,
                              options: Options(
                                contentType: 'multipart/form-data',
                                headers:
                                    token != null
                                        ? {'Authorization': 'Bearer $token'}
                                        : {},
                              ),
                            );
                          } else {
                            response = await dio.post(
                              '$BASE_URL/api/equipment',
                              data: formData,
                              options: Options(
                                contentType: 'multipart/form-data',
                                headers:
                                    token != null
                                        ? {'Authorization': 'Bearer $token'}
                                        : {},
                              ),
                            );
                          }

                          // Close loading dialog
                          if (context.mounted && !dialogClosed) {
                            Navigator.pop(context);
                            dialogClosed = true;
                          }

                          final ok =
                              (response.statusCode == 201 ||
                                  response.statusCode == 200) &&
                              response.data != null &&
                              response.data['success'] == true;
                          if (ok) {
                            final e = response.data['data'];
                            final item = {
                              'id': e['_id'],
                              'name': e['name'] ?? '',
                              'description': e['description'] ?? '',
                              'price': e['price']?.toString() ?? '0',
                              'image': e['imageUrl'] ?? '',
                              'contact': e['contact'] ?? '',
                              'location': e['location'] ?? '',
                              'ownerId': e['owner']?.toString() ?? '',
                              'isAvailable': e['isAvailable'] == true,
                            };
                            setState(() {
                              if (isEditing && editingId != null) {
                                final idx = _equipmentList.indexWhere(
                                  (x) => x['id'] == editingId,
                                );
                                if (idx != -1) _equipmentList[idx] = item;
                              } else {
                                _equipmentList.insert(0, item);
                              }
                            });
                            _refreshMyTools();

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEditing
                                        ? 'Equipment updated successfully!'
                                        : 'Equipment added successfully!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            // Equipment was not added/updated
                            String actionText = isEditing ? 'updated' : 'added';
                            throw Exception(
                              'Failed to $actionText equipment. Please try again.',
                            );
                          }
                        } catch (e) {
                          // Ensure loading dialog is closed
                          if (context.mounted && !dialogClosed) {
                            Navigator.pop(context);
                            dialogClosed = true;
                          }

                          // Parse and display user-friendly error messages
                          String errorMessage =
                              isEditing
                                  ? 'Equipment could not be updated. Please try again.'
                                  : 'Equipment could not be added. Please try again.';

                          if (e is DioException) {
                            // Handle Dio errors
                            if (e.response != null &&
                                e.response?.data != null) {
                              final responseData = e.response!.data;
                              if (responseData is Map) {
                                if (responseData.containsKey('message')) {
                                  errorMessage =
                                      responseData['message'].toString();
                                } else if (responseData.containsKey('error')) {
                                  errorMessage =
                                      responseData['error'].toString();
                                  // Check if it's an authentication error
                                  if (errorMessage.toLowerCase().contains(
                                        'authenticate',
                                      ) ||
                                      e.response?.statusCode == 401) {
                                    errorMessage =
                                        'Authentication required. Please login again.';
                                  }
                                }
                              } else if (responseData is String) {
                                errorMessage = responseData;
                              }

                              // Handle specific status codes
                              if (e.response?.statusCode == 401) {
                                errorMessage =
                                    'Authentication required. Please login again.';
                              } else if (e.response?.statusCode == 403) {
                                errorMessage =
                                    'You do not have permission to ${isEditing ? 'update' : 'create'} this equipment.';
                              } else if (e.response?.statusCode == 404 &&
                                  isEditing) {
                                errorMessage =
                                    'Equipment not found. It may have been deleted.';
                              } else if (e.response?.statusCode == 400) {
                                // Keep the message from responseData if available
                                if (!errorMessage.contains('could not be')) {
                                  // Use the message from response
                                }
                              }
                            } else if (e.type ==
                                    DioExceptionType.connectionTimeout ||
                                e.type == DioExceptionType.receiveTimeout ||
                                e.type == DioExceptionType.sendTimeout) {
                              errorMessage =
                                  isEditing
                                      ? 'Connection timeout. Equipment could not be updated. Please check your internet connection and try again.'
                                      : 'Connection timeout. Equipment could not be added. Please check your internet connection and try again.';
                            } else if (e.type ==
                                DioExceptionType.connectionError) {
                              errorMessage =
                                  isEditing
                                      ? 'Unable to connect to server. Equipment could not be updated. Please check your internet connection.'
                                      : 'Unable to connect to server. Equipment could not be added. Please check your internet connection.';
                            } else {
                              errorMessage =
                                  e.message ??
                                  (isEditing
                                      ? 'Network error. Equipment could not be updated. Please try again.'
                                      : 'Network error. Equipment could not be added. Please try again.');
                            }
                          } else if (e is Exception) {
                            final exceptionMessage = e.toString().replaceFirst(
                              'Exception: ',
                              '',
                            );
                            if (exceptionMessage.isNotEmpty) {
                              errorMessage = exceptionMessage;
                            }
                          }

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(isEditing ? 'Update' : 'Add'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _confirmDeleteTool(int index) {
    final tool = _myTools[index];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Tool'),
            content: Text(
              'Are you sure you want to remove "${tool['name']}" from your tools?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  try {
                    final dio = Dio();
                    final authService = Provider.of<AuthService>(
                      context,
                      listen: false,
                    );
                    final token = await authService.getAuthToken();
                    final id = tool['id'];
                    final res = await dio.delete(
                      '$BASE_URL/api/equipment/$id',
                      options: Options(
                        headers:
                            token != null
                                ? {'Authorization': 'Bearer $token'}
                                : {},
                      ),
                    );
                    if (res.statusCode == 200 && res.data['success'] == true) {
                      setState(() {
                        _equipmentList.removeWhere((e) => e['id'] == id);
                      });
                      _refreshMyTools();
                      if (context.mounted) Navigator.pop(context);
                    } else {
                      throw Exception('Failed to delete');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error deleting: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Remove'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Marketplace'),
        backgroundColor: Colors.green[700],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'My Tools'), Tab(text: 'Browse Tools')],
        ),
      ),
      floatingActionButton:
          _tabController.index == 0
              ? FloatingActionButton(
                onPressed: () => _showAddToolDialog(),
                child: const Icon(Icons.add),
                backgroundColor: Colors.green,
              )
              : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Tools Tab
          RefreshIndicator(
            onRefresh: _fetchEquipment,
            child:
                _myTools.isEmpty
                    ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.agriculture,
                                size: 70,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'You haven\'t added any tools yet',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () => _showAddToolDialog(),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Your First Tool'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      itemCount: _myTools.length,
                      itemBuilder: (context, index) {
                        final tool = _myTools[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  tool['image'],
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        height: 180,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.image, size: 50),
                                        ),
                                      ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            tool['name'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                tool['isAvailable']
                                                    ? Colors.green
                                                    : Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            tool['isAvailable']
                                                ? 'Available'
                                                : 'Unavailable',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      tool['description'],
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.price_change,
                                          size: 16,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          tool['price'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(tool['location']),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Edit button
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          color: Colors.blue,
                                          onPressed:
                                              () => _showAddToolDialog(
                                                tool: tool,
                                              ),
                                        ),
                                        // Delete button
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          color: Colors.red,
                                          onPressed:
                                              () => _confirmDeleteTool(index),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),

          // Browse Tools Tab
          RefreshIndicator(
            onRefresh: _fetchEquipment,
            child:
                _isLoading
                    ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 200,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    )
                    : _errorMessage != null
                    ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 200,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_errorMessage!),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _fetchEquipment,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      itemCount: _equipmentList.length,
                      itemBuilder: (context, index) {
                        final tool = _equipmentList[index];
                        final isMyTool =
                            _currentUserId != null &&
                            tool['ownerId'] == _currentUserId;

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  tool['image'],
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        height: 180,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.image, size: 50),
                                        ),
                                      ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            tool['name'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                tool['isAvailable']
                                                    ? Colors.green
                                                    : Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            tool['isAvailable']
                                                ? 'Available'
                                                : 'Unavailable',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (isMyTool)
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Your Tool',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      tool['description'],
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.price_change,
                                          size: 16,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '₹${tool['price']}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(tool['location']),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (!isMyTool && tool['isAvailable'])
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                            onPressed:
                                                () => _launchCaller(
                                                  tool['contact'],
                                                ),
                                            icon: const Icon(
                                              Icons.call,
                                              size: 16,
                                            ),
                                            label: const Text('Call'),
                                          ),
                                          const SizedBox(width: 8),
                                          OutlinedButton.icon(
                                            onPressed:
                                                () => _launchWhatsApp(
                                                  tool['contact'],
                                                ),
                                            icon: const Icon(
                                              Icons.message,
                                              size: 16,
                                            ),
                                            label: const Text('Message'),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
