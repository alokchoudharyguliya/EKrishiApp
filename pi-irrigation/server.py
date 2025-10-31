"""
Raspberry Pi Irrigation System - WebSocket Server
Receives commands from Node.js backend and controls GPIO
"""
import asyncio
import websockets
import json
import logging
import signal
import sys
from datetime import datetime
from config import WS_CONFIG, SENSOR_CONFIG, LOG_CONFIG
from gpio_controller import GPIOController

# Setup logging
logging.basicConfig(
    level=getattr(logging, LOG_CONFIG['LEVEL']),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_CONFIG['FILE']) if LOG_CONFIG.get('FILE') else logging.NullHandler(),
        logging.StreamHandler() if LOG_CONFIG['ENABLE_CONSOLE'] else logging.NullHandler()
    ]
)
logger = logging.getLogger(__name__)

# Global GPIO controller
gpio_controller = None
connected_clients = set()
sensor_task = None

async def handle_client(websocket, path):
    """
    Handle WebSocket client connection
    """
    client_addr = websocket.remote_address
    logger.info(f"Client connected from {client_addr}")
    connected_clients.add(websocket)
    
    try:
        # Send initial connection acknowledgment
        await websocket.send(json.dumps({
            'type': 'connection',
            'status': 'connected',
            'message': 'Connected to Raspberry Pi Irrigation System',
            'timestamp': datetime.now().isoformat()
        }))
        
        # Listen for messages
        async for message in websocket:
            try:
                data = json.loads(message)
                logger.debug(f"Received message: {data}")
                
                # Process command
                response = await process_command(data)
                
                # Send response back
                await websocket.send(json.dumps(response))
                
            except json.JSONDecodeError as e:
                logger.error(f"Invalid JSON received: {e}")
                await websocket.send(json.dumps({
                    'requestId': data.get('requestId') if 'data' in locals() else None,
                    'success': False,
                    'error': 'Invalid JSON format'
                }))
            except Exception as e:
                logger.error(f"Error processing message: {e}", exc_info=True)
                await websocket.send(json.dumps({
                    'requestId': data.get('requestId') if 'data' in locals() else None,
                    'success': False,
                    'error': str(e)
                }))
                
    except websockets.exceptions.ConnectionClosed:
        logger.info(f"Client {client_addr} disconnected")
    except Exception as e:
        logger.error(f"Error with client {client_addr}: {e}", exc_info=True)
    finally:
        connected_clients.discard(websocket)
        logger.info(f"Client {client_addr} removed from connected clients")

async def process_command(data):
    """
    Process incoming command from backend
    """
    request_id = data.get('requestId', 'unknown')
    action = data.get('action')
    params = data.get('params', {})
    
    logger.info(f"Processing command: {action} (requestId: {request_id})")
    
    try:
        if action == 'toggle_pump' or action == 'pump_toggle':
            state = params.get('state')
            new_state = gpio_controller.toggle_pump(state)
            
            return {
                'requestId': request_id,
                'success': True,
                'data': {
                    'action': action,
                    'state': new_state,
                    'message': f"Pump turned {'ON' if new_state else 'OFF'}"
                }
            }
            
        elif action == 'pump_on':
            state = gpio_controller.toggle_pump(True)
            return {
                'requestId': request_id,
                'success': True,
                'data': {
                    'action': action,
                    'state': state,
                    'message': 'Pump turned ON'
                }
            }
            
        elif action == 'pump_off':
            state = gpio_controller.toggle_pump(False)
            return {
                'requestId': request_id,
                'success': True,
                'data': {
                    'action': action,
                    'state': state,
                    'message': 'Pump turned OFF'
                }
            }
            
        elif action == 'read_sensor':
            sensor_type = params.get('sensorType', 'temperature')
            if sensor_type == 'temperature':
                sensor_data = gpio_controller.read_temperature()
                return {
                    'requestId': request_id,
                    'success': True,
                    'sensorData': sensor_data
                }
            else:
                return {
                    'requestId': request_id,
                    'success': False,
                    'error': f'Unsupported sensor type: {sensor_type}'
                }
                
        elif action == 'get_status':
            pump_state = gpio_controller.get_pump_state()
            temp_data = gpio_controller.read_temperature()
            
            return {
                'requestId': request_id,
                'success': True,
                'data': {
                    'pumpState': pump_state,
                    'temperature': temp_data,
                    'timestamp': datetime.now().isoformat()
                }
            }
            
        else:
            return {
                'requestId': request_id,
                'success': False,
                'error': f'Unknown action: {action}'
            }
            
    except Exception as e:
        logger.error(f"Error executing command {action}: {e}", exc_info=True)
        return {
            'requestId': request_id,
            'success': False,
            'error': str(e)
        }

async def push_sensor_data():
    """
    Periodically push sensor data to all connected clients
    """
    while True:
        try:
            await asyncio.sleep(SENSOR_CONFIG['READ_INTERVAL'])
            
            if not connected_clients:
                continue
            
            # Read sensor
            sensor_data = gpio_controller.read_temperature()
            pump_state = gpio_controller.get_pump_state()
            
            # Prepare message
            message = {
                'type': 'sensor_data',
                'data': {
                    'temperature': sensor_data,
                    'pumpState': pump_state,
                    'timestamp': datetime.now().isoformat()
                }
            }
            
            # Send to all connected clients
            disconnected = set()
            for client in connected_clients:
                try:
                    await client.send(json.dumps(message))
                except websockets.exceptions.ConnectionClosed:
                    disconnected.add(client)
                except Exception as e:
                    logger.error(f"Error sending sensor data: {e}")
                    disconnected.add(client)
            
            # Remove disconnected clients
            connected_clients -= disconnected
            
            logger.debug(f"Pushed sensor data to {len(connected_clients)} clients")
            
        except Exception as e:
            logger.error(f"Error in sensor push loop: {e}", exc_info=True)
            await asyncio.sleep(5)  # Wait before retrying

def signal_handler(signum, frame):
    """
    Handle shutdown signals gracefully
    """
    logger.info("Shutdown signal received. Cleaning up...")
    if gpio_controller:
        gpio_controller.cleanup()
    sys.exit(0)

async def main():
    """
    Main server function
    """
    global gpio_controller, sensor_task
    
    # Setup signal handlers
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Initialize GPIO controller
    try:
        gpio_controller = GPIOController()
        logger.info("GPIO Controller initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize GPIO Controller: {e}")
        sys.exit(1)
    
    # Start sensor data push task if enabled
    if SENSOR_CONFIG['ENABLE_AUTO_PUSH']:
        sensor_task = asyncio.create_task(push_sensor_data())
        logger.info(f"Sensor auto-push enabled (interval: {SENSOR_CONFIG['READ_INTERVAL']}s)")
    
    # Start WebSocket server
    host = WS_CONFIG['HOST']
    port = WS_CONFIG['PORT']
    
    logger.info(f"Starting WebSocket server on {host}:{port}")
    
    async with websockets.serve(handle_client, host, port):
        logger.info(f"WebSocket server started and listening on ws://{host}:{port}")
        try:
            await asyncio.Future()  # Run forever
        except KeyboardInterrupt:
            logger.info("Server shutting down...")
        finally:
            # Cleanup
            if sensor_task:
                sensor_task.cancel()
            if gpio_controller:
                gpio_controller.cleanup()
            logger.info("Server stopped")

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("Server interrupted by user")
        if gpio_controller:
            gpio_controller.cleanup()

