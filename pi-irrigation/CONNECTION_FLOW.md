# WebSocket Connection Flow - How `connected_clients` Works

## Overview

The `connected_clients` set in `server.py` stores all active WebSocket connections from clients (your Node.js backend). Here's exactly where they come from and how they're managed.

---

## Connection Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│  Node.js Backend (PiWebSocketClient)                            │
│  Creates WebSocket connection to Raspberry Pi                   │
│  ws://192.168.1.100:8765                                        │
└────────────────────┬────────────────────────────────────────────┘
                     │ WebSocket Connection Request
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│  Raspberry Pi WebSocket Server (server.py)                      │
│  Line 260: websockets.serve(handle_client, host, port)          │
│  ─────────────────────────────────────────────────────────────  │
│  • Server listens on port 8765                                  │
│  • When client connects, calls handle_client() automatically    │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│  handle_client(websocket, path) function                        │
│  Line 31-81                                                      │
│  ─────────────────────────────────────────────────────────────  │
│  Line 37: connected_clients.add(websocket)  ← CLIENT ADDED HERE│
│                                                                  │
│  • websocket = WebSocket connection object from client          │
│  • This websocket object is stored in connected_clients set     │
│  • Each connection = one websocket object                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## Step-by-Step Explanation

### 1. Initialization (Line 28)

```python
connected_clients = set()  # Empty set created at startup
```

This is a **global set** that starts empty when the server starts.

---

### 2. WebSocket Server Setup (Line 260)

```python
async with websockets.serve(handle_client, host, port):
```

**What happens:**
- The `websockets.serve()` function starts a WebSocket server
- `handle_client` is passed as the **connection handler**
- When ANY client connects, `websockets.serve()` automatically calls `handle_client(websocket, path)`
- The `websocket` parameter is the connection object representing the client

---

### 3. Client Connection (Line 31-37)

When a client (Node.js backend) connects:

```python
async def handle_client(websocket, path):
    """
    This function is AUTOMATICALLY called by websockets.serve()
    when a new client connects
    """
    client_addr = websocket.remote_address
    logger.info(f"Client connected from {client_addr}")
    connected_clients.add(websocket)  # ← CLIENT ADDED TO SET HERE
```

**Key Points:**
- `websocket` parameter = the connection object for this specific client
- Line 37: The websocket is added to `connected_clients` set
- Each time a client connects, this function runs and adds their websocket

---

### 4. Where Clients Come From

**Clients come from your Node.js backend:**

```javascript
// backend/services/piWebSocketService.js
const piClient = piWebSocketService.getConnection(deviceId, piUrl);
// This creates a WebSocket connection to the Pi server
// Pi server receives this connection and calls handle_client()
```

**Connection URL:**
- Format: `ws://<PI_IP_ADDRESS>:8765`
- Example: `ws://192.168.1.100:8765`
- This is specified when registering the device

---

### 5. Client Removal (Line 80)

When a client disconnects:

```python
finally:
    connected_clients.discard(websocket)  # ← CLIENT REMOVED HERE
    logger.info(f"Client {client_addr} removed from connected clients")
```

**When this happens:**
- Client closes connection
- Network error occurs
- Server shuts down
- Connection times out

---

### 6. Using `connected_clients` (Line 177-220)

The `push_sensor_data()` function uses `connected_clients` to broadcast to all connected clients:

```python
async def push_sensor_data():
    while True:
        await asyncio.sleep(SENSOR_CONFIG['READ_INTERVAL'])
        
        if not connected_clients:  # Check if any clients connected
            continue
        
        # Read sensor data
        sensor_data = gpio_controller.read_temperature()
        
        # Send to ALL connected clients
        for client in connected_clients:  # ← Iterate through all clients
            try:
                await client.send(json.dumps(message))  # Send to this client
            except websockets.exceptions.ConnectionClosed:
                disconnected.add(client)  # Mark as disconnected
        
        connected_clients -= disconnected  # Remove disconnected clients
```

---

## Complete Flow Example

### Scenario: Node.js Backend Connects

1. **Backend starts** and calls:
   ```javascript
   piWebSocketService.getConnection("pi-001", "ws://192.168.1.100:8765")
   ```

2. **Backend creates WebSocket connection** to `ws://192.168.1.100:8765`

3. **Pi server receives connection** at line 260 (`websockets.serve()`)

4. **Pi server automatically calls** `handle_client(websocket, path)` with:
   - `websocket` = connection object for this backend
   - `path` = WebSocket path (usually "/")

5. **handle_client() adds client** at line 37:
   ```python
   connected_clients.add(websocket)  # Now contains 1 client
   ```

6. **Client stays in set** while connected

7. **push_sensor_data() can now send** sensor data to this client every 10 seconds

8. **When backend disconnects**, line 80 removes it:
   ```python
   connected_clients.discard(websocket)  # Set is empty again
   ```

---

## Multiple Clients

If multiple Node.js backends connect (or same backend connects multiple times):

```python
connected_clients = {
    <websocket_object_1>,  # First backend connection
    <websocket_object_2>,  # Second backend connection
    <websocket_object_3>,  # Third backend connection
}
```

Each `websocket` object is unique and represents one connection.

---

## Important Code Locations

| Line | Code | Purpose |
|------|------|---------|
| **28** | `connected_clients = set()` | Initialize empty set |
| **260** | `websockets.serve(handle_client, ...)` | Setup server, auto-calls handle_client on connection |
| **37** | `connected_clients.add(websocket)` | **ADD client when they connect** |
| **80** | `connected_clients.discard(websocket)` | **REMOVE client when they disconnect** |
| **185** | `if not connected_clients:` | Check if any clients connected |
| **204** | `for client in connected_clients:` | **ITERATE through all clients** to send data |

---

## Summary

**Where `connected_clients` comes from:**

1. ✅ Starts as empty set (line 28)
2. ✅ Clients are **Node.js backend WebSocket connections**
3. ✅ When backend connects to `ws://<PI_IP>:8765`, `websockets.serve()` receives it
4. ✅ `websockets.serve()` automatically calls `handle_client(websocket, path)`
5. ✅ `handle_client()` adds the `websocket` object to `connected_clients` (line 37)
6. ✅ Multiple clients = multiple websocket objects in the set
7. ✅ When client disconnects, `handle_client()` removes it (line 80)

**The key is:** `websockets.serve()` handles the low-level connection management and automatically calls `handle_client()` for each new connection, passing the connection object as the `websocket` parameter.

---

## Visual Timeline

```
Time    Event                                    connected_clients
────────────────────────────────────────────────────────────────────
T0      Server starts                            {}
T1      Backend 1 connects                       {websocket_1}
T2      Backend 2 connects                       {websocket_1, websocket_2}
T3      push_sensor_data() sends to all          {websocket_1, websocket_2}
T4      Backend 1 disconnects                    {websocket_2}
T5      Backend 2 disconnects                    {}
```

---

## Testing Connection

To verify clients are being added:

1. Start Pi server: `python3 server.py`
2. Look for log: `"Client connected from ('192.168.1.100', 54321)"`
3. Check `connected_clients` size:
   ```python
   print(f"Connected clients: {len(connected_clients)}")
   ```

---

**Last Updated:** 2024-01-01

