# Raspberry Pi Irrigation System - Integration Guide

Complete guide for interfacing with and using the Raspberry Pi irrigation system.

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Hardware Setup](#hardware-setup)
3. [Raspberry Pi Setup](#raspberry-pi-setup)
4. [Backend Integration](#backend-integration)
5. [WebSocket Protocol](#websocket-protocol)
6. [API Usage Examples](#api-usage-examples)
7. [Testing](#testing)
8. [Troubleshooting](#troubleshooting)
9. [Configuration Reference](#configuration-reference)

---

## System Overview

The irrigation system uses a **WebSocket-based architecture** for real-time bidirectional communication between the Node.js backend and Raspberry Pi hardware.

### Architecture Flow

```
Flutter App
    ↓ HTTP REST API
Node.js Backend (Express)
    ↓ WebSocket Client (ws://pi-ip:8765)
Raspberry Pi (WebSocket Server)
    ↓ GPIO Operations
Hardware (Pump Relay, Sensors)
```

### Key Components

- **Pi WebSocket Server** (`server.py`): Runs on Raspberry Pi, handles GPIO operations
- **Backend WebSocket Client** (`piWebSocketService.js`): Connects from Node.js backend to Pi
- **REST API Endpoints**: Expose Pi functionality to Flutter app
- **Automatic Sensor Push**: Pi pushes sensor data every 10 seconds to connected clients

---

## Hardware Setup

### Required Components

1. **Raspberry Pi** (3B+, 4, or newer)
2. **Relay Module** (for pump control)
3. **Temperature Sensor** (optional - DHT11/DHT22, DS18B20, or analog)
4. **MCP3008 ADC** (if using analog sensors)

### Wiring

#### Pump Relay Connection
- **Relay IN** → **GPIO 18** (Physical pin 12)
- **VCC** → **5V**
- **GND** → **GND**
- **Relay OUT** → **Pump power supply**

#### Temperature Sensor (Choose one)

**DHT11/DHT22:**
- **Data Pin** → **GPIO 4** (Physical pin 7)
- **VCC** → **3.3V**
- **GND** → **GND**

**DS18B20:**
- Connect to **GPIO 4** via 4.7kΩ pull-up resistor
- Enable 1-wire interface: `sudo modprobe w1-gpio && sudo modprobe w1-therm`

**Analog Sensor (via MCP3008):**
- Connect MCP3008 to SPI interface
- Sensor → MCP3008 Channel 0
- Configure in `config.py`: `'TEMP_SENSOR_TYPE': 'analog'`

---

## Raspberry Pi Setup

### 1. Install Dependencies

```bash
cd /home/alok/ekrishi
pip3 install -r requirements.txt
```

**Required packages:**
- `websockets==12.0` - WebSocket server
- `RPi.GPIO==0.7.1` - GPIO control

**Optional (for specific sensors):**
- `Adafruit_DHT==1.4.0` - For DHT11/DHT22 sensors
- `spidev` - For MCP3008 ADC (usually pre-installed)

### 2. Configure GPIO Pins

Edit `config.py` to match your hardware:

```python
GPIO_CONFIG = {
    'PUMP_RELAY_PIN': 18,      # Change if using different pin
    'TEMP_SENSOR_PIN': 4,      # Change if using different pin
    'TEMP_SENSOR_TYPE': 'analog',  # Options: 'analog', 'dht11', 'dht22', 'ds18b20'
    'ADC_CHANNEL': 0,          # MCP3008 channel for analog sensors
}
```

### 3. Configure Network Settings

Edit `config.py`:

```python
WS_CONFIG = {
    'HOST': '0.0.0.0',  # Listen on all interfaces (use 'localhost' for local only)
    'PORT': 8765,       # WebSocket server port
}
```

**Important:** Ensure the Pi's IP address is accessible from your Node.js backend server.

### 4. Run the Server

#### Development Mode
```bash
cd /home/alok/ekrishi
python3 server.py
```

#### Production Mode (using systemd)

Create `/etc/systemd/system/irrigation.service`:

```ini
[Unit]
Description=Raspberry Pi Irrigation WebSocket Server
After=network.target

[Service]
Type=simple
User=alok
WorkingDirectory=/home/alok/ekrishi
ExecStart=/usr/bin/python3 /home/alok/ekrishi/server.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable irrigation.service
sudo systemctl start irrigation.service
sudo systemctl status irrigation.service
```

View logs:
```bash
journalctl -u irrigation.service -f
```

---

## Backend Integration

### 1. Register Device in Database

The backend needs to know about your Pi device. Register it via API:

```bash
POST /api/irrigation/device/register
Content-Type: application/json
Authorization: Bearer <your-token>

{
  "deviceId": "pi-main-field-1",
  "piUrl": "ws://192.168.1.100:8765",
  "deviceName": "Main Irrigation System",
  "location": "Field 1",
  "description": "Primary irrigation controller"
}
```

**Replace:**
- `192.168.1.100` with your Pi's IP address
- `pi-main-field-1` with your unique device identifier

### 2. Connection Management

The backend automatically:
- Establishes WebSocket connection when device is registered
- Maintains persistent connection
- Auto-reconnects on disconnect (exponential backoff: 1s, 2s, 4s, ... up to 30s)
- Queues commands if disconnected, sends when reconnected

### 3. Connection Status

Check connection status:

```javascript
// In backend code
const piClient = piWebSocketService.getConnection(deviceId, piUrl);
const status = piClient.getStatus();
console.log(status);
// { url: 'ws://...', deviceId: '...', isConnected: true, readyState: 1 }
```

---

## WebSocket Protocol

### Message Format

All messages use JSON format:

**Request:**
```json
{
  "requestId": "req_1_1234567890",
  "action": "toggle_pump",
  "params": {
    "state": true
  },
  "timestamp": "2024-01-01T12:00:00Z"
}
```

**Response:**
```json
{
  "requestId": "req_1_1234567890",
  "success": true,
  "data": {
    "action": "toggle_pump",
    "state": true,
    "message": "Pump turned ON"
  }
}
```

### Supported Actions

#### 1. Pump Control

**Toggle Pump:**
```json
{
  "action": "toggle_pump",
  "params": {
    "state": true  // true = ON, false = OFF, null = toggle
  }
}
```

**Turn Pump ON:**
```json
{
  "action": "pump_on",
  "params": {}
}
```

**Turn Pump OFF:**
```json
{
  "action": "pump_off",
  "params": {}
}
```

#### 2. Sensor Reading

**Read Temperature:**
```json
{
  "action": "read_sensor",
  "params": {
    "sensorType": "temperature"
  }
}
```

**Response:**
```json
{
  "requestId": "...",
  "success": true,
  "sensorData": {
    "value": 25.5,
    "unit": "C",
    "timestamp": 1234567890.123
  }
}
```

#### 3. Get Status

**Get System Status:**
```json
{
  "action": "get_status",
  "params": {}
}
```

**Response:**
```json
{
  "requestId": "...",
  "success": true,
  "data": {
    "pumpState": false,
    "temperature": {
      "value": 25.5,
      "unit": "C",
      "timestamp": 1234567890.123
    },
    "timestamp": "2024-01-01T12:00:00Z"
  }
}
```

### Automatic Sensor Push

The Pi automatically pushes sensor data every **10 seconds** to all connected clients:

```json
{
  "type": "sensor_data",
  "data": {
    "temperature": {
      "value": 25.5,
      "unit": "C",
      "timestamp": 1234567890.123
    },
    "pumpState": false,
    "timestamp": "2024-01-01T12:00:00Z"
  }
}
```

---

## API Usage Examples

### REST API Endpoints

All endpoints require authentication token in header: `Authorization: Bearer <token>`

#### 1. Register Device

```bash
POST /api/irrigation/device/register
{
  "deviceId": "pi-main-field-1",
  "piUrl": "ws://192.168.1.100:8765",
  "deviceName": "Main Irrigation",
  "location": "Field 1"
}
```

#### 2. Toggle Pump

```bash
POST /api/irrigation/pump/toggle
{
  "deviceId": "pi-main-field-1",
  "state": true  // true = ON, false = OFF, omit = toggle
}
```

**Response:**
```json
{
  "success": true,
  "message": "Pump turned ON",
  "data": {
    "deviceId": "pi-main-field-1",
    "state": true,
    "timestamp": "2024-01-01T12:00:00Z"
  }
}
```

#### 3. Read Sensor

```bash
GET /api/irrigation/sensor/read?deviceId=pi-main-field-1
```

**Response:**
```json
{
  "success": true,
  "data": {
    "temperature": {
      "value": 25.5,
      "unit": "C",
      "timestamp": 1234567890.123
    },
    "timestamp": "2024-01-01T12:00:00Z"
  }
}
```

#### 4. Get Status

```bash
GET /api/irrigation/status?deviceId=pi-main-field-1
```

**Response:**
```json
{
  "success": true,
  "data": {
    "isConnected": true,
    "pumpState": false,
    "temperature": {
      "value": 25.5,
      "unit": "C",
      "timestamp": 1234567890.123
    },
    "lastSeen": "2024-01-01T12:00:00Z"
  }
}
```

#### 5. List Devices

```bash
GET /api/irrigation/devices
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "deviceId": "pi-main-field-1",
      "deviceName": "Main Irrigation",
      "location": "Field 1",
      "piUrl": "ws://192.168.1.100:8765",
      "isActive": true,
      "lastSeen": "2024-01-01T12:00:00Z"
    }
  ]
}
```

### JavaScript/Node.js Examples

#### Using the Service Directly

```javascript
const piWebSocketService = require('./services/piWebSocketService');

// Get connection
const deviceId = 'pi-main-field-1';
const piUrl = 'ws://192.168.1.100:8765';
const piClient = piWebSocketService.getConnection(deviceId, piUrl);

// Turn pump ON
try {
  const result = await piClient.sendCommand('pump_on', {});
  console.log('Pump state:', result.state);
} catch (error) {
  console.error('Error:', error.message);
}

// Read sensor
try {
  const sensorData = await piClient.sendCommand('read_sensor', {
    sensorType: 'temperature'
  });
  console.log('Temperature:', sensorData.value, sensorData.unit);
} catch (error) {
  console.error('Error:', error.message);
}

// Listen to automatic sensor updates
piClient.on('sensorData', (data) => {
  console.log('Sensor update:', data);
});
```

---

## Testing

### 1. Test Pi WebSocket Server Locally

On the Raspberry Pi:

```bash
cd /home/alok/ekrishi
python3 server.py
```

You should see:
```
GPIO Controller initialized - Pump: GPIO 18, Temp Sensor: GPIO 4
Starting WebSocket server on 0.0.0.0:8765
WebSocket server started and listening on ws://0.0.0.0:8765
```

### 2. Test Connection from Backend

Using `websocat` (install: `cargo install websocat` or download binary):

```bash
websocat ws://192.168.1.100:8765
```

Send test command:
```json
{"action": "get_status", "requestId": "test1", "params": {}}
```

Expected response:
```json
{"requestId": "test1", "success": true, "data": {"pumpState": false, "temperature": {...}, "timestamp": "..."}}
```

### 3. Test from Node.js Backend

```javascript
// test-pi-connection.js
const piWebSocketService = require('./services/piWebSocketService');

async function test() {
  const deviceId = 'test-device';
  const piUrl = 'ws://192.168.1.100:8765';
  const client = piWebSocketService.getConnection(deviceId, piUrl);
  
  // Wait for connection
  await new Promise(resolve => {
    client.once('connected', resolve);
    setTimeout(resolve, 5000); // 5 second timeout
  });
  
  // Test commands
  try {
    const status = await client.sendCommand('get_status', {});
    console.log('Status:', status);
    
    const pumpOn = await client.sendCommand('pump_on', {});
    console.log('Pump ON:', pumpOn);
    
    await new Promise(r => setTimeout(r, 2000)); // Wait 2 seconds
    
    const pumpOff = await client.sendCommand('pump_off', {});
    console.log('Pump OFF:', pumpOff);
  } catch (error) {
    console.error('Error:', error);
  }
}

test();
```

Run:
```bash
node test-pi-connection.js
```

### 4. Test via REST API

```bash
# Register device
curl -X POST http://localhost:3000/api/irrigation/device/register \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "deviceId": "pi-test-1",
    "piUrl": "ws://192.168.1.100:8765",
    "deviceName": "Test Device",
    "location": "Test Location"
  }'

# Toggle pump
curl -X POST http://localhost:3000/api/irrigation/pump/toggle \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "deviceId": "pi-test-1",
    "state": true
  }'

# Read sensor
curl http://localhost:3000/api/irrigation/sensor/read?deviceId=pi-test-1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Troubleshooting

### Connection Issues

**Problem: Cannot connect to Pi**

1. **Check Pi IP address:**
   ```bash
   # On Pi
   hostname -I
   ```

2. **Check firewall:**
   ```bash
   # On Pi, allow port 8765
   sudo ufw allow 8765
   ```

3. **Test connection:**
   ```bash
   # From backend server
   telnet 192.168.1.100 8765
   # Or
   nc -zv 192.168.1.100 8765
   ```

4. **Check server is running:**
   ```bash
   # On Pi
   ps aux | grep server.py
   netstat -tlnp | grep 8765
   ```

**Problem: Connection drops frequently**

- Check network stability
- Increase reconnect timeout in backend
- Check Pi system resources: `htop` or `free -h`

### GPIO Issues

**Problem: Pump not responding**

1. **Check GPIO permissions:**
   ```bash
   # Run with sudo or add user to gpio group
   sudo usermod -a -G gpio alok
   # Then logout and login again
   ```

2. **Test GPIO manually:**
   ```python
   import RPi.GPIO as GPIO
   GPIO.setmode(GPIO.BCM)
   GPIO.setup(18, GPIO.OUT)
   GPIO.output(18, GPIO.HIGH)  # Should turn relay ON
   ```

3. **Check wiring:**
   - Verify relay is connected to correct GPIO pin
   - Check relay module power (VCC and GND)
   - Test relay with simple LED if available

**Problem: Sensor readings are incorrect**

1. **Check sensor type in config:**
   ```python
   'TEMP_SENSOR_TYPE': 'analog'  # Make sure this matches your hardware
   ```

2. **Test sensor directly:**
   - For DHT11/DHT22: Use `Adafruit_DHT.read_retry()` directly
   - For analog: Check MCP3008 connections and SPI interface
   - For DS18B20: Check 1-wire interface is enabled

3. **Check sensor wiring:**
   - Verify correct GPIO pin
   - Check power connections (3.3V or 5V depending on sensor)
   - Verify pull-up resistors for digital sensors

### Server Issues

**Problem: Server crashes on startup**

1. **Check dependencies:**
   ```bash
   pip3 list | grep websockets
   pip3 list | grep RPi.GPIO
   ```

2. **Check logs:**
   ```bash
   # If running as service
   journalctl -u irrigation.service -n 50
   
   # If running manually
   # Check console output or irrigation.log
   ```

3. **Check Python version:**
   ```bash
   python3 --version  # Should be 3.7+
   ```

**Problem: No sensor data being pushed**

1. **Check auto-push is enabled:**
   ```python
   SENSOR_CONFIG = {
       'ENABLE_AUTO_PUSH': True,  # Should be True
   }
   ```

2. **Check clients are connected:**
   - Look for "Client connected" messages in logs
   - Verify backend is connected

3. **Check sensor reading interval:**
   ```python
   'READ_INTERVAL': 10  # Seconds between sensor reads
   ```

---

## Configuration Reference

### config.py

```python
# GPIO Pin Configuration (BCM numbering)
GPIO_CONFIG = {
    'PUMP_RELAY_PIN': 18,        # GPIO pin for pump relay
    'TEMP_SENSOR_PIN': 4,        # GPIO pin for temperature sensor
    'TEMP_SENSOR_TYPE': 'analog', # 'analog', 'dht11', 'dht22', 'ds18b20'
    'ADC_CHANNEL': 0,            # MCP3008 channel for analog sensors
}

# WebSocket Server Configuration
WS_CONFIG = {
    'HOST': '0.0.0.0',  # '0.0.0.0' = all interfaces, 'localhost' = local only
    'PORT': 8765,       # WebSocket server port
}

# Sensor Reading Configuration
SENSOR_CONFIG = {
    'READ_INTERVAL': 10,         # Seconds between sensor readings
    'ENABLE_AUTO_PUSH': True,    # Auto-push sensor data to clients
}

# Pump Configuration
PUMP_CONFIG = {
    'AUTO_OFF_TIMEOUT': None,    # Seconds before auto-off (None = manual)
    'MAX_RUNTIME': 3600,         # Maximum pump runtime in seconds (1 hour)
}

# Logging Configuration
LOG_CONFIG = {
    'LEVEL': 'INFO',             # 'DEBUG', 'INFO', 'WARNING', 'ERROR'
    'FILE': 'irrigation.log',    # Log file path (None = no file logging)
    'ENABLE_CONSOLE': True,      # Print logs to console
}
```

### Backend Configuration

Device registration is stored in MongoDB (`IrrigationDevice` model):

```javascript
{
  userId: ObjectId,
  deviceId: String,        // Unique device identifier
  piUrl: String,           // WebSocket URL (e.g., "ws://192.168.1.100:8765")
  deviceName: String,      // Display name
  location: String,        // Location description
  isActive: Boolean,       // Device enabled/disabled
  lastSeen: Date           // Last successful communication
}
```

---

## Security Considerations

1. **Network Security:**
   - Use firewall rules to restrict access to port 8765
   - Consider VPN for remote access
   - Use WPA2/WPA3 for Wi-Fi

2. **Authentication:**
   - Backend should validate user ownership before allowing commands
   - Consider adding authentication at Pi level for production

3. **Access Control:**
   - Limit GPIO pin access to necessary pins only
   - Set appropriate file permissions on Pi files

4. **Production Recommendations:**
   - Use HTTPS/WSS if exposing over internet
   - Implement rate limiting on backend
   - Monitor for unauthorized access attempts

---

## Performance Notes

- **Latency:** WebSocket messages typically have 5-10ms latency when connected
- **Throughput:** Can handle hundreds of commands per second
- **Reconnection:** Automatic reconnection with exponential backoff
- **Sensor Push:** Efficient - one connection pushes to all clients

---

## Support and Maintenance

### Logs Location

**Pi Side:**
- Console output (if running manually)
- `irrigation.log` (if configured)
- Systemd journal: `journalctl -u irrigation.service`

**Backend Side:**
- Console logs show connection status
- MongoDB stores all events and sensor readings

### Monitoring

- Check `lastSeen` field in device registration
- Monitor connection status via `/api/irrigation/status`
- Review `IrrigationEvent` collection for pump operations
- Review `SensorReading` collection for sensor data history

---

## Quick Reference

### Start Server
```bash
cd /home/alok/ekrishi
python3 server.py
```

### Stop Server
```bash
# If running manually: Ctrl+C
# If running as service:
sudo systemctl stop irrigation.service
```

### Check Status
```bash
# On Pi
ps aux | grep server.py

# Via API
GET /api/irrigation/status?deviceId=YOUR_DEVICE_ID
```

### Common Commands
```bash
# Toggle pump
POST /api/irrigation/pump/toggle
{"deviceId": "YOUR_DEVICE_ID", "state": true}

# Read sensor
GET /api/irrigation/sensor/read?deviceId=YOUR_DEVICE_ID

# Get all devices
GET /api/irrigation/devices
```

---

**Last Updated:** 2024-01-01  
**Version:** 1.0

