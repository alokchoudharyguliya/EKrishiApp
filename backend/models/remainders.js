const mongoose = require('mongoose');
const Schema = mongoose.Schema;

/**
 * Remainders Model
 * Stores reminders/notifications for users
 */
const remainderSchema = new Schema({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  title: {
    type: String,
    required: true,
    trim: true,
    maxlength: 200
  },
  description: {
    type: String,
    trim: true,
    maxlength: 1000,
    default: ''
  },
  reminderDate: {
    type: Date,
    required: true,
    index: true
  },
  isCompleted: {
    type: Boolean,
    default: false
  },
  priority: {
    type: String,
    enum: ['low', 'medium', 'high'],
    default: 'medium'
  },
  category: {
    type: String,
    trim: true,
    default: 'general'
  },
  relatedEventId: {
    type: Schema.Types.ObjectId,
    ref: 'Event',
    default: null
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Indexes for efficient queries
remainderSchema.index({ userId: 1, reminderDate: 1 });
remainderSchema.index({ userId: 1, isCompleted: 1 });

// Update updatedAt before saving
remainderSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('Remainder', remainderSchema);

