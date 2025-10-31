# Backend User Model Update

**File:** `backend/models/user.js`
**Type:** Model Enhancement
**Date:** Current Session

---

## Changes Made

### Role Enum Update

**Line 30:** Updated role enum to include 'farmer'
- **Before:** `enum: ['student', 'faculty', 'other', 'admin']`
- **After:** `enum: ['student', 'faculty', 'other', 'admin', 'farmer']`

---

## Exact Line Change

- **Line 30:** Updated enum array to include 'farmer' role

---

## Purpose

Allows users to be registered as farmers, enabling farmer-specific features and UI elements in the application.

---

## Migration Notes

- Existing users remain unaffected
- New users can now select 'farmer' as their role
- No data migration needed (backward compatible)

