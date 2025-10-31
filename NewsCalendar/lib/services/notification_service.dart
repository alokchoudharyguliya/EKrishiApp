import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/constants.dart';
import '../models/events.dart' as eventModel;
import 'auth_service.dart';
import 'package:provider/provider.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // Adjust timezone as needed

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize plugin
    final bool? initialized = await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    if (initialized == true) {
      _initialized = true;
    }

    // Request permissions
    await _requestPermissions();
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Android 13+ requires runtime permission
    if (await _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission() ==
        true) {
      // Permission granted
    }

    // iOS permissions are requested in initialization
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can navigate to event details
    print('Notification tapped: ${response.payload}');
  }

  /// Schedule a notification for an event reminder
  Future<void> scheduleEventReminder({
    required String eventId,
    required String eventTitle,
    required String eventDescription,
    required DateTime reminderTime,
    required DateTime eventStartTime,
    String? activityType,
    String? cropType,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    // Create notification body
    String body = eventDescription.isNotEmpty
        ? eventDescription
        : 'Event reminder: $eventTitle';
    
    if (activityType != null) {
      body = '$activityType: $body';
    }
    if (cropType != null) {
      body = 'Crop: $cropType - $body';
    }

    // Schedule notification
    await _notifications.zonedSchedule(
      int.parse(eventId.replaceAll(RegExp(r'[^0-9]'), '').substring(0, 8)) + 
        reminderTime.millisecondsSinceEpoch ~/ 10000, // Unique ID
      eventTitle,
      body,
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_reminders',
          'Event Reminders',
          channelDescription: 'Notifications for farming event reminders',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode({
        'eventId': eventId,
        'type': 'event_reminder',
      }),
    );
  }

  /// Schedule multiple reminders for an event
  Future<void> scheduleEventReminders(eventModel.Event event) async {
    if (!_initialized) {
      await initialize();
    }

    if (event.reminders.isEmpty) return;

    final eventStartTime = event.eventMode == 'timed' && event.startTime != null
        ? event.startTime!
        : event.startDate;

    for (var reminder in event.reminders) {
      if (reminder.reminderTime.isBefore(DateTime.now())) {
        continue; // Skip past reminders
      }

      await scheduleEventReminder(
        eventId: event.id,
        eventTitle: event.title,
        eventDescription: event.description ?? '',
        reminderTime: reminder.reminderTime,
        eventStartTime: eventStartTime,
        activityType: event.activityType,
        cropType: event.cropType,
      );
    }
  }

  /// Cancel all reminders for an event
  Future<void> cancelEventReminders(String eventId) async {
    // Cancel all notifications for this event
    // Note: This is a simplified version - you may need to store notification IDs
    // to cancel specific ones
    await _notifications.cancelAll();
  }

  /// Check for pending notifications from backend
  Future<List<Map<String, dynamic>>> getPendingNotifications(String? token) async {
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/api/notifications/pending'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['notifications'] ?? []);
        }
      }
    } catch (e) {
      print('Error fetching pending notifications: $e');
    }

    return [];
  }

  /// Mark a notification as notified
  Future<bool> markAsNotified({
    required String eventId,
    required int reminderIndex,
    required String? token,
  }) async {
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/api/notifications/mark-notified'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'eventId': eventId,
          'reminderIndex': reminderIndex,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notification as notified: $e');
      return false;
    }
  }

  /// Show immediate in-app notification (popup)
  Future<void> showInAppNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'in_app_notifications',
          'In-App Notifications',
          channelDescription: 'Immediate notifications shown in the app',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }
}

