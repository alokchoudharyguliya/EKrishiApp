# Frontend Event Model Update

**File:** `NewsCalendar/lib/models/events.dart`
**Type:** Model Enhancement
**Date:** Current Session

---

## Changes Made

### 1. Added Reminder Class
- New class to represent reminder objects
- Fields: reminderTime, reminderType, reminderValue, isNotified, notificationId

### 2. Added New Fields to Event Class

**Event Mode:**
- `eventMode`: String ('all-day' or 'timed'), default: 'all-day'
- `startTime`: DateTime? (optional, for timed events)
- `endTime`: DateTime? (optional, for timed events)

**Farmer-Specific Fields:**
- `cropType`: String? (optional)
- `cropVariety`: String? (optional)
- `activityType`: String? (enum: Planting, Harvesting, etc.)
- `fieldLocation`: String? (optional)
- `equipmentNeeded`: List<String> (optional, default: [])

**Reminder System:**
- `reminders`: List<Reminder> (optional, default: [])
- `reminderSettings`: Map<String, dynamic>? (optional)

### 3. Updated Methods
- `toJson()`: Include all new fields
- `fromJson()`: Parse all new fields
- `copyWith()`: Include all new fields
- `Event.create()`: Include all new fields

### 4. Hive Fields
- Added @HiveField annotations for all new fields (starting from 13)

---

## Exact Line Changes

- **Lines 32-40:** Added new @HiveField annotations for new fields
- **Lines 47-60:** Updated constructor to include new fields
- **Lines 49-65:** Updated toJson() to include new fields
- **Lines 67-97:** Updated fromJson() to parse new fields
- **Lines 114-142:** Updated copyWith() to include new fields
- **Lines 160-186:** Updated Event.create() to include new fields

---

## Notes

- All new fields are optional (nullable) for backward compatibility
- Reminder class uses Map for Hive storage
- Need to run `flutter pub run build_runner build` to regenerate events.g.dart

---

## Next Steps

After this update, run:
```bash
cd NewsCalendar
flutter pub run build_runner build --delete-conflicting-outputs
```

