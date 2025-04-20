class Event {
  final String id;
  final String title;
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description; // <-- Add this line

  Event({
    required this.id,
    required this.title,
    required this.userId,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  /// Convert Event object to JSON for sending to backend
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'userId': userId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    try {
      return Event(
        id: json['id'] ?? json['_id'] ?? '',
        title: json['title'] ?? '',
        userId: json['userId'] ?? json['user_id'] ?? json['createdBy'] ?? '',
        startDate: _parseDateTime(json['start_date'] ?? json['startDate']),
        endDate:
            json['end_date'] != null || json['endDate'] != null
                ? _parseDateTime(json['end_date'] ?? json['endDate'])
                : null,
        createdAt: _parseDateTime(
          json['createdAt'] ?? json['created_at'] ?? DateTime.now().toString(),
        ),
        updatedAt: _parseDateTime(
          json['updatedAt'] ?? json['updated_at'] ?? DateTime.now().toString(),
        ),
        description: json['description'],
      );
    } catch (e) {
      throw FormatException('Failed to parse Event: $e\nJSON: $json');
    }
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date is DateTime) return date;
    if (date == null) return DateTime.now();

    try {
      // Try parsing ISO format first
      if (date is String) {
        return DateTime.parse(date);
      }

      // Handle other cases if needed
      return DateTime.now();
    } catch (e) {
      print('Failed to parse date: $date');
      return DateTime.now();
    }
  }

  Event copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
  }) {
    return Event(
      createdAt: createdAt,
      updatedAt: updatedAt,
      userId: userId,
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
    );
  }

  // Static copy method
  static Event copy(Event other) {
    return Event(
      createdAt: other.createdAt,
      updatedAt: other.updatedAt,
      id: other.id,
      userId: other.userId,
      title: other.title,
      startDate: other.startDate,
      description: other.description,
    );
  }
}
