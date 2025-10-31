class IrrigationEvent {
  final String id;
  final String userId;
  final String deviceId;
  final String action; // 'pump_on', 'pump_off', 'pump_toggle'
  final bool state; // true = pump on, false = pump off
  final String triggeredBy; // 'user', 'schedule', 'sensor', 'manual'
  final int? duration; // Duration in seconds (optional)
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  IrrigationEvent({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.action,
    required this.state,
    this.triggeredBy = 'user',
    this.duration,
    this.metadata = const {},
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'userId': userId,
      'deviceId': deviceId,
      'action': action,
      'state': state,
      'triggeredBy': triggeredBy,
      'duration': duration,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory IrrigationEvent.fromJson(Map<String, dynamic> json) {
    try {
      return IrrigationEvent(
        id: json['id'] ?? json['_id'] ?? '',
        userId: json['userId']?.toString() ?? '',
        deviceId: json['deviceId'] ?? '',
        action: json['action'] ?? '',
        state: json['state'] ?? false,
        triggeredBy: json['triggeredBy'] ?? 'user',
        duration: json['duration'] as int?,
        metadata:
            json['metadata'] is Map
                ? Map<String, dynamic>.from(json['metadata'])
                : {},
        createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      );
    } catch (e) {
      throw FormatException('Failed to parse IrrigationEvent: $e\nJSON: $json');
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

  IrrigationEvent copyWith({
    String? id,
    String? userId,
    String? deviceId,
    String? action,
    bool? state,
    String? triggeredBy,
    int? duration,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return IrrigationEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      action: action ?? this.action,
      state: state ?? this.state,
      triggeredBy: triggeredBy ?? this.triggeredBy,
      duration: duration ?? this.duration,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'IrrigationEvent(id: $id, deviceId: $deviceId, action: $action, state: $state)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IrrigationEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
