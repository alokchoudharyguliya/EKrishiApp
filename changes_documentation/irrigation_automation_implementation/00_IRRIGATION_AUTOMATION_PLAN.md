# Irrigation Automation Implementation Plan

**Date:** Current Session  
**Status:** Planning Phase  
**Objective:** Implement automated irrigation scheduling system integrated with calendar/events

---

## Executive Summary

This document outlines a comprehensive plan to implement irrigation automation that:
1. **Integrates with existing Event/Calendar system** - Uses calendar events with `activityType: 'Irrigation'` for scheduling
2. **Supports multiple automation modes** - Time-based, sensor-based, and hybrid automation
3. **Provides recurring schedule support** - Daily, weekly, custom patterns
4. **Includes smart automation** - Moisture sensor-based auto-irrigation
5. **Maintains user control** - Manual override, schedule management, notifications

---

## 1. Current System Analysis

### 1.1 Existing Infrastructure

#### Event System ✅
- **Model**: `Event` with `activityType` enum including `'Irrigation'`
- **Fields**: `startTime`, `endTime`, `eventMode` ('timed' or 'all-day')
- **Location**: `fieldLocation` field exists
- **Status**: Ready for irrigation event integration

#### Irrigation System ✅
- **Device Management**: Registration, status checking
- **Pump Control**: Manual on/off toggle via API
- **Sensor Reading**: Temperature, moisture sensors
- **WebSocket**: Real-time communication with Raspberry Pi
- **Event History**: Pump timing tracking

#### Missing Components ❌
- **Irrigation Schedule Model**: No dedicated schedule storage
- **Scheduler Service**: No cron/background job system
- **Automation Logic**: No smart automation based on schedules/sensors
- **Recurring Schedules**: No repeat pattern support
- **Next Scheduled Display**: Currently hardcoded in UI

---

## 2. Implementation Ideas & Approaches

### 2.1 Integration Approach Options

#### **Option A: Event-Based Approach** (Recommended)
**Pros:**
- Leverages existing Event system infrastructure
- Calendar integration is natural
- Reminders/notifications already built-in
- User familiar interface (calendar)
- Reuses existing event CRUD operations

**Cons:**
- Events are typically one-time, need recurring logic
- May need additional fields for irrigation-specific data

**Implementation:**
- Use Event model with `activityType: 'Irrigation'`
- Add `isRecurring`, `recurrencePattern` fields to Event
- Scheduler service processes Irrigation events
- Create new events for recurring instances

#### **Option B: Dedicated Schedule Model**
**Pros:**
- Clean separation of concerns
- Irrigation-specific fields
- More flexible for automation rules

**Cons:**
- Duplicate infrastructure (similar to Events)
- Need separate UI
- More code to maintain

**Recommendation: Use Option A with enhancements**

---

### 2.2 Automation Modes

#### **Mode 1: Time-Based Automation** (Scheduled)
- User creates irrigation schedule (recurring or one-time)
- System triggers pump at scheduled time
- Duration controlled by schedule settings

#### **Mode 2: Sensor-Based Automation** (Smart)
- Monitor moisture sensor readings
- Automatically trigger irrigation when threshold reached
- Configurable thresholds per device/field

#### **Mode 3: Hybrid Automation** (Recommended)
- Time-based scheduling with sensor validation
- Check moisture before scheduled irrigation
- Skip if moisture is adequate
- Log decision reason

#### **Mode 4: Calendar Event Triggered**
- User adds Irrigation event to calendar
- System automatically executes at event time
- Can be recurring via event recurrence

---

### 2.3 Recurring Schedule Patterns

Support these recurrence patterns:
- **Daily**: Every day at specific time
- **Weekly**: Specific days of week (e.g., Mon, Wed, Fri)
- **Custom Interval**: Every N days
- **Monthly**: Specific day of month
- **One-time**: Single scheduled irrigation

---

## 3. Detailed Implementation Plan

### Phase 1: Database & Models Enhancement

#### 1.1 Enhance Event Model for Irrigation
**File:** `backend/models/event.js`

**Add Fields:**
```javascript
// Irrigation-specific fields (only for activityType: 'Irrigation')
irrigationSettings: {
  deviceId: String,           // Link to irrigation device
  duration: Number,           // Duration in minutes
  automationMode: {
    type: String,
    enum: ['scheduled', 'sensor-based', 'hybrid', 'manual'],
    default: 'scheduled'
  },
  moistureThreshold: Number,  // For sensor-based (0-100)
  isExecuted: Boolean,        // Track if scheduled irrigation ran
  executionTime: Date,        // When it actually ran
  skipReason: String          // Why it was skipped (if applicable)
},

// Recurrence for irrigation schedules
recurrence: {
  isRecurring: Boolean,
  pattern: {
    type: String,
    enum: ['daily', 'weekly', 'custom', 'monthly', 'none'],
    default: 'none'
  },
  interval: Number,           // For custom: every N days
  daysOfWeek: [Number],       // For weekly: [1,3,5] = Mon,Wed,Fri
  dayOfMonth: Number,         // For monthly: day 1-31
  endDate: Date,              // When recurrence ends
  maxOccurrences: Number      // Limit number of occurrences
}
```

**Lines to Modify:** Add after line 130 in `backend/models/event.js`

---

#### 1.2 Create IrrigationSchedule Model (Alternative/Complementary)
**File:** `backend/models/irrigationSchedule.js` (NEW)

**Purpose:** Store dedicated irrigation schedules separate from events (if needed for complex schedules)

```javascript
{
  userId: ObjectId,
  deviceId: String,
  name: String,
  enabled: Boolean,
  startTime: Date,           // Time of day (e.g., 06:00)
  duration: Number,          // Minutes
  daysOfWeek: [Number],      // [0,2,4] = Sun, Tue, Thu
  automationMode: String,
  moistureThreshold: Number,
  lastExecuted: Date,
  nextExecution: Date,
  createdAt: Date,
  updatedAt: Date
}
```

**Note:** May not need this if Event model enhancement is sufficient.

---

### Phase 2: Backend Services

#### 2.1 Create Irrigation Scheduler Service
**File:** `backend/services/irrigationSchedulerService.js` (NEW)

**Functions:**
1. `checkScheduledIrrigations()` - Cron job entry point
2. `executeScheduledIrrigation(event)` - Execute a scheduled irrigation
3. `checkSensorConditions(deviceId)` - Check if moisture threshold met
4. `shouldSkipIrrigation(event, sensorData)` - Decision logic for hybrid mode
5. `createRecurringInstances()` - Generate future events from recurring patterns
6. `getNextScheduledIrrigation(deviceId)` - Get next scheduled time

**Cron Schedule:** Run every 1-5 minutes to check for due irrigations

---

#### 2.2 Enhance Irrigation Controller
**File:** `backend/controllers/irrigationController.js`

**Add Functions:**
1. `createIrrigationSchedule()` - POST `/api/irrigation/schedule`
2. `getIrrigationSchedules()` - GET `/api/irrigation/schedules`
3. `updateIrrigationSchedule()` - PUT `/api/irrigation/schedule/:id`
4. `deleteIrrigationSchedule()` - DELETE `/api/irrigation/schedule/:id`
5. `getNextScheduled()` - GET `/api/irrigation/schedule/next`
6. `toggleSchedule()` - POST `/api/irrigation/schedule/:id/toggle`

---

#### 2.3 Update Irrigation Routes
**File:** `backend/routes/irrigationRoutes.js`

**Add Routes:**
```javascript
// Schedule management
router.post('/schedule', irrigationController.createIrrigationSchedule);
router.get('/schedules', irrigationController.getIrrigationSchedules);
router.get('/schedule/next', irrigationController.getNextScheduled);
router.put('/schedule/:id', irrigationController.updateIrrigationSchedule);
router.delete('/schedule/:id', irrigationController.deleteIrrigationSchedule);
router.post('/schedule/:id/toggle', irrigationController.toggleSchedule);
```

---

#### 2.4 Create Background Job/Cron System
**File:** `backend/services/cronService.js` or use `node-cron` package

**Tasks:**
1. Check for due irrigation schedules every minute
2. Execute scheduled irrigations
3. Create recurring event instances
4. Clean up old executed events

**Integration:** Add to `backend/index.js` or separate worker process

---

### Phase 3: Event System Integration

#### 3.1 Enhance Event Controller for Irrigation
**File:** `backend/controllers/eventController.js`

**Modifications:**
- When `activityType: 'Irrigation'` is set:
  - Validate `irrigationSettings` are provided
  - Link to user's irrigation device
  - Create initial schedule execution plan

---

#### 3.2 Event-to-Irrigation Bridge Service
**File:** `backend/services/irrigationEventService.js` (NEW)

**Purpose:** Handle conversion between Event model and irrigation execution

**Functions:**
1. `processIrrigationEvent(event)` - Process calendar event as irrigation
2. `syncEventToSchedule(event)` - Sync event to irrigation schedule
3. `markEventAsExecuted(eventId, executionTime)` - Update event after execution

---

### Phase 4: Frontend Implementation

#### 4.1 Update Irrigation Screen
**File:** `NewsCalendar/lib/screens/irrigation_screen.dart`

**Changes:**
- Replace hardcoded "Next Scheduled Irrigation" (lines 1181-1193)
- Add API call to fetch next scheduled irrigation
- Display actual scheduled time from backend
- Add "View All Schedules" button
- Show active schedules list

**API Integration:**
```dart
Future<void> _fetchNextScheduledIrrigation() async {
  // GET /api/irrigation/schedule/next?deviceId=xxx
  // Update state with next scheduled time
}
```

---

#### 4.2 Create Irrigation Schedule Management Screen
**File:** `NewsCalendar/lib/screens/irrigation_schedule_screen.dart` (NEW)

**Features:**
- List all irrigation schedules
- Create new schedule (time, recurrence, device)
- Edit/delete schedules
- Enable/disable schedules
- View execution history

---

#### 4.3 Enhance Event Creation for Irrigation
**File:** `NewsCalendar/lib/screens/create_event_screen.dart` (or relevant file)

**When activityType = 'Irrigation':**
- Show irrigation-specific fields:
  - Device selection dropdown
  - Duration picker
  - Automation mode selector
  - Moisture threshold (for sensor-based)
  - Recurrence pattern options

---

#### 4.4 Update Event Model (Dart)
**File:** `NewsCalendar/lib/models/events.dart`

**Add Fields:**
```dart
// Irrigation settings
final Map<String, dynamic>? irrigationSettings;
final Map<String, dynamic>? recurrence;
```

---

### Phase 5: Smart Automation Logic

#### 5.1 Sensor-Based Automation Service
**File:** `backend/services/smartIrrigationService.js` (NEW)

**Functions:**
1. `evaluateMoistureLevel(deviceId)` - Check current moisture
2. `shouldIrrigate(deviceId, threshold)` - Decision logic
3. `executeSmartIrrigation(deviceId)` - Auto-trigger if needed
4. `getOptimalIrrigationTime(deviceId)` - Suggest best time

---

#### 5.2 Automation Decision Flow

```
For Each Scheduled Irrigation:
  1. Check if execution time reached
  2. Get automation mode:
     - 'scheduled': Execute immediately
     - 'sensor-based': Check moisture, execute if below threshold
     - 'hybrid': Check moisture, execute if below threshold (skip if adequate)
     - 'manual': Skip (user-triggered only)
  3. Execute pump:
     - Turn ON pump
     - Wait for duration
     - Turn OFF pump
     - Log IrrigationEvent with triggeredBy: 'schedule'
  4. Update schedule:
     - Mark as executed
     - Calculate next occurrence (if recurring)
     - Create next event instance (if needed)
```

---

## 4. Technical Implementation Details

### 4.1 Cron Job Setup

**Option 1: node-cron** (Recommended)
```javascript
const cron = require('node-cron');

// Run every minute
cron.schedule('* * * * *', async () => {
  await irrigationSchedulerService.checkScheduledIrrigations();
});
```

**Option 2: setInterval**
```javascript
// Check every minute
setInterval(async () => {
  await irrigationSchedulerService.checkScheduledIrrigations();
}, 60000);
```

**Location:** Add to `backend/index.js` or separate worker file

---

### 4.2 Schedule Execution Logic

```javascript
async function executeScheduledIrrigation(event) {
  const { deviceId, duration, automationMode } = event.irrigationSettings;
  
  // 1. Validate device connection
  const device = await IrrigationDevice.findOne({ deviceId });
  if (!device || !device.isActive) {
    throw new Error('Device not available');
  }
  
  // 2. Check automation mode
  if (automationMode === 'hybrid' || automationMode === 'sensor-based') {
    const sensorData = await getLatestSensorReading(deviceId);
    if (shouldSkipIrrigation(event, sensorData)) {
      await logSkippedIrrigation(event, 'Moisture level adequate');
      return;
    }
  }
  
  // 3. Execute irrigation
  const piClient = piWebSocketService.getConnection(deviceId, device.piUrl);
  await piClient.sendCommand('pump_on', {});
  
  // 4. Wait for duration
  await new Promise(resolve => setTimeout(resolve, duration * 60 * 1000));
  
  // 5. Turn off pump
  await piClient.sendCommand('pump_off', {});
  
  // 6. Log event
  await new IrrigationEvent({
    userId: event.userId,
    deviceId,
    action: 'pump_on',
    state: true,
    triggeredBy: 'schedule',
    duration: duration * 60,
    metadata: { eventId: event._id }
  }).save();
  
  // 7. Update event
  event.irrigationSettings.isExecuted = true;
  event.irrigationSettings.executionTime = new Date();
  await event.save();
}
```

---

### 4.3 Recurring Schedule Generation

```javascript
async function createRecurringInstances(event) {
  if (!event.recurrence?.isRecurring) return;
  
  const instances = [];
  let currentDate = new Date(event.startTime || event.start_date);
  const endDate = event.recurrence.endDate || addMonths(currentDate, 3);
  
  while (currentDate <= endDate && instances.length < (event.recurrence.maxOccurrences || 100)) {
    const instance = new Event({
      ...event.toObject(),
      _id: new mongoose.Types.ObjectId(),
      startTime: currentDate,
      irrigationSettings: {
        ...event.irrigationSettings,
        isExecuted: false
      },
      recurrence: { ...event.recurrence, isRecurring: false } // Mark instance as non-recurring
    });
    
    instances.push(instance);
    currentDate = calculateNextOccurrence(currentDate, event.recurrence);
  }
  
  await Event.insertMany(instances);
}
```

---

## 5. API Endpoints Summary

### New Endpoints

#### Schedule Management
- `POST /api/irrigation/schedule` - Create irrigation schedule
- `GET /api/irrigation/schedules?deviceId=xxx` - List schedules
- `GET /api/irrigation/schedule/next?deviceId=xxx` - Get next scheduled
- `GET /api/irrigation/schedule/:id` - Get schedule details
- `PUT /api/irrigation/schedule/:id` - Update schedule
- `DELETE /api/irrigation/schedule/:id` - Delete schedule
- `POST /api/irrigation/schedule/:id/toggle` - Enable/disable schedule

#### Automation
- `POST /api/irrigation/automation/enable` - Enable smart automation
- `POST /api/irrigation/automation/disable` - Disable smart automation
- `GET /api/irrigation/automation/status` - Get automation status

---

## 6. Frontend UI/UX Enhancements

### 6.1 Irrigation Dashboard Updates
- Replace static "Next Scheduled" with dynamic data
- Show countdown to next irrigation
- Display active schedules card
- Show last executed irrigation
- Quick schedule creation button

### 6.2 Schedule Management UI
- Calendar view of scheduled irrigations
- List view with filters (active/inactive, device)
- Create/Edit form with:
  - Time picker
  - Recurrence pattern selector
  - Duration slider
  - Automation mode toggle
  - Device selection

### 6.3 Integration with Event Calendar
- Irrigation events show special icon
- Click event → show irrigation details
- Create irrigation event from calendar
- Recurring irrigation events visible in calendar

---

## 7. Testing Strategy

### 7.1 Unit Tests
- Schedule creation/update/deletion
- Recurrence pattern generation
- Automation decision logic
- Sensor threshold checking

### 7.2 Integration Tests
- End-to-end schedule execution
- Event-to-irrigation flow
- WebSocket pump control
- Database consistency

### 7.3 Manual Testing
- Create schedule via API
- Verify cron job execution
- Test sensor-based automation
- Test recurring schedule generation

---

## 8. Implementation Phases Summary

### Phase 1: Foundation (Week 1)
- ✅ Enhance Event model with irrigation fields
- ✅ Create scheduler service structure
- ✅ Set up cron job system
- ✅ Basic schedule execution logic

### Phase 2: Schedule Management (Week 2)
- ✅ Create schedule CRUD APIs
- ✅ Frontend schedule management screen
- ✅ Update irrigation screen with next scheduled
- ✅ Integration with event system

### Phase 3: Automation (Week 3)
- ✅ Sensor-based automation logic
- ✅ Hybrid automation mode
- ✅ Smart irrigation decisions
- ✅ Automation status APIs

### Phase 4: Recurring Schedules (Week 4)
- ✅ Recurrence pattern support
- ✅ Instance generation logic
- ✅ Calendar integration
- ✅ UI for recurring schedule creation

### Phase 5: Polish & Testing (Week 5)
- ✅ Error handling
- ✅ Logging & monitoring
- ✅ Performance optimization
- ✅ Documentation
- ✅ Testing

---

## 9. Database Schema Changes

### Event Model Additions
```javascript
irrigationSettings: {
  deviceId: String,
  duration: Number,
  automationMode: String,
  moistureThreshold: Number,
  isExecuted: Boolean,
  executionTime: Date,
  skipReason: String
},
recurrence: {
  isRecurring: Boolean,
  pattern: String,
  interval: Number,
  daysOfWeek: [Number],
  dayOfMonth: Number,
  endDate: Date,
  maxOccurrences: Number
}
```

### New Indexes
- `{ userId: 1, 'irrigationSettings.deviceId': 1, startTime: 1 }`
- `{ 'irrigationSettings.isExecuted': 1, startTime: 1 }`

---

## 10. Risk Mitigation

### Potential Issues & Solutions

1. **Cron Job Reliability**
   - Use process manager (PM2) for automatic restart
   - Add logging for missed executions
   - Health check endpoint

2. **Device Connection Failures**
   - Retry logic for failed executions
   - Queue failed schedules for retry
   - Notify user of failures

3. **Sensor Data Unavailability**
   - Fallback to time-based if sensor fails
   - Default threshold values
   - Alert on sensor failures

4. **Recurring Schedule Performance**
   - Limit instance generation (e.g., next 30 days)
   - Background job for future instances
   - Cleanup old executed instances

---

## 11. Future Enhancements (Post-MVP)

1. **Weather Integration** - Skip irrigation if rain forecasted
2. **ML-Based Optimization** - Learn optimal irrigation times
3. **Multi-Zone Support** - Different schedules per zone
4. **Water Usage Tracking** - Monitor and optimize water consumption
5. **Mobile Notifications** - Push notifications for schedule executions
6. **Analytics Dashboard** - Irrigation effectiveness metrics

---

## 12. Success Criteria

✅ Users can create irrigation schedules via calendar events  
✅ Schedules execute automatically at scheduled times  
✅ Sensor-based automation prevents over-irrigation  
✅ Recurring schedules work correctly  
✅ Next scheduled irrigation displays accurately  
✅ Manual override works at any time  
✅ All irrigation executions are logged  
✅ System handles device connection failures gracefully  

---

## Next Steps

1. **Review & Approval** - Get stakeholder approval on approach
2. **Database Migration** - Plan schema changes
3. **Start Phase 1** - Begin with Event model enhancements
4. **Incremental Development** - Implement and test each phase
5. **User Testing** - Get feedback early and often

---

**Document Version:** 1.0  
**Last Updated:** Current Session  
**Author:** Development Team

