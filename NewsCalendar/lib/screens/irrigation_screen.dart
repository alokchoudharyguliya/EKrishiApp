import 'package:flutter/material.dart';
import 'package:newscalendar/utils/imports.dart';
import 'package:http/http.dart' as http;

class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({Key? key}) : super(key: key);

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  // Device registration state
  bool _isLoading = true;
  bool _isDeviceRegistered = false;
  bool _isRegistering = false;
  Map<String, dynamic>? _deviceData;
  
  // Registration form controllers
  final _deviceIdController = TextEditingController();
  final _piUrlController = TextEditingController();
  final _deviceNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Dashboard state
  bool _pumpOn = false;
  final List<Map<String, dynamic>> _pumpTimings = [
    {'day': 'Mon', 'hours': 2},
    {'day': 'Tue', 'hours': 1.5},
    {'day': 'Wed', 'hours': 2.5},
    {'day': 'Thu', 'hours': 1},
    {'day': 'Fri', 'hours': 3},
    {'day': 'Sat', 'hours': 2},
    {'day': 'Sun', 'hours': 1.2},
  ];

  @override
  void initState() {
    super.initState();
    _checkDeviceRegistration();
  }

  @override
  void dispose() {
    _deviceIdController.dispose();
    _piUrlController.dispose();
    _deviceNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// Check if device is registered by calling backend API
  Future<void> _checkDeviceRegistration() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getAuthToken();
      
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login to continue')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // Check local storage first
      final prefs = await SharedPreferences.getInstance();
      final storedDeviceId = prefs.getString('irrigation_device_id');
      
      if (storedDeviceId != null) {
        // Device ID exists in local storage, verify with backend
        final response = await http.get(
          Uri.parse('$BASE_URL/api/irrigation/device'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['data'] != null) {
            setState(() {
              _isDeviceRegistered = true;
              _deviceData = data['data'];
              _deviceIdController.text = data['data']['deviceId'] ?? '';
              _piUrlController.text = data['data']['piUrl'] ?? '';
              _deviceNameController.text = data['data']['deviceName'] ?? '';
              _locationController.text = data['data']['location'] ?? '';
            });
            // Update local storage
            await prefs.setString('irrigation_device_id', data['data']['deviceId']);
          } else {
            // Device not found, clear local storage
            await prefs.remove('irrigation_device_id');
            setState(() => _isDeviceRegistered = false);
          }
        } else if (response.statusCode == 404) {
          // No device registered
          await prefs.remove('irrigation_device_id');
          setState(() => _isDeviceRegistered = false);
        } else {
          throw Exception('Failed to check device registration');
        }
      } else {
        // No device in local storage, check backend
        final response = await http.get(
          Uri.parse('$BASE_URL/api/irrigation/device'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['data'] != null) {
            setState(() {
              _isDeviceRegistered = true;
              _deviceData = data['data'];
              _deviceIdController.text = data['data']['deviceId'] ?? '';
              _piUrlController.text = data['data']['piUrl'] ?? '';
              _deviceNameController.text = data['data']['deviceName'] ?? '';
              _locationController.text = data['data']['location'] ?? '';
            });
            // Store device ID in local storage
            await prefs.setString('irrigation_device_id', data['data']['deviceId']);
          } else {
            setState(() => _isDeviceRegistered = false);
          }
        } else if (response.statusCode == 404) {
          setState(() => _isDeviceRegistered = false);
        } else {
          throw Exception('Failed to check device registration');
        }
      }
    } catch (e) {
      print('Error checking device registration: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
      setState(() => _isDeviceRegistered = false);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Register device by calling backend API
  Future<void> _registerDevice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isRegistering = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getAuthToken();
      
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login to continue')),
          );
        }
        setState(() => _isRegistering = false);
        return;
      }

      // Prepare request body
      final requestBody = {
        'deviceId': _deviceIdController.text.trim(),
        'piUrl': _piUrlController.text.trim(),
      };

      // Add optional fields if provided
      if (_deviceNameController.text.trim().isNotEmpty) {
        requestBody['deviceName'] = _deviceNameController.text.trim();
      }
      if (_locationController.text.trim().isNotEmpty) {
        requestBody['location'] = _locationController.text.trim();
      }

      final response = await http.post(
        Uri.parse('$BASE_URL/api/irrigation/device/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 15));

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (responseData['success'] == true) {
          // Store device ID in local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('irrigation_device_id', responseData['data']['deviceId']);

          setState(() {
            _isDeviceRegistered = true;
            _deviceData = responseData['data'];
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(responseData['message'] ?? 'Device registered successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception(responseData['message'] ?? 'Registration failed');
        }
      } else {
        throw Exception(responseData['message'] ?? 'Failed to register device');
      }
    } catch (e) {
      print('Error registering device: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  void _togglePump() {
    setState(() {
      _pumpOn = !_pumpOn;
    });
    // Here you can add code to send a request to your backend to switch the pump
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_pumpOn ? 'Pump switched ON' : 'Pump switched OFF'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Irrigation Management'),
          backgroundColor: Colors.blue,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Irrigation Management'),
        backgroundColor: Colors.blue,
        actions: _isDeviceRegistered
            ? [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _checkDeviceRegistration,
                  tooltip: 'Refresh',
                ),
              ]
            : null,
      ),
      body: _isDeviceRegistered ? _buildDashboard() : _buildRegistrationForm(),
    );
  }

  /// Build registration form UI
  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.devices, color: Colors.blue[700], size: 32),
                        const SizedBox(width: 12),
                        const Text(
                          'Register Your Device',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connect your Raspberry Pi irrigation device to get started',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _deviceIdController,
              decoration: const InputDecoration(
                labelText: 'Device ID *',
                hintText: 'Enter unique device identifier',
                prefixIcon: Icon(Icons.tag),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Device ID is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _piUrlController,
              decoration: const InputDecoration(
                labelText: 'Pi WebSocket URL *',
                hintText: 'ws://192.168.1.100:8765',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Pi WebSocket URL is required';
                }
                // Validate WebSocket URL format
                if (!value.trim().startsWith('ws://') || 
                    !value.trim().contains(':') ||
                    !RegExp(r'^ws://.+:\d+$').hasMatch(value.trim())) {
                  return 'Invalid format. Use: ws://IP:PORT (e.g., ws://192.168.1.100:8765)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _deviceNameController,
              decoration: const InputDecoration(
                labelText: 'Device Name (Optional)',
                hintText: 'My Irrigation Device',
                prefixIcon: Icon(Icons.label),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (Optional)',
                hintText: 'Farm A, Field 1',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isRegistering ? null : _registerDevice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isRegistering
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Register Device',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              '* Required fields',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build dashboard UI (shown after device registration)
  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Device info card
          if (_deviceData != null)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.devices, color: Colors.blue[700]),
                title: Text(_deviceData!['deviceName'] ?? 'Irrigation Device'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${_deviceData!['deviceId']}'),
                    if (_deviceData!['location'] != null && _deviceData!['location'].isNotEmpty)
                      Text('Location: ${_deviceData!['location']}'),
                  ],
                ),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
          const SizedBox(height: 16),
          // Pump control
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  Icon(
                    Icons.water,
                    color: _pumpOn ? Colors.blue : Colors.grey,
                    size: 40,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      _pumpOn ? 'Water Pump is ON' : 'Water Pump is OFF',
                      style: TextStyle(
                        fontSize: 18,
                        color: _pumpOn ? Colors.blue : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Switch(
                    value: _pumpOn,
                    onChanged: (val) => _togglePump(),
                    activeColor: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Pump On Timings (hrs/week)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          // Simple bar graph
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _pumpTimings.map((data) {
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: (data['hours'] as num).toDouble() * 25,
                        width: 18.0,
                        decoration: BoxDecoration(
                          color: Colors.blue[300],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data['day'],
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        data['hours'].toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 30),
          // Sensor info card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.info, color: Colors.blue[700]),
              title: const Text('Soil Moisture Sensor'),
              subtitle: const Text('Current: 45% (Optimal: 40-60%)'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.schedule, color: Colors.blue[700]),
              title: const Text('Next Scheduled Irrigation'),
              subtitle: const Text('Tomorrow, 6:00 AM'),
              trailing: Icon(Icons.alarm, color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}
