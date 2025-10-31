# Postman Testing Guide - Backend Pi Connection

## Date
2025-01-31

## Overview
Complete Postman testing guide for the Irrigation System Backend API, including all endpoints with connection testing.

---

## Setup Instructions

### 1. Import Collection
1. Open Postman
2. Click "Import" button
3. Import the `POSTMAN_COLLECTION.json` file (provided below)

### 2. Create Environment
Create a new Postman Environment with these variables:

| Variable | Initial Value | Current Value | Description |
|----------|--------------|---------------|-------------|
| `baseUrl` | `http://localhost:3001` | - | Backend server URL |
| `authToken` | (empty) | - | JWT token from login |
| `deviceId` | `pi-device-1` | - | Your device ID |
| `piUrl` | `ws://192.168.1.100:8765` | - | Pi WebSocket URL |

### 3. Get Authentication Token
First, login to get your auth token:

**POST** `{{baseUrl}}/login`
```json
{
  "email": "your-email@example.com",
  "password": "your-password"
}
```

Copy the `token` from response and set it in environment variable `authToken`.

---

## Test Sequence

### Step 1: Register Device
This creates the device and establishes WebSocket connection to Pi.

**Method:** `POST`  
**URL:** `{{baseUrl}}/api/irrigation/device/register`

**Headers:**
```
Authorization: Bearer {{authToken}}
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
  "deviceId": "{{deviceId}}",
  "piUrl": "{{piUrl}}",
  "deviceName": "My Irrigation Device",
  "location": "Field 1"
}
```

**Expected Response (201):**
```json
{
  "success": true,
  "message": "Device registered successfully",
  "data": {
    "userId": "...",
    "deviceId": "pi-device-1",
    "deviceName": "My Irrigation Device",
    "piUrl": "ws://192.168.1.100:8765",
    "location": "Field 1",
    "isActive": true,
    "createdAt": "2025-01-31T...",
    "_id": "..."
  }
}
```

**Check Backend Console:**
- Should see: `[PiWebSocket] Connecting to Pi at ws://...`
- Should see: `[PiWebSocket] Connected to Pi device: ...`
- Should see: `[IrrigationController] Successfully connected to device ... during registration`

**If Connection Fails:**
- Check Pi server is running
- Verify `piUrl` is correct and accessible
- Check network connectivity
- Will see warning in console but registration still succeeds (connection will retry)

---

### Step 2: Get Device Status
Check connection status and current state.

**Method:** `GET`  
**URL:** `{{baseUrl}}/api/irrigation/status?deviceId={{deviceId}}`

**Headers:**
```
Authorization: Bearer {{authToken}}
```

**Expected Response (200):**
```json
{
  "success": true,
  "data": {
    "deviceId": "pi-device-1",
    "deviceName": "My Irrigation Device",
    "connectionStatus": {
      "isConnected": true,
      "url": "ws://192.168.1.100:8765"
    },
    "currentState": {
      "pumpState": false,
      "lastPumpAction": null
    },
    "sensorData": null,
    "lastSeen": "2025-01-31T..."
  }
}
```

**Key Fields to Check:**
- `connectionStatus.isConnected`: Should be `true` if Pi is connected
- `connectionStatus.url`: Should match your `piUrl`
- `currentState.pumpState`: Current pump state

**If `isConnected` is false:**
- Check backend console for connection errors
- Verify Pi server is running
- Check network/firewall settings

---

### Step 3: Toggle Pump ON
Test pump control with explicit state.

**Method:** `POST`  
**URL:** `{{baseUrl}}/api/irrigation/pump/toggle`

**Headers:**
```
Authorization: Bearer {{authToken}}
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
  "deviceId": "{{deviceId}}",
  "state": true
}
```

**Expected Response (200):**
```json
{
  "success": true,
  "message": "Pump turned ON",
  "data": {
    "deviceId": "pi-device-1",
    "state": true,
    "timestamp": "2025-01-31T..."
  }
}
```

**Check Backend Console:**
- Should see connection established (if not already)
- Should see command sent successfully
- Should see response received

**Check Pi Server Console:**
- Should see command received
- Should see pump state changed
- Should see response sent back

---

### Step 4: Toggle Pump OFF
Turn pump off.

**Method:** `POST`  
**URL:** `{{baseUrl}}/api/irrigation/pump/toggle`

**Body (raw JSON):**
```json
{
  "deviceId": "{{deviceId}}",
  "state": false
}
```

**Expected Response (200):**
```json
{
  "success": true,
  "message": "Pump turned OFF",
  "data": {
    "deviceId": "pi-device-1",
    "state": false,
    "timestamp": "2025-01-31T..."
  }
}
```

---

### Step 5: Read Sensor
Test sensor reading.

**Method:** `GET`  
**URL:** `{{baseUrl}}/api/irrigation/sensor/read?deviceId={{deviceId}}&sensorType=temperature`

**Headers:**
```
Authorization: Bearer {{authToken}}
```

**Expected Response (200):**
```json
{
  "success": true,
  "data": {
    "deviceId": "pi-device-1",
    "sensorType": "temperature",
    "value": 25.5,
    "unit": "C",
    "timestamp": "2025-01-31T..."
  }
}
```

---

### Step 6: Get Sensor History
Get historical sensor readings.

**Method:** `GET`  
**URL:** `{{baseUrl}}/api/irrigation/sensor/history?deviceId={{deviceId}}&limit=10`

**Headers:**
```
Authorization: Bearer {{authToken}}
```

**Expected Response (200):**
```json
{
  "success": true,
  "data": {
    "deviceId": "pi-device-1",
    "count": 5,
    "readings": [
      {
        "sensorType": "temperature",
        "value": 25.5,
        "unit": "C",
        "timestamp": "2025-01-31T..."
      },
      ...
    ]
  }
}
```

---

### Step 7: Get Device Info
Get registered device information.

**Method:** `GET`  
**URL:** `{{baseUrl}}/api/irrigation/device`

**Headers:**
```
Authorization: Bearer {{authToken}}
```

**Expected Response (200):**
```json
{
  "success": true,
  "data": {
    "deviceId": "pi-device-1",
    "deviceName": "My Irrigation Device",
    "piUrl": "ws://192.168.1.100:8765",
    "location": "Field 1",
    "isActive": true,
    "lastSeen": "2025-01-31T...",
    "createdAt": "2025-01-31T..."
  }
}
```

---

## Testing Connection Issues

### Test 1: Connection Timeout
1. Stop Pi server
2. Try to register device
3. Should still succeed (with warning in console)
4. Try to toggle pump - should wait 10 seconds then timeout with error

### Test 2: Connection Retry
1. Register device (Pi server stopped)
2. Start Pi server
3. Wait for automatic reconnection (check backend console)
4. Try toggle pump - should work after reconnection

### Test 3: Immediate Command After Registration
1. Register device
2. Immediately (within 1 second) try toggle pump
3. Should wait for connection and succeed

### Test 4: Multiple Rapid Commands
1. Register device
2. Send 3 toggle commands rapidly
3. All should wait for connection and execute successfully

---

## Error Scenarios

### Error 1: Device Not Connected
**Request:**
```json
POST /api/irrigation/pump/toggle
{
  "deviceId": "invalid-device",
  "state": true
}
```

**Response (404):**
```json
{
  "success": false,
  "message": "Irrigation device not found or inactive"
}
```

### Error 2: Invalid Pi URL Format
**Request:**
```json
POST /api/irrigation/device/register
{
  "deviceId": "test-device",
  "piUrl": "invalid-url"
}
```

**Response (400):**
```json
{
  "success": false,
  "message": "Invalid WebSocket URL format. Use: ws://IP:PORT (e.g., ws://192.168.1.100:8765)"
}
```

### Error 3: Connection Timeout
**Symptom:** Command fails after 10 seconds

**Response (500):**
```json
{
  "success": false,
  "message": "Failed to toggle pump",
  "error": "Connection timeout for device pi-device-1 after 10000ms"
}
```

### Error 4: Authentication Required
**Request:** Without Authorization header

**Response (401):**
```json
{
  "success": false,
  "message": "User authentication required"
}
```

---

## Complete cURL Examples

### Register Device
```bash
curl -X POST http://localhost:3001/api/irrigation/device/register \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "pi-device-1",
    "piUrl": "ws://192.168.1.100:8765",
    "deviceName": "My Irrigation Device",
    "location": "Field 1"
  }'
```

### Get Status
```bash
curl -X GET "http://localhost:3001/api/irrigation/status?deviceId=pi-device-1" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Toggle Pump ON
```bash
curl -X POST http://localhost:3001/api/irrigation/pump/toggle \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "pi-device-1",
    "state": true
  }'
```

### Read Sensor
```bash
curl -X GET "http://localhost:3001/api/irrigation/sensor/read?deviceId=pi-device-1&sensorType=temperature" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Monitoring Console Outputs

### Backend Console (Node.js)
Watch for these messages:
```
[PiWebSocket] Connecting to Pi at ws://192.168.1.100:8765...
[PiWebSocket] Connected to Pi device: pi-device-1
[PiWebSocket] Received connection acknowledgment from Pi device: pi-device-1
[IrrigationController] Successfully connected to device pi-device-1 during registration
```

### Pi Server Console (Python)
Watch for these messages:
```
Client connected from ('192.168.1.50', 52341)
Processing command: pump_on (requestId: req_1_...)
```

---

## Troubleshooting

### Issue: Connection Never Establishes
1. Check Pi server is running: `python3 server.py`
2. Check Pi server logs for errors
3. Verify network connectivity: `ping <PI_IP>`
4. Check firewall settings
5. Verify WebSocket URL format: `ws://IP:PORT`

### Issue: Commands Timeout
1. Check connection status endpoint first
2. Verify `isConnected: true` in status
3. Check backend console for connection errors
4. Restart Pi server and wait for reconnection

### Issue: "Device not found" Error
1. Verify deviceId is correct
2. Check device is registered: `GET /api/irrigation/device`
3. Ensure device belongs to logged-in user

### Issue: Authentication Errors
1. Get new token from login endpoint
2. Update `authToken` in Postman environment
3. Check token hasn't expired

---

## Quick Test Checklist

- [ ] Backend server running on port 3001
- [ ] Pi server running and accessible
- [ ] Postman environment configured
- [ ] Auth token obtained and set
- [ ] Device registered successfully
- [ ] Status shows `isConnected: true`
- [ ] Toggle pump ON works
- [ ] Toggle pump OFF works
- [ ] Read sensor works
- [ ] Get sensor history works

---

## Performance Notes

- **First Command Delay:** First command after registration may take 8-10 seconds (waiting for connection)
- **Subsequent Commands:** Should be fast (< 1 second) if connection established
- **Connection Timeout:** 10 seconds for connection establishment
- **Command Timeout:** 10 seconds for command execution

