#!/usr/bin/env python3
"""
Test script for Raspberry Pi WebSocket server
Run this script to test the Pi WebSocket server directly
"""
import asyncio
import websockets
import json
from datetime import datetime

# ===== CONFIGURATION =====
# Change this to your Raspberry Pi's IP address
PI_WS_URL = "ws://192.168.1.100:8765"  # ← UPDATE THIS!

# ===== END CONFIGURATION =====

async def test_pi_connection():
    """Test connection and send commands to Pi"""
    try:
        print("=" * 60)
        print("Raspberry Pi WebSocket Server Test")
        print("=" * 60)
        print(f"\nConnecting to {PI_WS_URL}...")
        
        async with websockets.connect(PI_WS_URL) as websocket:
            print("✅ Connected to Pi!")
            
            # Wait for initial connection message
            print("\n📡 Waiting for initial connection message...")
            initial_msg = await websocket.recv()
            initial_data = json.loads(initial_msg)
            print(f"📨 Initial message:")
            print(json.dumps(initial_data, indent=2))
            
            # Test 1: Get Status
            print("\n" + "=" * 60)
            print("[Test 1] Getting system status...")
            print("=" * 60)
            await websocket.send(json.dumps({
                "action": "get_status",
                "requestId": "test-status-1",
                "params": {}
            }))
            response = await websocket.recv()
            print("Response:")
            print(json.dumps(json.loads(response), indent=2))
            
            await asyncio.sleep(1)
            
            # Test 2: Read Sensor
            print("\n" + "=" * 60)
            print("[Test 2] Reading temperature sensor...")
            print("=" * 60)
            await websocket.send(json.dumps({
                "action": "read_sensor",
                "requestId": "test-sensor-1",
                "params": {
                    "sensorType": "temperature"
                }
            }))
            response = await websocket.recv()
            print("Response:")
            print(json.dumps(json.loads(response), indent=2))
            
            await asyncio.sleep(1)
            
            # Test 3: Turn Pump ON
            print("\n" + "=" * 60)
            print("[Test 3] Turning pump ON...")
            print("=" * 60)
            await websocket.send(json.dumps({
                "action": "pump_on",
                "requestId": "test-pump-on-1",
                "params": {}
            }))
            response = await websocket.recv()
            print("Response:")
            print(json.dumps(json.loads(response), indent=2))
            
            await asyncio.sleep(2)
            
            # Test 4: Turn Pump OFF
            print("\n" + "=" * 60)
            print("[Test 4] Turning pump OFF...")
            print("=" * 60)
            await websocket.send(json.dumps({
                "action": "pump_off",
                "requestId": "test-pump-off-1",
                "params": {}
            }))
            response = await websocket.recv()
            print("Response:")
            print(json.dumps(json.loads(response), indent=2))
            
            await asyncio.sleep(1)
            
            # Test 5: Toggle Pump (with state)
            print("\n" + "=" * 60)
            print("[Test 5] Toggling pump ON (with state parameter)...")
            print("=" * 60)
            await websocket.send(json.dumps({
                "action": "toggle_pump",
                "requestId": "test-toggle-1",
                "params": {
                    "state": True
                }
            }))
            response = await websocket.recv()
            print("Response:")
            print(json.dumps(json.loads(response), indent=2))
            
            await asyncio.sleep(2)
            
            # Test 6: Toggle Pump (without state - should toggle)
            print("\n" + "=" * 60)
            print("[Test 6] Toggling pump (without state parameter)...")
            print("=" * 60)
            await websocket.send(json.dumps({
                "action": "toggle_pump",
                "requestId": "test-toggle-2",
                "params": {}
            }))
            response = await websocket.recv()
            print("Response:")
            print(json.dumps(json.loads(response), indent=2))
            
            await asyncio.sleep(2)
            
            # Test 7: Listen for automatic sensor push (wait 12 seconds)
            print("\n" + "=" * 60)
            print("[Test 7] Waiting for automatic sensor push...")
            print("=" * 60)
            print("(This should arrive automatically every 10 seconds)")
            print("Waiting up to 12 seconds...")
            try:
                sensor_push = await asyncio.wait_for(websocket.recv(), timeout=12.0)
                print("\n📊 Sensor push received:")
                print(json.dumps(json.loads(sensor_push), indent=2))
            except asyncio.TimeoutError:
                print("⚠️ No sensor push received within 12 seconds")
                print("   (This may be normal if auto-push is disabled in config)")
            
            print("\n" + "=" * 60)
            print("✅ All tests completed!")
            print("=" * 60)
            
    except websockets.exceptions.InvalidURI:
        print(f"\n❌ Error: Invalid WebSocket URL: {PI_WS_URL}")
        print("   Format should be: ws://IP_ADDRESS:8765")
        print("   Example: ws://192.168.1.100:8765")
    except ConnectionRefusedError:
        print(f"\n❌ Error: Connection refused to {PI_WS_URL}")
        print("\nTroubleshooting:")
        print("   1. Check Pi WebSocket server is running:")
        print("      On Pi: cd /home/alok/ekrishi && python3 server.py")
        print("   2. Verify Pi IP address is correct")
        print("      On Pi: hostname -I")
        print("   3. Check firewall allows port 8765")
        print("      On Pi: sudo ufw allow 8765")
        print("   4. Test connection:")
        print(f"      telnet {PI_WS_URL.replace('ws://', '').split(':')[0]} 8765")
    except OSError as e:
        if "Name or service not known" in str(e):
            print(f"\n❌ Error: Cannot resolve hostname in {PI_WS_URL}")
            print("   Check the IP address is correct")
        else:
            print(f"\n❌ Connection error: {e}")
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    print("\n⚠️  Make sure to update PI_WS_URL in this script with your Pi's IP address!")
    print("   Current URL:", PI_WS_URL)
    print()
    
    try:
        asyncio.run(test_pi_connection())
    except KeyboardInterrupt:
        print("\n\n⚠️  Test interrupted by user")
    except Exception as e:
        print(f"\n❌ Fatal error: {e}")

