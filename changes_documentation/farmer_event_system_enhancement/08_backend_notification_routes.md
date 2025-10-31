# Backend Notification Routes

**File:** `backend/routes/notificationRoutes.js`
**Type:** New File
**Date:** Current Session

---

## File Created

New routes file for notification endpoints.

---

## Routes Defined

1. **GET `/api/notifications/pending`**
   - Get pending notifications for user
   - Protected by authMiddleware

2. **POST `/api/notifications/mark-notified`**
   - Mark a reminder as notified
   - Body: `{ eventId, reminderIndex }`
   - Protected by authMiddleware

3. **GET `/api/notifications/check`**
   - Quick check for pending notifications
   - Protected by authMiddleware

---

## Integration

**File:** `backend/index.js`
- **Line 22:** Import notificationRoutes
- **Line 141:** Mount routes at `/api/notifications`

---

## Security

All routes protected with `authMiddleware` from `../utils/auth`.

