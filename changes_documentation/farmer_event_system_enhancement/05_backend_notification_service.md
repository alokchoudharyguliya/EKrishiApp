# Backend Notification Service

**File:** `backend/services/notificationService.js`
**Type:** New File
**Date:** Current Session

---

## File Created

New service file for handling event reminder notifications.

---

## Functions Implemented

### 1. `calculateReminderTime(eventStartDate, reminderType, reminderValue)`
- **Purpose:** Calculate the exact reminder time based on event start and reminder settings
- **Parameters:**
  - `eventStartDate`: Event start date/time
  - `reminderType`: 'days', 'hours', or 'minutes'
  - `reminderValue`: Number of days/hours/minutes before event
- **Returns:** Calculated Date object for reminder time

### 2. `scheduleEventReminders(event)`
- **Purpose:** Schedule all reminders for an event
- **Parameters:** Event document
- **Returns:** Array of scheduled reminder objects with calculated reminderTime

### 3. `getPendingNotifications(userId)`
- **Purpose:** Get all pending notifications for a user that are due
- **Parameters:** User ID
- **Returns:** Array of notification objects with event details

### 4. `markReminderAsNotified(eventId, reminderIndex)`
- **Purpose:** Mark a specific reminder as notified
- **Parameters:** Event ID and reminder index
- **Returns:** Updated event document

### 5. `cancelEventReminders(eventId)`
- **Purpose:** Cancel all reminders when event is deleted
- **Parameters:** Event ID
- **Returns:** Promise<void>

### 6. `updateEventReminders(eventId, updatedEventData)`
- **Purpose:** Recalculate reminder times when event is updated
- **Parameters:** Event ID and updated event data
- **Returns:** Updated event data with recalculated reminders

---

## Usage

This service is used by:
- Event controller when creating/updating events
- Notification controller for fetching pending notifications
- Background jobs/cron for checking due reminders

---

## Notes

- Reminder times are calculated relative to event start time
- Handles both all-day and timed events
- Resets notification status when reminders are updated

