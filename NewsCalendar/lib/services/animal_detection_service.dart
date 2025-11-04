/// Animal Detection Service
/// Handles API calls for animal detection (streams, detections, alerts)
/// 
/// Phase 4 - Animal Detection Implementation
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:newscalendar/constants/constants.dart';

/// Device stream information
class DeviceStreamInfo {
  final String deviceId;
  final String deviceName;
  final bool connected;
  final bool streamingEnabled;
  final List<CameraInfo> cameras;
  final List<StreamInfo> streams;

  DeviceStreamInfo({
    required this.deviceId,
    required this.deviceName,
    required this.connected,
    required this.streamingEnabled,
    required this.cameras,
    required this.streams,
  });

  factory DeviceStreamInfo.fromJson(Map<String, dynamic> json) {
    return DeviceStreamInfo(
      deviceId: json['deviceId'] ?? '',
      deviceName: json['deviceName'] ?? '',
      connected: json['connected'] ?? false,
      streamingEnabled: json['streamingEnabled'] ?? false,
      cameras: (json['cameras'] as List? ?? [])
          .map((c) => CameraInfo.fromJson(c))
          .toList(),
      streams: (json['streams'] as List? ?? [])
          .map((s) => StreamInfo.fromJson(s))
          .toList(),
    );
  }
}

/// Camera information
class CameraInfo {
  final int id;
  final String name;
  final String type;
  final bool enabled;

  CameraInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.enabled,
  });

  factory CameraInfo.fromJson(Map<String, dynamic> json) {
    return CameraInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? 'usb',
      enabled: json['enabled'] ?? true,
    );
  }
}

/// Stream information
class StreamInfo {
  final int cameraId;
  final String deviceId;
  final String name;
  final String status;
  final int frameCount;
  final int? lastFrameTime;

  StreamInfo({
    required this.cameraId,
    required this.deviceId,
    required this.name,
    required this.status,
    required this.frameCount,
    this.lastFrameTime,
  });

  factory StreamInfo.fromJson(Map<String, dynamic> json) {
    return StreamInfo(
      cameraId: json['cameraId'] ?? 0,
      deviceId: json['deviceId'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? 'unknown',
      frameCount: json['frameCount'] ?? 0,
      lastFrameTime: json['lastFrameTime'],
    );
  }
}

/// Animal Detection Service
class AnimalDetectionService {
  static const _storage = FlutterSecureStorage();

  /// Get authorization headers
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get device streams
  /// Returns stream info for a specific device
  static Future<DeviceStreamInfo> getDeviceStreams(String deviceId) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/api/animal-detection/streams/$deviceId'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return DeviceStreamInfo.fromJson(data);
        } else {
          throw Exception(data['message'] ?? 'Failed to get streams');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting device streams: $e');
    }
  }

  /// Get all active streams
  static Future<List<DeviceStreamInfo>> getAllStreams() async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/api/animal-detection/streams'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['streams'] as List? ?? [])
              .map((s) => DeviceStreamInfo.fromJson(s))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to get streams');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting streams: $e');
    }
  }

  /// Start camera streaming for device
  static Future<void> startStreaming(String deviceId) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/api/animal-detection/streams/start'),
        headers: await _getHeaders(),
        body: json.encode({'deviceId': deviceId}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to start streaming');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to start streaming');
      }
    } catch (e) {
      throw Exception('Error starting streaming: $e');
    }
  }

  /// Stop camera streaming for device
  static Future<void> stopStreaming(String deviceId) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/api/animal-detection/streams/stop'),
        headers: await _getHeaders(),
        body: json.encode({'deviceId': deviceId}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to stop streaming');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to stop streaming');
      }
    } catch (e) {
      throw Exception('Error stopping streaming: $e');
    }
  }

  /// Get detections for camera
  static Future<List<Map<String, dynamic>>> getCameraDetections(
    String deviceId,
    int cameraId, {
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$BASE_URL/api/animal-detection/cameras/$deviceId/$cameraId/detections?limit=$limit'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['detections'] ?? []);
        } else {
          throw Exception(data['message'] ?? 'Failed to get detections');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting detections: $e');
    }
  }
}



