# Backend Event Model Update

**File:** `backend/models/event.js`
**Type:** Model Enhancement
**Date:** Current Session

---

## Changes Made

### New Fields Added:

1. **Event Mode Field** (Line ~52)
   - Field: `eventMode`
   - Type: String, enum: `['all-day', 'timed']`
   - Default: `'all-day'`
   - Purpose: Distinguish between date-only events and timed events

2. **Time Fields** (Lines ~53-60)
   - Field: `startTime` (Date, optional)
   - Field: `endTime` (Date, optional)
   - Purpose: Store specific times for timed events

3. **Farmer-Specific Fields** (Lines ~61-75)
   - Field: `cropType` (String, optional)
   - Field: `cropVariety` (String, optional)
   - Field: `activityType` (String, enum with farming activities, optional)
   - Field: `fieldLocation` (String, optional)
   - Field: `equipmentNeeded` (Array of Strings, optional)

4. **Reminder System** (Lines ~76-95)
   - Field: `reminders` (Array of Objects)
     - Each reminder has: `reminderTime` (Date), `reminderType` (String), `isNotified` (Boolean)
   - Field: `reminderSettings` (Object with default preferences)

---

## Exact Line Changes

- **Lines 51-52:** Added comma after `description` field, added new fields starting at line 52
- **Lines 52-95:** New farmer-specific and reminder fields
- **Line 56:** Pre-save hook remains unchanged
- **Lines 60-61:** Model export remains unchanged

---

## Validation Notes

- Event mode validation: If `eventMode === 'timed'`, then `startTime` and `endTime` should be provided
- Activity type validation: Must be one of the predefined farming activities
- Reminder validation: Reminder times must be before the event start date/time

---

## Migration Notes

- Existing events will default to `eventMode: 'all-day'`
- New fields are optional, so existing data remains valid
- No data migration needed (backward compatible)

