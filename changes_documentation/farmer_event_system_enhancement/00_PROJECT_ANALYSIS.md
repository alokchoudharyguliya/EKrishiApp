# Project Analysis: Farmer Event System Enhancement

**Date:** Current Session
**Objective:** Transform generic event management system into farmer-specific event scheduling system with reminders and notifications

---

## Executive Summary

The current event/calendar system is a generic event management system that needs to be enhanced to serve farmers specifically. The system currently has basic CRUD operations but lacks:
1. Farmer-specific context and fields
2. Event reminder/timing system
3. Popup notifications for events
4. Integration with farmer workflows

---

## 1. Current System Architecture

### 1.1 Backend Structure

#### Event Model (`backend/models/event.js`)
- **Fields:**
  - `title` (String, required, max 100 chars)
  - `userId` (ObjectId, ref: User, required)
  - `start_date` (Date, required)
  - `end_date` (Date, optional)
  - `description` (String, optional)
  - `isDeleted` (Boolean, default: false)
  - `changeType` (String, default: null)
  - `lastUpdated` (Date, default: Date.now)
  - `isSynced` (Boolean, default: false)
  - `createdAt`, `updatedAt` (timestamps)

- **Issues Found:**
  - No farmer-specific fields (crop type, farming activity type, etc.)
  - No reminder/notification fields
  - No event type/category for farming activities
  - Generic structure not tailored for agricultural schedules

#### Event Controller (`backend/controllers/eventController.js`)
- **Endpoints:**
  - `getEvents()` - GET `/get-events` - Returns all events for a user
  - `getEventByEventId()` - GET `/get-event/:eventId` - Get single event
  - `deleteEvent()` - DELETE `/:eventId` - Delete event
  - `addEvents()` - POST `/add-events` - Bulk add events
  - `addEvent()` - POST `/` - Add single event
  - `updateEvent()` - PUT `/:id` - Update event

- **Issues Found:**
  - Line 16: Typo - uses `event` (lowercase) instead of `Event` (model)
  - No validation for farmer-specific data
  - No reminder/notification handling
  - Generic error messages

#### Event Routes (`backend/routes/eventRoute.js`)
- Routes are properly protected with `authMiddleware`
- All CRUD operations are available

#### Remainders Model (`backend/models/remainders.js`)
- **Existing but unused model:**
  - Has reminder structure with `reminderDate`, `priority`, `category`, `relatedEventId`
  - Not integrated with Event model
  - No controller or routes for reminders
  - Could be leveraged or merged with Event model

#### WebSocket Integration (`backend/index.js`)
- Real-time event updates via WebSocket
- Handles `eventCreated`, `eventUpdated`, `eventDeleted` events
- Broadcasts to all connected clients
- Lines 320-459: Event handlers for WebSocket actions

### 1.2 Frontend Structure

#### Event Model (`NewsCalendar/lib/models/events.dart`)
- Hive-based local storage model
- Fields match backend structure
- No farmer-specific fields
- No reminder/notification fields

#### Calendar Screen (`NewsCalendar/lib/screens/calendar_screen.dart`)
- Uses `table_calendar` package
- Displays events on calendar
- Has overlay for day details (lines 554-825)
- Edit/Delete functionality exists (lines 654-728)
- Create event functionality (lines 315-370)
- WebSocket integration for real-time updates
- Offline sync support with Hive

- **Issues Found:**
  - No reminder/notification UI
  - No time selection in create/update screens
  - No farmer-specific fields in forms
  - Generic event display

#### Create Event Screen (`NewsCalendar/lib/screens/create_event_screen.dart`)
- Simple form with title and description
- No date/time picker visible (dates passed from calendar)
- No reminder options
- No farmer-specific fields

#### Update Event Screen (`NewsCalendar/lib/screens/update_event_screen.dart`)
- Similar to create screen
- Only title and description editable
- No date/time editing
- No reminder management

### 1.3 User Model Analysis

#### Backend User (`backend/models/user.js`)
- Has `role` field with enum: `['student', 'faculty', 'other', 'admin']`
- **Issue:** No `'farmer'` role option
- Generic user model not tailored for farmers

#### Frontend User (`NewsCalendar/lib/models/user.dart`)
- Matches backend structure
- Same role enum limitations

---

## 2. Identified Gaps and Requirements

### 2.1 Missing Features
1. **Farmer-Specific Event Fields:**
   - Event type (Planting, Harvesting, Irrigation, Fertilization, Pest Control, etc.)
   - Crop name/variety
   - Field/location reference
   - Weather dependency indicator
   - Equipment needed
   - Estimated duration

2. **Reminder System:**
   - Reminder timing options (X days/hours before event)
   - Multiple reminder times per event
   - Notification scheduling
   - Reminder preferences

3. **Notification System:**
   - Popup notifications (in-app)
   - Push notifications (platform-level)
   - Notification scheduling service
   - Notification history

4. **Time Management:**
   - Event start time (currently only date)
   - Event end time
   - Duration calculation
   - Time-based reminders

### 2.2 Technical Improvements Needed
1. **Backend:**
   - Add farmer-specific fields to Event model
   - Create reminder/notification scheduling system
   - Add notification endpoint/service
   - Integrate or merge Remainder model with Event
   - Add farmer role to User model

2. **Frontend:**
   - Add time pickers to create/update screens
   - Add reminder configuration UI
   - Implement notification service
   - Add farmer-specific form fields
   - Create notification display/popup system
   - Add notification permissions handling

3. **Notification Packages:**
   - Need to add: `flutter_local_notifications` for local notifications
   - Platform-specific notification setup (Android/iOS)

---

## 3. Current Data Flow

### 3.1 Event Creation Flow
1. User selects date on calendar
2. Overlay shows day details
3. User clicks "Add Event" button
4. `CreateEventScreen` opens (title, description only)
5. Event saved locally in Hive
6. If online, synced to backend via POST `/`
7. Backend saves to MongoDB
8. WebSocket broadcasts to all clients
9. Calendar refreshes

### 3.2 Event Update Flow
1. User clicks edit icon on event
2. `UpdateEventScreen` opens
3. Updates title/description
4. Saved locally, synced to backend via PUT `/:id`
5. WebSocket broadcasts update

### 3.3 Event Delete Flow
1. User clicks delete icon
2. Confirmation dialog
3. Deleted locally, synced via DELETE `/:eventId`
4. WebSocket broadcasts deletion

---

## 4. Proposed Changes Structure

### Phase 1: Backend Enhancements
1. Update Event model with farmer-specific fields
2. Add reminder fields to Event model
3. Create Notification service/controller
4. Update User model to include 'farmer' role
5. Fix existing bugs (line 16 typo in eventController)

### Phase 2: Frontend Enhancements
1. Update Event model (Dart) with new fields
2. Add time pickers to create/update screens
3. Add reminder configuration UI
4. Implement notification service
5. Add farmer-specific form fields
6. Create notification popup widget

### Phase 3: Integration
1. Connect reminder system with notifications
2. Schedule notifications on event creation/update
3. Test end-to-end flow
4. Handle edge cases (deleted events, updated reminders)

---

## 5. Files That Will Be Modified

### Backend:
1. `backend/models/event.js` - Add farmer fields, reminder fields
2. `backend/models/user.js` - Add 'farmer' role
3. `backend/controllers/eventController.js` - Fix typo, add validation, handle reminders
4. `backend/routes/eventRoute.js` - Add notification routes (if needed)
5. `backend/index.js` - Add notification broadcasting (if needed)
6. `backend/controllers/notificationController.js` - NEW FILE
7. `backend/services/notificationService.js` - NEW FILE

### Frontend:
1. `NewsCalendar/lib/models/events.dart` - Add new fields
2. `NewsCalendar/lib/models/events.g.dart` - Regenerate with build_runner
3. `NewsCalendar/lib/screens/create_event_screen.dart` - Add time pickers, reminder UI, farmer fields
4. `NewsCalendar/lib/screens/update_event_screen.dart` - Add time pickers, reminder UI, farmer fields
5. `NewsCalendar/lib/screens/calendar_screen.dart` - Add notification handling
6. `NewsCalendar/lib/services/notification_service.dart` - NEW FILE
7. `NewsCalendar/lib/widgets/notification_popup.dart` - NEW FILE
8. `NewsCalendar/pubspec.yaml` - Add flutter_local_notifications dependency

---

## 6. Dependencies to Add

### Backend:
- None (existing packages sufficient)

### Frontend:
- `flutter_local_notifications: ^17.2.3` - For local notifications
- `timezone: ^0.9.2` - For timezone-aware scheduling

---

## 7. Questions for User Before Implementation

1. **Farmer-Specific Fields:**
   - Which fields are most important? (crop type, activity type, location, etc.)
   - Should events be categorized? (Planting, Harvesting, Maintenance, etc.)
   - Do we need to link events to specific crops/fields?

2. **Reminder System:**
   - What reminder intervals are needed? (1 day before, 1 hour before, etc.)
   - Should users set custom reminder times?
   - How many reminders per event? (one or multiple)

3. **Notifications:**
   - Should notifications work when app is closed?
   - Do we need push notifications or just in-app popups?
   - Should notifications be dismissible?

4. **Time Management:**
   - Should events have start/end times or just dates?
   - Do we need all-day vs timed events?

---

## 8. Current Bugs Found

1. **`backend/controllers/eventController.js` Line 16:**
   - Uses `event.find()` instead of `Event.find()`
   - Will cause runtime error

2. **Event Model date handling:**
   - `addDays` is used in addEvent (line 155-156) but may cause confusion
   - Dates are being manipulated without clear reason

---

## Next Steps

1. Wait for user confirmation on proposed changes
2. Get answers to questions above
3. Create detailed implementation plan
4. Implement changes phase by phase
5. Document each change in separate files with line numbers

