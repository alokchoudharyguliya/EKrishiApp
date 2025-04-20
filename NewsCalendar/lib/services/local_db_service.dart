import 'package:hive/hive.dart';
import 'package:newscalendar/models/events.dart';

class HiveLocalDbService implements LocalDbService {
  static const String _eventsBox = 'events';
  static const String _operationsBox = 'pending_operations';
  static const String _syncBox = 'sync_meta';

  @override
  Future<void> init() async {
    await Hive.openBox<Map>(_eventsBox);
    await Hive.openBox<List>(_operationsBox);
    await Hive.openBox<Map>(_syncBox);
  }

  @override
  Future<List<Map<String, dynamic>>> getEvents() async {
    final box = Hive.box<Map>(_eventsBox);
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Future<void> saveEvents(List<Map<String, dynamic>> events) async {
    final box = Hive.box<Map>(_eventsBox);
    await box.clear();

    for (final event in events) {
      if (event['id'] != null) {
        await box.put(event['id'], event);
      }
    }

    // Update last sync time
    await _updateLastSyncTime();
  }

  @override
  Future<void> mergeEvents(List<Event> events) async {
    final box = Hive.box<Map>(_eventsBox);
    final existingEvents = Map<String, Map>.from(box.toMap());

    for (final event in events) {
      final existing = existingEvents[event.id];

      // Conflict resolution: newest wins
      if (existing == null ||
          event.updatedAt.isAfter(DateTime.parse(existing['updatedAt']))) {
        await box.put(event.id, event.toJson());
      }
    }

    await _updateLastSyncTime();
  }

  @override
  Future<void> saveEvent(Event event) async {
    await Hive.box<Map>(_eventsBox).put(event.id, event.toJson());
  }

  @override
  Future<void> updateEvent(Event event) async {
    await Hive.box<Map>(_eventsBox).put(event.id, event.toJson());
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await Hive.box<Map>(_eventsBox).delete(eventId);
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    final box = Hive.box<Map>(_syncBox);
    final timestamp = box.get('last_sync')?['timestamp'];
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  Future<void> _updateLastSyncTime() async {
    await Hive.box<Map>(
      _syncBox,
    ).put('last_sync', {'timestamp': DateTime.now().toIso8601String()});
  }

  @override
  Future<void> queueOperation({
    required String type,
    required Map<String, dynamic> data,
    String? eventId,
  }) async {
    final box = Hive.box<List>(_operationsBox);
    final operations = box.get('operations')?.cast<Map>() ?? [];

    operations.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': type,
      'eventId': eventId,
      'data': data,
      'createdAt': DateTime.now().toIso8601String(),
    });

    await box.put('operations', operations);
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    final box = Hive.box<List>(_operationsBox);
    final operations = box.get('operations')?.cast<Map>() ?? [];
    return operations.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Future<void> removePendingOperation(String id) async {
    final box = Hive.box<List>(_operationsBox);
    final operations = box.get('operations')?.cast<Map>() ?? [];

    await box.put(
      'operations',
      operations.where((op) => op['id'] != id).toList(),
    );
  }

  @override
  Future<void> clearPendingOperations() async {
    await Hive.box<List>(_operationsBox).clear();
  }

  Future<void> close() async {
    await Hive.close();
  }
}

abstract class LocalDbService {
  Future<void> init();
  Future<List<Map<String, dynamic>>> getEvents();
  Future<void> saveEvents(List<Map<String, dynamic>> events);
  Future<void> mergeEvents(List<Event> events);
  Future<void> saveEvent(Event event);
  Future<void> updateEvent(Event event);
  Future<void> deleteEvent(String eventId);
  Future<DateTime?> getLastSyncTime();

  Future<void> queueOperation({
    required String type,
    required Map<String, dynamic> data,
    String? eventId,
  });

  Future<List<Map<String, dynamic>>> getPendingOperations();
  Future<void> removePendingOperation(String id);
  Future<void> clearPendingOperations();
}
