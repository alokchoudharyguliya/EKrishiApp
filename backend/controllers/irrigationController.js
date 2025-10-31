/**
 * Irrigation Controller - Handles irrigation system requests
 */
const piWebSocketService = require('../services/piWebSocketService');
const IrrigationDevice = require('../models/irrigationDevice');
const IrrigationEvent = require('../models/irrigationEvent');
const SensorReading = require('../models/sensorReading');

/**
 * Toggle pump on/off
 * POST /api/irrigation/pump/toggle
 */
exports.togglePump = async (req, res) => {
  try {
    const userId = req.user?.id || req.user?.userId || req.user?._id;
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'User authentication required'
      });
    }

    const { deviceId, state } = req.body;

    if (!deviceId) {
      return res.status(400).json({
        success: false,
        message: 'Device ID is required'
      });
    }

    // Verify device belongs to user
    const device = await IrrigationDevice.findOne({ userId, deviceId, isActive: true });
    if (!device) {
      return res.status(404).json({
        success: false,
        message: 'Irrigation device not found or inactive'
      });
    }

    // Get or create WebSocket connection
    const piClient = piWebSocketService.getConnection(deviceId, device.piUrl);

    // Determine action
    const action = state !== undefined ? (state ? 'pump_on' : 'pump_off') : 'pump_toggle';

    // Send command to Pi
    const result = await piClient.sendCommand(action, { state: state !== undefined ? state : null });

    // Save event to database
    const event = new IrrigationEvent({
      userId,
      deviceId,
      action,
      state: result.state || state,
      triggeredBy: 'user',
      metadata: {
        requestId: result.requestId,
        response: result
      }
    });
    await event.save();

    // Update device last seen
    device.lastSeen = new Date();
    await device.save();

    res.status(200).json({
      success: true,
      message: `Pump ${result.state ? 'turned ON' : 'turned OFF'}`,
      data: {
        deviceId,
        state: result.state,
        timestamp: new Date()
      }
    });

  } catch (error) {
    console.error('[IrrigationController] Toggle pump error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to toggle pump',
      error: error.message
    });
  }
};

/**
 * Get current sensor readings
 * GET /api/irrigation/sensor/read
 */
exports.readSensor = async (req, res) => {
  try {
    const userId = req.user?.id || req.user?.userId || req.user?._id;
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'User authentication required'
      });
    }

    const { deviceId, sensorType } = req.query;

    if (!deviceId) {
      return res.status(400).json({
        success: false,
        message: 'Device ID is required'
      });
    }

    // Verify device belongs to user
    const device = await IrrigationDevice.findOne({ userId, deviceId, isActive: true });
    if (!device) {
      return res.status(404).json({
        success: false,
        message: 'Irrigation device not found or inactive'
      });
    }

    // Get or create WebSocket connection
    const piClient = piWebSocketService.getConnection(deviceId, device.piUrl);

    // Send read sensor command
    const result = await piClient.sendCommand('read_sensor', {
      sensorType: sensorType || 'temperature'
    });

    // Save reading to database
    if (result.sensorData) {
      const reading = new SensorReading({
        userId,
        deviceId,
        sensorType: sensorType || 'temperature',
        value: result.sensorData.value,
        unit: result.sensorData.unit || 'C',
        metadata: {
          requestId: result.requestId,
          rawResponse: result
        }
      });
      await reading.save();
    }

    // Update device last seen
    device.lastSeen = new Date();
    await device.save();

    res.status(200).json({
      success: true,
      data: {
        deviceId,
        sensorType: sensorType || 'temperature',
        value: result.sensorData?.value || null,
        unit: result.sensorData?.unit || 'C',
        timestamp: new Date()
      }
    });

  } catch (error) {
    console.error('[IrrigationController] Read sensor error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to read sensor',
      error: error.message
    });
  }
};

/**
 * Get system status
 * GET /api/irrigation/status
 */
exports.getStatus = async (req, res) => {
  try {
    const userId = req.user?.id || req.user?.userId || req.user?._id;
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'User authentication required'
      });
    }

    const { deviceId } = req.query;

    if (!deviceId) {
      return res.status(400).json({
        success: false,
        message: 'Device ID is required'
      });
    }

    // Verify device belongs to user
    const device = await IrrigationDevice.findOne({ userId, deviceId, isActive: true });
    if (!device) {
      return res.status(404).json({
        success: false,
        message: 'Irrigation device not found or inactive'
      });
    }

    // Get connection status
    const connectionStatus = piWebSocketService.getConnectionStatus(deviceId);

    // Get latest sensor reading
    const latestReading = await SensorReading.findOne(
      { userId, deviceId },
      {},
      { sort: { timestamp: -1 } }
    );

    // Get latest pump event
    const latestEvent = await IrrigationEvent.findOne(
      { userId, deviceId },
      {},
      { sort: { createdAt: -1 } }
    );

    res.status(200).json({
      success: true,
      data: {
        deviceId: device.deviceId,
        deviceName: device.deviceName,
        connectionStatus: {
          isConnected: connectionStatus.isConnected,
          url: connectionStatus.url
        },
        currentState: {
          pumpState: latestEvent?.state || false,
          lastPumpAction: latestEvent?.createdAt || null
        },
        sensorData: latestReading ? {
          type: latestReading.sensorType,
          value: latestReading.value,
          unit: latestReading.unit,
          timestamp: latestReading.timestamp
        } : null,
        lastSeen: device.lastSeen
      }
    });

  } catch (error) {
    console.error('[IrrigationController] Get status error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get status',
      error: error.message
    });
  }
};

/**
 * Get sensor reading history
 * GET /api/irrigation/sensor/history
 */
exports.getSensorHistory = async (req, res) => {
  try {
    const userId = req.user?.id || req.user?.userId || req.user?._id;
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'User authentication required'
      });
    }

    const { deviceId, sensorType, limit = 100, startDate, endDate } = req.query;

    if (!deviceId) {
      return res.status(400).json({
        success: false,
        message: 'Device ID is required'
      });
    }

    // Verify device belongs to user
    const device = await IrrigationDevice.findOne({ userId, deviceId, isActive: true });
    if (!device) {
      return res.status(404).json({
        success: false,
        message: 'Irrigation device not found or inactive'
      });
    }

    // Build query
    const query = { userId, deviceId };
    if (sensorType) {
      query.sensorType = sensorType;
    }
    if (startDate || endDate) {
      query.timestamp = {};
      if (startDate) query.timestamp.$gte = new Date(startDate);
      if (endDate) query.timestamp.$lte = new Date(endDate);
    }

    // Fetch readings
    const readings = await SensorReading.find(query)
      .sort({ timestamp: -1 })
      .limit(parseInt(limit))
      .select('sensorType value unit timestamp');

    res.status(200).json({
      success: true,
      data: {
        deviceId,
        count: readings.length,
        readings: readings.reverse() // Return in chronological order
      }
    });

  } catch (error) {
    console.error('[IrrigationController] Get sensor history error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get sensor history',
      error: error.message
    });
  }
};

/**
 * Register a new irrigation device
 * POST /api/irrigation/device/register
 */
exports.registerDevice = async (req, res) => {
  try {
    const userId = req.user?.id || req.user?.userId || req.user?._id;
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'User authentication required'
      });
    }

    const { deviceId, deviceName, piUrl, location } = req.body;

    if (!deviceId || !piUrl) {
      return res.status(400).json({
        success: false,
        message: 'Device ID and Pi URL are required'
      });
    }

    // Validate WebSocket URL format
    if (!/^ws:\/\/.+:\d+$/.test(piUrl)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid WebSocket URL format. Use: ws://IP:PORT (e.g., ws://192.168.1.100:8765)'
      });
    }

    // Check if device already exists
    const existingDevice = await IrrigationDevice.findOne({ deviceId });
    if (existingDevice) {
      if (existingDevice.userId.toString() !== userId.toString()) {
        return res.status(403).json({
          success: false,
          message: 'Device already registered to another user'
        });
      }
      // Update existing device
      existingDevice.piUrl = piUrl;
      existingDevice.deviceName = deviceName || existingDevice.deviceName;
      existingDevice.location = location || existingDevice.location;
      existingDevice.isActive = true;
      await existingDevice.save();

      return res.status(200).json({
        success: true,
        message: 'Device updated',
        data: existingDevice
      });
    }

    // Create new device
    const device = new IrrigationDevice({
      userId,
      deviceId,
      deviceName: deviceName || `Irrigation Device ${deviceId}`,
      piUrl,
      location: location || '',
      isActive: true
    });
    await device.save();

    // Initialize WebSocket connection
    piWebSocketService.getConnection(deviceId, piUrl);

    res.status(201).json({
      success: true,
      message: 'Device registered successfully',
      data: device
    });

  } catch (error) {
    console.error('[IrrigationController] Register device error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to register device',
      error: error.message
    });
  }
};

/**
 * Get user's registered irrigation device
 * GET /api/irrigation/device
 */
exports.getDevice = async (req, res) => {
  try {
    const userId = req.user?.id || req.user?.userId || req.user?._id;
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'User authentication required'
      });
    }

    // Find user's active device
    const device = await IrrigationDevice.findOne({ userId, isActive: true });

    if (!device) {
      return res.status(404).json({
        success: false,
        message: 'No device registered',
        data: null
      });
    }

    res.status(200).json({
      success: true,
      data: {
        deviceId: device.deviceId,
        deviceName: device.deviceName,
        piUrl: device.piUrl,
        location: device.location,
        isActive: device.isActive,
        lastSeen: device.lastSeen,
        createdAt: device.createdAt
      }
    });

  } catch (error) {
    console.error('[IrrigationController] Get device error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get device',
      error: error.message
    });
  }
};

