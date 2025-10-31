/**
 * WebSocket Client Service for Raspberry Pi Communication
 * Manages persistent WebSocket connections to Raspberry Pi devices
 */
const WebSocket = require('ws');
const EventEmitter = require('events');

class PiWebSocketClient extends EventEmitter {
  constructor(piUrl, deviceId) {
    super();
    this.piUrl = piUrl;
    this.deviceId = deviceId;
    this.ws = null;
    this.reconnectInterval = 5000; // 5 seconds
    this.reconnectTimer = null;
    this.messageQueue = [];
    this.isConnecting = false;
    this.isConnected = false;
    this.pendingRequests = new Map(); // Store pending requests with requestId
    this.requestCounter = 0;
    
    this.connect();
  }

  /**
   * Establish WebSocket connection to Raspberry Pi
   */
  connect() {
    if (this.isConnecting || (this.ws && this.ws.readyState === WebSocket.OPEN)) {
      return;
    }

    this.isConnecting = true;
    console.log(`[PiWebSocket] Connecting to Pi at ${this.piUrl}...`);

    try {
      this.ws = new WebSocket(this.piUrl);

      this.ws.on('open', () => {
        console.log(`[PiWebSocket] Connected to Pi device: ${this.deviceId}`);
        this.isConnected = true;
        this.isConnecting = false;
        this.emit('connected', this.deviceId);
        
        // Send queued messages
        this.flushMessageQueue();
      });

      this.ws.on('message', (data) => {
        try {
          const message = JSON.parse(data.toString());
          this.handleMessage(message);
        } catch (error) {
          console.error(`[PiWebSocket] Error parsing message:`, error);
        }
      });

      this.ws.on('close', () => {
        console.log(`[PiWebSocket] Connection closed for device: ${this.deviceId}`);
        this.isConnected = false;
        this.isConnecting = false;
        this.emit('disconnected', this.deviceId);
        
        // Attempt reconnection
        this.scheduleReconnect();
      });

      this.ws.on('error', (error) => {
        console.error(`[PiWebSocket] Error for device ${this.deviceId}:`, error.message);
        this.isConnecting = false;
        this.emit('error', { deviceId: this.deviceId, error });
        
        // Attempt reconnection
        this.scheduleReconnect();
      });

    } catch (error) {
      console.error(`[PiWebSocket] Connection error:`, error);
      this.isConnecting = false;
      this.scheduleReconnect();
    }
  }

  /**
   * Schedule reconnection attempt
   */
  scheduleReconnect() {
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer);
    }

    this.reconnectTimer = setTimeout(() => {
      console.log(`[PiWebSocket] Attempting to reconnect to ${this.deviceId}...`);
      this.connect();
    }, this.reconnectInterval);
  }

  /**
   * Handle incoming messages from Pi
   */
  handleMessage(message) {
    // Handle responses to pending requests
    if (message.requestId && this.pendingRequests.has(message.requestId)) {
      const { resolve, reject } = this.pendingRequests.get(message.requestId);
      this.pendingRequests.delete(message.requestId);
      
      if (message.success) {
        resolve(message.data || message);
      } else {
        reject(new Error(message.error || 'Unknown error'));
      }
      return;
    }

    // Handle unsolicited messages (sensor data, status updates)
    if (message.type === 'sensor_data') {
      this.emit('sensorData', {
        deviceId: this.deviceId,
        ...message.data
      });
    } else if (message.type === 'status_update') {
      this.emit('statusUpdate', {
        deviceId: this.deviceId,
        ...message.data
      });
    } else {
      this.emit('message', { deviceId: this.deviceId, message });
    }
  }

  /**
   * Send command to Pi
   * @param {string} action - Action to perform (e.g., 'toggle_pump', 'read_sensor')
   * @param {Object} params - Action parameters
   * @returns {Promise<Object>} Response from Pi
   */
  async sendCommand(action, params = {}) {
    return new Promise((resolve, reject) => {
      if (!this.isConnected || this.ws.readyState !== WebSocket.OPEN) {
        // Queue message if not connected
        this.messageQueue.push({ action, params, resolve, reject });
        reject(new Error(`Pi device ${this.deviceId} is not connected`));
        return;
      }

      const requestId = `req_${++this.requestCounter}_${Date.now()}`;
      const message = {
        requestId,
        action,
        params,
        timestamp: new Date().toISOString()
      };

      this.pendingRequests.set(requestId, { resolve, reject });

      // Set timeout for request (10 seconds)
      setTimeout(() => {
        if (this.pendingRequests.has(requestId)) {
          this.pendingRequests.delete(requestId);
          reject(new Error(`Request timeout for action: ${action}`));
        }
      }, 10000);

      try {
        this.ws.send(JSON.stringify(message));
      } catch (error) {
        this.pendingRequests.delete(requestId);
        reject(error);
      }
    });
  }

  /**
   * Flush queued messages after reconnection
   */
  flushMessageQueue() {
    while (this.messageQueue.length > 0) {
      const { action, params, resolve, reject } = this.messageQueue.shift();
      this.sendCommand(action, params)
        .then(resolve)
        .catch(reject);
    }
  }

  /**
   * Close connection
   */
  disconnect() {
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = null;
    }

    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }

    this.isConnected = false;
    this.isConnecting = false;
    this.messageQueue = [];
    this.pendingRequests.clear();
  }

  /**
   * Get connection status
   */
  getStatus() {
    return {
      url: this.piUrl,
      deviceId: this.deviceId,
      isConnected: this.isConnected,
      readyState: this.ws ? this.ws.readyState : WebSocket.CLOSED
    };
  }
}

/**
 * Pi Connection Manager
 * Manages multiple Pi device connections
 */
class PiConnectionManager {
  constructor() {
    this.connections = new Map(); // deviceId -> PiWebSocketClient
  }

  /**
   * Get or create connection to a Pi device
   * @param {string} deviceId - Device identifier
   * @param {string} piUrl - WebSocket URL (e.g., 'ws://192.168.1.100:8765')
   * @returns {PiWebSocketClient} WebSocket client instance
   */
  getConnection(deviceId, piUrl) {
    if (this.connections.has(deviceId)) {
      const client = this.connections.get(deviceId);
      // Update URL if changed
      if (client.piUrl !== piUrl) {
        client.disconnect();
        const newClient = new PiWebSocketClient(piUrl, deviceId);
        this.connections.set(deviceId, newClient);
        return newClient;
      }
      return client;
    }

    const client = new PiWebSocketClient(piUrl, deviceId);
    this.connections.set(deviceId, client);
    return client;
  }

  /**
   * Remove connection
   */
  removeConnection(deviceId) {
    if (this.connections.has(deviceId)) {
      this.connections.get(deviceId).disconnect();
      this.connections.delete(deviceId);
    }
  }

  /**
   * Get connection status for a device
   */
  getConnectionStatus(deviceId) {
    if (!this.connections.has(deviceId)) {
      return { isConnected: false, error: 'No connection found' };
    }
    return this.connections.get(deviceId).getStatus();
  }

  /**
   * Get all connections
   */
  getAllConnections() {
    return Array.from(this.connections.entries()).map(([deviceId, client]) => ({
      deviceId,
      status: client.getStatus()
    }));
  }
}

// Export singleton instance
module.exports = new PiConnectionManager();

