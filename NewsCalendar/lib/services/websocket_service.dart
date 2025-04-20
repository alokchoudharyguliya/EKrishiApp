import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:newscalendar/auth_service.dart';
import 'local_db_service.dart';

class WebSocketService with ChangeNotifier {
  WebSocketChannel? _channel;
  StreamSubscription? _messageSubscription;
  bool _isConnected = false;
  String? _lastError;
  final String _apiBaseUrl;
  final AuthService _authService;

  // Callback for incoming messages
  Function(Map<String, dynamic>)? onMessage;

  // Connection state getters
  bool get isConnected => _isConnected;
  String? get lastError => _lastError;

  WebSocketService({
    required String apiBaseUrl,
    required AuthService authService,
  }) : _apiBaseUrl = apiBaseUrl,
       _authService = authService;

  // Initialize connection
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      // Get current auth token
      final token = _authService.token;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      // Close existing connection if any
      await _disconnect();

      // Establish new connection
      _channel = IOWebSocketChannel.connect(
        '$_apiBaseUrl?token=$token',
        headers: {'Authorization': 'Bearer $token'},
      );

      // Set up listeners
      _messageSubscription = _channel?.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );

      _isConnected = true;
      _lastError = null;
      notifyListeners();

      if (kDebugMode) {
        print('WebSocket connected successfully');
      }
    } catch (e) {
      _lastError = e.toString();
      _isConnected = false;
      notifyListeners();
      if (kDebugMode) {
        print('WebSocket connection error: $e');
      }
      rethrow;
    }
  }

  // Disconnect from server
  Future<void> disconnect() async {
    await _disconnect();
    _isConnected = false;
    notifyListeners();
  }

  // Internal disconnect handler
  Future<void> _disconnect() async {
    await _messageSubscription?.cancel();
    await _channel?.sink.close();
    _messageSubscription = null;
    _channel = null;
  }

  // Send message to server
  Future<void> sendMessage(Map<String, dynamic> message) async {
    if (!_isConnected) {
      await connect();
    }

    try {
      final jsonMessage = json.encode(message);
      _channel?.sink.add(jsonMessage);

      if (kDebugMode) {
        print('Sent WebSocket message: $jsonMessage');
      }
    } catch (e) {
      _lastError = 'Failed to send message: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  // Handle incoming messages
  void _handleMessage(dynamic message) {
    try {
      if (kDebugMode) {
        print('Received WebSocket message: $message');
      }

      final decoded = json.decode(message);
      if (decoded is Map<String, dynamic>) {
        onMessage?.call(decoded);
      }
    } catch (e) {
      _lastError = 'Failed to process message: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) {
        print('Message processing error: $e');
      }
    }
  }

  // Handle connection errors
  void _handleError(Object error) {
    _lastError = error.toString();
    _isConnected = false;
    notifyListeners();

    if (kDebugMode) {
      print('WebSocket error: $error');
    }

    // Attempt reconnect after delay
    Future.delayed(const Duration(seconds: 5), connect);
  }

  // Handle disconnection
  void _handleDisconnect() {
    _isConnected = false;
    notifyListeners();

    if (kDebugMode) {
      print('WebSocket disconnected');
    }

    // Attempt reconnect after delay
    Future.delayed(const Duration(seconds: 5), connect);
  }

  // Clean up resources
  @override
  void dispose() {
    _messageSubscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}
