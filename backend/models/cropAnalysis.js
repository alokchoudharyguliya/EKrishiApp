const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const cropAnalysisSchema = new Schema({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: false // Optional for anonymous analysis
  },
  imageName: {
    type: String,
    required: true
  },
  imageSize: {
    type: Number // Size in bytes
  },
  context: {
    imageType: String,
    cropType: String,
    observedProblem: String,
    plantAge: Number,
    recentWeatherEvent: Boolean
  },
  result: {
    type: Schema.Types.Mixed, // Store full AI response
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'processing', 'completed', 'failed'],
    default: 'processing'
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

// Update updatedAt on save
cropAnalysisSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('CropAnalysis', cropAnalysisSchema);


