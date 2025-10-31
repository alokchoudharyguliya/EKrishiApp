"""
Configuration file for Raspberry Pi Irrigation System
Pin configurations and system settings
"""

# GPIO Pin Configuration
# BCM numbering (GPIO numbers, not physical pin numbers)
GPIO_CONFIG = {
    # Pump control relay pin
    'PUMP_RELAY_PIN': 18,  # GPIO 18 (Physical pin 12)
    
    # Temperature sensor pin (if using digital sensor like DHT11/DHT22)
    # For analog sensors, use an ADC converter and specify ADC channel
    'TEMP_SENSOR_PIN': 4,  # GPIO 4 (Physical pin 7)
    
    # Sensor type: 'dht11', 'dht22', 'ds18b20', 'analog'
    'TEMP_SENSOR_TYPE': 'analog',  # Change based on your sensor
    
    # For analog sensors using MCP3008 ADC
    'ADC_CHANNEL': 0,  # Channel 0 on MCP3008
}

# WebSocket Server Configuration
WS_CONFIG = {
    'HOST': '0.0.0.0',  # Listen on all interfaces
    'PORT': 8765,       # WebSocket server port
}

# Sensor Reading Configuration
SENSOR_CONFIG = {
    'READ_INTERVAL': 10,  # Read sensor every 10 seconds
    'ENABLE_AUTO_PUSH': True,  # Automatically push sensor data to connected clients
}

# Pump Configuration
PUMP_CONFIG = {
    'AUTO_OFF_TIMEOUT': None,  # KamSeconds before auto-off (None = manual only)
    'MAX_RUNTIME': 3600,  # Maximum pump runtime in seconds (1 hour)
}

# Logging Configuration
LOG_CONFIG = {
    'LEVEL': 'INFO',  # DEBUG, INFO, WARNING, ERROR
    'FILE': 'irrigation.log',  # Log file path
    'ENABLE_CONSOLE': True,  # Print logs to console
}


