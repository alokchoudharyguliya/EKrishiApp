# Irrigation Device Registration Flow - Implementation

## Overview
This document describes the changes made to implement device registration flow for the Irrigation Management system. Users must now register their Raspberry Pi irrigation device before accessing the dashboard.

## Changes Summary

### Backend Changes

#### 1. Added `getDevice` endpoint in `irrigationController.js`
- **File**: `backend/controllers/irrigationController.js`
- **Lines**: 403-449 (new function)
- **Purpose**: Check if user has a registered device
- **Endpoint**: `GET /api/irrigation/device`
- **Authentication**: Required (Bearer token)
- **Response**: 
  - 200: Device found, returns device data
  - 404: No device registered
  - 401: Authentication required

**Function Details**:
```javascript
exports.getDevice = async (req, res) => {
  // Extracts userId from JWT token
  // Finds active device for user
  // Returns device information or 404 if not found
}
```

#### 2. Added route for `getDevice` endpoint
- **File**: `backend/routes/irrigationRoutes.js`
- **Line**: 14 (new route)
- **Change**: Added `router.get('/device', irrigationController.getDevice);`
- **Purpose**: Expose the getDevice endpoint

### Flutter App Changes

#### 3. Complete rewrite of `irrigation_screen.dart`
- **File**: `NewsCalendar/lib/screens/irrigation_screen.dart`
- **Total Lines**: 544 (complete rewrite from 160 lines)
- **Major Changes**:

##### a. Added State Management (Lines 11-23)
- `_isLoading`: Loading state during device check
- `_isDeviceRegistered`: Boolean flag for device registration status
- `_isRegistering`: Loading state during registration
- `_deviceData`: Stores device information
- Form controllers for registration fields

##### b. Added `_checkDeviceRegistration()` method (Lines 71-152)
- **Lines 71-152**: Main function to check device registration
- Checks local storage first for cached device ID
- Calls backend API `GET /api/irrigation/device`
- Uses Bearer token authentication
- Updates local storage on success
- Handles 404 (no device) and other errors

##### c. Added `_registerDevice()` method (Lines 155-218)
- **Lines 155-218**: Function to register new device
- Validates form inputs
- Calls backend API `POST /api/irrigation/device/register`
- Uses Bearer token authentication
- Stores device ID in local storage on success
- Shows success/error messages

##### d. Added `_buildRegistrationForm()` method (Lines 345-464)
- **Lines 345-464**: UI for device registration form
- Form fields:
  - Device ID (required) - Line 377-392
  - Pi WebSocket URL (required) - Line 393-411
  - Device Name (optional) - Line 412-422
  - Location (optional) - Line 423-433
- Form validation with proper error messages
- WebSocket URL format validation
- Submit button with loading state

##### e. Modified `build()` method (Lines 294-312)
- **Lines 294-312**: Conditional rendering based on device status
- Shows loading spinner while checking (Lines 296-304)
- Shows registration form if no device (Line 310)
- Shows dashboard if device is registered (Line 310)

##### f. Modified `_buildDashboard()` method (Lines 467-544)
- **Lines 467-544**: Enhanced dashboard view
- Added device info card at top (Lines 471-489)
- Shows device name, ID, and location
- Existing pump control and sensor cards remain

##### g. Added imports (Lines 1-3)
- `package:flutter/material.dart`
- `package:newscalendar/utils/imports.dart` (includes http, json, Provider, SharedPreferences)
- `package:http/http.dart` as http

## File Changes Log

### Backend Files Modified

1. **backend/controllers/irrigationController.js**
   - **Lines Added**: 403-449
   - **Change Type**: New function `getDevice`
   - **Total New Lines**: 47

2. **backend/routes/irrigationRoutes.js**
   - **Line Modified**: 14 (added new route)
   - **Change Type**: Route addition
   - **New Line**: `router.get('/device', irrigationController.getDevice);`

### Flutter Files Modified

3. **NewsCalendar/lib/screens/irrigation_screen.dart**
   - **Previous Lines**: 160
   - **New Lines**: 544
   - **Change Type**: Complete rewrite
   - **Lines Changed**: All
   - **Key Sections**:
     - Lines 11-23: State variables
     - Lines 71-152: Device check function
     - Lines 155-218: Registration function
     - Lines 345-464: Registration form UI
     - Lines 467-544: Dashboard UI

## API Endpoints Used

### 1. GET /api/irrigation/device
- **Purpose**: Get user's registered device
- **Authentication**: Bearer token required
- **Headers**: 
  - `Authorization: Bearer <token>`
  - `Content-Type: application/json`
- **Response (200)**:
  ```json
  {
    "success": true,
    "data": {
      "deviceId": "string",
      "deviceName": "string",
      "piUrl": "string",
      "location": "string",
      "isActive": true,
      "lastSeen": "timestamp",
      "createdAt": "timestamp"
    }
  }
  ```
- **Response (404)**:
  ```json
  {
    "success": false,
    "message": "No device registered",
    "data": null
  }
  ```

### 2. POST /api/irrigation/device/register
- **Purpose**: Register a new device
- **Authentication**: Bearer token required
- **Headers**: 
  - `Authorization: Bearer <token>`
  - `Content-Type: application/json`
- **Request Body**:
  ```json
  {
    "deviceId": "string (required)",
    "piUrl": "string (required, format: ws://IP:PORT)",
    "deviceName": "string (optional)",
    "location": "string (optional)"
  }
  ```
- **Response (201/200)**:
  ```json
  {
    "success": true,
    "message": "Device registered successfully",
    "data": {
      "deviceId": "string",
      "deviceName": "string",
      "piUrl": "string",
      "location": "string",
      "isActive": true
    }
  }
  ```

## Local Storage Keys

- **Key**: `irrigation_device_id`
- **Type**: String
- **Purpose**: Store device ID locally for quick access
- **Storage**: SharedPreferences
- **Used In**: 
  - `_checkDeviceRegistration()` - Line 114
  - `_registerDevice()` - Line 196

## Flow Diagram

```
User opens Irrigation Screen
         |
         v
Check Local Storage for device ID
         |
    +----+----+
    | Found?  |
    +----+----+
         |
    Yes  |  No
    |    |
    v    v
Verify with Backend API
    |    |
    |    v
    |  Call GET /api/irrigation/device
    |    |
    |    +----+----+
    |    | Found?  |
    |    +----+----+
    |         |
    |    Yes  |  No
    |    |    |
    |    |    v
    |    |  Show Registration Form
    |    |    |
    |    |    v
    |    |  User fills form
    |    |    |
    |    |    v
    |    |  POST /api/irrigation/device/register
    |    |    |
    |    |    +----+----+
    |    |    |Success?|
    |    |    +----+----+
    |    |         |
    |    |    Yes  |  No
    |    |    |    |
    |    |    |    v
    |    |    |  Show Error
    |    |    |
    |    |    v
    |    |  Store device ID in local storage
    |    |    |
    |    v    v
    |  Show Dashboard
    |
    v
Display Irrigation Management Dashboard
```

## Validation Rules

1. **Device ID**: Required, cannot be empty
2. **Pi WebSocket URL**: 
   - Required
   - Must start with `ws://`
   - Must match pattern: `ws://IP:PORT`
   - Example: `ws://192.168.1.100:8765`
   - Validated in Flutter (Line 408-412) and Backend (Line 343 in irrigationController.js)

## Error Handling

- Network timeout: 10 seconds for GET, 15 seconds for POST
- Authentication errors: Shows "Please login to continue"
- Backend errors: Displays error message from API response
- Validation errors: Shows inline form validation messages

## Testing Checklist

- [ ] User without device sees registration form
- [ ] Registration form validates required fields
- [ ] Registration form validates WebSocket URL format
- [ ] Successful registration stores device ID locally
- [ ] After registration, dashboard is displayed
- [ ] Device info is shown in dashboard
- [ ] Refresh button works after registration
- [ ] Bearer token is sent in all API calls
- [ ] Error messages are displayed appropriately
- [ ] Local storage is cleared if device not found on backend

## Notes

- Single device per user is supported
- Device ID is stored in local storage for quick access
- Backend verification happens on every check
- Registration form includes helpful hints and examples
- All API calls use proper Bearer token authentication
- WebSocket URL format matches backend validation pattern

