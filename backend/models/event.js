const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Title is required'],
    trim: true,
    maxlength: [100, 'Title cannot exceed 100 characters'],
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User',
    required: [true, 'User ID is required'],
  },
  start_date: {
    type: Date,
    required: [true, 'Date is required'],
    // validate: {
    //   validator: function(start_date) {
    //     // Custom validation: Date must not be in the past
    //     return start_date >= new Date();
    //   },
    //   message: 'Start date must be in the future',
    // },
  },
  isDeleted:String,
  changeType:String,
  lastUpdated:String,
  isSynced:Boolean,
  end_date: {
    type: Date,
    // validate: {
    //   validator: function(end_date) {
    //     return end_date >= this.start_date;
    //   },
    //   message: 'End date must be in the future',
    // },
  },
  description: { type: String, required: false },

}, {
  timestamps: true,
});
eventSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});
const Event = mongoose.model('Event', eventSchema);
module.exports = Event;