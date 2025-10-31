import 'dart:convert';
import 'package:flutter/services.dart';

/// Model class representing a camera configuration
class CameraConfig {
  final String id;
  final String name;
  final String streamId; // WebRTC stream ID
  final bool enabled;
  final String? description; // Optional description

  CameraConfig({
    required this.id,
    required this.name,
    required this.streamId,
    this.enabled = true,
    this.description,
  });

  /// Create CameraConfig from JSON
  factory CameraConfig.fromJson(Map<String, dynamic> json) {
    return CameraConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      streamId: json['streamId'] as String,
      enabled: json['enabled'] ?? true,
      description: json['description'] as String?,
    );
  }

  /// Convert CameraConfig to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'streamId': streamId,
      'enabled': enabled,
      if (description != null) 'description': description,
    };
  }
}

/// Service class to manage camera configurations
class CameraConfigService {
  static const String _configPath = 'assets/config/cameras.json';
  List<CameraConfig> _cameras = [];
  bool _isLoaded = false;

  /// Get all camera configurations
  Future<List<CameraConfig>> getCameras() async {
    if (!_isLoaded) {
      await loadCameras();
    }
    return List.unmodifiable(_cameras);
  }

  /// Get only enabled cameras
  Future<List<CameraConfig>> getEnabledCameras() async {
    final cameras = await getCameras();
    return cameras.where((camera) => camera.enabled).toList();
  }

  /// Get a specific camera by ID
  Future<CameraConfig?> getCameraById(String id) async {
    final cameras = await getCameras();
    try {
      return cameras.firstWhere((camera) => camera.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get a specific camera by stream ID
  Future<CameraConfig?> getCameraByStreamId(String streamId) async {
    final cameras = await getCameras();
    try {
      return cameras.firstWhere((camera) => camera.streamId == streamId);
    } catch (e) {
      return null;
    }
  }

  /// Load cameras from JSON file
  Future<void> loadCameras() async {
    try {
      final String jsonString = await rootBundle.loadString(_configPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> camerasList = jsonData['cameras'] ?? [];
      _cameras =
          camerasList
              .map(
                (cameraJson) =>
                    CameraConfig.fromJson(cameraJson as Map<String, dynamic>),
              )
              .toList();

      _isLoaded = true;
    } catch (e) {
      print('Error loading camera config: $e');
      _cameras = [];
      _isLoaded = true;
    }
  }

  /// Reload cameras from JSON file (useful after external updates)
  Future<void> reloadCameras() async {
    _isLoaded = false;
    await loadCameras();
  }
}
