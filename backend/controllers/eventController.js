const event = require('../models/event');
const mongoose = require('mongoose');
exports.getEvents = async (req, res) => {
    try {
        const userId = req.body.userId;

        if (!userId) {
            return res.status(400).json({ message: "User ID is required." });
        }

        const events = await event.find({ userId });

        res.status(200).json({ success: true, events });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: "Server error" });
    }
};
exports.getEventByEventId = async (req, res) => {

}
exports.updateEvent = async (req, res) => {
    try {
        const { eventId, title, date, description } = req.body;

        if (!eventId) {
            return res.status(400).json({ message: "Event ID is required." });
        }

        const updatedEvent = await Event.findByIdAndUpdate(
            eventId,
            { title, date, description },
            { new: true, runValidators: true }
        );

        if (!updatedEvent) {
            return res.status(404).json({ message: "Event not found." });
        }

        res.status(200).json({ success: true, message: "Event updated successfully.", event: updatedEvent });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: "Server error." });
    }
};


exports.deleteEvent = async (req, res) => {
    try {
        const { eventId } = req.body;
        if (!eventId) {
            return res.status(400).json({ message: "Event ID is required." });
        }

        const deletedEvent = await event.findByIdAndDelete(eventId);

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
        const { userId, title, end_date, start_date, description } = req.body;

        // Basic validation (optional, since Mongoose also validates)
        if (!userId || !title || !start_date|| !end_date) {
            return res.status(400).json({ message: "userId, title, and date are required." });
        }

        // Check if userId is a valid ObjectId (if referencing User model)
        if (!mongoose.Types.ObjectId.isValid(userId)) {
            return res.status(400).json({ message: "Invalid userId format." });
        }

        const newEvent = new event({
            userId,
            title,
            start_date: new Date(start_date), // Ensure date is a valid Date object
            end_date: new Date(end_date), // Ensure date is a valid Date object
            description: description || '', // Handle undefined description
        });

        console.log(end_date);
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
