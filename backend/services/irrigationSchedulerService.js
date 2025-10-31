/**
 * Irrigation Scheduler Service
 * Handles automated execution of scheduled irrigation events
 * Runs via cron job to check and execute due irrigations
 */
const Event = require('../models/event');
const IrrigationEvent = require('../models/irrigationEvent');
const IrrigationDevice = require('../models/irrigationDevice');
const piWebSocketService = require('./piWebSocketService');

/**
 * Check for scheduled irrigations that are due and execute them
 * This function is called by the cron job every minute
 */
async function checkScheduledIrrigations() {
  try {
    const now = new Date();
    
    // Find all irrigation events that are due:
    // - activityType is 'Irrigation'
    // - irrigationSettings.enabled is true
    // - irrigationSettings.isExecuted is false
    // - Scheduled time has passed or is within the current minute
    // - Event is not deleted
    
    const dueEvents = await Event.find({
      activityType: 'Irrigation',
      'irrigationSettings.enabled': true,
      'irrigationSettings.isExecuted': false,
      isDeleted: false,
      $or: [
        {
          eventMode: 'timed',
          startTime: {
            $lte: new Date(now.getTime() + 60000) // Within next minute
          },
          startTime: { $gte: new Date(now.getTime() - 60000) } // Or within last minute (in case of delay)
        },
        {
          eventMode: 'all-day',
          start_date: {
            $lte: new Date(now.getTime() + 60000)
          },
          start_date: { $gte: new Date(now.getTime() - 60000) }
        }
      ]
    });

    console.log(`[IrrigationScheduler] Found ${dueEvents.length} due irrigation event(s)`);

    // Execute each due irrigation
    for (const event of dueEvents) {
      try {
        await executeScheduledIrrigation(event);
      } catch (error) {
        console.error(`[IrrigationScheduler] Error executing irrigation for event ${event._id}:`, error);
        // Continue with other events even if one fails
      }
    }

  } catch (error) {
    console.error('[IrrigationScheduler] Error checking scheduled irrigations:', error);
  }
}

/**
 * Execute a scheduled irrigation event
 * @param {Object} event - Event document with irrigationSettings
 */
async function executeScheduledIrrigation(event) {
  try {
    const { deviceId, duration } = event.irrigationSettings || {};
    
    if (!deviceId) {
      console.warn(`[IrrigationScheduler] Event ${event._id} has no deviceId, skipping`);
      return;
    }

    // Get device information
    const device = await IrrigationDevice.findOne({ 
      deviceId, 
      isActive: true 
    });

    if (!device) {
      console.warn(`[IrrigationScheduler] Device ${deviceId} not found or inactive for event ${event._id}`);
      // Mark event as executed with error note
      event.irrigationSettings.isExecuted = true;
      event.irrigationSettings.executionTime = new Date();
      await event.save();
      return;
    }

    console.log(`[IrrigationScheduler] Executing irrigation for event ${event._id}, device ${deviceId}, duration ${duration} minutes`);

    // Get WebSocket connection to Pi
    const piClient = piWebSocketService.getConnection(deviceId, device.piUrl);

    // Check if device is connected
    const connectionStatus = piClient.getStatus();
    if (!connectionStatus.isConnected) {
      console.warn(`[IrrigationScheduler] Device ${deviceId} is not connected, skipping execution`);
      // Don't mark as executed - will retry on next check
      return;
    }

    // Execute irrigation: Turn ON pump
    const pumpOnResult = await piClient.sendCommand('pump_on', {});
    
    if (!pumpOnResult || !pumpOnResult.success) {
      throw new Error(`Failed to turn on pump: ${pumpOnResult?.error || 'Unknown error'}`);
    }

    console.log(`[IrrigationScheduler] Pump turned ON for event ${event._id}`);

    // Log irrigation start event
    const startEvent = new IrrigationEvent({
      userId: event.userId,
      deviceId: deviceId,
      action: 'pump_on',
      state: true,
      triggeredBy: 'schedule',
      duration: duration * 60, // Convert minutes to seconds
      metadata: {
        eventId: event._id.toString(),
        eventTitle: event.title,
        scheduledTime: event.eventMode === 'timed' && event.startTime 
          ? event.startTime 
          : event.start_date,
        durationMinutes: duration
      }
    });
    await startEvent.save();

    // Wait for the specified duration (convert minutes to milliseconds)
    const durationMs = (duration || 30) * 60 * 1000;
    console.log(`[IrrigationScheduler] Waiting ${duration} minutes before turning pump OFF`);
    
    // Use setTimeout wrapped in Promise for async wait
    await new Promise(resolve => setTimeout(resolve, durationMs));

    // Turn OFF pump
    const pumpOffResult = await piClient.sendCommand('pump_off', {});
    
    if (!pumpOffResult || !pumpOffResult.success) {
      console.error(`[IrrigationScheduler] Failed to turn off pump for event ${event._id}`);
      // Log error but continue with marking as executed
    } else {
      console.log(`[IrrigationScheduler] Pump turned OFF for event ${event._id}`);
    }

    // Log irrigation end event
    const endEvent = new IrrigationEvent({
      userId: event.userId,
      deviceId: deviceId,
      action: 'pump_off',
      state: false,
      triggeredBy: 'schedule',
      metadata: {
        eventId: event._id.toString(),
        eventTitle: event.title,
        executionTime: new Date()
      }
    });
    await endEvent.save();

    // Mark event as executed
    event.irrigationSettings.isExecuted = true;
    event.irrigationSettings.executionTime = new Date();
    await event.save();

    console.log(`[IrrigationScheduler] Successfully executed irrigation for event ${event._id}`);

    // Check if this was a recurring event and generate next instance if needed
    // Note: We only check if master event (isRecurring=true) still has recurring pattern
    // The executed instance itself is marked as non-recurring, but the master template might need a new instance
    // This will be handled when user creates recurring schedules, but we could also implement auto-generation here

    // Update device last seen
    device.lastSeen = new Date();
    await device.save();

  } catch (error) {
    console.error(`[IrrigationScheduler] Error executing scheduled irrigation for event ${event._id}:`, error);
    
    // Mark event as executed with error note (to prevent retry loops)
    // In a production system, you might want to implement retry logic instead
    try {
      event.irrigationSettings.isExecuted = true;
      event.irrigationSettings.executionTime = new Date();
      await event.save();
    } catch (saveError) {
      console.error(`[IrrigationScheduler] Error saving event after execution failure:`, saveError);
    }
    
    throw error; // Re-throw to be caught by caller
  }
}

/**
 * Get next scheduled irrigation for a device (helper function)
 * Used by the API endpoint
 * @param {String} deviceId - Device ID
 * @param {String} userId - User ID
 * @returns {Object|null} Next scheduled event or null
 */
async function getNextScheduledForDevice(deviceId, userId) {
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
  });

  return nextEvent;
}

module.exports = {
  checkScheduledIrrigations,
  executeScheduledIrrigation,
  getNextScheduledForDevice
};

