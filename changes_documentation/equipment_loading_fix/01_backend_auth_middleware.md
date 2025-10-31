# Backend Auth Middleware Fix

## File Changed
`backend/utils/auth.js`

## Problem
The auth middleware was calling `.replace()` on `req.header('Authorization')` without checking if it exists, causing a crash when the header is missing.

## Changes Made

### Line 5-6: Added null check for Authorization header
**Before:**
```javascript
const token = req.header('Authorization').replace('Bearer ', '');
```

**After:**
```javascript
const authHeader = req.header('Authorization');
if (!authHeader || !authHeader.startsWith('Bearer ')) {
  return res.status(401).json({ success: false, error: 'Please authenticate' });
}
const token = authHeader.replace('Bearer ', '');
```

### Line 10: Updated error response format
**Before:**
```javascript
res.status(401).send({ error: 'Please authenticate' });
```

**After:**
```javascript
res.status(401).json({ success: false, error: 'Please authenticate' });
```

## Impact
- Prevents crashes when Authorization header is missing
- Returns consistent JSON response format matching other endpoints
- Allows frontend to properly handle authentication errors

## Line Numbers Changed
- **Line 5-8**: Added header validation check
- **Line 10**: Updated error response format

