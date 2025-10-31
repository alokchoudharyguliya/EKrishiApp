# Quick Test Steps - Pi WebSocket Server

## Quick Start (5 Steps)

### Step 1: Start Pi Server
On Raspberry Pi:
```bash
cd /home/alok/ekrishi
python3 server.py
```

You should see:
```
Starting WebSocket server on 0.0.0.0:8765
WebSocket server started and listening on ws://0.0.0.0:8765
```

### Step 2: Get Pi IP Address
On Raspberry Pi:
```bash
hostname -I
```
Note the IP (e.g., `192.168.1.100`)

### Step 3: Choose Test Method

#### Option A: Browser Console (Easiest)
1. Open browser console (F12)
2. Copy-paste this code:
```javascript
const ws = new WebSocket('ws://YOUR_PI_IP:8765');
ws.onmessage = (e) => console.log('Received:', JSON.parse(e.data));
ws.onopen = () => {
    console.log('Connected!');
    ws.send(JSON.stringify({
        action: 'get_status',
        requestId: 'test-1',
        params: {}
    }));
};
```

#### Option B: Python Script (Recommended)
1. Edit `test_pi_websocket.py` - Change `PI_WS_URL` to your Pi IP
2. Run:
```bash
pip3 install websockets
python3 test_pi_websocket.py
```

#### Option C: Postman
1. Open Postman → New → WebSocket Request
2. URL: `ws://YOUR_PI_IP:8765`
3. Click Connect
4. Send: `{"action":"get_status","requestId":"test-1","params":{}}`

### Step 4: Verify Connection
You should receive a connection message:
```json
{
  "type": "connection",
  "status": "connected",
  "message": "Connected to Raspberry Pi Irrigation System"
}
```

### Step 5: Test Commands

Send these commands (replace `YOUR_PI_IP`):

**Get Status:**
```json
{"action":"get_status","requestId":"test-1","params":{}}
```

**Read Sensor:**
```json
{"action":"read_sensor","requestId":"test-2","params":{"sensorType":"temperature"}}
```

**Turn Pump ON:**
```json
{"action":"pump_on","requestId":"test-3","params":{}}
```

**Turn Pump OFF:**
```json
{"action":"pump_off","requestId":"test-4","params":{}}
```

---

## Troubleshooting

**Can't connect?**
- Check Pi server is running
- Verify IP address
- Test: `telnet YOUR_PI_IP 8765`
- Check firewall: `sudo ufw allow 8765`

**No response?**
- Check JSON format is valid
- Check action names match exactly
- Check Pi console for errors

---

## Full Documentation

See `WEBSOCKET_TESTING_GUIDE.md` for complete details and all testing methods.

