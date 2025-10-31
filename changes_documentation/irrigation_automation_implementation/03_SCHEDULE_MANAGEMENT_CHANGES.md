# Schedule Management & Recurring Schedules - Implementation Changes

**Date:** Current Session  
**Status:** ✅ Complete  
**Focus:** Schedule CRUD operations + Recurring schedule support

---

## Summary

Added complete schedule management functionality including:
- Create, Read, Update, Delete schedules via API
- Frontend UI for managing schedules
- Recurring schedule support (daily, weekly, monthly, custom)
- Enable/disable schedules
- Schedule list view with details

---

## Backend Changes

### 1. `backend/controllers/irrigationController.js`
**Lines Added:** 752-1245 (494 lines)

**New Functions:**
1. `exports.createIrrigationSchedule` - POST `/api/irrigation/schedule`
   - Creates new irrigation schedule (Event with irrigationSettings)
   - Supports recurring schedules
   - Generates future instances for recurring patterns

2. `exports.getIrrigationSchedules` - GET `/api/irrigation/schedules?deviceId=xxx`
   - Returns all schedules for a device
   - Includes schedule details, recurrence info, execution status

3. `exports.updateIrrigationSchedule` - PUT `/api/irrigation/schedule/:id`
   - Updates schedule properties
   - Only allows updates if not yet executed
   - Regenerates recurring instances if recurrence changed

4. `exports.deleteIrrigationSchedule` - DELETE `/api/irrigation/schedule/:id`
   - Soft deletes schedule (sets isDeleted=true)

5. `exports.toggleSchedule` - POST `/api/irrigation/schedule/:id/toggle`
   - Enables/disables schedule without deleting

6. `generateRecurringInstances(masterEvent)` - Helper function
   - Generates future event instances from recurring pattern
   - Supports: daily, weekly, monthly, custom intervals
   - Limits generation to next 90 days for performance

7. `getNextOccurrence(currentDate, pattern, interval, daysOfWeek, dayOfMonth)` - Helper function
   - Calculates next occurrence date based on pattern

---

### 2. `backend/routes/irrigationRoutes.js`
**Lines Modified:** 28-34

**New Routes:**
```javascript
router.post('/schedule', irrigationController.createIrrigationSchedule);
router.get('/schedules', irrigationController.getIrrigationSchedules);
router.put('/schedule/:id', irrigationController.updateIrrigationSchedule);
router.delete('/schedule/:id', irrigationController.deleteIrrigationSchedule);
router.post('/schedule/:id/toggle', irrigationController.toggleSchedule);
```

---

### 3. `backend/services/irrigationSchedulerService.js`
**Lines Modified:** ~150 (added comment about recurring instance generation)

**Note:** Recurring instance generation happens during schedule creation/update. The scheduler service executes each instance when due.

---

## Frontend Changes

### 4. `NewsCalendar/lib/screens/irrigation_schedule_screen.dart` (NEW FILE)
**Total Lines:** 838 lines

**Two Main Screens:**

#### A. `IrrigationScheduleScreen` (List View)
- Displays all schedules for a device
- Shows schedule details:
  - Title, description
  - Scheduled date/time
  - Recurrence pattern
  - Duration
  - Enabled/disabled status
  - Execution status
- Actions:
  - Enable/disable toggle
  - Delete schedule
  - Refresh list
  - Navigate to create new schedule
- Features:
  - Pull-to-refresh
  - Empty state when no schedules
  - Error handling

#### B. `CreateIrrigationScheduleScreen` (Create/Edit Form)
- Form fields:
  - Title (required)
  - Description (optional)
  - Duration in minutes (required, 1-1440)
  - Event mode (timed/all-day)
  - Date & time picker
  - Recurring toggle
  - Recurrence pattern selector (daily/weekly/monthly/custom)
  - Custom interval input (for custom pattern)
  - Days of week selector (for weekly pattern)
  - End date picker (optional)
- Validation:
  - Required fields
  - Duration range
  - Weekly pattern requires at least one day
- Submit: Creates or updates schedule via API

---

### 5. `NewsCalendar/lib/screens/irrigation_screen.dart`
**Lines Modified:** 1 (import), 1267-1347 (UI updates)

**Changes:**
1. Added import: `import 'package:newscalendar/screens/irrigation_schedule_screen.dart';`
2. Made "Next Scheduled Irrigation" card clickable → navigates to schedule screen
3. Added "Manage Schedules" button → navigates to schedule screen
4. Both buttons refresh next scheduled time when returning

---

## API Endpoints

### Schedule Management

#### `POST /api/irrigation/schedule`
**Create new schedule**

**Request Body:**
```json
{
  "deviceId": "device123",
  "title": "Morning Irrigation",
  "description": "Daily morning irrigation",
  "duration": 30,
  "eventMode": "timed",
  "startTime": "2024-01-15T06:00:00.000Z",
  "recurrence": {
    "isRecurring": true,
    "pattern": "daily",
    "interval": 1,
    "endDate": "2024-12-31T00:00:00.000Z"
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Irrigation schedule created successfully",
  "data": { ...event object... }
}
```

---

#### `GET /api/irrigation/schedules?deviceId=xxx`
**Get all schedules for device**

**Response:**
```json
{
  "success": true,
  "data": {
    "deviceId": "device123",
    "schedules": [...],
    "count": 5
  }
}
```

---

#### `PUT /api/irrigation/schedule/:id`
**Update schedule**

**Request Body:** Same as create (all fields optional, only include what to update)

**Response:**
```json
{
  "success": true,
  "message": "Irrigation schedule updated successfully",
  "data": { ...updated event... }
}
```

---

#### `DELETE /api/irrigation/schedule/:id`
**Delete schedule (soft delete)**

**Response:**
```json
{
  "success": true,
  "message": "Irrigation schedule deleted successfully"
}
```

---

#### `POST /api/irrigation/schedule/:id/toggle`
**Enable/disable schedule**

**Response:**
```json
{
  "success": true,
  "message": "Schedule enabled successfully",
  "data": {
    "enabled": true
  }
}
```

---

## Recurring Schedule Patterns

### Supported Patterns

1. **Daily**
   - Repeats every N days (interval parameter)
   - Example: Every day, every 2 days, every 3 days

2. **Weekly**
   - Repeats on specific days of week
   - `daysOfWeek`: Array of day numbers [0=Sun, 1=Mon, ..., 6=Sat]
   - Example: [1,3,5] = Monday, Wednesday, Friday

3. **Monthly**
   - Repeats on same day of month each month
   - `dayOfMonth`: Day number (1-31)
   - Example: Every 15th of the month

4. **Custom**
   - Repeats every N days (interval parameter)
   - Similar to daily but explicitly marked as custom
   - Example: Every 7 days, every 14 days

### Instance Generation

- When a recurring schedule is created/updated, the system generates future instances
- Instances are generated up to 90 days in advance
- Each instance is a separate Event document with:
  - Same irrigationSettings
  - Different scheduled time
  - `recurrence.isRecurring: false` (marked as instance, not master)
- The scheduler executes each instance independently
- Master event and instances are linked via same userId, deviceId, and irrigationSettings structure

---

## User Flow

### Creating a Schedule

1. User opens Irrigation Screen
2. Clicks "Manage Schedules" button
3. Clicks "+ New Schedule" (FAB)
4. Fills in form:
   - Title, duration, date/time
   - Optionally enables recurring
   - Selects recurrence pattern
5. Submits → Schedule created
6. If recurring, future instances are generated
7. Returns to list → sees new schedule

### Managing Schedules

1. View all schedules in list
2. Enable/disable toggle (pause without deleting)
3. Delete schedule (soft delete)
4. Click schedule to edit (future enhancement - currently only create)

### Execution Flow

1. Cron job checks every minute
2. Finds due schedules (including recurring instances)
3. Executes each due schedule
4. Marks as executed
5. Master recurring event remains, executed instances are marked as executed

---

## Files Changed Summary

### Backend
1. `backend/controllers/irrigationController.js` (+494 lines)
2. `backend/routes/irrigationRoutes.js` (+5 routes)
3. `backend/services/irrigationSchedulerService.js` (+comments)

### Frontend
4. `NewsCalendar/lib/screens/irrigation_schedule_screen.dart` (NEW - 838 lines)
5. `NewsCalendar/lib/screens/irrigation_screen.dart` (+83 lines, +1 import)

---

## Testing Checklist

### Backend
- [ ] Create one-time schedule via API
- [ ] Create daily recurring schedule
- [ ] Create weekly recurring schedule (specific days)
- [ ] Create monthly recurring schedule
- [ ] Create custom interval schedule
- [ ] Verify recurring instances are generated
- [ ] Update schedule properties
- [ ] Toggle schedule enable/disable
- [ ] Delete schedule
- [ ] Get schedules list
- [ ] Verify scheduler executes recurring instances

### Frontend
- [ ] Navigate to schedule management screen
- [ ] Create one-time schedule via UI
- [ ] Create recurring schedule via UI
- [ ] View schedule list
- [ ] Enable/disable schedule
- [ ] Delete schedule
- [ ] Verify schedule appears in list
- [ ] Verify "Next Scheduled" updates after creating schedule
- [ ] Test form validation
- [ ] Test date/time pickers

---

## Notes

1. **Instance Generation:** Recurring instances are generated during schedule creation/update, not during execution. This ensures schedules are ready in advance.

2. **Performance:** Instance generation is limited to next 90 days. For longer schedules, consider implementing background job to generate instances periodically.

3. **Edit Functionality:** Currently, schedule edit is via update API but UI edit button not yet implemented. Users can delete and recreate, or update via API.

4. **Soft Delete:** Schedules are soft-deleted (isDeleted=true) rather than hard-deleted, allowing recovery if needed.

5. **Recurring Master vs Instances:** Master event keeps `isRecurring: true`, instances have `isRecurring: false`. This allows distinguishing between template and actual scheduled events.

---

## Future Enhancements

1. Edit schedule from list view (tap to edit)
2. View execution history per schedule
3. Batch operations (enable/disable multiple)
4. Schedule templates
5. Advanced recurrence (every Nth weekday, last day of month, etc.)
6. Background job to generate instances beyond 90 days

---

**Status:** ✅ Complete - Ready for Testing

