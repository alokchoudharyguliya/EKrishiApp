/**
 * Irrigation Controller - Handles irrigation system requests
 */
const piWebSocketService = require('../services/piWebSocketService');
const IrrigationDevice = require('../models/irrigationDevice');
const IrrigationEvent = require('../models/irrigationEvent');
const SensorReading = require('../models/sensorReading');
const Event = require('../models/event');

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
    console.log(req.body);
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
    console.log(deviceId, userId);
    // Verify device belongs to user
    const device = await IrrigationDevice.findOne({deviceId});
    if (!device) {
      return res.status(404).json({
        success: false,
        message: 'Irrigation device not found or inactive'
      });
    }

    // Ensure connection exists (creates if not exists, returns existing if exists)
    const piClient = piWebSocketService.getConnection(deviceId, device.piUrl);
    console.log(`[IrrigationController] Connection client retrieved for device ${deviceId}, piUrl: ${device.piUrl}`);
    
    // Get connection status
    const connectionStatus = piClient.getStatus();
    console.log(`[IrrigationController] Connection status for device ${deviceId}:`, connectionStatus);

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
          isConnecting: connectionStatus.isConnecting,
          url: connectionStatus.url || device.piUrl,
          readyState: connectionStatus.readyStateDescription || 'UNKNOWN',
          error: connectionStatus.error || null
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

      // Reinitialize WebSocket connection with new URL
      const piClient = piWebSocketService.getConnection(deviceId, piUrl);
      
      // Verify connection can be established (with timeout)
      try {
        await piClient.waitForConnection(8000); // 8 second timeout
        console.log(`[IrrigationController] Successfully connected to device ${deviceId} during update`);
      } catch (error) {
        console.warn(`[IrrigationController] Could not establish connection to device ${deviceId} during update: ${error.message}`);
        // Continue with update even if connection fails - connection will retry automatically
      }

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
    const piClient = piWebSocketService.getConnection(deviceId, piUrl);
    
    // Verify connection can be established (with timeout)
    try {
      await piClient.waitForConnection(8000); // 8 second timeout for registration
      console.log(`[IrrigationController] Successfully connected to device ${deviceId} during registration`);
    } catch (error) {
      console.warn(`[IrrigationController] Could not establish connection to device ${deviceId} during registration: ${error.message}`);
      // Continue with registration even if connection fails - connection will retry automatically
    }

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

/**
 * Get pump timing statistics for last 7 days
 * GET /api/irrigation/pump/timings
 */
exports.getPumpTimings = async (req, res) => {
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

    // Get latest pump event to check if pump is currently ON
    const latestEvent = await IrrigationEvent.findOne(
      { userId, deviceId },
      {},
      { sort: { createdAt: -1 } }
    );

    const now = new Date();
    const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

    // Fetch all pump events from last 7 days
    const events = await IrrigationEvent.find({
      userId,
      deviceId,
      createdAt: { $gte: sevenDaysAgo },
      action: { $in: ['pump_on', 'pump_off'] }
    })
      .sort({ createdAt: 1 }) // Sort chronologically
      .select('action state createdAt');

    // Initialize day totals (Mon-Sun)
    const dayTotals = {
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0
    };

    // Track if pump is currently on and when it started
    let pumpOnStart = null;
    if (latestEvent && latestEvent.state === true) {
      pumpOnStart = latestEvent.createdAt;
    }

    // Process events to calculate durations
    for (let i = 0; i < events.length; i++) {
      const event = events[i];
      const eventDate = new Date(event.createdAt);

      if (event.state === true) {
        // Pump turned ON - record start time
        pumpOnStart = eventDate;
      } else if (event.state === false && pumpOnStart !== null) {
        // Pump turned OFF - calculate duration
        const durationMs = eventDate.getTime() - pumpOnStart.getTime();
        const durationHours = durationMs / (1000 * 60 * 60);

        // Get day of week (0 = Sunday, 1 = Monday, ..., 6 = Saturday)
        const dayIndex = eventDate.getDay();
        const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        const dayName = dayNames[dayIndex];

        dayTotals[dayName] += durationHours;
        pumpOnStart = null;
      }
    }

    // If pump is still ON, calculate duration from last ON event to now
    if (pumpOnStart !== null) {
      const durationMs = now.getTime() - pumpOnStart.getTime();
      const durationHours = durationMs / (1000 * 60 * 60);

      // Get day of week for current time
      const dayIndex = now.getDay();
      const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      const dayName = dayNames[dayIndex];

      dayTotals[dayName] += durationHours;
    }

    // Format response data (order: Mon-Sun)
    const timingsData = [
      { day: 'Mon', hours: parseFloat(dayTotals['Mon'].toFixed(2)) },
      { day: 'Tue', hours: parseFloat(dayTotals['Tue'].toFixed(2)) },
      { day: 'Wed', hours: parseFloat(dayTotals['Wed'].toFixed(2)) },
      { day: 'Thu', hours: parseFloat(dayTotals['Thu'].toFixed(2)) },
      { day: 'Fri', hours: parseFloat(dayTotals['Fri'].toFixed(2)) },
      { day: 'Sat', hours: parseFloat(dayTotals['Sat'].toFixed(2)) },
      { day: 'Sun', hours: parseFloat(dayTotals['Sun'].toFixed(2)) }
    ];

    res.status(200).json({
      success: true,
      data: {
        deviceId,
        timings: timingsData,
        period: 'last_7_days'
      }
    });

  } catch (error) {
    console.error('[IrrigationController] Get pump timings error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get pump timings',
      error: error.message
    });
  }
};

/**
 * Get next scheduled irrigation for a device
 * GET /api/irrigation/schedule/next
 */
exports.getNextScheduled = async (req, res) => {
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

    // Find next scheduled irrigation event
    // Look for events where:
    // - activityType is 'Irrigation'
    // - irrigationSettings.deviceId matches
    // - irrigationSettings.enabled is true
    // - irrigationSettings.isExecuted is false
    // - Event is not deleted
    // - Scheduled time is in the future
    const now = new Date();
    
    const nextEvent = await Event.findOne({
      userId,
      activityType: 'Irrigation',
      'irrigationSettings.deviceId': deviceId,
      'irrigationSettings.enabled': true,
      'irrigationSettings.isExecuted': false,
      isDeleted: false,
      $or: [
        { 
          eventMode: 'timed', 
          startTime: { $gt: now } 
        },
        { 
          eventMode: 'all-day', 
          start_date: { $gt: now } 
        }
      ]
    })
    .sort({ 
      startTime: 1, 
      start_date: 1 
    })
    .select('title startTime start_date irrigationSettings eventMode');

    if (!nextEvent) {
      return res.status(200).json({
        success: true,
        data: {
          deviceId,
          hasSchedule: false,
          nextScheduledTime: null,
          message: 'No scheduled irrigation found'
        }
      });
    }

    // Determine the scheduled time
    const scheduledTime = nextEvent.eventMode === 'timed' && nextEvent.startTime
      ? nextEvent.startTime
      : nextEvent.start_date;

    // Format time for display
    const timeUntil = scheduledTime - now;
    const daysUntil = Math.floor(timeUntil / (1000 * 60 * 60 * 24));
    const hoursUntil = Math.floor((timeUntil % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutesUntil = Math.floor((timeUntil % (1000 * 60 * 60)) / (1000 * 60));

    let displayText = '';
    if (daysUntil > 0) {
      displayText = daysUntil === 1 ? 'Tomorrow' : `In ${daysUntil} days`;
      // Add time if it's a timed event
      if (nextEvent.eventMode === 'timed' && nextEvent.startTime) {
        const hours = nextEvent.startTime.getHours();
        const minutes = nextEvent.startTime.getMinutes();
        const ampm = hours >= 12 ? 'PM' : 'AM';
        const displayHours = hours % 12 || 12;
        const displayMinutes = minutes.toString().padStart(2, '0');
        displayText += `, ${displayHours}:${displayMinutes} ${ampm}`;
      }
    } else if (hoursUntil > 0) {
      displayText = `In ${hoursUntil} hour${hoursUntil > 1 ? 's' : ''}`;
      if (minutesUntil > 0) {
        displayText += ` ${minutesUntil} minute${minutesUntil > 1 ? 's' : ''}`;
      }
    } else if (minutesUntil > 0) {
      displayText = `In ${minutesUntil} minute${minutesUntil > 1 ? 's' : ''}`;
    } else {
      displayText = 'Due now';
    }

    res.status(200).json({
      success: true,
      data: {
        deviceId,
        hasSchedule: true,
        nextScheduledTime: scheduledTime,
        scheduledDateTime: scheduledTime.toISOString(),
        displayText: displayText,
        duration: nextEvent.irrigationSettings?.duration || 30,
        eventId: nextEvent._id,
        eventTitle: nextEvent.title
      }
    });

  } catch (error) {
    console.error('[IrrigationController] Get next scheduled error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get next scheduled irrigation',
      error: error.message
    });
  }
};

/**
 * Create irrigation schedule (creates an Event with irrigationSettings)
 * POST /api/irrigation/schedule
 */
exports.createIrrigationSchedule = async (req, res) => {
  try {
    const userId = req.user?.id || req.user?.userId || req.user?._id;
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'User authentication required'
      });
    }

    const {
      deviceId,
      title,
      startTime, // Date/time for timed events
      startDate, // Date for all-day events
      duration = 30,
      eventMode = 'timed', // 'timed' or 'all-day'
      recurrence,
      description
    } = req.body;

    if (!deviceId) {
      return res.status(400).json({
        success: false,
        message: 'Device ID is required'
      });
    }

    if (!title) {
      return res.status(400).json({
        success: false,
        message: 'Title is required'
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

    // Determine scheduled time
    const scheduledDateTime = eventMode === 'timed' && startTime
      ? new Date(startTime)
      : startDate
        ? new Date(startDate)
        : new Date();

    if (isNaN(scheduledDateTime.getTime())) {
      return res.status(400).json({
        success: false,
        message: 'Invalid date/time format'
      });
    }

    // Create event data
    const eventData = {
      userId,
      title,
      description: description || `Irrigation for ${device.deviceName || deviceId}`,
      activityType: 'Irrigation',
      eventMode: eventMode || 'timed',
      irrigationSettings: {
        deviceId,
        duration: parseInt(duration) || 30,
        enabled: true,
        isExecuted: false
      },
      recurrence: recurrence || {
        isRecurring: false,
        pattern: 'none'
      }
    };

    // Set time fields based on event mode
    if (eventMode === 'timed' && startTime) {
      eventData.startTime = new Date(startTime);
      eventData.start_date = new Date(startTime); // Also set for compatibility
      eventData.endTime = new Date(new Date(startTime).getTime() + (duration * 60 * 1000));
      eventData.end_date = eventData.endTime;
    } else {
      eventData.start_date = scheduledDateTime;
      eventData.end_date = scheduledDateTime;
    }

    // Create the event
    const newEvent = new Event(eventData);
    await newEvent.save();

    // If recurring, generate future instances
    if (recurrence && recurrence.isRecurring && recurrence.pattern !== 'none') {
      await generateRecurringInstances(newEvent);
    }

    res.status(201).json({
      success: true,
      message: 'Irrigation schedule created successfully',
      data: newEvent
    });

  } catch (error) {
    console.error('[IrrigationController] Create schedule error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create irrigation schedule',
      error: error.message
    });
  }
};

/**
 * Get all irrigation schedules for a device
 * GET /api/irrigation/schedules?deviceId=xxx
 */
exports.getIrrigationSchedules = async (req, res) => {
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

    // Find all irrigation events for this device (not deleted)
    const schedules = await Event.find({
      userId,
      activityType: 'Irrigation',
      'irrigationSettings.deviceId': deviceId,
      isDeleted: false
    })
    .sort({ createdAt: -1 })
    .select('title description startTime start_date eventMode irrigationSettings recurrence createdAt updatedAt');

    res.status(200).json({
      success: true,
      data: {
        deviceId,
        schedules: schedules,
        count: schedules.length
      }
    });

  } catch (error) {
    console.error('[IrrigationController] Get schedules error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get irrigation schedules',
      error: error.message
    });
  }
};

/**
 * Update irrigation schedule
 * PUT /api/irrigation/schedule/:id
 */
exports.updateIrrigationSchedule = async (req, res) => {
  try {
    const userId = req.user?.id || req.user?.userId || req.user?._id;
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'User authentication required'
      });
    }

    const { id } = req.params;
    const updates = req.body;

    // Find the event
    const event = await Event.findOne({
      _id: id,
      userId,
      activityType: 'Irrigation',
      isDeleted: false
    });

    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Irrigation schedule not found'
      });
    }

    // Only allow updates if not yet executed
    if (event.irrigationSettings?.isExecuted) {
      return res.status(400).json({
        success: false,
        message: 'Cannot update executed schedule. Create a new schedule instead.'
      });
    }

    // Update fields
    if (updates.title) event.title = updates.title;
    if (updates.description !== undefined) event.description = updates.description;
    if (updates.duration) {
      event.irrigationSettings = event.irrigationSettings || {};
      event.irrigationSettings.duration = parseInt(updates.duration);
    }
    if (updates.startTime) {
      event.startTime = new Date(updates.startTime);
      event.start_date = event.startTime;
    }
    if (updates.startDate) {
      event.start_date = new Date(updates.startDate);
    }
    if (updates.recurrence) {
      event.recurrence = { ...event.recurrence, ...updates.recurrence };
    }
    if (updates.eventMode) {
      event.eventMode = updates.eventMode;
    }

    await event.save();

    // If recurrence changed and is now recurring, generate instances
    if (updates.recurrence && updates.recurrence.isRecurring && updates.recurrence.pattern !== 'none') {
      await generateRecurringInstances(event);
    }

    res.status(200).json({
      success: true,
      message: 'Irrigation schedule updated successfully',
      data: event
    });

  } catch (error) {
    console.error('[IrrigationController] Update schedule error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update irrigation schedule',
      error: error.message
    });
  }
};

/**
 * Delete irrigation schedule
 * DELETE /api/irrigation/schedule/:id
 */
exports.deleteIrrigationSchedule = async (req, res) => {
  try {
    const userId = req.user?.id || req.user?.userId || req.user?._id;
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'User authentication required'
      });
    }

    const { id } = req.params;

    // Find and soft delete (or hard delete if preferred)
    const event = await Event.findOne({
      _id: id,
      userId,
      activityType: 'Irrigation'
    });

    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Irrigation schedule not found'
      });
    }

    // Soft delete
    event.isDeleted = true;
    await event.save();

    res.status(200).json({
      success: true,
      message: 'Irrigation schedule deleted successfully'
    });

  } catch (error) {
    console.error('[IrrigationController] Delete schedule error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete irrigation schedule',
      error: error.message
    });
  }
};

/**
 * Toggle schedule enable/disable
 * POST /api/irrigation/schedule/:id/toggle
 */
exports.toggleSchedule = async (req, res) => {
  try {
    const userId = req.user?.id || req.user?.userId || req.user?._id;
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'User authentication required'
      });
    }

    const { id } = req.params;

    const event = await Event.findOne({
      _id: id,
      userId,
      activityType: 'Irrigation',
      isDeleted: false
    });

    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Irrigation schedule not found'
      });
    }

    // Toggle enabled state
    event.irrigationSettings = event.irrigationSettings || {};
    event.irrigationSettings.enabled = !event.irrigationSettings.enabled;
    await event.save();

    res.status(200).json({
      success: true,
      message: `Schedule ${event.irrigationSettings.enabled ? 'enabled' : 'disabled'} successfully`,
      data: {
        enabled: event.irrigationSettings.enabled
      }
    });

  } catch (error) {
    console.error('[IrrigationController] Toggle schedule error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to toggle schedule',
      error: error.message
    });
  }
};

/**
 * Helper function to generate recurring event instances
 * @param {Object} masterEvent - The master recurring event
 */
async function generateRecurringInstances(masterEvent) {
  try {
    if (!masterEvent.recurrence || !masterEvent.recurrence.isRecurring) {
      return;
    }

    const { pattern, interval, daysOfWeek, dayOfMonth, endDate, maxOccurrences } = masterEvent.recurrence;
    const startDate = masterEvent.eventMode === 'timed' && masterEvent.startTime
      ? new Date(masterEvent.startTime)
      : new Date(masterEvent.start_date);

    const instances = [];
    let currentDate = new Date(startDate);
    const endDateTime = endDate ? new Date(endDate) : null;
    const maxCount = maxOccurrences || 365; // Default max 1 year
    let instanceCount = 0;

    // Skip the first one (master event already exists)
    currentDate = getNextOccurrence(currentDate, pattern, interval, daysOfWeek, dayOfMonth);

    while (instanceCount < maxCount) {
      // Check end date
      if (endDateTime && currentDate > endDateTime) {
        break;
      }

      // Create instance
      const instanceData = {
        ...masterEvent.toObject(),
        _id: undefined, // Let MongoDB create new ID
        irrigationSettings: {
          ...masterEvent.irrigationSettings,
          isExecuted: false,
          executionTime: undefined
        },
        recurrence: {
          ...masterEvent.recurrence,
          isRecurring: false // Mark instance as non-recurring
        }
      };

      // Set time based on event mode
      if (masterEvent.eventMode === 'timed') {
        instanceData.startTime = new Date(currentDate);
        instanceData.start_date = new Date(currentDate);
        const duration = masterEvent.irrigationSettings?.duration || 30;
        instanceData.endTime = new Date(currentDate.getTime() + (duration * 60 * 1000));
        instanceData.end_date = instanceData.endTime;
      } else {
        instanceData.start_date = new Date(currentDate);
        instanceData.end_date = new Date(currentDate);
      }

      instances.push(instanceData);

      // Get next occurrence
      currentDate = getNextOccurrence(currentDate, pattern, interval, daysOfWeek, dayOfMonth);
      instanceCount++;

      // Limit to reasonable number for initial generation (next 90 days)
      if (currentDate > new Date(Date.now() + 90 * 24 * 60 * 60 * 1000)) {
        break;
      }
    }

    // Insert instances if any
    if (instances.length > 0) {
      await Event.insertMany(instances);
      console.log(`[IrrigationController] Generated ${instances.length} recurring instances for event ${masterEvent._id}`);
    }

  } catch (error) {
    console.error('[IrrigationController] Error generating recurring instances:', error);
    throw error;
  }
}

/**
 * Helper function to calculate next occurrence date
 */
function getNextOccurrence(currentDate, pattern, interval, daysOfWeek, dayOfMonth) {
  const next = new Date(currentDate);

  switch (pattern) {
    case 'daily':
      next.setDate(next.getDate() + (interval || 1));
      break;

    case 'weekly':
      if (daysOfWeek && daysOfWeek.length > 0) {
        // Find next occurrence on specified days of week
        let found = false;
        let attempts = 0;
        while (!found && attempts < 14) { // Max 2 weeks search
          next.setDate(next.getDate() + 1);
          const dayOfWeek = next.getDay();
          if (daysOfWeek.includes(dayOfWeek)) {
            found = true;
          }
          attempts++;
        }
      } else {
        next.setDate(next.getDate() + 7);
      }
      break;

    case 'monthly':
      next.setMonth(next.getMonth() + 1);
      if (dayOfMonth) {
        next.setDate(dayOfMonth);
      }
      break;

    case 'custom':
      next.setDate(next.getDate() + (interval || 1));
      break;

    default:
      next.setDate(next.getDate() + 1);
  }

  return next;
}

// Export helper for use in scheduler service
exports.generateRecurringInstances = generateRecurringInstances;

