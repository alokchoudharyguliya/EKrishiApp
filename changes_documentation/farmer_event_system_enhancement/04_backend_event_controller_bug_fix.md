# Backend Event Controller Bug Fix

**File:** `backend/controllers/eventController.js`
**Type:** Bug Fix
**Date:** Current Session

---

## Bug Description

**Line 16:** Typo in model reference
- **Current (broken):** `const events = await event.find({ userId }).sort({ start_date: 1 });`
- **Should be:** `const events = await Event.find({ userId }).sort({ start_date: 1 });`

The variable `event` (lowercase) is not defined, while the model is imported as `Event` (uppercase) on line 1.

---

## Exact Line Change

- **Line 16:** Changed `event.find()` to `Event.find()`

---

## Impact

- **Before:** Would cause runtime error: "event is not defined"
- **After:** Correctly queries the Event model from MongoDB

---

## Testing

After this fix, the `getEvents` endpoint should work correctly without throwing errors.

