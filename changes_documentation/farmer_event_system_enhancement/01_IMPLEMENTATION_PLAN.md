# Implementation Plan: Farmer Event System Enhancement

**Date:** Current Session
**Status:** Ready for Implementation

---

## User Requirements Summary

1. **Farmer-Specific Fields:** ALL
   - Crop type/variety
   - Activity type (Planting, Harvesting, Irrigation, etc.)
   - Field/location reference
   - Equipment needed

2. **Reminder System:** ALL features
   - Reminder intervals (customizable)
   - Custom reminder times
   - Multiple reminders per event

3. **Notifications:**
   - In-app popups
   - Push notifications (when app is closed)
   - Dismissible notifications

4. **Time Management:**
   - Event mode: "all-day" (date-only) OR "timed" (with specific start/end times)
   - Support for both types

---

## Implementation Phases

### Phase 1: Backend Enhancements

#### 1.1 Update Event Model
**File:** `backend/models/event.js`
**Changes:**
- Add `eventMode` field: `'all-day'` or `'timed'` (enum)
- Add `startTime` field (Date/Time, optional - only for timed events)
- Add `endTime` field (Date/Time, optional - only for timed events)
- Add `cropType` field (String, optional)
- Add `cropVariety` field (String, optional)
- Add `activityType` field (String, enum: ['Planting', 'Harvesting', 'Irrigation', 'Fertilization', 'Pest Control', 'Pruning', 'Weeding', 'Other'])
- Add `fieldLocation` field (String, optional)
- Add `equipmentNeeded` field (Array of Strings, optional)
- Add `reminders` field (Array of Objects with: `reminderTime`, `reminderType`, `isNotified`)
- Add `reminderSettings` field (Object with default reminder preferences)

#### 1.2 Fix Bug in Event Controller
**File:** `backend/controllers/eventController.js`
**Changes:**
- Line 16: Fix `event.find()` to `Event.find()`

#### 1.3 Create Notification Service
**File:** `backend/services/notificationService.js` (NEW)
**Features:**
- Schedule notifications based on reminder times
- Handle notification sending logic
- Manage notification queue

#### 1.4 Create Notification Controller
**File:** `backend/controllers/notificationController.js` (NEW)
**Features:**
- Endpoint to get pending notifications for a user
- Endpoint to mark notifications as read/dismissed
- Endpoint to trigger notification check

#### 1.5 Update User Model
**File:** `backend/models/user.js`
**Changes:**
- Update role enum to include `'farmer'`: `['student', 'faculty', 'other', 'admin', 'farmer']`

#### 1.6 Update Event Controller
**File:** `backend/controllers/eventController.js`
**Changes:**
- Add validation for new farmer-specific fields
- Handle reminder creation/update when events are created/updated
- Integrate with notification service
- Update validation logic for timed vs all-day events

---

### Phase 2: Frontend Enhancements

#### 2.1 Update Event Model (Dart)
**File:** `NewsCalendar/lib/models/events.dart`
**Changes:**
- Add all new fields matching backend
- Update `toJson()` and `fromJson()` methods
- Update `copyWith()` method
- Regenerate `events.g.dart` using build_runner

#### 2.2 Update Create Event Screen
**File:** `NewsCalendar/lib/screens/create_event_screen.dart`
**Changes:**
- Add event mode toggle (all-day vs timed)
- Add time pickers (visible only for timed events)
- Add crop type/variety input fields
- Add activity type dropdown
- Add field location input
- Add equipment needed (multi-select or tags)
- Add reminder configuration section with ability to add multiple reminders
- Update form validation
- Update API call to include all new fields

#### 2.3 Update Update Event Screen
**File:** `NewsCalendar/lib/screens/update_event_screen.dart`
**Changes:**
- Same as create screen (all fields editable)
- Pre-populate all fields with existing event data
- Handle mode changes (all-day <-> timed)
- Update API call to include all new fields

#### 2.4 Add Notification Service
**File:** `NewsCalendar/lib/services/notification_service.dart` (NEW)
**Features:**
- Initialize notification plugin
- Request permissions
- Schedule local notifications
- Handle notification taps
- Cancel notifications for deleted/updated events
- Check for pending notifications

#### 2.5 Add Notification Popup Widget
**File:** `NewsCalendar/lib/widgets/notification_popup.dart` (NEW)
**Features:**
- Display in-app notification popup
- Show event details
- Dismissible
- Navigate to event on tap

#### 2.6 Update Calendar Screen
**File:** `NewsCalendar/lib/screens/calendar_screen.dart`
**Changes:**
- Initialize notification service on app start
- Check for notifications periodically
- Display notification popup when event reminder time arrives
- Show farmer-specific fields in event overlay
- Update event display to show activity type, crop type, etc.

#### 2.7 Update Pubspec.yaml
**File:** `NewsCalendar/pubspec.yaml`
**Changes:**
- Add `flutter_local_notifications: ^17.2.3`
- Add `timezone: ^0.9.2`

---

### Phase 3: Integration & Testing

#### 3.1 Notification Integration
- Connect backend reminder system with frontend notifications
- Test notification scheduling on event creation
- Test notification updates on event updates
- Test notification cancellation on event deletion

#### 3.2 End-to-End Testing
- Create all-day event with reminders
- Create timed event with reminders
- Update event and verify reminders update
- Delete event and verify reminders cancel
- Test multiple reminders per event

---

## Files to be Modified/Created

### Backend Files:
1. `backend/models/event.js` - UPDATE
2. `backend/models/user.js` - UPDATE
3. `backend/controllers/eventController.js` - UPDATE (fix bug + add features)
4. `backend/services/notificationService.js` - CREATE
5. `backend/controllers/notificationController.js` - CREATE
6. `backend/routes/eventRoute.js` - UPDATE (may need notification routes)

### Frontend Files:
1. `NewsCalendar/lib/models/events.dart` - UPDATE
2. `NewsCalendar/lib/models/events.g.dart` - REGENERATE
3. `NewsCalendar/lib/screens/create_event_screen.dart` - UPDATE
4. `NewsCalendar/lib/screens/update_event_screen.dart` - UPDATE
5. `NewsCalendar/lib/screens/calendar_screen.dart` - UPDATE
6. `NewsCalendar/lib/services/notification_service.dart` - CREATE
7. `NewsCalendar/lib/widgets/notification_popup.dart` - CREATE
8. `NewsCalendar/pubspec.yaml` - UPDATE

---

## Expected Line Changes Summary

(Will be tracked in separate change documentation files)

---

## Implementation Order

1. Backend Model Updates (Event, User)
2. Backend Bug Fix (eventController)
3. Backend Notification Service & Controller
4. Frontend Model Updates
5. Frontend UI Enhancements (Create/Update screens)
6. Frontend Notification System
7. Integration & Testing

---

## Notes

- All changes will be documented in separate files with exact line numbers
- Each phase will have its own documentation file
- Testing should be done after each phase

