# Irrigation Automation - Quick Summary

## Key Concepts

### 1. Integration Strategy
**Use Existing Event System** - Leverage calendar events with `activityType: 'Irrigation'` instead of creating separate system.

### 2. Three Main Components

#### A. **Schedule Storage** (Event Model Enhanced)
- Add `irrigationSettings` field to Event model
- Add `recurrence` field for repeating schedules
- Link events to irrigation devices

#### B. **Scheduler Service** (Background Job)
- Cron job runs every minute
- Checks for due irrigation schedules
- Executes pump control automatically
- Creates recurring event instances

#### C. **Automation Modes**
1. **Scheduled** - Time-based, always executes
2. **Sensor-Based** - Triggers only when moisture low
3. **Hybrid** - Scheduled but checks moisture first (skips if adequate)
4. **Manual** - User-triggered only

---

## Implementation Flow

```
User creates Irrigation Event (Calendar)
    ↓
Event stored with irrigationSettings
    ↓
Scheduler Service (runs every minute)
    ↓
Checks: Is irrigation due now?
    ↓
Checks: Automation mode?
    ├─→ Scheduled: Execute pump
    ├─→ Sensor-Based: Check moisture → Execute if needed
    └─→ Hybrid: Check moisture → Execute or Skip
    ↓
Turn ON pump → Wait duration → Turn OFF pump
    ↓
Log IrrigationEvent (triggeredBy: 'schedule')
    ↓
Update event (mark as executed)
    ↓
If recurring: Create next instance
```

---

## File Changes Summary

### Backend Files to Create
1. `backend/services/irrigationSchedulerService.js` - Main scheduler logic
2. `backend/services/irrigationEventService.js` - Event-to-irrigation bridge
3. `backend/services/smartIrrigationService.js` - Sensor-based automation

### Backend Files to Modify
1. `backend/models/event.js` - Add irrigationSettings & recurrence fields
2. `backend/controllers/irrigationController.js` - Add schedule management endpoints
3. `backend/routes/irrigationRoutes.js` - Add schedule routes
4. `backend/index.js` - Add cron job initialization

### Frontend Files to Create
1. `NewsCalendar/lib/screens/irrigation_schedule_screen.dart` - Schedule management UI

### Frontend Files to Modify
1. `NewsCalendar/lib/screens/irrigation_screen.dart` - Replace hardcoded "Next Scheduled"
2. `NewsCalendar/lib/models/events.dart` - Add irrigationSettings & recurrence fields
3. Event creation screen - Add irrigation-specific fields when activityType='Irrigation'

---

## API Endpoints Needed

### Schedule Management
- `POST /api/irrigation/schedule` - Create schedule
- `GET /api/irrigation/schedules` - List all schedules
- `GET /api/irrigation/schedule/next` - Get next scheduled time ⭐ (For UI)
- `PUT /api/irrigation/schedule/:id` - Update schedule
- `DELETE /api/irrigation/schedule/:id` - Delete schedule
- `POST /api/irrigation/schedule/:id/toggle` - Enable/disable

---

## Key Decision Points

### Q: Use Event Model or Separate Schedule Model?
**A: Event Model** - Reuse existing infrastructure, calendar integration, reminders built-in

### Q: How to handle recurring schedules?
**A: Generate Event Instances** - Create future event instances from recurring pattern

### Q: Where to run scheduler?
**A: Backend Cron Job** - Use `node-cron` or `setInterval` in main server process

### Q: How to handle sensor-based automation?
**A: Check Before Execution** - In hybrid/sensor mode, check moisture before executing

---

## Quick Start (Priority Order)

### Step 1: Database & Models (Critical Path)
- [ ] Add `irrigationSettings` to Event model
- [ ] Add `recurrence` to Event model
- [ ] Create database migration if needed

### Step 2: Basic Schedule Execution (Core Functionality)
- [ ] Create scheduler service
- [ ] Add cron job (check every minute)
- [ ] Basic execution logic (turn pump on/off)

### Step 3: Next Scheduled API (UI Requirement)
- [ ] Add `GET /api/irrigation/schedule/next` endpoint
- [ ] Update frontend to fetch and display
- [ ] Replace hardcoded text in irrigation_screen.dart

### Step 4: Schedule CRUD (User Management)
- [ ] Create schedule via API
- [ ] List schedules
- [ ] Update/delete schedules
- [ ] Frontend schedule management screen

### Step 5: Smart Automation (Enhancement)
- [ ] Sensor checking logic
- [ ] Automation mode decision
- [ ] Skip logic for hybrid mode

### Step 6: Recurring Schedules (Advanced)
- [ ] Recurrence pattern support
- [ ] Instance generation
- [ ] Calendar integration

---

## Current Status: irrigation_screen.dart (Lines 1181-1193)

**Current Code:**
```dart
Card(
  child: ListTile(
    leading: Icon(Icons.schedule, color: Colors.blue[700]),
    title: const Text('Next Scheduled Irrigation'),
    subtitle: const Text('Tomorrow, 6:00 AM'), // ❌ HARDCODED
    trailing: Icon(Icons.alarm, color: Colors.orange),
  ),
),
```

**After Implementation:**
```dart
Card(
  child: ListTile(
    leading: Icon(Icons.schedule, color: Colors.blue[700]),
    title: const Text('Next Scheduled Irrigation'),
    subtitle: Text(_nextScheduledTime ?? 'No schedule set'), // ✅ Dynamic
    trailing: Icon(Icons.alarm, color: Colors.orange),
  ),
),
```

**Required:**
1. Add state variable: `String? _nextScheduledTime;`
2. Add method: `_fetchNextScheduledIrrigation()`
3. Call method in `initState()` or after device registration
4. Display result in subtitle

---

## Integration with Calendar

### User Flow
1. User opens Calendar
2. Creates new event
3. Sets `activityType: 'Irrigation'`
4. System shows irrigation-specific fields:
   - Device selection
   - Duration
   - Automation mode
   - Recurrence options
5. Event saved → Schedule created automatically
6. Scheduler executes at scheduled time
7. Irrigation appears in calendar as executed event

---

## Benefits of This Approach

✅ **Reuses Existing Code** - Event system already built  
✅ **Familiar UX** - Users know how to use calendar  
✅ **Reminders Included** - Event reminder system works automatically  
✅ **Calendar Visibility** - Irrigation shows in calendar view  
✅ **Flexible** - Can support one-time and recurring  
✅ **Integrated** - Works with existing device/pump system  

---

## Potential Challenges & Solutions

| Challenge | Solution |
|-----------|----------|
| Event model not designed for schedules | Add irrigation-specific fields, keep backward compatible |
| Cron job reliability | Use PM2, add health checks, logging |
| Sensor data unavailable | Fallback to time-based, alert user |
| Performance with many schedules | Index database, limit instance generation |
| Recurring instance management | Generate in batches, cleanup old instances |

---

## Estimated Timeline

- **Phase 1 (Foundation)**: 3-5 days
- **Phase 2 (Schedule Management)**: 3-4 days  
- **Phase 3 (Automation)**: 2-3 days
- **Phase 4 (Recurring)**: 3-4 days
- **Phase 5 (Testing/Polish)**: 2-3 days

**Total: ~2-3 weeks** for complete implementation

---

## Questions to Answer Before Starting

1. Should schedules be separate from calendar events, or integrated?
   → **Recommendation: Integrated (this plan)**

2. How many recurring patterns needed initially?
   → **Recommendation: Start with daily/weekly, add more later**

3. Priority: Basic scheduling or smart automation first?
   → **Recommendation: Basic scheduling first (MVP), then automation**

4. How to handle timezone?
   → **Use device/user timezone, store in UTC in DB**

---

**See `00_IRRIGATION_AUTOMATION_PLAN.md` for detailed implementation guide.**

