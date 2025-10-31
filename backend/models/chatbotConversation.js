/**
 * ChatbotConversation Model
 * Stores conversation history for the agriculture chatbot
 */
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const messageSchema = new Schema({
  role: {
    type: String,
    enum: ['user', 'assistant', 'system'],
    required: true
  },
  content: {
    type: String,
    required: true
  },
  provider: {
    type: String,
    enum: ['gemini', 'openai', 'error', null],
    default: null  // null for user messages
  },
  tokensUsed: {
    type: Number,
    default: 0
  },
  timestamp: {
    type: Date,
    default: Date.now
  },
  isError: {
    type: Boolean,
    default: false
  }
}, { _id: false }); // Don't create _id for nested messages

const chatbotConversationSchema = new Schema({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  sessionId: {
    type: String,
    required: true,
    index: true
  },
  messages: [messageSchema],
  metadata: {
    totalTokensGemini: {
      type: Number,
      default: 0
    },
    totalTokensOpenAI: {
      type: Number,
      default: 0
    },
    fallbackCount: {
      type: Number,
      default: 0
    },
    lastProvider: {
      type: String,
      enum: ['gemini', 'openai', null],
      default: null
    }
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
chatbotConversationSchema.index({ userId: 1, sessionId: 1 });
chatbotConversationSchema.index({ userId: 1, 'messages.timestamp': -1 });
chatbotConversationSchema.index({ sessionId: 1 });

// Update updatedAt before saving
chatbotConversationSchema.pre('save', function(next) {
  this.updatedAt = new Date();
  next();
});

module.exports = mongoose.model('ChatbotConversation', chatbotConversationSchema);

