# Chatbot Implementation - Complete Guide

## Overview
Agriculture-specific chatbot with Gemini (primary) + OpenAI (fallback) integration.

---

## Quick Start

### 1. Install Backend Dependencies
```bash
cd backend
npm install
```

### 2. Configure Environment Variables
Add to `backend/.env`:
```env
GOOGLE_API_KEY=your_google_api_key_here
OPENAI_API_KEY=your_openai_api_key_here  # Optional for fallback
```

**Get Google API Key:**
1. Visit https://makersuite.google.com/app/apikey
2. Create API key
3. Copy to `.env`

**Get OpenAI API Key (Optional):**
1. Visit https://platform.openai.com/api-keys
2. Create API key
3. Copy to `.env`

### 3. Restart Backend Server
```bash
npm start
```

### 4. Test Frontend
- Open Flutter app
- Navigate to Chatbot tab
- Send a test message

---

## Architecture

```
Flutter App (chatbot_screen.dart)
    ↓
ChatbotService (chatbot_service.dart)
    ↓
Backend API (/api/chatbot/message)
    ↓
ChatbotController (chatbotController.js)
    ↓
ChatbotService (chatbotService.js)
    ├─→ Try Gemini API
    │   └─→ Success? Return response
    │
    └─→ Rate limited? Try OpenAI API
        └─→ Return response
    ↓
Save to MongoDB (chatbotConversation model)
    ↓
Return to Flutter App
```

---

## Features

✅ Agriculture-specific responses  
✅ EKrishi app knowledge  
✅ Rejects non-agriculture queries  
✅ Gemini primary, OpenAI fallback  
✅ Conversation history persistence  
✅ Session management  
✅ Token usage tracking  
✅ Error handling  

---

## API Endpoints

### POST `/api/chatbot/message`
Send message, get AI response.

**Request:**
```json
{
  "message": "How do I detect crop diseases?",
  "sessionId": "optional-session-id"
}
```

**Response:**
```json
{
  "success": true,
  "response": "AI response...",
  "sessionId": "session-id",
  "provider": "gemini",
  "metadata": {
    "tokensUsed": 150
  }
}
```

### GET `/api/chatbot/history?sessionId=xxx`
Get conversation history.

### DELETE `/api/chatbot/history/:sessionId`
Delete conversation.

### GET `/api/chatbot/conversations`
List all user conversations.

---

## Files Documentation

See individual documentation files:
- `01_backend_dependencies.md` - Dependencies added
- `02_backend_model_chatbotConversation.md` - Database model
- `03_backend_service_chatbotService.md` - Core service
- `04_backend_controller_chatbotController.md` - API controllers
- `05_backend_routes_chatbotRoutes.md` - Routes
- `06_backend_index_route_mount.md` - Route mounting
- `07_frontend_service_chatbot_service.md` - Flutter service
- `08_frontend_screen_chatbot_screen.md` - UI integration
- `00_file_changes_summary.md` - Complete summary

---

## Troubleshooting

### "No AI service configured" error
- Check API keys in `.env`
- Restart server after adding keys

### "Authentication required" error
- Ensure user is logged in
- Check JWT token is valid

### Slow responses
- Check internet connection
- Gemini/OpenAI API may be slow
- Consider timeout settings

### Rate limit errors
- Free tier limits exceeded
- Will automatically fallback to OpenAI
- Consider upgrading API tier

---

## Testing

### Test Agriculture Queries
- "How do I detect crop diseases?"
- "What's the best irrigation schedule?"
- "How do I use the irrigation feature?"

### Test Non-Agriculture Rejection
- "Tell me a joke" → Should reject politely
- "What's the weather?" → Should redirect to agriculture

### Test App Features
- "How does crop analysis work?"
- "Where is the equipment marketplace?"

---

## Next Steps

1. Test with real queries
2. Monitor API usage and costs
3. Fine-tune system prompts
4. Add analytics dashboard
5. Consider adding RAG for better app knowledge

---

## Support

For issues or questions, check:
- Documentation files in this folder
- Backend logs for errors
- Frontend console for API errors

