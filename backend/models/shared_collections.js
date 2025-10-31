const mongoose = require('mongoose');
const Schema = mongoose.Schema;

/**
 * Shared Collections Model
 * Stores shared resources or collections that users can share with each other
 * Examples: shared equipment lists, shared event calendars, shared crop analyses
 */
const sharedCollectionSchema = new Schema({
  ownerId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  name: {
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
  collectionType: {
    type: String,
    enum: ['equipment', 'events', 'crop_analysis', 'irrigation_devices', 'general'],
    required: true,
    index: true
  },
  sharedWith: [{
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User'
    },
    permission: {
      type: String,
      enum: ['read', 'write', 'admin'],
      default: 'read'
    },
    addedAt: {
      type: Date,
      default: Date.now
    }
  }],
  isPublic: {
    type: Boolean,
    default: false
  },
  resourceIds: [{
    type: Schema.Types.Mixed // Can store IDs from different collections
  }],
  metadata: {
    type: Schema.Types.Mixed,
    default: {}
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
sharedCollectionSchema.index({ ownerId: 1, collectionType: 1 });
sharedCollectionSchema.index({ 'sharedWith.userId': 1 });
sharedCollectionSchema.index({ isPublic: 1 });

// Update updatedAt before saving
sharedCollectionSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('SharedCollection', sharedCollectionSchema);

