# Calendar Event Issues - Summary Report

**Date:** Current Session  
**Analysis Status:** ✅ Complete

---

## Critical Issues Found

### 🔴 **ISSUE #1: Wrong API Endpoint** (CRITICAL)
**File:** `NewsCalendar/lib/screens/calendar_screen.dart`  
**Line:** 202  
**Current:**
```dart
Uri.parse('$BASE_URL/'),  // Posts to root path
```

**Problem:**
- Posting to `http://10.178.48.15:3001/` (root - no route handler)
- Should be: `http://10.178.48.15:3001/api/events/`

**Evidence:**
- Backend route: `backend/routes/eventRoute.js` line 14: `router.post('/', eventController.addEvent)`
- Mounted at: `backend/index.js` line 136: `app.use(eventRoutes);`
- But `eventRoutes` has no `/api/events` prefix - it's mounted at root!

**Actual Route:** 
- Based on code: `POST /` (if eventRoutes mounted at root)
- OR `POST /api/events/` (if mounted at `/api/events`)

**Need to verify:** How is `eventRoutes` actually mounted in index.js?

---

### 🔴 **ISSUE #2: pendingEvents Mechanism** (HIGH - Comment Out)
**Files:** `calendar_screen.dart`  
**Locations:** 
- Line 18: `_pendingOperationsBox` declaration
- Lines 171-193: `_processPendingEvents()` function
- Lines 195-237: `_syncEventToRemote()` - uses HTTP POST
- Lines 239-278: `_syncUpdateToRemote()`
- Lines 280-316: `_syncDeleteToRemote()`
- Line 326: `_pendingOperationsBox` initialization
- Lines 163, 400, 451, 455, 613, 617: All `_pendingOperationsBox` usage

**Problem:**
- Complex offline sync mechanism
- Events stored in Hive `pending-operations` box
- Synced when connectivity restored
- Causes state confusion and debugging issues
- **User requested to comment this out**

**Action Required:** Comment all pendingEvents-related code

---

### 🟡 **ISSUE #3: WebSocket Handler Missing New Event Fields** (MEDIUM)
**File:** `backend/index.js`  
**Lines:** 322-380 (`handleCreateEvent`)

**Problem:**
```javascript
const newEvent = new Event({
    title: eventData.title,
    start_date: parseDate(eventData.start_date),
    end_date: parseDate(eventData.end_date),
    description: eventData.description,
    userId: userId,
    // ❌ Missing: eventMode, startTime, endTime, activityType, 
    // cropType, cropVariety, fieldLocation, equipmentNeeded,
    // reminders, irrigationSettings, recurrence
});
```

**Impact:** When events created via WebSocket, new Event model fields are lost

---

### 🟡 **ISSUE #4: WebSocket Broadcast Missing Fields** (MEDIUM)
**File:** `backend/index.js`  
**Lines:** 464-488 (`broadcastEvents`), 491-514 (`sendEventsToClient`)

**Problem:**
```javascript
data: events.map(event => ({
    id: event._id,
    title: event.title,
    start_date: formatDate(event.start_date),
    end_date: event.end_date ? formatDate(event.end_date) : null,
    description: event.description,
    userId: event.userId,
    createdBy: event.createdBy
    // ❌ Missing all new fields from Event model
}))
```

**Impact:** Frontend receives incomplete event data, missing new fields

---

### 🟡 **ISSUE #5: Frontend Never Uses WebSocket createEvent** (MEDIUM)
**File:** `calendar_screen.dart`  
**Lines:** 420-475 (`_createEventViaWebSocket`)

**Problem:**
- Function name suggests WebSocket usage, but actually uses HTTP POST
- WebSocket channel exists but never sends `createEvent` action
- Backend has WebSocket handler ready but frontend doesn't use it

**Current Flow:**
1. Creates local Event object
2. Stores in Hive
3. Calls `_syncEventToRemote()` which does HTTP POST
4. Never sends WebSocket message

**Backend Expects:**
```javascript
// backend/index.js line 280
case 'createEvent':
    await handleCreateEvent(data.event, ws, userId);
```

**Frontend Should Send:**
```dart
_channel?.sink.add(jsonEncode({
  'action': 'createEvent',
  'event': eventData,
}));
```

---

### 🟡 **ISSUE #6: Event State Management** (MEDIUM)
**File:** `calendar_screen.dart`  
**Lines:** 508-526 (`_processWebSocketMessage`)

**Problem:**
- Events stored in `_events` map with eventId as key
- But pending events have client-generated UUID
- Backend events have MongoDB ObjectId
- ID mismatch prevents proper updates
- State might not trigger UI refresh

---

### 🟢 **ISSUE #7: Date Format Handling** (LOW)
**Problem:** 
- Frontend sends `dd-MM-yyyy` format
- Backend HTTP expects ISO format
- Backend WebSocket has custom parser for `dd-MM-yyyy`
- Inconsistency but likely working

---

## Route Verification Needed

**Question:** What is the actual mounted path for eventRoutes?

**From `backend/index.js` line 136:**
```javascript
app.use(eventRoutes);  // No path prefix shown
```

**But other routes have prefixes:**
```javascript
app.use('/api/equipment', equipmentRoutes);  // Line 133
app.use('/api/irrigation', irrigationRoutes);  // Line 139
```

**Need to check:** Is eventRoutes mounted at root (`/`) or at `/api/events/`?

**If mounted at root:**
- `POST /` → `eventController.addEvent` ✅ (matches current frontend)
- But conflicts with other root routes

**If mounted at `/api/events/`:**
- `POST /api/events/` → `eventController.addEvent` ✅
- Frontend needs to update endpoint

---

## Fixes Required (Priority Order)

### Fix 1: Determine Correct Endpoint
- Check how `eventRoutes` is mounted
- Update frontend to use correct path
- **Priority: CRITICAL**

### Fix 2: Comment Out pendingEvents
- Comment all `_pendingOperationsBox` code
- Remove offline sync logic
- Simplify to online-only event creation
- **Priority: HIGH**

### Fix 3: Use WebSocket OR HTTP (Not Both)
- Choose one approach:
  - **Option A:** Use HTTP POST to `/api/events/` (simpler)
  - **Option B:** Use WebSocket `createEvent` action (real-time)
- Remove duplicate path
- **Priority: MEDIUM**

### Fix 4: Fix WebSocket Broadcasting
- Include all Event model fields in broadcast
- Update `broadcastEvents()` and `sendEventsToClient()`
- **Priority: HIGH**

### Fix 5: Fix State Management
- Use backend-generated IDs
- Update event map properly
- Ensure UI refresh
- **Priority: MEDIUM**

---

## Specific Code Locations for Fixes

### Frontend (`calendar_screen.dart`)

**Line 18:** Comment pendingOperationsBox
```dart
// late final Box<eventModel.Event> _pendingOperationsBox;
```

**Line 163:** Comment pendingEvents processing
```dart
// _processPendingEvents();
```

**Lines 171-193:** Comment entire function
```dart
// void _processPendingEvents() async { ... }
```

**Lines 195-237:** Replace with simplified version
```dart
// Comment _syncEventToRemote()
// Replace with direct API call or WebSocket
```

**Line 202:** Fix endpoint
```dart
Uri.parse('$BASE_URL/api/events/'),  // Verify correct path
```

**Lines 420-475:** Simplify `_createEventViaWebSocket`
- Remove pendingEvents logic
- Use either HTTP POST or WebSocket (not both)

---

### Backend (`backend/index.js`)

**Lines 347-354:** Include all event fields
```javascript
const newEvent = new Event({
    ...eventData,  // Spread all fields
    userId: userId,
    // Ensure all fields included
});
```

**Lines 469-477, 496-504:** Include all fields in broadcast
```javascript
data: events.map(event => ({
    ...event.toObject(),  // Include all fields
    id: event._id,
    // Or explicitly list all needed fields
}))
```

---

## Recommended Approach

### Simplified Flow (After Fixes):

1. **User creates event** → Form submission
2. **Frontend sends** → HTTP POST to `/api/events/` OR WebSocket `createEvent`
3. **Backend saves** → Event to database with all fields
4. **Backend broadcasts** → All events to all WebSocket clients
5. **Frontend receives** → WebSocket `events` message
6. **Frontend updates** → `_events` map and UI refreshes

**No offline sync, no pendingEvents, simple and straightforward**

---

## Testing After Fixes

1. ✅ Create event → Should appear immediately on calendar
2. ✅ Check backend database → Event should be saved
3. ✅ Check WebSocket messages → Should broadcast to all clients
4. ✅ Verify all event fields → Should be preserved
5. ✅ Test with multiple clients → Should sync in real-time

---

**Status:** Analysis complete - Ready for implementation fixes

