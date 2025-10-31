import 'package:hive/hive.dart';
part 'events.g.dart';

// Reminder model for event reminders
@HiveType(typeId: 1)
class Reminder {
  @HiveField(0)
  final DateTime reminderTime;
  @HiveField(1)
  final String reminderType; // 'days', 'hours', or 'minutes'
  @HiveField(2)
  final int reminderValue;
  @HiveField(3)
  final bool isNotified;
  @HiveField(4)
  final String? notificationId;

  Reminder({
    required this.reminderTime,
    required this.reminderType,
    required this.reminderValue,
    this.isNotified = false,
    this.notificationId,
  });

  Map<String, dynamic> toJson() {
    return {
      'reminderTime': reminderTime.toIso8601String(),
      'reminderType': reminderType,
      'reminderValue': reminderValue,
      'isNotified': isNotified,
      'notificationId': notificationId,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      reminderTime: DateTime.parse(json['reminderTime']),
      reminderType: json['reminderType'],
      reminderValue: json['reminderValue'],
      isNotified: json['isNotified'] ?? false,
      notificationId: json['notificationId'],
    );
  }
}

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
  
  // Event mode: 'all-day' or 'timed'
  @HiveField(13)
  final String eventMode;
  
  // Time fields (for timed events)
  @HiveField(14)
  final DateTime? startTime;
  @HiveField(15)
  final DateTime? endTime;
  
  // Farmer-specific fields
  @HiveField(16)
  final String? cropType;
  @HiveField(17)
  final String? cropVariety;
  @HiveField(18)
  final String? activityType;
  @HiveField(19)
  final String? fieldLocation;
  @HiveField(20)
  final List<String> equipmentNeeded;
  
  // Reminder system
  @HiveField(21)
  final List<Reminder> reminders;
  @HiveField(22)
  final Map<String, dynamic>? reminderSettings;

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
    this.eventMode = 'all-day',
    this.startTime,
    this.endTime,
    this.cropType,
    this.cropVariety,
    this.activityType,
    this.fieldLocation,
    this.equipmentNeeded = const [],
    this.reminders = const [],
    this.reminderSettings,
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
      'eventMode': eventMode,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'cropType': cropType,
      'cropVariety': cropVariety,
      'activityType': activityType,
      'fieldLocation': fieldLocation,
      'equipmentNeeded': equipmentNeeded,
      'reminders': reminders.map((r) => r.toJson()).toList(),
      'reminderSettings': reminderSettings,
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
        eventMode: json['eventMode'] ?? 'all-day',
        startTime: json['startTime'] != null ? _parseDateTime(json['startTime']) : null,
        endTime: json['endTime'] != null ? _parseDateTime(json['endTime']) : null,
        cropType: json['cropType'],
        cropVariety: json['cropVariety'],
        activityType: json['activityType'],
        fieldLocation: json['fieldLocation'],
        equipmentNeeded: json['equipmentNeeded'] != null 
            ? List<String>.from(json['equipmentNeeded'])
            : [],
        reminders: json['reminders'] != null
            ? (json['reminders'] as List).map((r) => Reminder.fromJson(r)).toList()
            : [],
        reminderSettings: json['reminderSettings'],
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
    String? eventMode,
    DateTime? startTime,
    DateTime? endTime,
    String? cropType,
    String? cropVariety,
    String? activityType,
    String? fieldLocation,
    List<String>? equipmentNeeded,
    List<Reminder>? reminders,
    Map<String, dynamic>? reminderSettings,
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
      eventMode: eventMode ?? this.eventMode,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      cropType: cropType ?? this.cropType,
      cropVariety: cropVariety ?? this.cropVariety,
      activityType: activityType ?? this.activityType,
      fieldLocation: fieldLocation ?? this.fieldLocation,
      equipmentNeeded: equipmentNeeded ?? this.equipmentNeeded,
      reminders: reminders ?? this.reminders,
      reminderSettings: reminderSettings ?? this.reminderSettings,
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
    String eventMode = 'all-day',
    DateTime? startTime,
    DateTime? endTime,
    String? cropType,
    String? cropVariety,
    String? activityType,
    String? fieldLocation,
    List<String> equipmentNeeded = const [],
    List<Reminder> reminders = const [],
    Map<String, dynamic>? reminderSettings,
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
      eventMode: eventMode,
      startTime: startTime,
      endTime: endTime,
      cropType: cropType,
      cropVariety: cropVariety,
      activityType: activityType,
      fieldLocation: fieldLocation,
      equipmentNeeded: equipmentNeeded,
      reminders: reminders,
      reminderSettings: reminderSettings,
    );
  }
}
