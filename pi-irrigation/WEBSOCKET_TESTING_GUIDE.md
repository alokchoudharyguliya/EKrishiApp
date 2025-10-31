# WebSocket Testing Guide - Direct Pi Server Testing

Complete guide for testing the Raspberry Pi WebSocket server directly without going through the Node.js backend.

---

## Prerequisites

1. **Raspberry Pi WebSocket Server Running**
2. **Network Access** - Your computer must be able to reach the Pi
3. **Pi IP Address** - Know your Pi's IP address (e.g., `192.168.1.100`)
4. **Testing Tool** - Choose one of the tools below

---

## Step 1: Start the Pi WebSocket Server

### On Raspberry Pi:

```bash
cd /home/alok/ekrishi
python3 server.py
```

**Expected Output:**
```
GPIO Controller initialized - Pump: GPIO 18, Temp Sensor: GPIO 4
Starting WebSocket server on 0.0.0.0:8765
WebSocket server started and listening on ws://0.0.0.0:8765
Sensor auto-push enabled (interval: 10s)
```

**Note:** If you see GPIO errors (common if not on actual Pi hardware), the server may still work but pump/sensor commands will fail.

---

## Step 2: Find Your Pi's IP Address

### On Raspberry Pi:

```bash
hostname -I
# or
ip addr show
```

Example output: `192.168.1.100`

---

## Step 3: Choose a Testing Method

### Method 1: Browser Console (Easiest)

### Method 2: Python Script (Recommended)

### Method 3: Node.js Script

### Method 4: Postman (WebSocket Support)

### Method 5: websocat (Command Line)

### Method 6: Online WebSocket Client

---

## Method 1: Browser Console Testing

### Steps:

1. **Open Browser Console** (F12 or Right-click → Inspect → Console)

2. **Connect to Pi:**
   ```javascript
   const ws = new WebSocket('ws://192.168.1.100:8765');
   ```

3. **Listen for messages:**
   ```javascript
   ws.onopen = () => {
       console.log('Connected to Pi!');
   };
   
   ws.onmessage = (event) => {
       const data = JSON.parse(event.data);
       console.log('Received:', data);
   };
   
   ws.onerror = (error) => {
       console.error('Error:', error);
   };
   
   ws.onclose = () => {
       console.log('Disconnected');
   };
   ```

4. **Wait for connection message** - You should see:
   ```json
   {
     "type": "connection",
     "status": "connected",
     "message": "Connected to Raspberry Pi Irrigation System",
     "timestamp": "2024-01-01T12:00:00.000000"
   }
   ```

5. **Send commands:**

   **Get Status:**
   ```javascript
   ws.send(JSON.stringify({
       action: 'get_status',
       requestId: 'test-1',
       params: {}
   }));
   ```

   **Turn Pump ON:**
   ```javascript
   ws.send(JSON.stringify({
       action: 'pump_on',
       requestId: 'test-2',
       params: {}
   }));
   ```

   **Turn Pump OFF:**
   ```javascript
   ws.send(JSON.stringify({
       action: 'pump_off',
       requestId: 'test-3',
       params: {}
   }));
   ```

   **Read Sensor:**
   ```javascript
   ws.send(JSON.stringify({
       action: 'read_sensor',
       requestId: 'test-4',
       params: {
           sensorType: 'temperature'
       }
   }));
   ```

   **Toggle Pump:**
   ```javascript
   ws.send(JSON.stringify({
       action: 'toggle_pump',
       requestId: 'test-5',
       params: {
           state: true  // true = ON, false = OFF, omit = toggle
       }
   }));
   ```

6. **Watch for responses** in console

7. **Close connection:**
   ```javascript
   ws.close();
   ```

---

## Method 2: Python Script (Recommended)

### Create test script: `test_pi_websocket.py`

```python
#!/usr/bin/env python3
"""
Test script for Raspberry Pi WebSocket server
"""
import asyncio
import websockets
import json
from datetime import datetime

# Pi WebSocket server URL
PI_WS_URL = "ws://192.168.1.100:8765"  # Change to your Pi's IP

async def test_pi_connection():
    """Test connection and send commands to Pi"""
    try:
        print(f"Connecting to {PI_WS_URL}...")
        async with websockets.connect(PI_WS_URL) as websocket:
            print("✅ Connected to Pi!")
            
            # Wait for initial connection message
            initial_msg = await websocket.recv()
            print(f"\n📨 Initial message: {json.loads(initial_msg)}")
            
            # Test 1: Get Status
            print("\n[Test 1] Getting system status...")
            await websocket.send(json.dumps({
                "action": "get_status",
                "requestId": "test-status-1",
                "params": {}
            }))
            response = await websocket.recv()
            print(f"Response: {json.dumps(json.loads(response), indent=2)}")
            
            await asyncio.sleep(1)
            
            # Test 2: Read Sensor
            print("\n[Test 2] Reading sensor...")
            await websocket.send(json.dumps({
                "action": "read_sensor",
                "requestId": "test-sensor-1",
                "params": {
                    "sensorType": "temperature"
                }
            }))
            response = await websocket.recv()
            print(f"Response: {json.dumps(json.loads(response), indent=2)}")
            
            await asyncio.sleep(1)
            
            # Test 3: Turn Pump ON
            print("\n[Test 3] Turning pump ON...")
            await websocket.send(json.dumps({
                "action": "pump_on",
                "requestId": "test-pump-on-1",
                "params": {}
            }))
            response = await websocket.recv()
            print(f"Response: {json.dumps(json.loads(response), indent=2)}")
            
            await asyncio.sleep(2)
            
            # Test 4: Turn Pump OFF
            print("\n[Test 4] Turning pump OFF...")
            await websocket.send(json.dumps({
                "action": "pump_off",
                "requestId": "test-pump-off-1",
                "params": {}
            }))
            response = await websocket.recv()
            print(f"Response: {json.dumps(json.loads(response), indent=2)}")
            
            await asyncio.sleep(1)
            
            # Test 5: Toggle Pump
            print("\n[Test 5] Toggling pump...")
            await websocket.send(json.dumps({
                "action": "toggle_pump",
                "requestId": "test-toggle-1",
                "params": {
                    "state": True
                }
            }))
            response = await websocket.recv()
            print(f"Response: {json.dumps(json.loads(response), indent=2)}")
            
            await asyncio.sleep(2)
            
            # Listen for automatic sensor push (wait 10 seconds)
            print("\n[Test 6] Waiting for automatic sensor push (10 seconds)...")
            try:
                sensor_push = await asyncio.wait_for(websocket.recv(), timeout=12.0)
                print(f"📊 Sensor push received: {json.dumps(json.loads(sensor_push), indent=2)}")
            except asyncio.TimeoutError:
                print("⚠️ No sensor push received (may be disabled)")
            
            print("\n✅ All tests completed!")
            
    except websockets.exceptions.InvalidURI:
        print(f"❌ Error: Invalid WebSocket URL: {PI_WS_URL}")
        print("   Format should be: ws://IP_ADDRESS:8765")
    except ConnectionRefusedError:
        print(f"❌ Error: Connection refused to {PI_WS_URL}")
        print("   Check:")
        print("   1. Pi WebSocket server is running")
        print("   2. Pi IP address is correct")
        print("   3. Firewall allows port 8765")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    print("=" * 60)
    print("Raspberry Pi WebSocket Server Test")
    print("=" * 60)
    asyncio.run(test_pi_connection())
```

### Run the script:

```bash
# Install websockets if not already installed
pip3 install websockets

# Run test
python3 test_pi_websocket.py
```

---

## Method 3: Node.js Script

### Create test script: `test_pi_websocket.js`

```javascript
const WebSocket = require('ws');

// Pi WebSocket server URL
const PI_WS_URL = 'ws://192.168.1.100:8765'; // Change to your Pi's IP

console.log('Connecting to', PI_WS_URL);
const ws = new WebSocket(PI_WS_URL);

ws.on('open', () => {
    console.log('✅ Connected to Pi!');
    
    // Wait for initial connection message
    setTimeout(() => {
        // Test 1: Get Status
        console.log('\n[Test 1] Getting system status...');
        ws.send(JSON.stringify({
            action: 'get_status',
            requestId: 'test-status-1',
            params: {}
        }));
    }, 1000);
});

ws.on('message', (data) => {
    try {
        const message = JSON.parse(data.toString());
        console.log('📨 Received:', JSON.stringify(message, null, 2));
        
        // Continue with next test based on requestId
        handleTestSequence(message);
    } catch (error) {
        console.error('Error parsing message:', error);
    }
});

let testStep = 1;

function handleTestSequence(response) {
    testStep++;
    
    switch(testStep) {
        case 2:
            setTimeout(() => {
                console.log('\n[Test 2] Reading sensor...');
                ws.send(JSON.stringify({
                    action: 'read_sensor',
                    requestId: 'test-sensor-1',
                    params: { sensorType: 'temperature' }
                }));
            }, 1000);
            break;
            
        case 3:
            setTimeout(() => {
                console.log('\n[Test 3] Turning pump ON...');
                ws.send(JSON.stringify({
                    action: 'pump_on',
                    requestId: 'test-pump-on-1',
                    params: {}
                }));
            }, 1000);
            break;
            
        case 4:
            setTimeout(() => {
                console.log('\n[Test 4] Turning pump OFF...');
                ws.send(JSON.stringify({
                    action: 'pump_off',
                    requestId: 'test-pump-off-1',
                    params: {}
                }));
            }, 2000);
            break;
            
        case 5:
            setTimeout(() => {
                console.log('\n[Test 5] Waiting for sensor push (10 seconds)...');
                setTimeout(() => {
                    console.log('✅ All tests completed!');
                    ws.close();
                }, 12000);
            }, 1000);
            break;
    }
}

ws.on('error', (error) => {
    console.error('❌ WebSocket error:', error.message);
    if (error.message.includes('ECONNREFUSED')) {
        console.log('\nTroubleshooting:');
        console.log('1. Check Pi server is running');
        console.log('2. Verify IP address:', PI_WS_URL);
        console.log('3. Check firewall settings');
    }
});

ws.on('close', () => {
    console.log('\nConnection closed');
});
```

### Run the script:

```bash
# Install ws package if needed
npm install ws

# Run test
node test_pi_websocket.js
```

---

## Method 4: Postman WebSocket Testing

### Steps:

1. **Open Postman** (version 10.0+)

2. **Create New Request:**
   - Click **New** → **WebSocket Request**
   - Or use **New** → **HTTP Request** → Change to **WebSocket**

3. **Enter URL:**
   ```
   ws://192.168.1.100:8765
   ```

4. **Click Connect**

5. **Wait for connection message** - Should see:
   ```json
   {
     "type": "connection",
     "status": "connected",
     "message": "Connected to Raspberry Pi Irrigation System"
   }
   ```

6. **Send Messages:**

   **Get Status:**
   ```json
   {
     "action": "get_status",
     "requestId": "test-1",
     "params": {}
   }
   ```

   **Turn Pump ON:**
   ```json
   {
     "action": "pump_on",
     "requestId": "test-2",
     "params": {}
   }
   ```

   **Read Sensor:**
   ```json
   {
     "action": "read_sensor",
     "requestId": "test-3",
     "params": {
       "sensorType": "temperature"
     }
   }
   ```

7. **View responses** in the message panel

---

## Method 5: websocat (Command Line)

### Install websocat:

**On Linux/Mac:**
```bash
# Install via cargo
cargo install websocat

# Or download binary
wget https://github.com/vi/websocat/releases/download/v1.11.0/websocat.x86_64-unknown-linux-musl
chmod +x websocat.x86_64-unknown-linux-musl
```

**On Windows:**
- Download from: https://github.com/vi/websocat/releases
- Or use WSL/Linux subsystem

### Connect:

```bash
websocat ws://192.168.1.100:8765
```

### Send commands:

Once connected, type JSON commands:

```json
{"action":"get_status","requestId":"test-1","params":{}}
```

Press Enter to send.

### Example session:

```bash
$ websocat ws://192.168.1.100:8765
{"type":"connection","status":"connected","message":"Connected to Raspberry Pi Irrigation System","timestamp":"2024-01-01T12:00:00.000000"}
{"action":"get_status","requestId":"test-1","params":{}}
{"requestId":"test-1","success":true,"data":{"pumpState":false,"temperature":{"value":25.5,"unit":"C","timestamp":1234567890.123},"timestamp":"2024-01-01T12:00:00.000000"}}
{"action":"pump_on","requestId":"test-2","params":{}}
{"requestId":"test-2","success":true,"data":{"action":"pump_on","state":true,"message":"Pump turned ON"}}
```

---

## Method 6: Online WebSocket Client

1. **Visit:** https://www.websocket.org/echo.html or https://websocketking.com/

2. **Enter URL:** `ws://192.168.1.100:8765`

3. **Click Connect**

4. **Send messages** using the JSON format below

---

## Message Formats

### Request Format

All requests must be valid JSON:

```json
{
  "action": "action_name",
  "requestId": "unique-request-id",
  "params": {
    // Optional parameters
  },
  "timestamp": "2024-01-01T12:00:00Z"  // Optional
}
```

### Available Actions

#### 1. Get Status
```json
{
  "action": "get_status",
  "requestId": "req-1",
  "params": {}
}
```

**Response:**
```json
{
  "requestId": "req-1",
  "success": true,
  "data": {
    "pumpState": false,
    "temperature": {
      "value": 25.5,
      "unit": "C",
      "timestamp": 1234567890.123
    },
    "timestamp": "2024-01-01T12:00:00.000000"
  }
}
```

#### 2. Turn Pump ON
```json
{
  "action": "pump_on",
  "requestId": "req-2",
  "params": {}
}
```

**Response:**
```json
{
  "requestId": "req-2",
  "success": true,
  "data": {
    "action": "pump_on",
    "state": true,
    "message": "Pump turned ON"
  }
}
```

#### 3. Turn Pump OFF
```json
{
  "action": "pump_off",
  "requestId": "req-3",
  "params": {}
}
```

**Response:**
```json
{
  "requestId": "req-3",
  "success": true,
  "data": {
    "action": "pump_off",
    "state": false,
    "message": "Pump turned OFF"
  }
}
```

#### 4. Toggle Pump
```json
{
  "action": "toggle_pump",
  "requestId": "req-4",
  "params": {
    "state": true  // true = ON, false = OFF, omit = toggle
  }
}
```

**Response:**
```json
{
  "requestId": "req-4",
  "success": true,
  "data": {
    "action": "toggle_pump",
    "state": true,
    "message": "Pump turned ON"
  }
}
```

#### 5. Read Sensor
```json
{
  "action": "read_sensor",
  "requestId": "req-5",
  "params": {
    "sensorType": "temperature"
  }
}
```

**Response:**
```json
{
  "requestId": "req-5",
  "success": true,
  "sensorData": {
    "value": 25.5,
    "unit": "C",
    "timestamp": 1234567890.123
  }
}
```

---

## Automatic Sensor Push

The Pi automatically sends sensor data every **10 seconds** to all connected clients:

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
    "timestamp": "2024-01-01T12:00:00.000000"
  }
}
```

**Note:** This is pushed automatically, not in response to a request.

---

## Troubleshooting

### Connection Refused

**Problem:** Cannot connect to `ws://192.168.1.100:8765`

**Solutions:**
1. **Check server is running:**
   ```bash
   # On Pi
   ps aux | grep server.py
   ```

2. **Check IP address:**
   ```bash
   # On Pi
   hostname -I
   ```

3. **Check firewall:**
   ```bash
   # On Pi
   sudo ufw status
   sudo ufw allow 8765
   ```

4. **Test connection:**
   ```bash
   # From your computer
   telnet 192.168.1.100 8765
   # Or
   nc -zv 192.168.1.100 8765
   ```

### No Response to Commands

**Problem:** Connected but no response

**Solutions:**
1. **Check message format** - Must be valid JSON
2. **Check requestId** - Should be unique
3. **Check action name** - Must match supported actions
4. **Check Pi logs** - Look for errors on Pi console

### GPIO Errors

**Problem:** Server runs but pump/sensor commands fail

**Solutions:**
1. **If not on actual Pi:** This is expected - GPIO needs real hardware
2. **If on Pi:** Check GPIO permissions and wiring
3. **Sensor errors:** Check sensor configuration in `config.py`

---

## Quick Test Checklist

- [ ] Pi server is running (`python3 server.py`)
- [ ] Can ping Pi from your computer
- [ ] Port 8765 is accessible (telnet/nc test)
- [ ] Connected successfully (received connection message)
- [ ] Can send commands and receive responses
- [ ] Status command works
- [ ] Sensor read works (may return mock data if no sensor)
- [ ] Pump commands work (may fail GPIO if not on real Pi)
- [ ] Automatic sensor push works (wait 10 seconds)

---

## Example Complete Test Session

### Using Python Script:

```bash
$ python3 test_pi_websocket.py
============================================================
Raspberry Pi WebSocket Server Test
============================================================
Connecting to ws://192.168.1.100:8765...
✅ Connected to Pi!

📨 Initial message: {
  "type": "connection",
  "status": "connected",
  "message": "Connected to Raspberry Pi Irrigation System",
  "timestamp": "2024-01-01T12:00:00.000000"
}

[Test 1] Getting system status...
Response: {
  "requestId": "test-status-1",
  "success": true,
  "data": {
    "pumpState": false,
    "temperature": {
      "value": 25.5,
      "unit": "C",
      "timestamp": 1234567890.123
    },
    "timestamp": "2024-01-01T12:00:00.000000"
  }
}

[Test 2] Reading sensor...
Response: {
  "requestId": "test-sensor-1",
  "success": true,
  "sensorData": {
    "value": 25.5,
    "unit": "C",
    "timestamp": 1234567890.123
  }
}

[Test 3] Turning pump ON...
Response: {
  "requestId": "test-pump-on-1",
  "success": true,
  "data": {
    "action": "pump_on",
    "state": true,
    "message": "Pump turned ON"
  }
}

[Test 4] Turning pump OFF...
Response: {
  "requestId": "test-pump-off-1",
  "success": true,
  "data": {
    "action": "pump_off",
    "state": false,
    "message": "Pump turned OFF"
  }
}

[Test 5] Toggling pump...
Response: {
  "requestId": "test-toggle-1",
  "success": true,
  "data": {
    "action": "toggle_pump",
    "state": true,
    "message": "Pump turned ON"
  }
}

[Test 6] Waiting for automatic sensor push (10 seconds)...
📊 Sensor push received: {
  "type": "sensor_data",
  "data": {
    "temperature": {
      "value": 25.5,
      "unit": "C",
      "timestamp": 1234567890.123
    },
    "pumpState": true,
    "timestamp": "2024-01-01T12:10:00.000000"
  }
}

✅ All tests completed!
```

---

**Last Updated:** 2024-01-01  
**Version:** 1.0

