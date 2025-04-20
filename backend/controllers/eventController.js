const event = require('../models/event');
const mongoose = require('mongoose');
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
    const eventId=req.params.id;
    if (!userId) {
      return res.status(400).json({ message: "User ID is required." });
    }

    const events = await event.findOne({ userId,eventId: eventId});

    res.status(200).json({ success: true, events });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
}
exports.deleteEvent = async (req, res) => {
  try {
    const { eventId, userId } = req.body;

    if (!userId) {
      return res.status(400).json({ message: "User ID is required." });
    }

    if (!eventId) {
      return res.status(400).json({ message: "Event ID is required." });
    }

    const deletedEvent = await event.findByIdAndDelete({ _id: eventId, userId: userId });

    if (!deletedEvent) {
      return res.status(404).json({ message: "Event not found." });
    }

    res.status(200).json({ success: true, message: "Event deleted successfully." });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server error." });
  }
};
exports.addEvent = async (req, res) => {
  try {
    const { userId ,end_date,start_date, title} = req.body;
    const newEvent = new event({ ...req.body, userId: userId, start_date: new Date(start_date), end_date: new Date(end_date) });

    if (!userId || !title || !start_date || !end_date) {
      return res.status(400).json({ message: "userId, title, and date are required." });
    }
    await newEvent.save();
    res.status(201).json({
      success: true,
      message: "Event added successfully",
      event: newEvent
    });

  } catch (err) {
    console.error(err);

    // Handle Mongoose validation errors (e.g., invalid date)
    if (err.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: err.message // Example: "Event date must be in the future"
      });
    }

    // Generic server error
    res.status(500).json({
      success: false,
      message: "Server error"
    });
  }
};
exports.addEvents = async (req, res) => {
  console.log("hay")
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
    const insertedEvents = await event.insertMany(processedEvents);

    // Return success response (remove Mongoose-specific fields like __v)
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
    const eventId = req.params.id;
    if (!eventId) {
      return res.status(400).json({ message: "Event ID is required." });
    }
    const updatedEvent = await event.findOneAndUpdate(
      { _id: eventId, userId: userId },
      req.body,
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



