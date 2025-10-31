class IrrigationDevice {
  final String id;
  final String userId;
  final String deviceId;
  final String deviceName;
  final String piUrl;
  final String location;
  final bool isActive;
  final DateTime lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;

  IrrigationDevice({
    required this.id,
    required this.userId,
    required this.deviceId,
    this.deviceName = 'Irrigation Device',
    required this.piUrl,
    this.location = '',
    this.isActive = true,
    required this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'userId': userId,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'piUrl': piUrl,
      'location': location,
      'isActive': isActive,
      'lastSeen': lastSeen.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory IrrigationDevice.fromJson(Map<String, dynamic> json) {
    try {
      return IrrigationDevice(
        id: json['id'] ?? json['_id'] ?? '',
        userId: json['userId']?.toString() ?? '',
        deviceId: json['deviceId'] ?? '',
        deviceName: json['deviceName'] ?? 'Irrigation Device',
        piUrl: json['piUrl'] ?? '',
        location: json['location'] ?? '',
        isActive: json['isActive'] ?? true,
        lastSeen: _parseDateTime(json['lastSeen']) ?? DateTime.now(),
        createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
        updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now(),
      );
    } catch (e) {
      throw FormatException(
        'Failed to parse IrrigationDevice: $e\nJSON: $json',
      );
    }
  }

  static DateTime? _parseDateTime(dynamic date) {
    if (date is DateTime) return date;
    if (date == null) return null;

    try {
      if (date is String) {
        return DateTime.parse(date);
      }
      return null;
    } catch (e) {
      print('Failed to parse date: $date');
      return null;
    }
  }

  IrrigationDevice copyWith({
    String? id,
    String? userId,
    String? deviceId,
    String? deviceName,
    String? piUrl,
    String? location,
    bool? isActive,
    DateTime? lastSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IrrigationDevice(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      piUrl: piUrl ?? this.piUrl,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'IrrigationDevice(id: $id, deviceId: $deviceId, deviceName: $deviceName, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IrrigationDevice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
