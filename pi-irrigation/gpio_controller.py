"""
GPIO Controller for Raspberry Pi Irrigation System
Handles all GPIO operations for pump control and sensor readings
"""
import RPi.GPIO as GPIO
import time
import logging
from config import GPIO_CONFIG, PUMP_CONFIG

# Setup logging
logger = logging.getLogger(__name__)

class GPIOController:
    def __init__(self):
        self.pump_pin = GPIO_CONFIG['PUMP_RELAY_PIN']
        self.temp_pin = GPIO_CONFIG['TEMP_SENSOR_PIN']
        self.temp_sensor_type = GPIO_CONFIG['TEMP_SENSOR_TYPE']
        self.pump_state = False
        self.pump_start_time = None
        
        # Initialize GPIO
        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)
        
        # Setup pump relay pin
        GPIO.setup(self.pump_pin, GPIO.OUT)
        GPIO.output(self.pump_pin, GPIO.LOW)  # Start with pump OFF (LOW = relay OFF)
        
        # Setup temperature sensor pin based on sensor type
        if self.temp_sensor_type in ['dht11', 'dht22']:
            # DHT sensors need data pin setup
            GPIO.setup(self.temp_pin, GPIO.IN, pull_up_down=GPIO.PUD_UP)
        elif self.temp_sensor_type == 'ds18b20':
            # DS18B20 uses 1-wire interface
            # Enable 1-wire if not already enabled
            pass
        elif self.temp_sensor_type == 'analog':
            # Analog sensors need ADC (MCP3008) - handled separately
            pass
        
        logger.info(f"GPIO Controller initialized - Pump: GPIO {self.pump_pin}, Temp Sensor: GPIO {self.temp_pin}")

    def toggle_pump(self, state=None):
        """
        Toggle pump on/off
        Args:
            state: True = ON, False = OFF, None = toggle current state
        Returns:
            bool: New pump state
        """
        if state is None:
            # Toggle current state
            new_state = not self.pump_state
        else:
            new_state = bool(state)
        
        try:
            if new_state:
                # Check max runtime
                if self.pump_start_time:
                    runtime = time.time() - self.pump_start_time
                    if runtime > PUMP_CONFIG['MAX_RUNTIME']:
                        logger.warning(f"Pump runtime exceeded maximum ({PUMP_CONFIG['MAX_RUNTIME']}s)")
                        return self.pump_state
                
                # Turn pump ON (HIGH = relay ON)
                GPIO.output(self.pump_pin, GPIO.HIGH)
                self.pump_state = True
                self.pump_start_time = time.time()
                logger.info("Pump turned ON")
            else:
                # Turn pump OFF (LOW = relay OFF)
                GPIO.output(self.pump_pin, GPIO.LOW)
                self.pump_state = False
                if self.pump_start_time:
                    runtime = time.time() - self.pump_start_time
                    logger.info(f"Pump turned OFF (runtime: {runtime:.1f}s)")
                    self.pump_start_time = None
                else:
                    logger.info("Pump turned OFF")
            
            return self.pump_state
            
        except Exception as e:
            logger.error(f"Error toggling pump: {e}")
            raise

    def get_pump_state(self):
        """Get current pump state"""
        return self.pump_state

    def read_temperature(self):
        """
        Read temperature from sensor
        Returns:
            dict: {'value': float, 'unit': 'C', 'timestamp': float}
        """
        try:
            if self.temp_sensor_type == 'analog':
                # For analog sensors with ADC (example using MCP3008)
                # This is a placeholder - implement based on your ADC hardware
                temperature = self._read_analog_temperature()
            elif self.temp_sensor_type == 'dht11':
                temperature = self._read_dht11()
            elif self.temp_sensor_type == 'dht22':
                temperature = self._read_dht22()
            elif self.temp_sensor_type == 'ds18b20':
                temperature = self._read_ds18b20()
            else:
                # Mock temperature for testing
                temperature = 25.5
            
            return {
                'value': round(temperature, 2),
                'unit': 'C',
                'timestamp': time.time()
            }
            
        except Exception as e:
            logger.error(f"Error reading temperature: {e}")
            # Return last known value or default
            return {
                'value': 0.0,
                'unit': 'C',
                'timestamp': time.time(),
                'error': str(e)
            }

    def _read_analog_temperature(self):
        """
        Read from analog temperature sensor via ADC
        Placeholder implementation - adapt for your ADC hardware
        """
        # TODO: Implement ADC reading if using analog sensor
        # Example with MCP3008:
        # import spidev
        # spi = spidev.SpiDev()
        # spi.open(0, 0)
        # adc_value = spi.xfer2([1, (8 + GPIO_CONFIG['ADC_CHANNEL']) << 4, 0])
        # data = ((adc_value[1] & 3) << 8) + adc_value[2]
        # voltage = data * 3.3 / 1024.0
        # temperature = voltage * 100.0  # Assuming LM35 sensor (10mV per degree)
        
        # Mock temperature for testing
        import random
        return 20 + random.uniform(-2, 5)

    def _read_dht11(self):
        """Read from DHT11 sensor"""
        try:
            import Adafruit_DHT
            humidity, temperature = Adafruit_DHT.read_retry(Adafruit_DHT.DHT11, self.temp_pin)
            if temperature is None:
                raise ValueError("Failed to read DHT11")
            return temperature
        except ImportError:
            logger.warning("Adafruit_DHT library not installed. Using mock value.")
            return 25.0

    def _read_dht22(self):
        """Read from DHT22 sensor"""
        try:
            import Adafruit_DHT
            humidity, temperature = Adafruit_DHT.read_retry(Adafruit_DHT.DHT22, self.temp_pin)
            if temperature is None:
                raise ValueError("Failed to read DHT22")
            return temperature
        except ImportError:
            logger.warning("Adafruit_DHT library not installed. Using mock value.")
            return 25.0

    def _read_ds18b20(self):
        """Read from DS18B20 1-wire sensor"""
        try:
            # DS18B20 reads from /sys/bus/w1/devices/
            # Implementation depends on 1-wire setup
            # Placeholder
            return 25.0
        except Exception as e:
            logger.error(f"Error reading DS18B20: {e}")
            return 25.0

    def cleanup(self):
        """Cleanup GPIO resources"""
        try:
            # Turn off pump
            if self.pump_state:
                GPIO.output(self.pump_pin, GPIO.LOW)
            
            GPIO.cleanup()
            logger.info("GPIO cleaned up")
        except Exception as e:
            logger.error(f"Error during GPIO cleanup: {e}")

