# Frontend Notification Popup Widget

**File:** `NewsCalendar/lib/widgets/notification_popup.dart`
**Type:** New File
**Date:** Current Session

---

## File Created

In-app notification popup widget with overlay helper.

---

## Components

### 1. NotificationPopup Widget
A card-based notification display widget showing:
- **Header**: Title with notification icon and dismiss button
- **Activity Type Badge**: Chip displaying activity type (if available)
- **Description**: Event description text
- **Event Details**: Crop type and field location icons with text
- **Event Time**: Formatted date and time display
- **Action Buttons**: Dismiss and View Event buttons

### 2. NotificationOverlay Helper Class
Static helper for showing notifications as overlay:
- **`show()`**: Display notification as overlay at top of screen
- **`dismiss()`**: Remove overlay notification
- Auto-dismiss after specified duration
- Positioned at top with safe area padding

---

## Widget Properties

```dart
NotificationPopup({
  required String title,
  String? description,
  required DateTime eventTime,
  String? activityType,
  String? cropType,
  String? fieldLocation,
  VoidCallback? onTap,
  VoidCallback? onDismiss,
})
```

---

## Features

- **Dismissible**: Close button and dismiss action
- **Tappable**: Navigate to event details on tap
- **Styled**: Material Design card with proper spacing
- **Informative**: Shows all relevant event information
- **Responsive**: Adapts to different screen sizes

---

## Usage Example

```dart
NotificationOverlay.show(
  context: context,
  title: 'Planting Reminder',
  description: 'Time to plant tomatoes',
  eventTime: DateTime.now().add(Duration(hours: 2)),
  activityType: 'Planting',
  cropType: 'Tomatoes',
  onTap: () => Navigator.push(...),
  duration: Duration(seconds: 5),
);
```

---

## UI Structure

1. Header Row (Icon + Title + Close Button)
2. Activity Type Chip (conditional)
3. Description Text (conditional)
4. Details Row (Crop + Location icons)
5. Time Display Row
6. Action Buttons Row (Dismiss + View Event)

---

## Notes

- Material Design compliant
- Accessible and readable
- Smooth animations (via Overlay)
- Auto-dismiss functionality
- Proper text overflow handling

