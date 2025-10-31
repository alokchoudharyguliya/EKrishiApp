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
  isDeleted: {
    type: Boolean,
    default: false
  },
  changeType: {
    type: String,
    default: null
  },
  lastUpdated: {
    type: Date,
    default: Date.now
  },
  isSynced: {
    type: Boolean,
    default: false
  },
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
  
  // Event mode: 'all-day' for date-only events, 'timed' for events with specific times
  eventMode: {
    type: String,
    enum: ['all-day', 'timed'],
    default: 'all-day'
  },
  
  // Time fields (only used when eventMode is 'timed')
  startTime: {
    type: Date,
    required: false
  },
  endTime: {
    type: Date,
    required: false
  },
  
  // Farmer-specific fields
  cropType: {
    type: String,
    trim: true,
    maxlength: [100, 'Crop type cannot exceed 100 characters']
  },
  cropVariety: {
    type: String,
    trim: true,
    maxlength: [100, 'Crop variety cannot exceed 100 characters']
  },
  activityType: {
    type: String,
    enum: ['Planting', 'Harvesting', 'Irrigation', 'Fertilization', 'Pest Control', 'Pruning', 'Weeding', 'Other'],
    trim: true
  },
  fieldLocation: {
    type: String,
    trim: true,
    maxlength: [200, 'Field location cannot exceed 200 characters']
  },
  equipmentNeeded: {
    type: [String],
    default: []
  },
  
  // Reminder system
  reminders: [{
    reminderTime: {
      type: Date,
      required: true
    },
    reminderType: {
      type: String,
      enum: ['days', 'hours', 'minutes'],
      required: true
    },
    reminderValue: {
      type: Number,
      required: true
    },
    isNotified: {
      type: Boolean,
      default: false
    },
    notificationId: {
      type: String
    }
  }],
  
  reminderSettings: {
    defaultReminderType: {
      type: String,
      enum: ['days', 'hours', 'minutes'],
      default: 'days'
    },
    defaultReminderValue: {
      type: Number,
      default: 1
    }
  },

  // Irrigation-specific settings (only for activityType: 'Irrigation')
  irrigationSettings: {
    deviceId: {
      type: String,
      required: false
    },
    duration: {
      type: Number, // Duration in minutes
      default: 30,
      min: 1,
      max: 1440 // Max 24 hours
    },
    isExecuted: {
      type: Boolean,
      default: false
    },
    executionTime: {
      type: Date,
      required: false
    },
    enabled: {
      type: Boolean,
      default: true // Allow users to enable/disable schedule
    }
  },

  // Recurrence for irrigation schedules
  recurrence: {
    isRecurring: {
      type: Boolean,
      default: false
    },
    pattern: {
      type: String,
      enum: ['daily', 'weekly', 'custom', 'monthly', 'none'],
      default: 'none'
    },
    interval: {
      type: Number, // For custom: every N days
      default: 1
    },
    daysOfWeek: {
      type: [Number], // For weekly: [1,3,5] = Mon,Wed,Fri (0=Sun, 6=Sat)
      default: []
    },
    dayOfMonth: {
      type: Number, // For monthly: day 1-31
      default: null
    },
    endDate: {
      type: Date, // When recurrence ends
      required: false
    },
    maxOccurrences: {
      type: Number, // Limit number of occurrences
      default: null
    }
  }

}, {
  timestamps: true,
});
eventSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  
  // Validation: If eventMode is 'timed', startTime and endTime should be provided
  if (this.eventMode === 'timed') {
    if (!this.startTime || !this.endTime) {
      return next(new Error('Start time and end time are required for timed events'));
    }
    if (this.startTime >= this.endTime) {
      return next(new Error('End time must be after start time'));
    }
  }
  
  // Validation: Reminder times should be before event start
  if (this.reminders && this.reminders.length > 0) {
    const eventStartTime = this.eventMode === 'timed' && this.startTime 
      ? this.startTime 
      : new Date(this.start_date);
    
    for (const reminder of this.reminders) {
      if (reminder.reminderTime >= eventStartTime) {
        return next(new Error('Reminder time must be before event start time'));
      }
    }
  }
  
  next();
});
const Event = mongoose.model('Event', eventSchema);
module.exports = Event;