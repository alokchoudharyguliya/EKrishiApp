import 'package:hive/hive.dart';
part 'events.g.dart';

@HiveType(typeId: 0)
class Event {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String userId;
  @HiveField(3)
  final DateTime startDate;
  @HiveField(4)
  final DateTime? endDate;
  @HiveField(5)
  final DateTime createdAt;
  @HiveField(6)
  final DateTime updatedAt;
  @HiveField(7)
  final String? description;
  @HiveField(8)
  final bool isSynced;
  @HiveField(9)
  final DateTime lastUpdated;
  @HiveField(10)
  final int version;
  @HiveField(11)
  final bool isDeleted;
  @HiveField(12)
  String? changeType;

  Event({
    required this.id,
    this.isDeleted = false,
    required this.title,
    required this.userId,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.isSynced = false,
    required this.lastUpdated,
    this.version = 0,
    this.changeType,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'userId': userId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'id': id,
      'isSynced': isSynced,
      'lastUpdated': lastUpdated.toIso8601String(),
      'version': version,
      'isDeleted': isDeleted,
      'changeType': changeType,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    try {
      return Event(
        isDeleted: json['isDeleted'] ?? false,
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
        lastUpdated: _parseDateTime(
          json['last_updated'] ??
              json['updatedAt'] ??
              DateTime.now().toString(),
        ),
        isSynced: json['isSynced'] ?? true,
        version: json['version'] ?? 0,
      );
    } catch (e) {
      throw FormatException('Failed to parse Event: $e\nJSON: $json');
    }
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date is DateTime) return date;
    if (date == null) return DateTime.now();

    try {
      if (date is String) {
        return DateTime.parse(date);
      }
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
    bool? isSynced,
    DateTime? lastUpdated,
    int? version,
    bool? isDeleted,
    String? userId,
    String? changeType,
  }) {
    return Event(
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userId: userId ?? this.userId,
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      isSynced: isSynced ?? this.isSynced,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      version: version ?? this.version,
      changeType: changeType ?? this.changeType,
    );
  }

  static Event copy(Event other) {
    return Event(
      isDeleted: other.isDeleted,
      createdAt: other.createdAt,
      updatedAt: other.updatedAt,
      id: other.id,
      userId: other.userId,
      title: other.title,
      startDate: other.startDate,
      description: other.description,
      isSynced: other.isSynced,
      lastUpdated: other.lastUpdated,
      version: other.version,
    );
  }

  factory Event.create({
    required String id,
    required String title,
    String? description,
    required DateTime startDate,
    DateTime? endDate,
    required userId,
    bool isDeleted = false,
    String? changeType,
  }) {
    final now = DateTime.now();
    return Event(
      isDeleted: isDeleted,
      id: id,
      title: title,
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      createdAt: now,
      lastUpdated: now,
      updatedAt: now,
      description: description,
      isSynced: false,
      version: 0,
      changeType: changeType,
    );
  }
}
