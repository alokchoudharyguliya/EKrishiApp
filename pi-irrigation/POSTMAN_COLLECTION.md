# Postman Collection - Irrigation API Testing Guide

Complete Postman collection and testing guide for the Irrigation System API.

---

## Quick Setup

1. **Import Collection:** Import the `POSTMAN_COLLECTION.json` file into Postman
2. **Set Environment Variables:** Configure the environment with your values
3. **Get Auth Token:** Login first to get your authentication token
4. **Start Testing:** Use the pre-configured requests

---

## Environment Variables

Create a Postman Environment with these variables:

| Variable | Example Value | Description |
|----------|--------------|-------------|
| `baseUrl` | `http://localhost:3000` | Backend server URL |
| `authToken` | `eyJhbGciOiJIUzI1NiIs...` | JWT authentication token |
| `deviceId` | `pi-main-field-1` | Your irrigation device ID |
| `piUrl` | `ws://192.168.1.100:8765` | Raspberry Pi WebSocket URL |

---

## Collection Structure

### 1. Authentication Setup
- Get Auth Token (Login)

### 2. Device Management
- Register Device
- Get Device

### 3. Pump Control
- Turn Pump ON
- Turn Pump OFF
- Toggle Pump

### 4. Sensor Operations
- Read Sensor
- Get Sensor History

### 5. System Status
- Get System Status

---

## API Endpoints

### Base URL
```
{{baseUrl}}/api/irrigation
```

---

## 1. Register Device

**Request:**
```
POST {{baseUrl}}/api/irrigation/device/register
```

**Headers:**
```
Authorization: Bearer {{authToken}}
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
  "deviceId": "pi-main-field-1",
  "piUrl": "ws://192.168.1.100:8765",
  "deviceName": "Main Irrigation System",
  "location": "Field 1",
  "description": "Primary irrigation controller"
}
```

**Example Request:**
```json
{
  "deviceId": "{{deviceId}}",
  "piUrl": "{{piUrl}}",
  "deviceName": "Main Irrigation System",
  "location": "Field 1"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "Device registered successfully",
  "data": {
    "_id": "...",
    "userId": "...",
    "deviceId": "pi-main-field-1",
    "deviceName": "Main Irrigation System",
    "piUrl": "ws://192.168.1.100:8765",
    "location": "Field 1",
    "isActive": true,
    "lastSeen": null,
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Device ID and Pi URL are required"
}
```

---

## 2. Get Device

**Request:**
```
GET {{baseUrl}}/api/irrigation/device
```

**Headers:**
```
Authorization: Bearer {{authToken}}
```

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "deviceId": "pi-main-field-1",
    "deviceName": "Main Irrigation System",
    "piUrl": "ws://192.168.1.100:8765",
    "location": "Field 1",
    "isActive": true,
    "lastSeen": "2024-01-01T12:00:00.000Z",
    "createdAt": "2024-01-01T12:00:00.000Z"
  }
}
```

**Not Found Response (404):**
```json
{
  "success": false,
  "message": "No device registered",
  "data": null
}
```

---

## 3. Turn Pump ON

**Request:**
```
POST {{baseUrl}}/api/irrigation/pump/toggle
```

**Headers:**
```
Authorization: Bearer {{authToken}}
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
  "deviceId": "pi-main-field-1",
  "state": true
}
```

**Example with Variable:**
```json
{
  "deviceId": "{{deviceId}}",
  "state": true
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Pump turned ON",
  "data": {
    "deviceId": "pi-main-field-1",
    "state": true,
    "timestamp": "2024-01-01T12:00:00.000Z"
  }
}
```

---

## 4. Turn Pump OFF

**Request:**
```
POST {{baseUrl}}/api/irrigation/pump/toggle
```

**Headers:**
```
Authorization: Bearer {{authToken}}
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
  "deviceId": "pi-main-field-1",
  "state": false
}
```

**Example with Variable:**
```json
{
  "deviceId": "{{deviceId}}",
  "state": false
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Pump turned OFF",
  "data": {
    "deviceId": "pi-main-field-1",
    "state": false,
    "timestamp": "2024-01-01T12:00:00.000Z"
  }
}
```

---

## 5. Toggle Pump (Toggle Current State)

**Request:**
```
POST {{baseUrl}}/api/irrigation/pump/toggle
```

**Headers:**
```
Authorization: Bearer {{authToken}}
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
  "deviceId": "pi-main-field-1"
}
```

**Example with Variable:**
```json
{
  "deviceId": "{{deviceId}}"
}
```

**Note:** Omit the `state` field to toggle between ON and OFF.

**Success Response (200):**
```json
{
  "success": true,
  "message": "Pump turned ON",
  "data": {
    "deviceId": "pi-main-field-1",
    "state": true,
    "timestamp": "2024-01-01T12:00:00.000Z"
  }
}
```

---

## 6. Read Sensor

**Request:**
```
GET {{baseUrl}}/api/irrigation/sensor/read?deviceId=pi-main-field-1&sensorType=temperature
```

**With Variables:**
```
GET {{baseUrl}}/api/irrigation/sensor/read?deviceId={{deviceId}}&sensorType=temperature
```

**Headers:**
```
Authorization: Bearer {{authToken}}
```

**Query Parameters:**
- `deviceId` (required) - Device identifier
- `sensorType` (optional) - Default: "temperature"

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "deviceId": "pi-main-field-1",
    "sensorType": "temperature",
    "value": 25.5,
    "unit": "C",
    "timestamp": "2024-01-01T12:00:00.000Z"
  }
}
```

**Error Response (500):**
```json
{
  "success": false,
  "message": "Failed to read sensor",
  "error": "Pi device pi-main-field-1 is not connected"
}
```

---

## 7. Get Sensor History

**Request:**
```
GET {{baseUrl}}/api/irrigation/sensor/history?deviceId=pi-main-field-1&limit=50&sensorType=temperature
```

**With Variables:**
```
GET {{baseUrl}}/api/irrigation/sensor/history?deviceId={{deviceId}}&limit=50&sensorType=temperature
```

**Headers:**
```
Authorization: Bearer {{authToken}}
```

**Query Parameters:**
- `deviceId` (required) - Device identifier
- `sensorType` (optional) - Filter by sensor type
- `limit` (optional) - Number of records (default: 100, max: 1000)
- `startDate` (optional) - ISO 8601 format: "2024-01-01T00:00:00Z"
- `endDate` (optional) - ISO 8601 format: "2024-01-31T23:59:59Z"

**Example with Date Range:**
```
GET {{baseUrl}}/api/irrigation/sensor/history?deviceId={{deviceId}}&limit=100&startDate=2024-01-01T00:00:00Z&endDate=2024-01-31T23:59:59Z
```

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "deviceId": "pi-main-field-1",
    "count": 50,
    "readings": [
      {
        "_id": "...",
        "sensorType": "temperature",
        "value": 25.5,
        "unit": "C",
        "timestamp": "2024-01-01T12:00:00.000Z"
      },
      {
        "_id": "...",
        "sensorType": "temperature",
        "value": 25.3,
        "unit": "C",
        "timestamp": "2024-01-01T11:59:50.000Z"
      }
    ]
  }
}
```

---

## 8. Get System Status

**Request:**
```
GET {{baseUrl}}/api/irrigation/status?deviceId=pi-main-field-1
```

**With Variables:**
```
GET {{baseUrl}}/api/irrigation/status?deviceId={{deviceId}}
```

**Headers:**
```
Authorization: Bearer {{authToken}}
```

**Query Parameters:**
- `deviceId` (required) - Device identifier

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "deviceId": "pi-main-field-1",
    "deviceName": "Main Irrigation System",
    "connectionStatus": {
      "isConnected": true,
      "url": "ws://192.168.1.100:8765"
    },
    "currentState": {
      "pumpState": false,
      "lastPumpAction": "2024-01-01T12:00:00.000Z"
    },
    "sensorData": {
      "type": "temperature",
      "value": 25.5,
      "unit": "C",
      "timestamp": "2024-01-01T12:00:00.000Z"
    },
    "lastSeen": "2024-01-01T12:00:00.000Z"
  }
}
```

**Not Connected Response:**
```json
{
  "success": true,
  "data": {
    "deviceId": "pi-main-field-1",
    "deviceName": "Main Irrigation System",
    "connectionStatus": {
      "isConnected": false,
      "url": "ws://192.168.1.100:8765"
    },
    "currentState": {
      "pumpState": false,
      "lastPumpAction": null
    },
    "sensorData": null,
    "lastSeen": null
  }
}
```

---

## Common Error Responses

### 401 Unauthorized
```json
{
  "success": false,
  "message": "User authentication required"
}
```

### 400 Bad Request
```json
{
  "success": false,
  "message": "Device ID is required"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Irrigation device not found or inactive"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Failed to toggle pump",
  "error": "Pi device pi-main-field-1 is not connected"
}
```

---

## Testing Sequence

### Step 1: Setup
1. Ensure Pi WebSocket server is running on Raspberry Pi
2. Get authentication token (login to your app)
3. Set environment variables in Postman

### Step 2: Register Device
1. **POST** `/api/irrigation/device/register`
   - Use your Pi's IP address in `piUrl`
   - Save the `deviceId` returned

### Step 3: Verify Connection
1. **GET** `/api/irrigation/status`
   - Check `connectionStatus.isConnected` should be `true`
   - Wait a few seconds if initially `false` (connection may be establishing)

### Step 4: Test Pump Control
1. **POST** `/api/irrigation/pump/toggle` with `"state": true`
   - Verify pump turns ON
2. **GET** `/api/irrigation/status`
   - Verify `pumpState` is `true`
3. **POST** `/api/irrigation/pump/toggle` with `"state": false`
   - Verify pump turns OFF
4. **POST** `/api/irrigation/pump/toggle` (no state)
   - Verify pump toggles

### Step 5: Test Sensor Reading
1. **GET** `/api/irrigation/sensor/read`
   - Verify sensor data is returned
   - Check temperature value is reasonable

### Step 6: Test History
1. **GET** `/api/irrigation/sensor/history`
   - Verify historical readings are returned
   - Try with different `limit` values
   - Test date range filtering

---

## Postman Pre-request Scripts

### Auto-set Device ID from Response

Add this to the **Tests** tab of "Register Device" request:

```javascript
if (pm.response.code === 201 || pm.response.code === 200) {
    const response = pm.response.json();
    if (response.success && response.data.deviceId) {
        pm.environment.set("deviceId", response.data.deviceId);
        console.log("Device ID saved:", response.data.deviceId);
    }
}
```

### Auto-extract Auth Token

If you have a login endpoint, add this to extract token:

```javascript
if (pm.response.code === 200) {
    const response = pm.response.json();
    if (response.token) {
        pm.environment.set("authToken", response.token);
    }
}
```

---

## Postman Test Scripts

### Test Success Response

Add to **Tests** tab of any request:

```javascript
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Response has success field", function () {
    const jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('success');
    pm.expect(jsonData.success).to.be.true;
});
```

### Test Pump Toggle Response

```javascript
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Pump state is returned", function () {
    const jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('data');
    pm.expect(jsonData.data).to.have.property('state');
    pm.expect(jsonData.data.state).to.be.a('boolean');
});
```

### Test Sensor Reading Response

```javascript
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Sensor data is returned", function () {
    const jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('data');
    pm.expect(jsonData.data).to.have.property('value');
    pm.expect(jsonData.data.value).to.be.a('number');
    pm.expect(jsonData.data).to.have.property('unit');
});
```

### Test Connection Status

```javascript
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Connection status is returned", function () {
    const jsonData = pm.response.json();
    pm.expect(jsonData.data).to.have.property('connectionStatus');
    pm.expect(jsonData.data.connectionStatus).to.have.property('isConnected');
    
    if (jsonData.data.connectionStatus.isConnected) {
        console.log("✅ Pi is connected");
    } else {
        console.log("⚠️ Pi is not connected");
    }
});
```

---

## Complete Request Examples

### 1. Register Device (Complete)

**Method:** `POST`  
**URL:** `http://localhost:3000/api/irrigation/device/register`  
**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```
**Body:**
```json
{
  "deviceId": "pi-main-field-1",
  "piUrl": "ws://192.168.1.100:8765",
  "deviceName": "Main Irrigation System",
  "location": "Field 1"
}
```

---

### 2. Turn Pump ON (Complete)

**Method:** `POST`  
**URL:** `http://localhost:3000/api/irrigation/pump/toggle`  
**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```
**Body:**
```json
{
  "deviceId": "pi-main-field-1",
  "state": true
}
```

---

### 3. Read Sensor (Complete)

**Method:** `GET`  
**URL:** `http://localhost:3000/api/irrigation/sensor/read?deviceId=pi-main-field-1&sensorType=temperature`  
**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

### 4. Get Status (Complete)

**Method:** `GET`  
**URL:** `http://localhost:3000/api/irrigation/status?deviceId=pi-main-field-1`  
**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

### 5. Get Sensor History (Complete)

**Method:** `GET`  
**URL:** `http://localhost:3000/api/irrigation/sensor/history?deviceId=pi-main-field-1&limit=50&sensorType=temperature`  
**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**With Date Range:**
**URL:** `http://localhost:3000/api/irrigation/sensor/history?deviceId=pi-main-field-1&limit=100&startDate=2024-01-01T00:00:00Z&endDate=2024-01-31T23:59:59Z`

---

## Import/Export Instructions

### Import Collection

1. Open Postman
2. Click **Import** button
3. Select **File** tab
4. Choose `POSTMAN_COLLECTION.json`
5. Click **Import**

### Export Collection

1. Select the collection in Postman
2. Click **...** (three dots)
3. Select **Export**
4. Choose **Collection v2.1**
5. Save file

### Import Environment

1. Click **Environments** in left sidebar
2. Click **Import**
3. Select environment JSON file or paste JSON
4. Set variable values
5. Click **Save**

---

## Troubleshooting

### "User authentication required" (401)

**Problem:** Missing or invalid auth token

**Solution:**
1. Login to get new token
2. Update `authToken` environment variable
3. Ensure token is included in `Authorization` header

### "Device not found" (404)

**Problem:** Device not registered or belongs to different user

**Solution:**
1. Register device first using `/device/register`
2. Verify `deviceId` matches registered device
3. Ensure you're using the correct user account

### "Pi device is not connected" (500)

**Problem:** WebSocket connection to Pi failed

**Solution:**
1. Verify Pi WebSocket server is running: `python3 server.py`
2. Check Pi IP address is correct
3. Verify firewall allows port 8765
4. Test connection: `telnet <pi-ip> 8765`
5. Wait a few seconds for auto-reconnection

### Connection timeout

**Problem:** Pi server not responding

**Solution:**
1. Check Pi server logs
2. Verify Pi is on same network
3. Check Pi's IP address hasn't changed
4. Restart Pi WebSocket server

---

## Quick Test Checklist

- [ ] Environment variables set (baseUrl, authToken, deviceId, piUrl)
- [ ] Pi WebSocket server running on Raspberry Pi
- [ ] Device registered successfully
- [ ] Connection status shows `isConnected: true`
- [ ] Pump ON command works
- [ ] Pump OFF command works
- [ ] Sensor reading returns valid data
- [ ] Sensor history returns records
- [ ] Status endpoint returns complete information

---

**Last Updated:** 2024-01-01  
**Version:** 1.0

