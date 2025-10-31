# Calendar Event System - Required Fixes

**Date:** Current Session  
**Status:** Analysis Complete - Fixes Documented

---

## Summary of Problems Found

### 🔴 **CRITICAL ISSUES (Must Fix)**

1. **Wrong API Endpoint** - Frontend posts to `$BASE_URL/` (root), but need to verify if this is correct
2. **pendingEvents Mechanism** - Complex offline sync interfering with normal flow (user wants commented out)

### 🟡 **MEDIUM ISSUES (Should Fix)**

3. **WebSocket Handler Missing Fields** - Doesn't save new Event model fields (eventMode, activityType, etc.)
4. **WebSocket Broadcast Incomplete** - Only sends basic fields, missing new Event model fields
5. **Dual Creation Paths** - Both HTTP POST and WebSocket, but not consistently used
6. **State Management** - Events not updating UI properly

---

## Detailed Analysis

### Problem 1: API Route Verification

**Current Frontend Code:**
```dart
// calendar_screen.dart line 202
Uri.parse('$BASE_URL/'),  // Posts to root: http://10.178.48.15:3001/
```

**Backend Route Setup:**
```javascript
// backend/index.js line 136
app.use(eventRoutes);  // Mounted at root (no /api/events prefix)

// backend/routes/eventRoute.js line 14
router.post('/', eventController.addEvent);  // Handles POST /
```

**Analysis:**
- `eventRoutes` is mounted at **root level** (unlike other routes which use `/api/` prefix)
- So `POST /` should work (matches frontend)
- BUT this is inconsistent with REST conventions
- Other routes use `/api/` prefix (equipment, irrigation, etc.)

**Questions:**
1. Is `POST /` actually working? (May conflict with other root routes)
2. Should route be changed to `/api/events/` for consistency?
3. Or is current setup correct and something else is wrong?

---

### Problem 2: pendingEvents Mechanism (To Comment Out)

**Code Locations in `calendar_screen.dart`:**

| Line | Code | Purpose |
|------|------|---------|
| 18 | `late final Box<eventModel.Event> _pendingOperationsBox;` | Declare Hive box |
| 163 | `_processPendingEvents();` | Call when online |
| 171-193 | `void _processPendingEvents() async { ... }` | Process pending events |
| 195-237 | `Future<void> _syncEventToRemote(...)` | Sync CREATE to backend |
| 239-278 | `Future<void> _syncUpdateToRemote(...)` | Sync UPDATE to backend |
| 280-316 | `Future<void> _syncDeleteToRemote(...)` | Sync DELETE to backend |
| 326 | `_pendingOperationsBox = Hive.box<...>('pending-operations');` | Initialize box |
| 400, 451, 455, 613, 617 | `_pendingOperationsBox.put(...)` | Store pending events |

**All this code should be commented out** per user request

---

### Problem 3: WebSocket Handler Missing Fields

**Backend:** `backend/index.js` lines 322-380

**Current Code (INCOMPLETE):**
```javascript
const newEvent = new Event({
    title: eventData.title,
    start_date: parseDate(eventData.start_date),
    end_date: parseDate(eventData.end_date),
    description: eventData.description,
    userId: userId,
    // ❌ Missing all new Event model fields:
    // - eventMode, startTime, endTime
    // - activityType, cropType, cropVariety
    // - fieldLocation, equipmentNeeded
    // - reminders, irrigationSettings, recurrence
});
```

**Should be:**
```javascript
const newEvent = new Event({
    ...eventData,  // Spread all fields from frontend
    userId: userId,
    // Override userId with authenticated user
});
```

---

### Problem 4: WebSocket Broadcast Missing Fields

**Backend:** `backend/index.js` lines 464-488, 491-514

**Current (INCOMPLETE):**
```javascript
data: events.map(event => ({
    id: event._id,
    title: event.title,
    start_date: formatDate(event.start_date),
    end_date: event.end_date ? formatDate(event.end_date) : null,
    description: event.description,
    userId: event.userId,
    createdBy: event.createdBy
}))
```

**Missing Fields:**
- `eventMode`, `startTime`, `endTime`
- `activityType`, `cropType`, `cropVariety`
- `fieldLocation`, `equipmentNeeded`
- `reminders`, `irrigationSettings`, `recurrence`
- `createdAt`, `updatedAt`

**Should include ALL fields** from Event model

---

### Problem 5: Frontend Not Using WebSocket createEvent

**Current Flow:**
```dart
// calendar_screen.dart _createEventViaWebSocket()
// Despite the name, it uses HTTP POST, not WebSocket!

if (isOnline) {
    _syncEventToRemote(eventToStore);  // HTTP POST
} else {
    _pendingOperationsBox.put(...);  // Store for later
}
// WebSocket channel exists but never used for creation!
```

**Backend Has WebSocket Handler Ready:**
```javascript
// backend/index.js line 280
case 'createEvent':
    await handleCreateEvent(data.event, ws, userId);
```

**Frontend Should Send:**
```dart
_channel?.sink.add(jsonEncode({
  'action': 'createEvent',
  'event': eventData,  // Full event data
}));
```

**But currently frontend never sends this!**

---

### Problem 6: Event State Not Updating

**Location:** `calendar_screen.dart` lines 508-526

**Current Logic Issues:**
1. Events stored in `_events` map with `eventId` as key
2. Frontend generates UUID for pending events
3. Backend generates MongoDB ObjectId
4. ID mismatch = events not linked properly
5. UI may not refresh when events received

**Issue:**
- When event created, stored locally with UUID
- Backend returns event with MongoDB _id
- These don't match, so frontend doesn't recognize as same event
- Event might appear twice (local + backend) or not update

---

## Fix Strategy

### Phase 1: Comment Out pendingEvents
- Comment all `_pendingOperationsBox` references
- Remove `_processPendingEvents()` calls
- Remove offline sync logic

### Phase 2: Fix Event Creation
**Option A - Use HTTP POST (Recommended for simplicity):**
```dart
// Direct POST to API
final response = await http.post(
  Uri.parse('$BASE_URL/api/events/'),  // Verify correct path first
  headers: { ... },
  body: jsonEncode(eventData),
);
// Wait for response
// Update local state
// Refresh calendar
```

**Option B - Use WebSocket (Real-time):**
```dart
// Send via WebSocket
_channel?.sink.add(jsonEncode({
  'action': 'createEvent',
  'event': eventData,
}));
// Wait for 'eventCreated' or 'events' message
// Update state from WebSocket response
```

### Phase 3: Fix Backend Broadcasting
- Include all Event model fields in WebSocket messages
- Ensure frontend receives complete event data

### Phase 4: Fix State Management
- Use backend-generated IDs
- Update `_events` map properly
- Ensure `setState()` triggers UI refresh

---

## Files That Will Be Changed

### Frontend:
1. **calendar_screen.dart**
   - Comment pendingEvents code (~150 lines)
   - Fix API endpoint or use WebSocket
   - Simplify event creation flow
   - Fix state updates

### Backend:
2. **backend/index.js**
   - Fix `handleCreateEvent()` to include all fields
   - Fix `broadcastEvents()` to send all fields
   - Fix `sendEventsToClient()` to send all fields

3. **backend/controllers/eventController.js**
   - Verify `addEvent()` handles all fields (already does via `...req.body`)

---

## Verification Checklist

Before implementing fixes, verify:
- [ ] What is exact mounted path for eventRoutes? (Root `/` or `/api/events/`?)
- [ ] Does `POST /` actually work or conflict with other routes?
- [ ] Should we change route to `/api/events/` for consistency?
- [ ] Test current event creation - does it save to database?
- [ ] Check backend logs - any errors when creating events?

---

**Status:** ✅ Analysis Complete - Awaiting User Approval to Proceed with Fixes

