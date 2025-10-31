# Irrigation WebSocket Setup - Change Documentation

## Overview
Implemented WebSocket-based communication system between Node.js backend and Raspberry Pi for irrigation management. This includes backend services, API endpoints, database models, and Raspberry Pi WebSocket server.

## Files Created

### Backend Services

#### 1. `backend/services/piWebSocketService.js`
**Purpose:** WebSocket client service for connecting to Raspberry Pi devices
**Lines:** 1-250 (entire file is new)
- **PiWebSocketClient class (lines 11-215):** Manages persistent WebSocket connection to a single Pi device
  - Connection management with auto-reconnect (lines 28-70)
  - Message queue for offline commands (lines 173-183)
  - Request/response handling with requestId tracking (lines 76-126)
  - Event emitter for sensor data and status updates (lines 128-150)
- **PiConnectionManager class (lines 218-250):** Singleton managing multiple Pi device connections
  - Connection pooling (lines 232-245)
  - Status tracking (lines 248-251)

#### 2. `backend/models/irrigationDevice.js`
**Purpose:** MongoDB model for user-to-device mapping
**Lines:** 1-42 (entire file is new)
- Schema definition (lines 5-32)
  - userId reference to User model (lines 6-8)
  - deviceId unique identifier (lines 10-13)
  - piUrl WebSocket URL (lines 15-23)
  - Device metadata (lines 24-31)
- Pre-save hook for timestamps (lines 35-38)
- Indexes for performance (lines 41)

#### 3. `backend/models/irrigationEvent.js`
**Purpose:** MongoDB model for pump control events
**Lines:** 1-40 (entire file is new)
- Schema definition (lines 5-26)
  - Action types: pump_on, pump_off, pump_toggle (lines 11-14)
  - State tracking (lines 16-17)
  - Trigger source tracking (lines 19-22)
  - Event metadata (lines 24-26)
- Indexes for efficient queries (lines 29-32)

#### 4. `backend/models/sensorReading.js`
**Purpose:** MongoDB model for time-series sensor data
**Lines:** 1-36 (entire file is new)
- Schema definition (lines 5-25)
  - Sensor type enum: temperature, moisture, humidity (lines 11-14)
  - Value and unit tracking (lines 16-19)
  - Timestamp indexing (lines 21-23)
- Compound indexes for time-series queries (lines 28-32)

#### 5. `backend/controllers/irrigationController.js`
**Purpose:** Express controller for irrigation API endpoints
**Lines:** 1-340 (entire file is new)
- **togglePump() method (lines 11-73):** Toggle pump on/off
  - User authentication check (lines 15-21)
  - Device validation (lines 27-33)
  - WebSocket command sending (lines 36-39)
  - Event logging (lines 42-52)
- **readSensor() method (lines 79-141):** Read sensor data
  - Sensor reading via WebSocket (lines 98-101)
  - Data persistence (lines 104-116)
- **getStatus() method (lines 148-220):** Get system status
  - Connection status check (lines 165-166)
  - Latest sensor reading (lines 169-174)
  - Latest pump event (lines 177-180)
- **getSensorHistory() method (lines 227-283):** Get sensor reading history
  - Time-range filtering (lines 249-253)
  - Pagination support (lines 259-261)
- **registerDevice() method (lines 290-340):** Register new Pi device
  - URL validation (lines 304-309)
  - Device creation/update (lines 312-340)
  - WebSocket connection initialization (lines 334)

#### 6. `backend/routes/irrigationRoutes.js`
**Purpose:** Express routes for irrigation endpoints
**Lines:** 1-21 (entire file is new)
- Route definitions (lines 8-20)
  - POST `/device/register` - Register device (line 11)
  - POST `/pump/toggle` - Toggle pump (line 14)
  - GET `/sensor/read` - Read sensor (line 17)
  - GET `/sensor/history` - Sensor history (line 18)
  - GET `/status` - System status (line 21)
- Authentication middleware (line 8)

### Raspberry Pi Files

#### 7. `pi-irrigation/config.py`
**Purpose:** Configuration file for GPIO pins and system settings
**Lines:** 1-45 (entire file is new)
- **GPIO_CONFIG dictionary (lines 6-19):** Pin configurations
  - PUMP_RELAY_PIN: GPIO 18 (line 8)
  - TEMP_SENSOR_PIN: GPIO 4 (line 11)
  - Sensor type configuration (line 14)
- **WS_CONFIG dictionary (lines 21-24):** WebSocket server settings
- **SENSOR_CONFIG dictionary (lines 26-29):** Sensor reading interval (10 seconds)
- **PUMP_CONFIG dictionary (lines 31-34):** Pump control settings
- **LOG_CONFIG dictionary (lines 36-39):** Logging configuration

#### 8. `pi-irrigation/gpio_controller.py`
**Purpose:** GPIO operations for pump and sensors
**Lines:** 1-190 (entire file is new)
- **GPIOController class (lines 12-190):**
  - **__init__() method (lines 13-46):** GPIO initialization
    - Pin setup for pump relay (lines 26-27)
    - Sensor pin configuration (lines 29-40)
  - **toggle_pump() method (lines 48-85):** Pump control
    - State management (lines 55-60)
    - Max runtime check (lines 63-68)
    - GPIO output control (lines 71-85)
  - **read_temperature() method (lines 87-108):** Sensor reading
    - Sensor type routing (lines 92-104)
  - **Sensor reading methods (lines 110-181):**
    - _read_analog_temperature() (lines 115-132)
    - _read_dht11() (lines 134-142)
    - _read_dht22() (lines 144-152)
    - _read_ds18b20() (lines 154-161)
  - **cleanup() method (lines 183-190):** GPIO cleanup

#### 9. `pi-irrigation/server.py`
**Purpose:** WebSocket server for Raspberry Pi
**Lines:** 1-237 (entire file is new)
- **handle_client() function (lines 29-75):** WebSocket client handler
  - Connection acknowledgment (lines 35-40)
  - Message processing loop (lines 43-70)
  - Error handling (lines 61-75)
- **process_command() function (lines 77-169):** Command processor
  - toggle_pump/pump_toggle action (lines 88-102)
  - pump_on action (lines 104-114)
  - pump_off action (lines 116-126)
  - read_sensor action (lines 128-139)
  - get_status action (lines 141-160)
- **push_sensor_data() function (lines 171-212):** Auto-push sensor data
  - Periodic reading (every 10 seconds) (line 174)
  - Broadcast to all clients (lines 188-201)
- **main() function (lines 220-237):** Server startup
  - GPIO controller initialization (lines 226-231)
  - Sensor task creation (lines 233-235)
  - WebSocket server startup (lines 240-245)

#### 10. `pi-irrigation/requirements.txt`
**Purpose:** Python dependencies
**Lines:** 1-8 (entire file is new)
- websockets==12.0 (line 4)
- RPi.GPIO==0.7.1 (line 7)
- Optional sensor libraries (commented) (lines 10-13)

#### 11. `pi-irrigation/README.md`
**Purpose:** Setup and usage documentation for Pi server
**Lines:** 1-49 (entire file is new)
- Setup instructions (lines 4-17)
- Configuration guide (lines 19-24)
- Hardware setup notes (lines 26-31)
- Testing instructions (lines 33-44)

## Files Modified

### 12. `backend/index.js`
**Changes:**
- **Line 19:** Added import for irrigation routes
  ```javascript
  const irrigationRoutes = require('./routes/irrigationRoutes.js');
  ```
- **Line 91:** Added irrigation routes to Express app
  ```javascript
  app.use('/api/irrigation', irrigationRoutes);
  ```

## API Endpoints Created

1. **POST `/api/irrigation/device/register`**
   - Register a new Raspberry Pi device
   - Requires: deviceId, piUrl, deviceName (optional), location (optional)
   - Returns: Device registration confirmation

2. **POST `/api/irrigation/pump/toggle`**
   - Toggle pump on/off
   - Requires: deviceId, state (optional - if not provided, toggles)
   - Returns: Current pump state

3. **GET `/api/irrigation/sensor/read`**
   - Read current sensor value
   - Query params: deviceId, sensorType (optional, default: temperature)
   - Returns: Sensor reading data

4. **GET `/api/irrigation/sensor/history`**
   - Get sensor reading history
   - Query params: deviceId, sensorType (optional), limit (default: 100), startDate, endDate
   - Returns: Array of sensor readings

5. **GET `/api/irrigation/status`**
   - Get system status
   - Query params: deviceId
   - Returns: Connection status, pump state, latest sensor reading

## Communication Flow

```
Flutter App
    ↓ HTTP REST API
Node.js Backend (Express)
    ↓ WebSocket Client
Raspberry Pi (WebSocket Server)
    ↓ GPIO Operations
Hardware (Pump, Sensors)
```

## Environment Variables

No new environment variables required. Pi connection URLs are stored in MongoDB (IrrigationDevice model).

## Dependencies

### Backend (Node.js)
- `ws` - Already installed (used in existing WebSocket implementation)

### Raspberry Pi (Python)
- `websockets==12.0` - WebSocket server
- `RPi.GPIO==0.7.1` - GPIO control
- Optional sensor libraries (DHT11/DHT22 support)

## Testing

1. Start Pi WebSocket server:
   ```bash
   cd pi-irrigation
   python3 server.py
   ```

2. Register device via API:
   ```bash
   POST /api/irrigation/device/register
   {
     "deviceId": "pi-001",
     "piUrl": "ws://192.168.1.100:8765",
     "deviceName": "Main Irrigation",
     "location": "Field 1"
   }
   ```

3. Test pump control:
   ```bash
   POST /api/irrigation/pump/toggle
   {
     "deviceId": "pi-001",
     "state": true
   }
   ```

4. Read sensor:
   ```bash
   GET /api/irrigation/sensor/read?deviceId=pi-001
   ```

## Notes

- WebSocket connections are persistent and auto-reconnect on disconnect
- Sensor data is automatically pushed every 10 seconds to connected backend clients
- All pump events and sensor readings are logged to MongoDB
- GPIO cleanup is handled on Pi server shutdown
- The system supports multiple Pi devices per user

