# Frontend Notification Service

**File:** `NewsCalendar/lib/services/notification_service.dart`
**Type:** New File
**Date:** Current Session

---

## File Created

Complete notification service for handling local notifications and backend notification integration.

---

## Features Implemented

### 1. Initialization
- **`initialize()`**: Initializes Flutter Local Notifications plugin
- Sets up Android and iOS notification channels
- Requests necessary permissions
- Initializes timezone support

### 2. Scheduling Notifications
- **`scheduleEventReminder()`**: Schedule a single reminder notification
- **`scheduleEventReminders()`**: Schedule all reminders for an event
- Uses timezone-aware scheduling
- Creates unique notification IDs

### 3. Notification Management
- **`cancelEventReminders()`**: Cancel all reminders for an event
- **`showInAppNotification()`**: Show immediate in-app notification

### 4. Backend Integration
- **`getPendingNotifications()`**: Fetch pending notifications from backend
- **`markAsNotified()`**: Mark a reminder as notified on backend
- Handles authentication tokens

---

## Key Methods

### Notification Scheduling
```dart
Future<void> scheduleEventReminder({
  required String eventId,
  required String eventTitle,
  required String eventDescription,
  required DateTime reminderTime,
  required DateTime eventStartTime,
  String? activityType,
  String? cropType,
})
```

### Backend Sync
```dart
Future<List<Map<String, dynamic>>> getPendingNotifications(String? token)
Future<bool> markAsNotified({
  required String eventId,
  required int reminderIndex,
  required String? token,
})
```

---

## Notification Channels

1. **event_reminders**: For scheduled event reminders
2. **in_app_notifications**: For immediate in-app notifications

---

## Timezone Handling

- Uses `timezone` package for timezone-aware scheduling
- Default timezone: Asia/Kolkata (can be configured)
- Handles daylight saving time automatically

---

## Notes

- Singleton pattern for service instance
- Automatic permission requests
- Handles both local and backend notifications
- Notification tap handling configured
- Payload support for navigation

---

## Dependencies

- `flutter_local_notifications`
- `timezone`
- `http` (for backend API calls)

