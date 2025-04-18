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

  /// Create an Event object from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'],
      title: json['title'],
      userId: json['userId'],
      startDate: DateTime.parse(json['start_date']),
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Convert Event object to JSON for sending to backend
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'userId': userId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'description': description,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      // 'time': time?.format(
      // const TimeOfDayFormat.H_colon_mm_space_a(),
      // ), // or just time?.toString(),
    };
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

  // In your Event model
  String get uniqueId => id ?? DateTime.now().millisecondsSinceEpoch.toString();
}
