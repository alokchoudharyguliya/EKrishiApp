# Irrigation Sensor Data Integration - Implementation Plan

## Overview
Replace hardcoded sensor data in Flutter irrigation screen with real-time HTTP API calls to fetch actual sensor readings from the backend.

## Current State Analysis

### Flutter App (irrigation_screen.dart)
- **Lines 777-789**: Hardcoded sensor info card showing static data:
  - Title: "Soil Moisture Sensor"
  - Value: "Current: 45% (Optimal: 40-60%)" (hardcoded)
  - Status: Green checkmark icon

### Backend (irrigationController.js)
- **Lines 92-167**: `readSensor` endpoint exists and works:
  - Route: `GET /api/irrigation/sensor/read`
  - Query params: `deviceId` (required), `sensorType` (optional, default: 'temperature')
  - Returns: `{ success, data: { deviceId, sensorType, value, unit, timestamp } }`
- **Lines 173-257**: `getStatus` endpoint returns latest sensor reading:
  - Route: `GET /api/irrigation/status`
  - Query param: `deviceId`
  - Returns: `{ success, data: { sensorData: { type, value, unit, timestamp } } }`

### Existing Infrastructure
- Backend already saves sensor readings to MongoDB (SensorReading model)
- Backend has WebSocket connection to Pi devices via `piWebSocketService.js`
- Flutter app already uses HTTP for pump control and device status

## Implementation Plan

### Step 1: Add Sensor Data State Management in Flutter
**File:** `NewsCalendar/lib/screens/irrigation_screen.dart`

**Changes:**
- Add state variables for sensor data (lines ~28-30 area):
  - `Map<String, dynamic>? _sensorData` - Store current sensor reading
  - `bool _isLoadingSensor = false` - Loading state for sensor data
  - `String? _sensorErrorMessage` - Error message if sensor read fails

**Estimated Lines:** ~3 new state variables

### Step 2: Create Sensor Data Fetching Function
**File:** `NewsCalendar/lib/screens/irrigation_screen.dart`

**Changes:**
- Add new method `_fetchSensorData()` (after `_fetchDeviceStatus` method, around line ~317)
  - Use existing HTTP client pattern (similar to `_fetchDeviceStatus`)
  - Call `GET /api/irrigation/sensor/read?deviceId={deviceId}&sensorType=moisture`
  - Parse response and update state
  - Handle errors gracefully
  - Set loading states appropriately

**Estimated Lines:** ~40-50 lines for complete function with error handling

### Step 3: Integrate Sensor Fetching with Existing Flow
**File:** `NewsCalendar/lib/screens/irrigation_screen.dart`

**Changes:**
- In `_fetchDeviceStatus()` method (line ~273), also call `_fetchSensorData()` after successful status fetch
- In `_checkDeviceRegistration()` method (line ~149), call `_fetchSensorData()` after device registration
- In `_registerDevice()` method (line ~238), call `_fetchSensorData()` after successful registration
- In refresh button action (line ~442), include sensor data refresh

**Estimated Lines:** ~4-6 lines (function calls)

### Step 4: Replace Hardcoded Sensor Display with Real Data
**File:** `NewsCalendar/lib/screens/irrigation_screen.dart`

**Changes:**
- Replace hardcoded sensor card (lines 777-789) with dynamic data:
  - Display sensor type from `_sensorData['sensorType']`
  - Display actual value and unit: `${_sensorData['value']}${_sensorData['unit']}`
  - Add optimal range text (40-60% for moisture, configurable)
  - Show loading indicator when `_isLoadingSensor` is true
  - Show error message if sensor data fetch failed
  - Show last updated timestamp
  - Handle null/empty sensor data gracefully

**Estimated Lines:** ~25-35 lines (replacement with conditional rendering)

### Step 5: Add Sensor Data Refresh Capability
**File:** `NewsCalendar/lib/screens/irrigation_screen.dart`

**Changes:**
- Add refresh button/icon to sensor card (optional but recommended)
- Or implement auto-refresh with Timer (optional, not in initial implementation)
- Ensure sensor data refreshes when screen becomes visible (using existing refresh pattern)

**Estimated Lines:** ~5-10 lines (if adding refresh button)

## Technical Details

### API Endpoint Details
- **Endpoint:** `GET /api/irrigation/sensor/read`
- **Authentication:** Required (Bearer token in Authorization header)
- **Query Parameters:**
  - `deviceId` (required): Device identifier
  - `sensorType` (optional): 'temperature', 'moisture', or 'humidity' (default: 'temperature')
- **Response Format:**
  ```json
  {
    "success": true,
    "data": {
      "deviceId": "device123",
      "sensorType": "moisture",
      "value": 45.5,
      "unit": "%",
      "timestamp": "2024-01-15T10:30:00.000Z"
    }
  }
  ```

### Error Handling Strategy
- Network errors: Show user-friendly message, keep previous data
- API errors (404, 500): Show error message, allow manual retry
- Missing device: Show appropriate error
- Connection timeout: Show timeout message, allow retry

### State Management Pattern
- Follow existing pattern in `irrigation_screen.dart`:
  - Use `setState()` for state updates
  - Use `mounted` check before `setState()` in async functions
  - Store auth token via `AuthService`
  - Use `BASE_URL` constant for API endpoint

## Files to be Modified

### Primary File
1. **NewsCalendar/lib/screens/irrigation_screen.dart**
   - Lines to add state: ~28-30
   - Lines to add function: ~317-370 (after `_fetchDeviceStatus`)
   - Lines to modify: ~149, ~238, ~442 (integration points)
   - Lines to replace: ~777-789 (sensor card UI)

## Dependencies
- No new dependencies required
- Uses existing packages:
  - `http` package (already imported)
  - `Provider` package (for AuthService)
  - `SharedPreferences` (for device ID storage)

## Testing Checklist
- [ ] Sensor data displays correctly when device is registered
- [ ] Sensor data fetches on screen load
- [ ] Sensor data fetches after device registration
- [ ] Sensor data refreshes on manual refresh
- [ ] Error handling works for network failures
- [ ] Error handling works for missing device
- [ ] Loading indicator shows during fetch
- [ ] UI handles null/empty sensor data gracefully
- [ ] Different sensor types can be fetched (moisture, temperature, humidity)

## Future Enhancements (Not in Scope)
- WebSocket push for real-time sensor updates
- Auto-refresh with Timer
- Sensor data history graph
- Multiple sensor types displayed simultaneously
- Sensor data caching/offline support

## Estimated Implementation Time
- **Development:** 30-45 minutes
- **Testing:** 15-20 minutes
- **Total:** ~1 hour

## Notes
- This implementation uses HTTP polling approach (simpler, more reliable for MVP)
- WebSocket can be added later if real-time updates become critical
- Sensor data is stored in MongoDB, so we can also show historical data later
- The backend already handles sensor reading persistence automatically

