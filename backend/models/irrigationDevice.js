/**
 * IrrigationDevice Model
 * Maps users to their Raspberry Pi irrigation devices
 */
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const irrigationDeviceSchema = new Schema({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  deviceId: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  deviceName: {
    type: String,
    default: 'Irrigation Device'
  },
  piUrl: {
    type: String,
    required: true,
    validate: {
      validator: function(v) {
        return /^ws:\/\/.+:\d+$/.test(v);
      },
      message: 'Pi URL must be a valid WebSocket URL (e.g., ws://192.168.1.100:8765)'
    }
  },
  location: {
    type: String,
    default: ''
  },
  isActive: {
    type: Boolean,
    default: true
  },
  lastSeen: {
    type: Date,
    default: Date.now
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

// Update timestamps
irrigationDeviceSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Index for faster queries
irrigationDeviceSchema.index({ userId: 1, isActive: 1 });

module.exports = mongoose.model('IrrigationDevice', irrigationDeviceSchema);


