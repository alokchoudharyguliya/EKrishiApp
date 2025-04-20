import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:newscalendar/services/local_db_service.dart';
import 'package:newscalendar/services/websocket_service.dart';
import '../models/events.dart';

class SyncService with ChangeNotifier {
  final LocalDbService localDb;
  final WebSocketService webSocket;
  bool _isSyncing = false;
  DateTime _lastSync = DateTime.now();

  SyncService({required this.localDb, required this.webSocket});

  bool get isSyncing => _isSyncing;
  DateTime get lastSync => _lastSync;

  // Initialize synchronization
  Future<void> initialize() async {
    await localDb.init();
    _setupWebSocketListeners();
  }

  // Set up WebSocket message handlers
  void _setupWebSocketListeners() {
    webSocket.onMessage = (message) async {
      try {
        final data = json.decode(message.toString());

        if (data['type'] == 'events') {
          await _handleIncomingEvents(data['data']);
        } else if (data['type'] == 'eventCreated') {
          await _handleCreatedEvent(data['event']);
        } else if (data['type'] == 'eventUpdated') {
          await _handleUpdatedEvent(data['event']);
        } else if (data['type'] == 'eventDeleted') {
          await _handleDeletedEvent(data['eventId']);
        }
      } catch (e) {
        debugPrint('Error processing WebSocket message: $e');
      }
    };
  }

  // Full synchronization (initial load or manual refresh)
  Future<void> syncInitialData() async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();

    try {
      // 1. Get last sync timestamp from local DB
      final lastSync = await localDb.getLastSyncTime();

      // 2. Request updates from server
      webSocket.sendMessage({
        'action': 'sync',
        'since': lastSync?.toIso8601String(),
      });

      // 3. Process any pending local operations
      await _syncPendingOperations();
    } catch (e) {
      debugPrint('Sync error: $e');
    } finally {
      _isSyncing = false;
      _lastSync = DateTime.now();
      notifyListeners();
    }
  }

  // Sync pending create/update/delete operations
  Future<void> _syncPendingOperations() async {
    final pendingOps = await localDb.getPendingOperations();
    if (pendingOps.isEmpty) return;

    for (final op in pendingOps) {
      try {
        switch (op['type']) {
          case 'create':
            await webSocket.sendMessage({
              'action': 'createEvent',
              'event': op['data'],
            });
            break;
          case 'update':
            await webSocket.sendMessage({
              'action': 'updateEvent',
              'eventId': op['eventId'],
              'updates': op['data'],
            });
            break;
          case 'delete':
            await webSocket.sendMessage({
              'action': 'deleteEvent',
              'eventId': op['eventId'],
            });
            break;
        }
        await localDb.removePendingOperation(op['id']);
      } catch (e) {
        debugPrint('Failed to sync operation ${op['id']}: $e');
      }
    }
  }

  // Handle incoming batch of events
  Future<void> _handleIncomingEvents(List<dynamic> events) async {
    try {
      // Convert to Event models and filter valid ones
      final validEvents =
          events.map((e) => Event.fromJson(e)).whereType<Event>().toList();

      // Merge with local events (conflict resolution happens here)
      await localDb.mergeEvents(validEvents);
    } catch (e) {
      debugPrint('Error processing incoming events: $e');
    }
  }

  // Handle single created event
  Future<void> _handleCreatedEvent(Map<String, dynamic> eventData) async {
    try {
      final event = Event.fromJson(eventData);
      await localDb.saveEvent(event);
    } catch (e) {
      debugPrint('Error processing created event: $e');
    }
  }

  // Handle single updated event
  Future<void> _handleUpdatedEvent(Map<String, dynamic> eventData) async {
    try {
      final event = Event.fromJson(eventData);
      await localDb.updateEvent(event);
    } catch (e) {
      debugPrint('Error processing updated event: $e');
    }
  }

  // Handle deleted event
  Future<void> _handleDeletedEvent(String eventId) async {
    try {
      await localDb.deleteEvent(eventId);
    } catch (e) {
      debugPrint('Error processing deleted event: $e');
    }
  }

  // Create event with offline support
  Future<void> createEvent(Event event) async {
    // 1. Save to local DB immediately (as pending)
    await localDb.queueOperation(type: 'create', data: event.toJson());

    // 2. Try to sync if online
    if (webSocket.isConnected) {
      await _syncPendingOperations();
    }
  }

  // Update event with offline support
  Future<void> updateEvent(String eventId, Event event) async {
    // 1. Save to local DB immediately (as pending)
    await localDb.queueOperation(
      type: 'update',
      eventId: eventId,
      data: event.toJson(),
    );

    // 2. Try to sync if online
    if (webSocket.isConnected) {
      await _syncPendingOperations();
    }
  }

  // Delete event with offline support
  Future<void> deleteEvent(String eventId) async {
    // 1. Save to local DB immediately (as pending)
    // await localDb.queueOperation(type: 'delete', eventId: eventId);
    await localDb.deleteEvent(eventId.toString());

    // 2. Try to sync if online
    if (webSocket.isConnected) {
      await _syncPendingOperations();
    }
  }
}
