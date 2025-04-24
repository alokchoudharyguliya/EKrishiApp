const Event = require('../models/event');
const mongoose = require('mongoose');
const addDays=require('date-fns').addDays;
const { Types: { ObjectId } } = require('mongoose');
require('dotenv').config();
const User = require('../models/user');
const formatDate = require('../utils/helpers');
exports.getEvents = async (req, res) => {
  try {
    const userId = req.body.userId;

    if (!userId) {
      return res.status(400).json({ message: "User ID is required." });
    }

    const events = await event.find({ userId }).sort({ start_date: 1 });

    res.status(200).json({ success: true, events });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
};
exports.getEventByEventId = async (req, res) => {
  try {
    const userId = req.body.userId;
    const eventId = req.params.id;
    if (!userId) {
      return res.status(400).json({ message: "User ID is required." });
    }

    const events = await Event.findOne({ userId, eventId: eventId });

    res.status(200).json({ success: true, events });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
}
exports.deleteEvent = async (req, res) => {
  try {
    console.log(req.body);
    const { userId } = req.body;
    const {eventId}=req.params;

    if (!userId) {
      return res.status(400).json({ message: "User ID is required." });
    }

    if (!eventId) {
      return res.status(400).json({ message: "Event ID is required." });
    }

    const deletedEvent = await Event.deleteOne({ _id: eventId, userId: userId });

    if (!deletedEvent) {
      return res.status(404).json({ message: "Event not found." });
    }

    res.status(200).json({ success: true, message: "Event deleted successfully." });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server error." });
  }
};
exports.addEvents = async (req, res) => {
  try {
    const events = req.body.events;

    if (!events || !Array.isArray(events)) {
      return res.status(400).json({ message: 'Invalid events data format' });
    }

    // Process each event and convert ISO strings to Date objects
    const processedEvents = events.map(event => {
      const { _id, ...eventData } = event; // Exclude _id (let MongoDB generate it)

      return {
        ...eventData,
        title: event.title || 'Untitled Event',
        description: event.description || '',
        // allDay: event.allDay || false,
        userId: event.userId ? new ObjectId(event.userId) : null, // Convert to ObjectId if needed
        // Convert ISO strings to Date objects for MongoDB
        start_date: new Date(event.start_date),
        end_date: new Date(event.end_date),
        createdAt: event.createdAt ? new Date(event.createdAt) : new Date(),
        updatedAt: event.updatedAt ? new Date(event.updatedAt) : new Date(),
      };
    });

    // Insert all events into MongoDB
    const insertedEvents = await Event.insertMany(processedEvents);


    res.status(201).json({
      message: 'Events saved successfully',
      count: insertedEvents.length,
      events: insertedEvents.map(e => {
        const { __v, ...event } = e.toObject();
        return event;
      }),
    });
  } catch (error) {
    console.error('Error saving events:', error);
    res.status(500).json({
      message: 'Error saving events',
      error: error.message,
    });
  }
};
exports.updateEvent = async (req, res) => {
  try {
    const { userId } = req.body;
    const updates = req.body;
    const eventId = req.params.id;
    if (!eventId) {
      return res.status(400).json({ message: "Event ID is required." });
    }
    const updatedEvent = await Event.findOneAndUpdate(
      { _id: eventId, userId: userId },
      updates,
      { new: true, runValidators: true }
    );
    if (!updatedEvent) {
      return res.status(404).json({ message: "Event not found." });
    }
    res.status(200).json({ success: true, message: "Event updated successfully.", event: updatedEvent });
  } catch (err) {
    res.status(500).json({ success: false, message: "Server error." });
  }

};
exports.addEvent = async (req, res) => {
  try {
    const { userId, title, description, start_date, end_date } = req.body;
    
    // Validate required fields
    if (!userId || !title || !start_date || !end_date) {
      return res.status(400).json({ 
        success: false,
        message: "userId, title, start_date, and end_date are required." 
      });
    }

    // Validate date formats and logic
    const startDate = new Date(start_date);
    const endDate = new Date(end_date);
    
    if (isNaN(startDate.getTime()) || isNaN(endDate.getTime())) {
      return res.status(400).json({
        success: false,
        message: "Invalid date format. Please use ISO 8601 format (YYYY-MM-DD)"
      });
    }

    if (startDate > endDate) {
      return res.status(400).json({
        success: false,
        message: "End date must be after start date"
      });
    }

    // Create new event with adjusted dates (if needed)
    const newEvent = new Event({ 
      ...req.body,
      userId,
      start_date: addDays(startDate, 1), // Adjust dates as needed
      end_date: addDays(endDate, 1)
    });

    await newEvent.save();

    // Broadcast the new event to all connected clients via WebSocket
    if (req.wss) {
      req.wss.clients.forEach(client => {
        if (client.readyState === WebSocket.OPEN) {
          client.send(JSON.stringify({
            type: "eventCreated",
            message: "New event created",
            event: newEvent
          }));
        }
      });
    }

    console.log("Event added successfully");
    res.status(201).json({
      success: true,
      message: "Event added successfully",
      event: newEvent
    });

  } catch (err) {
    console.error("Error adding event:", err);

    // Handle specific error types
    if (err.name === 'ValidationError') {
      const messages = Object.values(err.errors).map(val => val.message);
      return res.status(400).json({
        success: false,
        message: "Validation error",
        errors: messages
      });
    }

    if (err.code === 11000) { // MongoDB duplicate key error
      return res.status(400).json({
        success: false,
        message: "Event with similar details already exists"
      });
    }

    // Generic server error
    res.status(500).json({
      success: false,
      message: "Server error while adding event",
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
};