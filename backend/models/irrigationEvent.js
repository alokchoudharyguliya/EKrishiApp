/**
 * IrrigationEvent Model
 * Stores pump control events (on/off actions)
 */
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const irrigationEventSchema = new Schema({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  deviceId: {
    type: String,
    required: true,
    index: true
  },
  action: {
    type: String,
    enum: ['pump_on', 'pump_off', 'pump_toggle'],
    required: true
  },
  state: {
    type: Boolean,
    required: true // true = pump on, false = pump off
  },
  triggeredBy: {
    type: String,
    enum: ['user', 'schedule', 'sensor', 'manual'],
    default: 'user'
  },
  duration: {
    type: Number, // Duration in seconds (if applicable)
    default: null
  },
  metadata: {
    type: Schema.Types.Mixed, // Additional data (reason, sensor readings, etc.)
    default: {}
  },
  createdAt: {
    type: Date,
    default: Date.now,
    index: true
  }
});

// Indexes for efficient queries
irrigationEventSchema.index({ userId: 1, createdAt: -1 });
irrigationEventSchema.index({ deviceId: 1, createdAt: -1 });
irrigationEventSchema.index({ createdAt: -1 });

module.exports = mongoose.model('IrrigationEvent', irrigationEventSchema);


