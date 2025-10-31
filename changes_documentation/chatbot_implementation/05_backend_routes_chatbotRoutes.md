# Backend Routes - ChatbotRoutes

## File Changed
- `backend/routes/chatbotRoutes.js`

## Change Type
NEW FILE - Created chatbot routes

## Line Numbers
- Entire file (new file, ~15 lines)

## Details

### Purpose
Defines API routes for chatbot endpoints with authentication middleware.

### Routes Defined

#### POST `/api/chatbot/message`
- Sends message and gets AI response
- Requires authentication
- Uses `chatbotController.sendMessage`

#### GET `/api/chatbot/history?sessionId=xxx`
- Gets conversation history
- Requires authentication
- Uses `chatbotController.getHistory`

#### DELETE `/api/chatbot/history/:sessionId`
- Deletes conversation history
- Requires authentication
- Uses `chatbotController.deleteHistory`

#### GET `/api/chatbot/conversations`
- Lists all user conversations
- Requires authentication
- Uses `chatbotController.getConversations`

### Authentication
All routes use `authMiddleware` from `../utils/auth.js` to ensure only authenticated users can access.

---

## Impact
- Exposes chatbot endpoints via REST API
- Secured with JWT authentication

