# Calendar Event System - Problem Analysis

**Date:** Current Session  
**Objective:** Analyze why events are not getting added to calendar  
**Focus:** Identify issues, comment pendingEvents mechanism, simplify to WebSocket-based

---

## Executive Summary

**Main Problem:** Events are being created but not appearing on calendar due to multiple issues:
1. **Wrong API endpoint** - Calendar uses `$BASE_URL/` instead of correct route
2. **pendingEvents mechanism** - Complex offline sync logic interfering with normal flow
3. **WebSocket not receiving events properly** - Events created but not broadcast/fetched correctly
4. **Dual creation paths** - Both HTTP POST and WebSocket createEvent, causing confusion
5. **State management issues** - Events stored in Hive but not properly updating UI state

---

## Current Architecture Analysis

### Frontend Flow (Calendar Screen)

#### Event Creation Flow (Current - PROBLEMATIC):
```
User creates event in CreateEventScreen
    ↓
Calls createCallback (calendar_screen.dart line 296)
    ↓
_createEventViaWebSocket() called (line 420)
    ↓
Creates Event object locally
    ↓
Stores in Hive _eventsBox (line 436)
    ↓
IF ONLINE:
    → Calls _syncEventToRemote() (line 448)
    → HTTP POST to $BASE_URL/ (WRONG ENDPOINT - line 202)
    → Should be $BASE_URL/api/events/ or use WebSocket
ELSE OFFLINE:
    → Stores in _pendingOperationsBox (line 455)
    → Will sync later when online (line 163, 171)
```

#### WebSocket Flow:
```
WebSocket connects (line 477-502)
    ↓
Receives "events" type message (line 508)
    ↓
Updates _events map (line 512-526)
    ↓
Calendar should refresh
```

---

## Problems Identified

### 1. **WRONG API ENDPOINT** ❌ CRITICAL
**Location:** `calendar_screen.dart` line 202

**Current Code:**
```dart
final response = await http.post(
  Uri.parse('$BASE_URL/'),  // ❌ WRONG - This is root path!
```

**Problem:**
- Posting to `http://10.178.48.15:3001/` (root path)
- Should be: `http://10.178.48.15:3001/api/events/` or `/api/events`

**Expected Route (from eventRoute.js):**
- `POST /api/events/` → `eventController.addEvent`
- OR use WebSocket `createEvent` action

**Impact:** Events likely failing to save to backend, or saving to wrong endpoint

---

### 2. **pendingEvents Mechanism Complexity** ❌ NEEDS TO BE COMMENTED
**Locations:**
- `calendar_screen.dart` lines 18, 171-193, 195-237, 239-278, 280-316, 324-327, 400, 451, 455, 613, 617
- Uses `_pendingOperationsBox` Hive box
- `_processPendingEvents()` function
- `_syncEventToRemote()`, `_syncUpdateToRemote()`, `_syncDeleteToRemote()`

**Current Logic:**
- Events stored in `pending-operations` Hive box when offline
- Synced when connectivity restored
- Complex state management with `changeType`, `isSynced` flags

**Problem:**
- Adds unnecessary complexity for simple event creation
- Can cause events to get stuck in pending state
- Makes debugging difficult
- User requested to comment this out

**Code to Comment:**
- All `_pendingOperationsBox` references
- `_processPendingEvents()` function
- `_syncEventToRemote()` → Replace with direct API call
- Offline handling logic in `_createEventViaWebSocket`, `_updateEventViaWebSocket`, `_deleteEventViaWebSocket`

---

### 3. **Dual Creation Paths** ❌ CONFUSING
**Paths:**
1. **HTTP POST** → `_syncEventToRemote()` → `POST $BASE_URL/`
2. **WebSocket** → `handleCreateEvent()` in backend → `POST /api/events/` via eventController

**Problem:**
- Frontend uses HTTP POST with wrong endpoint
- Backend has WebSocket handler that uses correct Event model
- Two different code paths doing same thing differently
- Frontend never uses WebSocket `createEvent` action

**Recommendation:**
- Use WebSocket `createEvent` action for consistency
- OR use HTTP POST to correct endpoint
- Remove duplicate path

---

### 4. **WebSocket Event Broadcasting** ⚠️ POTENTIAL ISSUE
**Backend:** `backend/index.js` lines 358, 409, 445

**Current Flow:**
```javascript
// In handleCreateEvent (line 322)
await newEvent.save(); // ✅ Saves to DB
await broadcastEvents(); // ✅ Broadcasts to all clients
ws.send(JSON.stringify({ type: 'eventCreated' })); // ✅ Sends to creator
```

**Problem:**
- `broadcastEvents()` sends all events to all clients (line 464-488)
- But `sendEventsToClient()` only sends basic fields (missing new Event model fields)
- Frontend expects full event data with all fields (activityType, eventMode, etc.)

**Missing Fields in Broadcast:**
```javascript
// Line 469-477 - Only sends:
- id, title, start_date, end_date, description, userId, createdBy
// Missing:
- eventMode, startTime, endTime
- activityType, cropType, cropVariety
- fieldLocation, equipmentNeeded
- reminders, irrigationSettings, recurrence
```

---

### 5. **Frontend State Not Updating** ❌ UI ISSUE
**Location:** `calendar_screen.dart` lines 508-526

**Current Logic:**
```dart
if (responseData["type"] == "events") {
  // Updates _events map
  // But only adds NEW events, doesn't replace existing
  // Uses eventId as key, but might have duplicates
}
```

**Problems:**
- Events map uses eventId as key, but multiple events could have same ID (pending vs synced)
- State updates might not trigger UI refresh
- Events stored in Hive but not always synced with `_events` map

---

### 6. **Date Format Mismatch** ⚠️ POTENTIAL ISSUE
**Frontend:** `calendar_screen.dart` line 430
```dart
startDate: DateFormat("dd-MM-yyyy").parse(eventData['start_date']),
```

**Backend:** `eventController.js` line 148-149
```javascript
const startDate = new Date(start_date); // Expects ISO or parseable format
```

**Backend WebSocket:** `backend/index.js` line 327-345
```javascript
// Tries to parse "dd-MM-yyyy" format (line 332)
// But may fail if ISO format sent
```

**Problem:**
- Frontend sends `dd-MM-yyyy` format
- Backend HTTP endpoint expects ISO or different format
- WebSocket handler has custom parser for `dd-MM-yyyy`
- Inconsistency can cause parsing errors

---

### 7. **Event Model Mismatch** ⚠️ DATA ISSUE
**Frontend Creates (line 426-434):**
```dart
eventModel.Event.create(
  id: _uuid.v4(),  // Client-generated ID
  title: eventData['title'],
  // ... basic fields only
  changeType: "CREATE",  // Frontend-specific field
)
```

**Backend Saves:**
- Uses Event model with all new fields (irrigationSettings, recurrence, etc.)
- Generates MongoDB _id
- Frontend ID might not match backend _id

**Problem:**
- Frontend creates event with client UUID
- Backend saves with MongoDB ObjectId
- ID mismatch prevents proper linking
- Frontend might not recognize backend-sent event as same event

---

## PendingEvents Mechanism - Code Locations

### Files to Comment:
1. **calendar_screen.dart**
   - Line 18: `late final Box<eventModel.Event> _pendingOperationsBox;`
   - Lines 171-193: `_processPendingEvents()` function
   - Lines 195-237: `_syncEventToRemote()` function
   - Lines 239-278: `_syncUpdateToRemote()` function
   - Lines 280-316: `_syncDeleteToRemote()` function
   - Line 326: `_pendingOperationsBox` initialization
   - Lines 163, 400, 451, 455, 613, 617: All references to `_pendingOperationsBox`

---

## Recommended Fixes

### Fix 1: Use Correct API Endpoint
**Change:** `calendar_screen.dart` line 202
```dart
// OLD:
Uri.parse('$BASE_URL/'),

// NEW:
Uri.parse('$BASE_URL/api/events/'),  // OR use WebSocket
```

### Fix 2: Simplify to Direct API Call or WebSocket
**Option A - Use HTTP POST (Simpler):**
```dart
// Direct POST to API endpoint
final response = await http.post(
  Uri.parse('$BASE_URL/api/events/'),
  headers: { ... },
  body: jsonEncode(eventData),
);
```

**Option B - Use WebSocket (More Real-time):**
```dart
// Send via WebSocket
_channel?.sink.add(jsonEncode({
  'action': 'createEvent',
  'event': eventData,
}));
```

### Fix 3: Comment Out PendingEvents Logic
- Comment all `_pendingOperationsBox` code
- Remove offline handling
- Always require online connection for event creation
- Simplify state management

### Fix 4: Fix WebSocket Broadcasting
**Backend:** `backend/index.js` lines 469-477, 496-504
- Include ALL event fields in broadcast
- Match Event model structure from backend

### Fix 5: Fix Event State Management
- Use backend-generated IDs
- Update `_events` map when receiving WebSocket messages
- Ensure UI refreshes after event creation

---

## Simplified Flow (After Fixes)

### Event Creation Flow (Proposed):
```
User creates event in CreateEventScreen
    ↓
Calls createCallback with event data
    ↓
_createEventViaWebSocket() OR direct HTTP POST
    ↓
IF USING HTTP:
    → POST /api/events/ with full event data
    → Wait for response
    → Update local state
    → Refresh calendar
    ↓
IF USING WEBSOCKET:
    → Send { action: 'createEvent', event: eventData }
    → Wait for 'eventCreated' response
    → OR wait for 'events' broadcast
    → Update local state
    ↓
Backend broadcasts to all clients
    ↓
Frontend receives 'events' message
    ↓
Updates _events map
    ↓
Calendar UI refreshes automatically
```

---

## Files That Need Changes

### Frontend Files:
1. **NewsCalendar/lib/screens/calendar_screen.dart**
   - Fix API endpoint (line 202)
   - Comment pendingEvents code (multiple locations)
   - Simplify event creation flow
   - Fix WebSocket message handling
   - Remove offline sync logic

2. **NewsCalendar/lib/screens/create_event_screen.dart**
   - Verify callback data format
   - Ensure all fields included

### Backend Files:
1. **backend/index.js**
   - Fix `broadcastEvents()` to include all event fields
   - Fix `sendEventsToClient()` to include all event fields
   - Verify `handleCreateEvent()` handles all new fields

2. **backend/controllers/eventController.js**
   - Verify `addEvent()` handles all new Event model fields
   - Check date parsing

---

## Specific Code Issues

### Issue 1: Wrong Endpoint in calendar_screen.dart
**Line 202:**
```dart
Uri.parse('$BASE_URL/'),  // ❌ Should be '/api/events/'
```

**Fix:**
```dart
Uri.parse('$BASE_URL/api/events/'),  // ✅ Correct endpoint
```

### Issue 2: WebSocket Handler Missing Fields
**Backend index.js line 347-354:**
```javascript
const newEvent = new Event({
    title: eventData.title,
    start_date: parseDate(eventData.start_date),
    end_date: parseDate(eventData.end_date),
    description: eventData.description,
    userId: userId,
    // ❌ Missing: eventMode, startTime, endTime, activityType, etc.
});
```

**Fix:** Include all fields from eventData

### Issue 3: Broadcast Missing Fields
**Backend index.js line 469-477:**
```javascript
data: events.map(event => ({
    id: event._id,
    title: event.title,
    start_date: formatDate(event.start_date),
    end_date: event.end_date ? formatDate(event.end_date) : null,
    description: event.description,
    userId: event.userId,
    // ❌ Missing many fields
}))
```

**Fix:** Include all Event model fields

### Issue 4: Frontend Not Updating State
**calendar_screen.dart line 508-526:**
- Only adds new events, doesn't replace existing
- Key collision issues
- State not triggering rebuild

---

## Summary of Problems

| # | Problem | Severity | Location | Fix Priority |
|---|---------|----------|----------|--------------|
| 1 | Wrong API endpoint (`$BASE_URL/` instead of `/api/events/`) | ❌ CRITICAL | calendar_screen.dart:202 | **HIGHEST** |
| 2 | pendingEvents mechanism complexity | ❌ HIGH | Multiple locations | **HIGH** (Comment out) |
| 3 | Dual creation paths (HTTP vs WebSocket) | ⚠️ MEDIUM | Frontend & Backend | **MEDIUM** |
| 4 | WebSocket broadcast missing fields | ⚠️ MEDIUM | backend/index.js:469-477 | **HIGH** |
| 5 | Frontend state not updating | ⚠️ MEDIUM | calendar_screen.dart:508-526 | **MEDIUM** |
| 6 | Date format inconsistency | ⚠️ LOW | Multiple locations | **LOW** |
| 7 | Event ID mismatch | ⚠️ MEDIUM | Frontend vs Backend | **MEDIUM** |

---

## Next Steps (After Analysis Approval)

1. **Comment out pendingEvents code** - Remove offline sync complexity
2. **Fix API endpoint** - Change to correct route
3. **Simplify event creation** - Use either HTTP POST or WebSocket (not both)
4. **Fix WebSocket broadcasting** - Include all event fields
5. **Fix state management** - Ensure events appear in UI
6. **Test event creation flow** - Verify end-to-end

---

**Status:** ✅ Analysis Complete - Awaiting Approval to Proceed with Fixes

