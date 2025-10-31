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
    console.log(`[PiWebSocket] Connecting to Pi at ${this.piUrl} for device ${this.deviceId}...`);

    try {
      this.ws = new WebSocket(this.piUrl);
      console.log(`[PiWebSocket] WebSocket instance created, waiting for connection...`);

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
        console.error(`[PiWebSocket] Error details:`, error);
        console.error(`[PiWebSocket] Connection URL was: ${this.piUrl}`);
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
    // Handle initial connection acknowledgment from Pi server
    if (message.type === 'connection' && message.status === 'connected') {
      console.log(`[PiWebSocket] Received connection acknowledgment from Pi device: ${this.deviceId}`);
      // Connection is confirmed - this happens after 'open' event
      // We already handle connection state in 'open' event, so just emit
      this.emit('connectionAcknowledged', { deviceId: this.deviceId, message: message.message });
      return;
    }

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
   * Wait for connection to be established
   * @param {number} timeout - Maximum time to wait in milliseconds (default: 10000)
   * @returns {Promise<void>} Resolves when connected, rejects on timeout
   */
  async waitForConnection(timeout = 10000) {
    // If already connected, return immediately
    if (this.isConnected && this.ws && this.ws.readyState === WebSocket.OPEN) {
      return Promise.resolve();
    }

    return new Promise((resolve, reject) => {
      // Check if already connected (race condition)
      if (this.isConnected && this.ws && this.ws.readyState === WebSocket.OPEN) {
        resolve();
        return;
      }

      // Set up timeout
      const timeoutId = setTimeout(() => {
        this.removeListener('connected', onConnected);
        this.removeListener('error', onError);
        reject(new Error(`Connection timeout for device ${this.deviceId} after ${timeout}ms`));
      }, timeout);

      // Set up success handler
      const onConnected = (deviceId) => {
        if (deviceId === this.deviceId) {
          clearTimeout(timeoutId);
          this.removeListener('connected', onConnected);
          this.removeListener('error', onError);
          resolve();
        }
      };

      // Set up error handler
      const onError = ({ deviceId, error }) => {
        if (deviceId === this.deviceId) {
          clearTimeout(timeoutId);
          this.removeListener('connected', onConnected);
          this.removeListener('error', onError);
          reject(new Error(`Connection error for device ${deviceId}: ${error.message || error}`));
        }
      };

      // Listen for connection events
      this.once('connected', onConnected);
      this.once('error', onError);

      // If not connecting, start connection
      if (!this.isConnecting && (!this.ws || this.ws.readyState === WebSocket.CLOSED)) {
        this.connect();
      }
    });
  }

  /**
   * Send command to Pi
   * @param {string} action - Action to perform (e.g., 'toggle_pump', 'read_sensor')
   * @param {Object} params - Action parameters
   * @param {number} connectionTimeout - Time to wait for connection if not connected (default: 10000)
   * @returns {Promise<Object>} Response from Pi
   */
  async sendCommand(action, params = {}, connectionTimeout = 10000) {
    // Wait for connection if not connected
    if (!this.isConnected || !this.ws || this.ws.readyState !== WebSocket.OPEN) {
      try {
        await this.waitForConnection(connectionTimeout);
      } catch (error) {
        // If connection fails, queue the message for later
        return new Promise((resolve, reject) => {
          this.messageQueue.push({ action, params, resolve, reject });
          reject(new Error(`Pi device ${this.deviceId} is not connected: ${error.message}`));
        });
      }
    }

    return new Promise((resolve, reject) => {
      // Double-check connection after wait
      if (!this.isConnected || !this.ws || this.ws.readyState !== WebSocket.OPEN) {
        reject(new Error(`Pi device ${this.deviceId} is not connected after wait`));
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
    const readyState = this.ws ? this.ws.readyState : WebSocket.CLOSED;
    let stateDescription = 'CLOSED';
    if (readyState === WebSocket.CONNECTING) stateDescription = 'CONNECTING';
    else if (readyState === WebSocket.OPEN) stateDescription = 'OPEN';
    else if (readyState === WebSocket.CLOSING) stateDescription = 'CLOSING';

    return {
      url: this.piUrl,
      deviceId: this.deviceId,
      isConnected: this.isConnected && readyState === WebSocket.OPEN,
      isConnecting: this.isConnecting,
      readyState: readyState,
      readyStateDescription: stateDescription
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
    console.log(`[PiWebSocket] getConnection called for deviceId: ${deviceId}, piUrl: ${piUrl}`);
    
    if (this.connections.has(deviceId)) {
      const client = this.connections.get(deviceId);
      console.log(`[PiWebSocket] Existing connection found for device ${deviceId}`);
      // Update URL if changed
      if (client.piUrl !== piUrl) {
        console.log(`[PiWebSocket] URL changed for device ${deviceId}, updating connection`);
        client.disconnect();
        const newClient = new PiWebSocketClient(piUrl, deviceId);
        console.log(`[PiWebSocket] Updated connection to Pi device: ${deviceId}`);
        this.connections.set(deviceId, newClient);
        return newClient;
      }
      console.log(`[PiWebSocket] Returning existing connection for device ${deviceId}`);
      return client;
    }

    console.log(`[PiWebSocket] Creating new connection for device ${deviceId} with URL: ${piUrl}`);
    const client = new PiWebSocketClient(piUrl, deviceId);
    this.connections.set(deviceId, client);
    console.log(`[PiWebSocket] New connection created and stored for device ${deviceId}`);
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
    console.log(`[PiWebSocket] getConnectionStatus called for deviceId: ${deviceId}`);
    console.log(`[PiWebSocket] Current connections Map keys:`, Array.from(this.connections.keys()));
    
    if (!this.connections.has(deviceId)) {
      console.log(`[PiWebSocket] No connection found for deviceId: ${deviceId}`);
      return { isConnected: false, error: 'No connection found' };
    }
    
    const status = this.connections.get(deviceId).getStatus();
    console.log(`[PiWebSocket] Connection status for deviceId ${deviceId}:`, status);
    return status;
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

