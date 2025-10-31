# Backend Controller - ChatbotController

## File Changed
- `backend/controllers/chatbotController.js`

## Change Type
NEW FILE - Created chatbot controller

## Line Numbers
- Entire file (new file, ~220 lines)

## Details

### Purpose
Handles HTTP requests for chatbot endpoints.

### Endpoints Handled

#### `sendMessage` - POST `/api/chatbot/message`
- **Lines 8-72**: Main endpoint for sending messages
- Validates user authentication
- Validates message input
- Saves user message to DB
- Gets AI response from service
- Saves assistant response to DB
- Returns response to client

**Request Body**:
```json
{
  "message": "How do I detect crop diseases?",
  "sessionId": "optional-session-id"
}
```

**Response**:
```json
{
  "success": true,
  "response": "AI response text...",
  "sessionId": "session-id",
  "provider": "gemini",
  "metadata": {
    "tokensUsed": 150
  }
}
```

#### `getHistory` - GET `/api/chatbot/history?sessionId=xxx`
- **Lines 78-133**: Retrieves conversation history
- Validates user owns the session
- Returns formatted message array

#### `deleteHistory` - DELETE `/api/chatbot/history/:sessionId`
- **Lines 138-178**: Deletes conversation history
- Validates user owns the session
- Returns success confirmation

#### `getConversations` - GET `/api/chatbot/conversations`
- **Lines 183-220**: Lists all user's conversations
- Returns session list with metadata
- Limited to 50 most recent

### Error Handling
- 400: Bad request (missing/invalid input)
- 401: Unauthorized (no authentication)
- 404: Not found (session doesn't exist)
- 500: Server error (with stack trace in development)

---

## Impact
- Provides RESTful API for chatbot
- Secure with authentication middleware
- Comprehensive error handling

