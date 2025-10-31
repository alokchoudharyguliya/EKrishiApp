/**
 * SensorReading Model
 * Stores time-series sensor data (temperature, moisture, etc.)
 */
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const sensorReadingSchema = new Schema({
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
  sensorType: {
    type: String,
    enum: ['temperature', 'moisture', 'humidity'],
    required: true,
    index: true
  },
  value: {
    type: Number,
    required: true
  },
  unit: {
    type: String,
    default: '' // 'C' for temperature, '%' for moisture, etc.
  },
  timestamp: {
    type: Date,
    default: Date.now,
    index: true
  },
  metadata: {
    type: Schema.Types.Mixed, // Additional sensor metadata
    default: {}
  }
});

// Indexes for efficient time-series queries
sensorReadingSchema.index({ userId: 1, sensorType: 1, timestamp: -1 });
sensorReadingSchema.index({ deviceId: 1, sensorType: 1, timestamp: -1 });
sensorReadingSchema.index({ timestamp: -1 });

// Compound index for aggregation queries
sensorReadingSchema.index({ deviceId: 1, timestamp: -1 });

module.exports = mongoose.model('SensorReading', sensorReadingSchema);


