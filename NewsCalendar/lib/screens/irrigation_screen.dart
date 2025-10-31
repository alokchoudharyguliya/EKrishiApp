import 'package:flutter/material.dart';
import 'package:newscalendar/utils/imports.dart';
import 'package:http/http.dart' as http;
import 'package:newscalendar/screens/irrigation_schedule_screen.dart';

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
  bool _isTogglingPump = false;
  bool _deviceConnected = false;
  String? _connectionErrorMessage;
  // Sensor data state
  Map<String, dynamic>? _sensorData;
  bool _isLoadingSensor = false;
  String? _sensorErrorMessage;
  // Pump timings data state
  List<Map<String, dynamic>> _pumpTimings = [];
  bool _isLoadingPumpTimings = false;
  String? _pumpTimingsErrorMessage;
  // Next scheduled irrigation state
  String? _nextScheduledTime;
  bool _isLoadingNextScheduled = false;

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
        final response = await http
            .get(
              Uri.parse('$BASE_URL/api/irrigation/device'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 10));

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
            await prefs.setString(
              'irrigation_device_id',
              data['data']['deviceId'],
            );
            // Fetch device status (connection and pump state)
            await _fetchDeviceStatus(data['data']['deviceId']);
            // Fetch sensor data
            await _fetchSensorData(data['data']['deviceId']);
            // Fetch pump timings
            await _fetchPumpTimings(data['data']['deviceId']);
            // Fetch next scheduled irrigation
            await _fetchNextScheduledIrrigation(data['data']['deviceId']);
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
        final response = await http
            .get(
              Uri.parse('$BASE_URL/api/irrigation/device'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 10));

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
            await prefs.setString(
              'irrigation_device_id',
              data['data']['deviceId'],
            );
            // Fetch device status (connection and pump state)
            await _fetchDeviceStatus(data['data']['deviceId']);
            // Fetch sensor data
            await _fetchSensorData(data['data']['deviceId']);
            // Fetch pump timings
            await _fetchPumpTimings(data['data']['deviceId']);
            // Fetch next scheduled irrigation
            await _fetchNextScheduledIrrigation(data['data']['deviceId']);
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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

      final response = await http
          .post(
            Uri.parse('$BASE_URL/api/irrigation/device/register'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (responseData['success'] == true) {
          // Store device ID in local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'irrigation_device_id',
            responseData['data']['deviceId'],
          );

          setState(() {
            _isDeviceRegistered = true;
            _deviceData = responseData['data'];
          });

          // Fetch device status (connection and pump state)
          await _fetchDeviceStatus(responseData['data']['deviceId']);
          // Fetch sensor data
          await _fetchSensorData(responseData['data']['deviceId']);
          // Fetch pump timings
          await _fetchPumpTimings(responseData['data']['deviceId']);
          // Fetch next scheduled irrigation
          await _fetchNextScheduledIrrigation(responseData['data']['deviceId']);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  responseData['message'] ?? 'Device registered successfully',
                ),
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

  /// Fetch device status (connection and pump state)
  Future<void> _fetchDeviceStatus(String deviceId) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getAuthToken();

      if (token == null) {
        return;
      }

      final response = await http
          .get(
            Uri.parse('$BASE_URL/api/irrigation/status?deviceId=$deviceId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final statusData = data['data'];
          final connectionStatus = statusData['connectionStatus'] ?? {};
          final currentState = statusData['currentState'] ?? {};

          setState(() {
            _deviceConnected = connectionStatus['isConnected'] ?? false;
            _pumpOn = currentState['pumpState'] ?? false;
            _connectionErrorMessage =
                _deviceConnected
                    ? null
                    : 'Raspberry Pi device is not connected. Please ensure the device is online.';
          });
        }
      }
    } catch (e) {
      print('Error fetching device status: $e');
      setState(() {
        _deviceConnected = false;
        _connectionErrorMessage = 'Failed to check device connection status.';
      });
    }
  }

  /// Fetch sensor data from backend API
  Future<void> _fetchSensorData(
    String deviceId, {
    String sensorType = 'temperature',
  }) async {
    if (!mounted) return;

    setState(() {
      _isLoadingSensor = true;
      _sensorErrorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getAuthToken();

      if (token == null) {
        if (mounted) {
          setState(() {
            _isLoadingSensor = false;
            _sensorErrorMessage = 'Authentication required';
          });
        }
        return;
      }

      final response = await http
          .get(
            Uri.parse(
              '$BASE_URL/api/irrigation/sensor/read?deviceId=$deviceId&sensorType=$sensorType',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (mounted) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['data'] != null) {
            setState(() {
              _sensorData = data['data'];
              _isLoadingSensor = false;
              _sensorErrorMessage = null;
            });
          } else {
            setState(() {
              _isLoadingSensor = false;
              _sensorErrorMessage =
                  data['message'] ?? 'Failed to fetch sensor data';
            });
          }
        } else {
          final errorData = json.decode(response.body);
          setState(() {
            _isLoadingSensor = false;
            _sensorErrorMessage =
                errorData['message'] ?? 'Failed to fetch sensor data';
          });
        }
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
      if (mounted) {
        setState(() {
          _isLoadingSensor = false;
          _sensorErrorMessage =
              'Failed to fetch sensor data. Please try again.';
        });
      }
    }
  }

  /// Fetch next scheduled irrigation from backend API
  Future<void> _fetchNextScheduledIrrigation(String deviceId) async {
    if (!mounted) return;

    setState(() {
      _isLoadingNextScheduled = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getAuthToken();

      if (token == null) {
        if (mounted) {
          setState(() {
            _isLoadingNextScheduled = false;
          });
        }
        return;
      }

      final response = await http
          .get(
            Uri.parse(
              '$BASE_URL/api/irrigation/schedule/next?deviceId=$deviceId',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (mounted) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['data'] != null) {
            final scheduleData = data['data'];
            if (scheduleData['hasSchedule'] == true) {
              setState(() {
                _nextScheduledTime = scheduleData['displayText'] ?? 'Scheduled';
                _isLoadingNextScheduled = false;
              });
            } else {
              setState(() {
                _nextScheduledTime = null;
                _isLoadingNextScheduled = false;
              });
            }
          } else {
            setState(() {
              _nextScheduledTime = null;
              _isLoadingNextScheduled = false;
            });
          }
        } else {
          setState(() {
            _nextScheduledTime = null;
            _isLoadingNextScheduled = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching next scheduled irrigation: $e');
      if (mounted) {
        setState(() {
          _nextScheduledTime = null;
          _isLoadingNextScheduled = false;
        });
      }
    }
  }

  /// Fetch pump timings from backend API
  Future<void> _fetchPumpTimings(String deviceId) async {
    if (!mounted) return;

    setState(() {
      _isLoadingPumpTimings = true;
      _pumpTimingsErrorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getAuthToken();

      if (token == null) {
        if (mounted) {
          setState(() {
            _isLoadingPumpTimings = false;
            _pumpTimingsErrorMessage = 'Authentication required';
          });
        }
        return;
      }

      final response = await http
          .get(
            Uri.parse(
              '$BASE_URL/api/irrigation/pump/timings?deviceId=$deviceId',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (mounted) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true &&
              data['data'] != null &&
              data['data']['timings'] != null) {
            setState(() {
              _pumpTimings = List<Map<String, dynamic>>.from(
                data['data']['timings'],
              );
              _isLoadingPumpTimings = false;
              _pumpTimingsErrorMessage = null;
            });
          } else {
            setState(() {
              _isLoadingPumpTimings = false;
              _pumpTimingsErrorMessage =
                  data['message'] ?? 'Failed to fetch pump timings';
            });
          }
        } else {
          final errorData = json.decode(response.body);
          setState(() {
            _isLoadingPumpTimings = false;
            _pumpTimingsErrorMessage =
                errorData['message'] ?? 'Failed to fetch pump timings';
          });
        }
      }
    } catch (e) {
      print('Error fetching pump timings: $e');
      if (mounted) {
        setState(() {
          _isLoadingPumpTimings = false;
          _pumpTimingsErrorMessage =
              'Failed to fetch pump timings. Please try again.';
        });
      }
    }
  }

  /// Format timestamp for display
  String _formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp is String) {
        final date = DateTime.parse(timestamp);
        final now = DateTime.now();
        final difference = now.difference(date);

        if (difference.inMinutes < 1) {
          return 'Just now';
        } else if (difference.inMinutes < 60) {
          return '${difference.inMinutes}m ago';
        } else if (difference.inHours < 24) {
          return '${difference.inHours}h ago';
        } else {
          return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
        }
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get sensor status icon based on sensor type and value
  Icon _getSensorStatusIcon(String? sensorType, dynamic value) {
    if (sensorType == 'moisture') {
      final moistureValue =
          value is num
              ? value.toDouble()
              : double.tryParse(value.toString()) ?? 0.0;
      if (moistureValue >= 40 && moistureValue <= 60) {
        return Icon(Icons.check_circle, color: Colors.green);
      } else if (moistureValue < 40) {
        return Icon(Icons.warning, color: Colors.orange);
      } else {
        return Icon(Icons.warning, color: Colors.red);
      }
    } else if (sensorType == 'temperature') {
      return Icon(Icons.thermostat, color: Colors.blue);
    } else if (sensorType == 'humidity') {
      return Icon(Icons.water_drop, color: Colors.lightBlue);
    }
    return Icon(Icons.check_circle, color: Colors.green);
  }

  /// Toggle pump on/off via backend API
  Future<void> _togglePump() async {
    // Don't allow toggling if device is not connected
    if (!_deviceConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_connectionErrorMessage ?? 'Device is not connected'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Store previous state to revert on failure
    final previousState = _pumpOn;
    final newState = !_pumpOn;

    // Optimistic update
    setState(() {
      _pumpOn = newState;
      _isTogglingPump = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getAuthToken();

      if (token == null) {
        throw Exception('Authentication required. Please log in.');
      }

      // Get device ID
      final deviceId = _deviceData?['deviceId'];
      if (deviceId == null) {
        throw Exception('Device ID not found');
      }

      // Send toggle request to backend
      final response = await http
          .post(
            Uri.parse('$BASE_URL/api/irrigation/pump/toggle'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({'deviceId': deviceId, 'state': newState}),
          )
          .timeout(const Duration(seconds: 10));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Success - update state from backend response
        setState(() {
          _pumpOn = responseData['data']['state'] ?? newState;
          _isTogglingPump = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseData['message'] ??
                    (_pumpOn ? 'Pump switched ON' : 'Pump switched OFF'),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception(responseData['message'] ?? 'Failed to toggle pump');
      }
    } catch (e) {
      // Revert to previous state on failure
      setState(() {
        _pumpOn = previousState;
        _isTogglingPump = false;
      });

      print('Error toggling pump: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceAll("Exception: ", "")}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Irrigation Management'),
          backgroundColor: Colors.blue,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Irrigation Management'),
        backgroundColor: Colors.blue,
        actions:
            _isDeviceRegistered
                ? [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      await _checkDeviceRegistration();
                      if (_deviceData != null &&
                          _deviceData!['deviceId'] != null) {
                        await _fetchDeviceStatus(_deviceData!['deviceId']);
                        await _fetchSensorData(_deviceData!['deviceId']);
                        await _fetchPumpTimings(_deviceData!['deviceId']);
                        await _fetchNextScheduledIrrigation(
                          _deviceData!['deviceId'],
                        );
                      }
                    },
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
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
              child:
                  _isRegistering
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
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
    return SingleChildScrollView(
      child: Padding(
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
                  title: Text(
                    _deviceData!['deviceName'] ?? 'Irrigation Device',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${_deviceData!['deviceId']}'),
                      if (_deviceData!['location'] != null &&
                          _deviceData!['location'].isNotEmpty)
                        Text('Location: ${_deviceData!['location']}'),
                    ],
                  ),
                  trailing: Icon(
                    _deviceConnected ? Icons.check_circle : Icons.error_outline,
                    color: _deviceConnected ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            // Connection status warning
            if (_deviceData != null && !_deviceConnected)
              Card(
                elevation: 2,
                color: Colors.orange[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.orange[300]!, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange[700],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _connectionErrorMessage ??
                              'Raspberry Pi device is not connected',
                          style: TextStyle(
                            color: Colors.orange[900],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Switch(
                          value: _pumpOn,
                          onChanged:
                              (_deviceConnected && !_isTogglingPump)
                                  ? (val) => _togglePump()
                                  : null,
                          activeColor: Colors.blue,
                        ),
                        if (_isTogglingPump)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Pump On Timings (Last 7 Days)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            // Real-time bar graph with axis labels
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    _isLoadingPumpTimings
                        ? const SizedBox(
                          height: 180,
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : _pumpTimingsErrorMessage != null
                        ? SizedBox(
                          height: 180,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red[300],
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _pumpTimingsErrorMessage!,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                        : _pumpTimings.isEmpty
                        ? const SizedBox(
                          height: 180,
                          child: Center(
                            child: Text(
                              'No pump timing data available',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                        : Column(
                          children: [
                            // Y-axis label
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 40,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hours',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 140,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children:
                                          _pumpTimings.map((data) {
                                            final hours =
                                                (data['hours'] as num)
                                                    .toDouble();
                                            final allHours =
                                                _pumpTimings
                                                    .map(
                                                      (d) =>
                                                          (d['hours'] as num)
                                                              .toDouble(),
                                                    )
                                                    .toList();
                                            final maxHours =
                                                allHours.isEmpty ||
                                                        allHours.every(
                                                          (h) => h == 0,
                                                        )
                                                    ? 1.0
                                                    : allHours.reduce(
                                                      (a, b) => a > b ? a : b,
                                                    );
                                            final maxHeight = 90.0;
                                            final barHeight =
                                                maxHours > 0
                                                    ? (hours / maxHours) *
                                                        maxHeight
                                                    : 0.0;

                                            return Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 2.0,
                                                    ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    // Bar
                                                    Container(
                                                      height:
                                                          barHeight > 0
                                                              ? barHeight
                                                              : 0,
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue[300],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    // Day label
                                                    Text(
                                                      data['day'],
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    // Hours label below day
                                                    Text(
                                                      hours > 0
                                                          ? '${hours.toStringAsFixed(1)}h'
                                                          : '0h',
                                                      style: TextStyle(
                                                        fontSize: 8,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                title: Text(
                  _sensorData?['sensorType'] != null
                      ? '${_sensorData!['sensorType'].toString().substring(0, 1).toUpperCase()}${_sensorData!['sensorType'].toString().substring(1)} Sensor'
                      : 'Soil Moisture Sensor',
                ),
                subtitle:
                    _isLoadingSensor
                        ? const Text('Loading sensor data...')
                        : _sensorErrorMessage != null
                        ? Text(
                          _sensorErrorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        )
                        : _sensorData != null && _sensorData!['value'] != null
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current: ${_sensorData!['value']}${_sensorData!['unit'] ?? ''}',
                            ),
                            if (_sensorData!['sensorType'] == 'moisture')
                              const Text(
                                'Optimal: 40-60%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            if (_sensorData!['timestamp'] != null)
                              Text(
                                'Updated: ${_formatTimestamp(_sensorData!['timestamp'])}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        )
                        : const Text('No sensor data available'),
                trailing:
                    _isLoadingSensor
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : _sensorErrorMessage != null
                        ? Icon(Icons.error_outline, color: Colors.red)
                        : _sensorData != null && _sensorData!['value'] != null
                        ? _getSensorStatusIcon(
                          _sensorData!['sensorType'],
                          _sensorData!['value'],
                        )
                        : Icon(Icons.info_outline, color: Colors.grey),
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
                subtitle:
                    _isLoadingNextScheduled
                        ? const Text('Loading...')
                        : Text(
                          _nextScheduledTime ?? 'No schedule set',
                          style: TextStyle(
                            color:
                                _nextScheduledTime == null
                                    ? Colors.grey[600]
                                    : null,
                          ),
                        ),
                trailing:
                    _isLoadingNextScheduled
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Icon(
                          Icons.alarm,
                          color:
                              _nextScheduledTime != null
                                  ? Colors.orange
                                  : Colors.grey,
                        ),
                onTap:
                    _deviceData != null && _deviceData!['deviceId'] != null
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => IrrigationScheduleScreen(
                                    deviceId: _deviceData!['deviceId'],
                                    deviceName:
                                        _deviceData!['deviceName'] ??
                                        'Irrigation Device',
                                  ),
                            ),
                          ).then((_) {
                            // Refresh next scheduled time when returning
                            if (_deviceData != null &&
                                _deviceData!['deviceId'] != null) {
                              _fetchNextScheduledIrrigation(
                                _deviceData!['deviceId'],
                              );
                            }
                          });
                        }
                        : null,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed:
                  _deviceData != null && _deviceData!['deviceId'] != null
                      ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => IrrigationScheduleScreen(
                                  deviceId: _deviceData!['deviceId'],
                                  deviceName:
                                      _deviceData!['deviceName'] ??
                                      'Irrigation Device',
                                ),
                          ),
                        ).then((_) {
                          // Refresh next scheduled time when returning
                          if (_deviceData != null &&
                              _deviceData!['deviceId'] != null) {
                            _fetchNextScheduledIrrigation(
                              _deviceData!['deviceId'],
                            );
                          }
                        });
                      }
                      : null,
              icon: const Icon(Icons.schedule),
              label: const Text('Manage Schedules'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
