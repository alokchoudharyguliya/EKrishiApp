# Raspberry Pi Irrigation System - WebSocket Server

This is the Raspberry Pi side code for the irrigation management system. It runs a WebSocket server that receives commands from the Node.js backend and controls GPIO pins for pump and sensor operations.

## Setup Instructions

1. **Install Python 3.7+**
   ```bash
   python3 --version
   ```

2. **Install dependencies**
   ```bash
   pip3 install -r requirements.txt
   ```

3. **Configure GPIO pins**
   - Edit `config.py` to set your GPIO pin numbers
   - Update sensor type if using different sensors (DHT11, DHT22, DS18B20, or analog)

4. **Run the server**
   ```bash
   python3 server.py
   ```

## Configuration

Edit `config.py` to configure:
- GPIO pin numbers for pump relay and temperature sensor
- WebSocket server host and port (default: 0.0.0.0:8765)
- Sensor reading interval (default: 10 seconds)
- Logging settings

## Hardware Setup

- **Pump Relay**: Connect relay module to GPIO pin specified in config
- **Temperature Sensor**: Connect your sensor to GPIO pin specified in config
  - For analog sensors, you may need an ADC converter (MCP3008)
  - For digital sensors (DHT11/DHT22), connect data pin to GPIO

## Testing

Test the WebSocket connection:
```bash
# Install websocat for testing
# Then connect:
websocat ws://localhost:8765

# Send test command:
{"action": "get_status", "requestId": "test1", "params": {}}
```

## Notes

- The server auto-pushes sensor data every 10 seconds to all connected clients
- GPIO cleanup is handled on server shutdown
- Logs are written to `irrigation.log` (configurable)


