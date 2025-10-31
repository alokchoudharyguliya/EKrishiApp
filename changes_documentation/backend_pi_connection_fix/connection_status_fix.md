# Connection Status Fix - getStatus() Issue

## Date
2025-01-31

## Problem
`getStatus()` endpoint was returning `isConnected: false` even when the connection should exist. The code worked fine until `getConnectionStatus(deviceId)` call.

## Root Cause
The `getStatus()` method in `irrigationController.js` was calling `getConnectionStatus()` directly without ensuring a connection exists first. 

**The Issue:**
- `getConnectionStatus(deviceId)` only checks if connection exists in the Map
- If no connection exists, it returns `{ isConnected: false, error: 'No connection found' }`
- It does NOT create a connection - it only checks status
- Connection is only created when `getConnection(deviceId, piUrl)` is called
- If device was registered but connection was lost or never established, status would be false

## Fix Applied

### Change 1: `backend/controllers/irrigationController.js` (Lines 201-207)
**Before:**
```javascript
// Get connection status
const connectionStatus = piWebSocketService.getConnectionStatus(deviceId);
```

**After:**
```javascript
// Ensure connection exists (creates if not exists, returns existing if exists)
const piClient = piWebSocketService.getConnection(deviceId, device.piUrl);
console.log(`[IrrigationController] Connection client retrieved for device ${deviceId}, piUrl: ${device.piUrl}`);

// Get connection status
const connectionStatus = piClient.getStatus();
console.log(`[IrrigationController] Connection status for device ${deviceId}:`, connectionStatus);
```

**Why:** Now `getConnection()` is called first, which either:
- Returns existing connection if it exists
- Creates new connection if it doesn't exist
- Then we get the actual status from the connection object

### Change 2: Enhanced Response (Lines 228-234)
Added more detailed connection status information:
- `isConnecting`: Shows if connection is in progress
- `readyState`: Human-readable connection state (CONNECTING, OPEN, CLOSED, etc.)
- `error`: Any error message if connection failed

### Change 3: Enhanced Logging
Added comprehensive logging throughout:
- `getConnection()`: Logs when connection is created/retrieved
- `getConnectionStatus()`: Logs connection lookup
- `connect()`: Logs connection attempts
- Error handlers: Log detailed error information

## Testing the Fix

### Step 1: Check Backend Console Logs
After calling `/api/irrigation/status`, you should see:

```
[IrrigationController] Connection client retrieved for device <deviceId>, piUrl: ws://10.178.48.113:8765
[PiWebSocket] getConnection called for deviceId: <deviceId>, piUrl: ws://10.178.48.113:8765
[PiWebSocket] Creating new connection for device <deviceId> with URL: ws://10.178.48.113:8765
[PiWebSocket] Connecting to Pi at ws://10.178.48.113:8765 for device <deviceId>...
[PiWebSocket] WebSocket instance created, waiting for connection...
[IrrigationController] Connection status for device <deviceId>: { isConnected: false, isConnecting: true, ... }
```

### Step 2: Check Connection
If connection succeeds, you'll see:
```
[PiWebSocket] Connected to Pi device: <deviceId>
[PiWebSocket] Received connection acknowledgment from Pi device: <deviceId>
```

If connection fails, you'll see:
```
[PiWebSocket] Error for device <deviceId>: <error message>
[PiWebSocket] Error details: <full error object>
[PiWebSocket] Connection URL was: ws://10.178.48.113:8765
```

### Step 3: Verify IP and Port
Make sure:
- Pi IP is correct: `10.178.48.113`
- Port is correct: `8765`
- Pi server is running: `python3 server.py`
- Network connectivity: Can you ping `10.178.48.113`?

## Common Connection Issues

### Issue 1: Connection Timeout
**Symptoms:** Connection stays in CONNECTING state
**Possible Causes:**
- Pi server not running
- Wrong IP address
- Network firewall blocking port 8765
- Pi on different network/subnet

**Solution:**
1. Check Pi server is running: `python3 server.py` on Raspberry Pi
2. Verify IP: `ifconfig` on Pi or check router
3. Test connectivity: `telnet 10.178.48.113 8765` from backend server
4. Check firewall: Allow port 8765 on both machines

### Issue 2: Connection Refused
**Symptoms:** Error message contains "ECONNREFUSED"
**Possible Causes:**
- Pi server not listening on correct interface
- Server listening on localhost only (127.0.0.1) instead of 0.0.0.0

**Solution:**
Check Pi server configuration in `pi-irrigation/server.py`:
```python
# Should be:
host = '0.0.0.0'  # Listen on all interfaces
# NOT:
host = '127.0.0.1'  # Only localhost
```

### Issue 3: Network Unreachable
**Symptoms:** Error message contains "EHOSTUNREACH" or "ENETUNREACH"
**Possible Causes:**
- Pi and backend on different networks
- Network routing issue
- VPN/firewall blocking

**Solution:**
1. Ensure both devices on same network
2. Check network connectivity: `ping 10.178.48.113`
3. Check routing: `traceroute 10.178.48.113`

### Issue 4: Wrong URL Format
**Symptoms:** Connection fails immediately
**Check:** URL format should be exactly: `ws://10.178.48.113:8765`
- Must start with `ws://` (not `http://` or `https://`)
- IP must be accessible from backend server
- Port must match Pi server port (default: 8765)

## Debugging Steps

1. **Check Device Registration:**
   ```bash
   GET /api/irrigation/device
   ```
   Verify `piUrl` is correct: `ws://10.178.48.113:8765`

2. **Check Status Endpoint:**
   ```bash
   GET /api/irrigation/status?deviceId=<your-device-id>
   ```
   Check response for:
   - `connectionStatus.isConnected`
   - `connectionStatus.isConnecting`
   - `connectionStatus.readyState`
   - `connectionStatus.error`

3. **Check Backend Console:**
   Look for connection logs - they will show exactly what's happening

4. **Test Direct Connection:**
   From backend server, test if you can reach Pi:
   ```bash
   telnet 10.178.48.113 8765
   # or
   nc -zv 10.178.48.113 8765
   ```

5. **Check Pi Server:**
   On Raspberry Pi, verify server is running and listening:
   ```bash
   netstat -tuln | grep 8765
   # Should show:
   # tcp    0    0 0.0.0.0:8765    0.0.0.0:*    LISTEN
   ```

## Expected Behavior After Fix

1. **First Status Call:**
   - Connection object is created
   - Connection attempt starts
   - Status shows `isConnecting: true`, `isConnected: false`
   - ReadyState: `CONNECTING`

2. **After Connection Established:**
   - Status shows `isConnected: true`, `isConnecting: false`
   - ReadyState: `OPEN`
   - URL matches device.piUrl

3. **If Connection Fails:**
   - Status shows `isConnected: false`
   - Error message in response
   - Auto-reconnection will attempt every 5 seconds

## Files Changed

1. `backend/controllers/irrigationController.js`
   - Line 201-207: Ensure connection exists before checking status
   - Line 228-234: Enhanced connection status response

2. `backend/services/piWebSocketService.js`
   - Line 322-345: Enhanced logging in `getConnection()`
   - Line 361-373: Enhanced logging in `getConnectionStatus()`
   - Line 34, 38: Enhanced logging in `connect()`
   - Line 68-71: Enhanced error logging

## Next Steps

1. Restart backend server
2. Call `/api/irrigation/status` endpoint
3. Check console logs for detailed connection information
4. If still failing, check:
   - Pi server is running
   - Network connectivity
   - Firewall settings
   - IP address correctness

