class SensorReading {
  final String id;
  final String userId;
  final String deviceId;
  final String sensorType; // 'temperature', 'moisture', 'humidity'
  final double value;
  final String unit;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  SensorReading({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.sensorType,
    required this.value,
    this.unit = '',
    required this.timestamp,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'userId': userId,
      'deviceId': deviceId,
      'sensorType': sensorType,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    try {
      return SensorReading(
        id: json['id'] ?? json['_id'] ?? '',
        userId: json['userId']?.toString() ?? '',
        deviceId: json['deviceId'] ?? '',
        sensorType: json['sensorType'] ?? '',
        value:
            (json['value'] is num)
                ? (json['value'] as num).toDouble()
                : double.tryParse(json['value']?.toString() ?? '0') ?? 0.0,
        unit: json['unit'] ?? '',
        timestamp: _parseDateTime(json['timestamp']) ?? DateTime.now(),
        metadata:
            json['metadata'] is Map
                ? Map<String, dynamic>.from(json['metadata'])
                : {},
      );
    } catch (e) {
      throw FormatException('Failed to parse SensorReading: $e\nJSON: $json');
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

  SensorReading copyWith({
    String? id,
    String? userId,
    String? deviceId,
    String? sensorType,
    double? value,
    String? unit,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return SensorReading(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      sensorType: sensorType ?? this.sensorType,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'SensorReading(id: $id, sensorType: $sensorType, value: $value$unit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SensorReading && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
