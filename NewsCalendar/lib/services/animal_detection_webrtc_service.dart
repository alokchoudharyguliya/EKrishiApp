/// Animal Detection WebRTC Service
/// Handles WebRTC connections for animal detection camera streams
///
/// Phase 4 - Animal Detection Implementation
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:newscalendar/constants/constants.dart';

/// Detection overlay data for displaying on video
class DetectionOverlay {
  final String animalType;
  final double confidence;
  final int x;
  final int y;
  final int width;
  final int height;

  DetectionOverlay({
    required this.animalType,
    required this.confidence,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory DetectionOverlay.fromJson(Map<String, dynamic> json) {
    final bbox = json['bbox'] ?? {};
    return DetectionOverlay(
      animalType: json['animalType'] ?? 'unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      x: bbox['x'] ?? 0,
      y: bbox['y'] ?? 0,
      width: bbox['width'] ?? 0,
      height: bbox['height'] ?? 0,
    );
  }
}

/// Animal Detection WebRTC Service
class AnimalDetectionWebRTCService {
  // WebRTC components
  RTCPeerConnection? _peerConnection;
  RTCVideoRenderer? _renderer;
  WebSocketChannel? _signalingChannel;

  // Stream management
  String? _currentStreamId;
  String? _deviceId;
  int? _cameraId;

  // Detection overlays
  List<DetectionOverlay> _currentDetections = [];
  StreamController<List<DetectionOverlay>>? _detectionController;

  // Connection state
  bool _isConnected = false;
  bool _isConnecting = false;

  // ICE configuration
  Map<String, dynamic>? _iceConfig;

  /// Get detection overlay stream
  Stream<List<DetectionOverlay>> get detectionStream {
    _detectionController ??=
        StreamController<List<DetectionOverlay>>.broadcast();
    return _detectionController!.stream;
  }

  /// Get renderer for video display
  RTCVideoRenderer? get renderer => _renderer;

  /// Check if connected
  bool get isConnected => _isConnected;

  /// Initialize WebRTC connection for camera stream
  ///
  /// [streamId] - Stream identifier from backend (format: deviceId:cameraId)
  /// [deviceId] - Device identifier
  /// [cameraId] - Camera ID (0-3)
  Future<void> connectToStream({
    required String streamId,
    required String deviceId,
    required int cameraId,
    String? token,
  }) async {
    if (_isConnecting || _isConnected) {
      debugPrint('[AnimalDetectionWebRTC] Already connected or connecting');
      return;
    }

    _isConnecting = true;
    _currentStreamId = streamId;
    _deviceId = deviceId;
    _cameraId = cameraId;

    try {
      debugPrint('[AnimalDetectionWebRTC] Connecting to stream: $streamId');

      // 1. Get WebRTC ICE configuration
      await _getIceConfiguration(token);

      // 2. Create video renderer
      _renderer = RTCVideoRenderer();
      await _renderer!.initialize();

      // 3. Create peer connection
      _peerConnection = await createPeerConnection(
        _iceConfig ??
            {
              'iceServers': [
                {'urls': 'stun:stun.l.google.com:19302'},
              ],
            },
      );

      // 4. Handle incoming tracks
      _peerConnection!.onTrack = (event) {
        debugPrint('[AnimalDetectionWebRTC] Received remote track');
        if (event.streams.isNotEmpty && _renderer != null) {
          _renderer!.srcObject = event.streams[0];
          _isConnected = true;
          _isConnecting = false;
        }
      };

      // 5. Set up ICE candidate handler
      _setupIceCandidateHandler();

      // 6. Connect to signaling server
      await _connectSignaling(token);

      // 7. Start listening for detection updates
      _startDetectionListener(deviceId, cameraId, token);
    } catch (error) {
      debugPrint('[AnimalDetectionWebRTC] Connection error: $error');
      _isConnecting = false;
      await disconnect();
      rethrow;
    }
  }

  /// Get ICE configuration from backend
  Future<void> _getIceConfiguration(String? token) async {
    try {
      final headers = <String, String>{'Content-Type': 'application/json'};

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(Uri.parse('$BASE_URL/api/webrtc/config'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _iceConfig = data['config'];
        debugPrint('[AnimalDetectionWebRTC] ICE config received');
      } else {
        throw Exception('Failed to get ICE config: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('[AnimalDetectionWebRTC] Error getting ICE config: $error');
      // Use default STUN servers as fallback
      _iceConfig = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:stun1.l.google.com:19302'},
        ],
      };
    }
  }

  /// Connect to WebRTC signaling server
  Future<void> _connectSignaling(String? token) async {
    try {
      // Connect to backend WebRTC signaling WebSocket endpoint
      final baseUrl = SOCK_BASE_URL
          .replaceFirst('ws://', '')
          .replaceFirst('wss://', '');
      final wsUrl =
          '${SOCK_BASE_URL.startsWith('wss://') ? 'wss://' : 'ws://'}$baseUrl/ws/webrtc';
      _signalingChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Send join-stream message
      _signalingChannel!.sink.add(
        json.encode({
          'action': 'join-stream',
          'streamId': _currentStreamId,
          'deviceId': _deviceId,
          'cameraId': _cameraId,
        }),
      );

      // Listen for signaling messages
      _signalingChannel!.stream.listen(
        (message) => _handleSignalingMessage(message),
        onError: (error) {
          debugPrint('[AnimalDetectionWebRTC] Signaling error: $error');
        },
        onDone: () {
          debugPrint('[AnimalDetectionWebRTC] Signaling connection closed');
          _isConnected = false;
        },
      );

      debugPrint('[AnimalDetectionWebRTC] Connected to signaling server');
    } catch (error) {
      debugPrint(
        '[AnimalDetectionWebRTC] Error connecting to signaling: $error',
      );
      rethrow;
    }
  }

  /// Handle WebRTC signaling messages
  void _handleSignalingMessage(dynamic message) {
    try {
      final data = json.decode(message.toString());
      final action = data['action'];

      if (action == 'offer' && _peerConnection != null) {
        _handleOffer(data);
      } else if (action == 'ice-candidate' && _peerConnection != null) {
        _handleIceCandidate(data);
      }
    } catch (error) {
      debugPrint(
        '[AnimalDetectionWebRTC] Error handling signaling message: $error',
      );
    }
  }

  /// Handle WebRTC offer
  Future<void> _handleOffer(Map<String, dynamic> data) async {
    try {
      final offer = data['offer'];
      final sessionDescription = RTCSessionDescription(
        offer['sdp'],
        offer['type'],
      );

      await _peerConnection!.setRemoteDescription(sessionDescription);

      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      // Send answer
      _signalingChannel?.sink.add(
        json.encode({
          'action': 'answer',
          'streamId': _currentStreamId,
          'answer': {'sdp': answer.sdp, 'type': answer.type},
        }),
      );

      debugPrint('[AnimalDetectionWebRTC] Sent answer');
    } catch (error) {
      debugPrint('[AnimalDetectionWebRTC] Error handling offer: $error');
    }
  }

  /// Handle ICE candidate
  Future<void> _handleIceCandidate(Map<String, dynamic> data) async {
    try {
      final candidate = data['candidate'];
      if (candidate != null && _peerConnection != null) {
        await _peerConnection!.addCandidate(
          RTCIceCandidate(
            candidate['candidate'],
            candidate['sdpMid'],
            candidate['sdpMLineIndex'],
          ),
        );
      }
    } catch (error) {
      debugPrint(
        '[AnimalDetectionWebRTC] Error handling ICE candidate: $error',
      );
    }
  }

  /// Handle ICE candidates from local peer connection
  void _setupIceCandidateHandler() {
    _peerConnection?.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        _signalingChannel?.sink.add(
          json.encode({
            'action': 'ice-candidate',
            'streamId': _currentStreamId,
            'candidate': {
              'candidate': candidate.candidate,
              'sdpMid': candidate.sdpMid,
              'sdpMLineIndex': candidate.sdpMLineIndex,
            },
          }),
        );
      }
    };
  }

  /// Start listening for detection updates via WebSocket
  void _startDetectionListener(String deviceId, int cameraId, String? token) {
    // Listen for detection updates from backend
    // Detection data will come via WebSocket or can be polled from API
    // For now, we'll poll the API periodically (can be optimized to WebSocket later)
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!_isConnected) {
        timer.cancel();
        return;
      }

      try {
        await _fetchLatestDetections(deviceId, cameraId, token);
      } catch (error) {
        debugPrint('[AnimalDetectionWebRTC] Error fetching detections: $error');
      }
    });
  }

  /// Fetch latest detections for overlay
  Future<void> _fetchLatestDetections(
    String deviceId,
    int cameraId,
    String? token,
  ) async {
    try {
      final headers = <String, String>{'Content-Type': 'application/json'};

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(
            Uri.parse(
              '$BASE_URL/api/animal-detection/cameras/$deviceId/$cameraId/detections?limit=10',
            ),
            headers: headers,
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['detections'] != null) {
          final detections =
              (data['detections'] as List)
                  .map((d) => DetectionOverlay.fromJson(d['detection'] ?? {}))
                  .toList();

          _currentDetections = detections;
          _detectionController?.add(detections);
        }
      }
    } catch (error) {
      // Silent fail - detections are optional
      debugPrint('[AnimalDetectionWebRTC] Error fetching detections: $error');
    }
  }

  /// Get current detections
  List<DetectionOverlay> get currentDetections =>
      List.unmodifiable(_currentDetections);

  /// Disconnect from stream
  Future<void> disconnect() async {
    debugPrint('[AnimalDetectionWebRTC] Disconnecting...');

    _isConnected = false;
    _isConnecting = false;

    // Close peer connection
    await _peerConnection?.close();
    _peerConnection = null;

    // Close signaling
    await _signalingChannel?.sink.close();
    _signalingChannel = null;

    // Dispose renderer
    await _renderer?.dispose();
    _renderer = null;

    // Clear detections
    _currentDetections = [];
    _detectionController?.close();
    _detectionController = null;

    _currentStreamId = null;
    _deviceId = null;
    _cameraId = null;

    debugPrint('[AnimalDetectionWebRTC] Disconnected');
  }

  /// Switch to different camera stream
  Future<void> switchCamera({
    required String streamId,
    required String deviceId,
    required int cameraId,
    String? token,
  }) async {
    await disconnect();
    await connectToStream(
      streamId: streamId,
      deviceId: deviceId,
      cameraId: cameraId,
      token: token,
    );
  }
}
