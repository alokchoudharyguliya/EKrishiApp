# Backend Model - ChatbotConversation

## File Changed
- `backend/models/chatbotConversation.js`

## Change Type
NEW FILE - Created MongoDB model

## Line Numbers
- Entire file (new file, ~90 lines)

## Details

### Purpose
MongoDB schema to store chatbot conversation history with provider tracking.

### Key Features
1. **Message Storage**: Stores user and assistant messages
2. **Provider Tracking**: Tracks which API was used (Gemini/OpenAI)
3. **Token Tracking**: Records token usage per provider
4. **Metadata**: Tracks fallback count and usage statistics
5. **Indexes**: Optimized for queries by userId and sessionId

### Schema Structure
```javascript
{
  userId: ObjectId,          // User reference
  sessionId: String,         // Session identifier
  messages: [{
    role: String,            // 'user' | 'assistant' | 'system'
    content: String,         // Message text
    provider: String,        // 'gemini' | 'openai' | null
    tokensUsed: Number,      // Token count
    timestamp: Date
  }],
  metadata: {
    totalTokensGemini: Number,
    totalTokensOpenAI: Number,
    fallbackCount: Number,
    lastProvider: String
  }
}
```

### Indexes
- `{ userId: 1, sessionId: 1 }` - Fast lookup of user sessions
- `{ userId: 1, 'messages.timestamp': -1 }` - Time-based queries
- `{ sessionId: 1 }` - Session lookup

---

## Impact
- Enables conversation history persistence
- Tracks API usage and costs
- Supports analytics and monitoring

