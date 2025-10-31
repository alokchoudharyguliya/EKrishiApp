const Event = require('../models/event');

/**
 * Notification Service
 * Handles notification scheduling and management for event reminders
 */

/**
 * Calculate reminder time based on event start and reminder settings
 * @param {Date} eventStartDate - Event start date/time
 * @param {String} reminderType - 'days', 'hours', or 'minutes'
 * @param {Number} reminderValue - Number of days/hours/minutes before event
 * @returns {Date} Calculated reminder time
 */
function calculateReminderTime(eventStartDate, reminderType, reminderValue) {
  const reminderTime = new Date(eventStartDate);
  
  switch (reminderType) {
    case 'days':
      reminderTime.setDate(reminderTime.getDate() - reminderValue);
      break;
    case 'hours':
      reminderTime.setHours(reminderTime.getHours() - reminderValue);
      break;
    case 'minutes':
      reminderTime.setMinutes(reminderTime.getMinutes() - reminderValue);
      break;
    default:
      throw new Error(`Invalid reminder type: ${reminderType}`);
  }
  
  return reminderTime;
}

/**
 * Schedule notifications for an event's reminders
 * @param {Object} event - Event document
 * @returns {Promise<Array>} Array of scheduled reminder objects
 */
async function scheduleEventReminders(event) {
  if (!event.reminders || event.reminders.length === 0) {
    return [];
  }
  
  const eventStartTime = event.eventMode === 'timed' && event.startTime 
    ? event.startTime 
    : new Date(event.start_date);
  
  const scheduledReminders = event.reminders.map(reminder => {
    // Calculate actual reminder time
    const reminderTime = calculateReminderTime(
      eventStartTime,
      reminder.reminderType,
      reminder.reminderValue
    );
    
    return {
      ...reminder,
      reminderTime: reminderTime,
      isNotified: false
    };
  });
  
  return scheduledReminders;
}

/**
 * Get pending notifications for a user
 * @param {String} userId - User ID
 * @returns {Promise<Array>} Array of events with pending reminders
 */
async function getPendingNotifications(userId) {
  const now = new Date();
  
  // Find events with reminders that haven't been notified yet
  const events = await Event.find({
    userId: userId,
    isDeleted: false,
    'reminders.reminderTime': { $lte: now },
    'reminders.isNotified': false
  }).sort({ 'reminders.reminderTime': 1 });
  
  // Extract pending reminders
  const pendingNotifications = [];
  
  events.forEach(event => {
    const eventStartTime = event.eventMode === 'timed' && event.startTime 
      ? event.startTime 
      : new Date(event.start_date);
    
    event.reminders.forEach((reminder, index) => {
      if (reminder.reminderTime <= now && !reminder.isNotified) {
        pendingNotifications.push({
          eventId: event._id,
          eventTitle: event.title,
          eventDescription: event.description,
          eventStartTime: eventStartTime,
          activityType: event.activityType,
          cropType: event.cropType,
          fieldLocation: event.fieldLocation,
          reminderTime: reminder.reminderTime,
          reminderType: reminder.reminderType,
          reminderValue: reminder.reminderValue,
          reminderIndex: index
        });
      }
    });
  });
  
  return pendingNotifications;
}

/**
 * Mark a reminder as notified
 * @param {String} eventId - Event ID
 * @param {Number} reminderIndex - Index of the reminder in the reminders array
 * @returns {Promise<Object>} Updated event
 */
async function markReminderAsNotified(eventId, reminderIndex) {
  const event = await Event.findById(eventId);
  
  if (!event) {
    throw new Error('Event not found');
  }
  
  if (event.reminders && event.reminders[reminderIndex]) {
    event.reminders[reminderIndex].isNotified = true;
    await event.save();
  }
  
  return event;
}

/**
 * Cancel all reminders for an event (when event is deleted)
 * @param {String} eventId - Event ID
 * @returns {Promise<void>}
 */
async function cancelEventReminders(eventId) {
  // Reminders are automatically handled when event is deleted
  // This function can be used for additional cleanup if needed
  const event = await Event.findById(eventId);
  
  if (event) {
    // Mark all reminders as notified to prevent notifications
    if (event.reminders) {
      event.reminders.forEach(reminder => {
        reminder.isNotified = true;
      });
      await event.save();
    }
  }
}

/**
 * Update reminders when event is updated
 * @param {String} eventId - Event ID
 * @param {Object} updatedEventData - Updated event data
 * @returns {Promise<Object>} Updated event with recalculated reminders
 */
async function updateEventReminders(eventId, updatedEventData) {
  const event = await Event.findById(eventId);
  
  if (!event) {
    throw new Error('Event not found');
  }
  
  // If reminders are being updated, recalculate reminder times
  if (updatedEventData.reminders) {
    const eventStartTime = updatedEventData.eventMode === 'timed' && updatedEventData.startTime 
      ? new Date(updatedEventData.startTime)
      : new Date(updatedEventData.start_date);
    
    updatedEventData.reminders = updatedEventData.reminders.map(reminder => {
      const reminderTime = calculateReminderTime(
        eventStartTime,
        reminder.reminderType,
        reminder.reminderValue
      );
      
      return {
        ...reminder,
        reminderTime: reminderTime,
        isNotified: false // Reset notification status for updated reminders
      };
    });
  }
  
  return updatedEventData;
}

module.exports = {
  calculateReminderTime,
  scheduleEventReminders,
  getPendingNotifications,
  markReminderAsNotified,
  cancelEventReminders,
  updateEventReminders
};

