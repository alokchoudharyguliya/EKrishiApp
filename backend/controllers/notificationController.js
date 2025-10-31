const notificationService = require('../services/notificationService');

/**
 * Get pending notifications for the authenticated user
 * GET /api/notifications/pending
 */
exports.getPendingNotifications = async (req, res) => {
  try {
    const userId = req.user.id || req.user._id;
    
    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required."
      });
    }
    
    const notifications = await notificationService.getPendingNotifications(userId);
    
    res.status(200).json({
      success: true,
      count: notifications.length,
      notifications: notifications
    });
  } catch (err) {
    console.error("Error fetching pending notifications:", err);
    res.status(500).json({
      success: false,
      message: "Server error while fetching notifications",
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
};

/**
 * Mark a reminder as notified/dismissed
 * POST /api/notifications/mark-notified
 * Body: { eventId, reminderIndex }
 */
exports.markAsNotified = async (req, res) => {
  try {
    const { eventId, reminderIndex } = req.body;
    const userId = req.user.id || req.user._id;
    
    if (!eventId || reminderIndex === undefined) {
      return res.status(400).json({
        success: false,
        message: "eventId and reminderIndex are required."
      });
    }
    
    // Verify event belongs to user
    const Event = require('../models/event');
    const event = await Event.findOne({ _id: eventId, userId: userId });
    
    if (!event) {
      return res.status(404).json({
        success: false,
        message: "Event not found or not authorized."
      });
    }
    
    await notificationService.markReminderAsNotified(eventId, reminderIndex);
    
    res.status(200).json({
      success: true,
      message: "Reminder marked as notified"
    });
  } catch (err) {
    console.error("Error marking reminder as notified:", err);
    res.status(500).json({
      success: false,
      message: "Server error while marking reminder",
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
};

/**
 * Check for pending notifications (utility endpoint)
 * GET /api/notifications/check
 */
exports.checkNotifications = async (req, res) => {
  try {
    const userId = req.user.id || req.user._id;
    
    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required."
      });
    }
    
    const notifications = await notificationService.getPendingNotifications(userId);
    
    res.status(200).json({
      success: true,
      hasNotifications: notifications.length > 0,
      count: notifications.length
    });
  } catch (err) {
    console.error("Error checking notifications:", err);
    res.status(500).json({
      success: false,
      message: "Server error while checking notifications",
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
};

