import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:newscalendar/constants/constants.dart';
import 'package:flutter/material.dart';

/// Response model for Pi commands
class PiResponse {
  final String? requestId;
  final bool success;
  final Map<String, dynamic>? data;
  final String? error;
  final String? connectionType; // 'direct' or 'backend'
  final bool queued; // true if command was queued for later

  PiResponse({
    this.requestId,
    required this.success,
    this.data,
    this.error,
    this.connectionType,
    this.queued = false,
  });

  factory PiResponse.fromJson(Map<String, dynamic> json, {String? connectionType, bool queued = false}) {
    return PiResponse(
      requestId: json['requestId'],
      success: json['success'] ?? false,
      data: json['data'] ?? json, // Fallback to whole response if no 'data' key
      error: json['error'],
      connectionType: connectionType,
      queued: queued,
    );
  }

  factory PiResponse.error(String error, {String? connectionType}) {
    return PiResponse(
      success: false,
      error: error,
      connectionType: connectionType,
    );
  }
}

/// Connection status information
class PiConnectionStatus {
  final bool isDirectAvailable;
  final bool isBackendAvailable;
  final String? directConnectionError;
  final String? lastUsedConnection; // 'direct' or 'backend' or null

  PiConnectionStatus({
    required this.isDirectAvailable,
    required this.isBackendAvailable,
    this.directConnectionError,
    this.lastUsedConnection,
  });
}

/// Service for communicating with Raspberry Pi
/// Tries direct WebSocket connection first, falls back to backend HTTP
class PiCommunicationService {
  WebSocketChannel? _directChannel;
  String? _piUrl;
  String? _deviceId;
  int _requestCounter = 0;
  final Map<String, Completer<PiResponse>> _pendingRequests = {};
  Timer? _connectionCheckTimer;
  String? _lastUsedConnection; // Track which connection was used last
  
  // Network detection
  final Connectivity _connectivity = Connectivity();

  PiCommunicationService() {
    // Monitor connectivity changes
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final result = results.firstOrNull ?? ConnectivityResult.none;
      debugPrint('[PiCommunicationService] Connectivity changed: $result');
    });
  }

  /// Initialize the service with Pi URL and device ID
  /// Should be called before using the service
  Future<void> initialize(String piUrl, String deviceId) async {
    _piUrl = piUrl;
    _deviceId = deviceId;
    _requestCounter = 0;
    debugPrint('[PiCommunicationService] Initialized with piUrl: $piUrl, deviceId: $deviceId');
  }

  /// Check if device is on WiFi
  Future<bool> _isOnWiFi() async {
    final results = await _connectivity.checkConnectivity();
    final connectivity = results.firstOrNull ?? ConnectivityResult.none;
    return connectivity == ConnectivityResult.wifi;
  }

  /// Extract IP address from WebSocket URL
  /// Example: ws://192.168.1.100:8765 -> 192.168.1.100
  String? _extractIpFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      debugPrint('[PiCommunicationService] Error extracting IP from URL: $e');
      return null;
    }
  }

  /// Check if IP address is in private network range
  /// Private ranges: 192.168.x.x, 10.x.x.x, 172.16-31.x.x
  bool _isPrivateIp(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    
    try {
      final octet1 = int.parse(parts[0]);
      final octet2 = int.parse(parts[1]);
      
      // 192.168.x.x
      if (octet1 == 192 && octet2 == 168) return true;
      
      // 10.x.x.x
      if (octet1 == 10) return true;
      
      // 172.16-31.x.x
      if (octet1 == 172 && octet2 >= 16 && octet2 <= 31) return true;
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if direct connection should be attempted
  /// Returns true if:
  /// - Device is on WiFi, AND
  /// - Pi URL contains a private IP address
  Future<bool> shouldTryDirectConnection() async {
    if (_piUrl == null) return false;
    
    final ip = _extractIpFromUrl(_piUrl!);
    if (ip == null) return false;
    
    // If Pi IP is not private, direct connection won't work
    if (!_isPrivateIp(ip)) {
      debugPrint('[PiCommunicationService] Pi IP ($ip) is not private, skipping direct connection');
      return false;
    }
    
    // Check if device is on WiFi
    final isWiFi = await _isOnWiFi();
    if (!isWiFi) {
      debugPrint('[PiCommunicationService] Device is not on WiFi, skipping direct connection');
      return false;
    }
    
    debugPrint('[PiCommunicationService] Direct connection attempt recommended (WiFi + private IP)');
    return true;
  }

  /// Try to establish direct WebSocket connection to Pi
  Future<void> _connectDirectWebSocket() async {
    if (_piUrl == null || _directChannel != null) return;
    
    try {
      debugPrint('[PiCommunicationService] Attempting direct WebSocket connection to $_piUrl');
      _directChannel = WebSocketChannel.connect(Uri.parse(_piUrl!));
      
      // Listen for messages
      _directChannel!.stream.listen(
        (message) {
          _handleDirectMessage(message);
        },
        onError: (error) {
          debugPrint('[PiCommunicationService] Direct WebSocket error: $error');
          _cleanupDirectConnection();
        },
        onDone: () {
          debugPrint('[PiCommunicationService] Direct WebSocket connection closed');
          _cleanupDirectConnection();
        },
        cancelOnError: true,
      );
      
      debugPrint('[PiCommunicationService] Direct WebSocket connection established');
    } catch (e) {
      debugPrint('[PiCommunicationService] Failed to establish direct WebSocket: $e');
      _cleanupDirectConnection();
      rethrow;
    }
  }

  /// Handle incoming message from direct WebSocket connection
  void _handleDirectMessage(dynamic message) {
    try {
      final data = json.decode(message.toString());
      
      if (data['requestId'] != null && _pendingRequests.containsKey(data['requestId'])) {
        final completer = _pendingRequests.remove(data['requestId']);
        if (completer != null && !completer.isCompleted) {
          completer.complete(PiResponse.fromJson(data, connectionType: 'direct'));
        }
      }
    } catch (e) {
      debugPrint('[PiCommunicationService] Error handling direct message: $e');
    }
  }

  /// Cleanup direct WebSocket connection
  void _cleanupDirectConnection() {
    try {
      _directChannel?.sink.close();
    } catch (e) {
      debugPrint('[PiCommunicationService] Error closing direct connection: $e');
    }
    _directChannel = null;
  }

  /// Check if direct connection is currently active
  bool _isDirectConnectionActive() {
    return _directChannel != null;
  }

  /// Try direct WebSocket connection with timeout
  Future<PiResponse> _tryDirectWebSocket(String action, Map<String, dynamic> params) async {
    // Check if we should try direct connection first
    final shouldTry = await shouldTryDirectConnection();
    if (!shouldTry) {
      throw Exception('Direct connection not recommended (not on WiFi or Pi IP not private)');
    }

    try {
      // Establish connection if not already connected
      if (!_isDirectConnectionActive()) {
        await _connectDirectWebSocket().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            throw TimeoutException('Direct connection timeout', const Duration(seconds: 3));
          },
        );
      }

      // Generate request ID
      final requestId = 'req_${++_requestCounter}_${DateTime.now().millisecondsSinceEpoch}';
      
      // Create message
      final message = {
        'requestId': requestId,
        'action': action,
        'params': params,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Create completer for response
      final completer = Completer<PiResponse>();
      _pendingRequests[requestId] = completer;

      // Send message
      _directChannel?.sink.add(json.encode(message));

      // Wait for response with timeout
      final response = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          _pendingRequests.remove(requestId);
          throw TimeoutException('Response timeout for direct connection', const Duration(seconds: 3));
        },
      );

      _lastUsedConnection = 'direct';
      return response;

    } on TimeoutException catch (e) {
      debugPrint('[PiCommunicationService] Direct WebSocket timeout: $e');
      _cleanupDirectConnection();
      rethrow;
    } catch (e) {
      debugPrint('[PiCommunicationService] Direct WebSocket error: $e');
      _cleanupDirectConnection();
      rethrow;
    }
  }

  /// Try backend HTTP REST API (fallback)
  Future<PiResponse> _tryBackendHttp(
    String action,
    Map<String, dynamic> params, {
    String? token,
  }) async {
    try {
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not available');
      }

      if (_deviceId == null) {
        throw Exception('Device ID not set');
      }

      // Map action to backend endpoint
      Uri endpoint;
      http.Response response;
      Map<String, dynamic> requestBody;

      switch (action) {
        case 'toggle_pump':
        case 'pump_on':
        case 'pump_off':
        case 'pump_toggle':
          endpoint = Uri.parse('$BASE_URL/api/irrigation/pump/toggle');
          final state = params['state'];
          requestBody = {
            'deviceId': _deviceId!,
            if (state != null) 'state': state,
          };
          response = await http
              .post(
                endpoint,
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                },
                body: json.encode(requestBody),
              )
              .timeout(const Duration(seconds: 10));
          break;

        case 'read_sensor':
          final sensorType = params['sensorType'] ?? 'temperature';
          endpoint = Uri.parse('$BASE_URL/api/irrigation/sensor/read?deviceId=${_deviceId!}&sensorType=$sensorType');
          response = await http
              .get(
                endpoint,
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                },
              )
              .timeout(const Duration(seconds: 10));
          break;

        case 'get_status':
          endpoint = Uri.parse('$BASE_URL/api/irrigation/status?deviceId=${_deviceId!}');
          response = await http
              .get(
                endpoint,
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                },
              )
              .timeout(const Duration(seconds: 10));
          break;

        default:
          throw Exception('Unknown action: $action');
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        _lastUsedConnection = 'backend';
        
        // Convert backend response to PiResponse format
        return PiResponse.fromJson({
          'requestId': responseData['data']?['requestId'],
          'success': true,
          'data': responseData['data'] ?? responseData,
        }, connectionType: 'backend');
      } else {
        throw Exception(responseData['message'] ?? 'Backend request failed');
      }
    } catch (e) {
      debugPrint('[PiCommunicationService] Backend HTTP error: $e');
      throw Exception('Backend request failed: $e');
    }
  }

  /// Send command to Pi (tries direct first, falls back to backend)
  /// [token] is required for backend fallback
  Future<PiResponse> sendCommand(
    String action,
    Map<String, dynamic> params, {
    String? token,
  }) async {
    // Try direct WebSocket connection first
    try {
      debugPrint('[PiCommunicationService] Attempting direct connection for action: $action');
      final response = await _tryDirectWebSocket(action, params);
      debugPrint('[PiCommunicationService] Direct connection successful');
      return response;
    } catch (e) {
      debugPrint('[PiCommunicationService] Direct connection failed: $e, falling back to backend');
      // Fallback to backend HTTP
      try {
        if (token == null) {
          throw Exception('Token required for backend fallback');
        }
        final response = await _tryBackendHttp(action, params, token: token);
        debugPrint('[PiCommunicationService] Backend connection successful');
        return response;
      } catch (backendError) {
        debugPrint('[PiCommunicationService] Both direct and backend connections failed');
        return PiResponse.error(
          'Both direct and backend connections failed. Direct: ${e.toString()}, Backend: ${backendError.toString()}',
        );
      }
    }
  }

  /// Convenience method: Toggle pump
  /// [token] is required for backend fallback
  Future<PiResponse> togglePump(bool? state, {String? token}) async {
    final action = state != null ? (state ? 'pump_on' : 'pump_off') : 'pump_toggle';
    return sendCommand(action, {'state': state}, token: token);
  }

  /// Convenience method: Read sensor
  /// [token] is required for backend fallback
  Future<PiResponse> readSensor(String sensorType, {String? token}) async {
    return sendCommand('read_sensor', {'sensorType': sensorType}, token: token);
  }

  /// Convenience method: Get status
  /// [token] is required for backend fallback
  Future<PiResponse> getStatus({String? token}) async {
    return sendCommand('get_status', {}, token: token);
  }

  /// Get connection status information
  Future<PiConnectionStatus> getConnectionStatus() async {
    final shouldTryDirect = await shouldTryDirectConnection();
    final isDirectActive = _isDirectConnectionActive();
    
    return PiConnectionStatus(
      isDirectAvailable: shouldTryDirect && isDirectActive,
      isBackendAvailable: true, // Backend is always available (assuming network connectivity)
      directConnectionError: isDirectActive ? null : 'Not connected',
      lastUsedConnection: _lastUsedConnection,
    );
  }

  /// Check if direct connection is available
  Future<bool> isDirectConnectionAvailable() async {
    final shouldTry = await shouldTryDirectConnection();
    return shouldTry && _isDirectConnectionActive();
  }

  /// Disconnect and cleanup
  void disconnect() {
    _cleanupDirectConnection();
    _connectionCheckTimer?.cancel();
    _pendingRequests.clear();
    debugPrint('[PiCommunicationService] Disposed');
  }

  /// Cleanup on dispose
  void dispose() {
    disconnect();
  }
}

