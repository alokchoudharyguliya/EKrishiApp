# Agriculture Chatbot Implementation Plan

## Date
2025-01-XX

---

## Implementation Overview

### **Technology Stack**
- **Backend**: Node.js with LangChain for prompt management
- **LLM**: OpenAI GPT-3.5-turbo (cost-effective) or GPT-4 (better quality)
- **Purpose**: Agriculture-specific chatbot with app knowledge and query filtering

### **Key Features**
1. ✅ Agriculture-specific responses only
2. ✅ Knowledge about EKrishi app features
3. ✅ Rejects non-agriculture queries politely
4. ✅ Context-aware conversations
5. ✅ Integration with existing authentication

---

## Implementation Architecture

### **Components to Create**

1. **Backend Service Layer** (`backend/services/chatbotService.js`)
   - LangChain integration
   - Agriculture domain filtering
   - App knowledge context
   - Conversation management

2. **Backend Controller** (`backend/controllers/chatbotController.js`)
   - Request handling
   - Response formatting
   - Error handling

3. **Backend Routes** (`backend/routes/chatbotRoutes.js`)
   - POST `/api/chatbot/message` - Send message
   - GET `/api/chatbot/history` - Get conversation history
   - DELETE `/api/chatbot/history/:sessionId` - Clear conversation

4. **Database Model** (`backend/models/chatbotConversation.js`)
   - Store conversation history
   - Track tokens usage
   - Session management

5. **Frontend Service** (`NewsCalendar/lib/services/chatbot_service.dart`)
   - API communication
   - Error handling
   - State management

6. **Frontend Integration** (`NewsCalendar/lib/screens/chatbot_screen.dart`)
   - Replace placeholder with API calls
   - Add loading states
   - Handle errors

---

## Implementation Details

### **1. Agriculture Domain Filtering**

**Strategy**: Use LangChain's prompt templates with explicit system prompts that:
- Define the bot as an agriculture expert
- List acceptable topics (crops, irrigation, pests, diseases, soil, equipment, etc.)
- Instruct to reject non-agriculture queries politely
- Provide app-specific knowledge

**Example System Prompt**:
```
You are an agriculture expert assistant for EKrishi, a comprehensive farming application. 

Your role:
- Answer questions about farming, crops, irrigation, pests, diseases, soil management, and agricultural equipment
- Provide guidance on using EKrishi app features
- Reject non-agriculture related queries politely and redirect to agriculture topics

EKrishi App Features:
1. Crop Disease Detection - Upload crop images for AI-powered disease diagnosis
2. Irrigation Management - Monitor and control irrigation devices with sensor data
3. Equipment Marketplace - Buy/sell farming equipment
4. Event Calendar - Manage farming activities and schedules
5. AI Crop Assistance - Get crop analysis and recommendations

If a user asks about non-agriculture topics (general questions, unrelated subjects), politely decline and suggest how you can help with farming instead.

Always use agriculture terminology and provide practical, actionable advice.
```

### **2. App Knowledge Integration**

**Method**: Inject app feature knowledge into system prompts using LangChain's prompt templates. The bot will know:
- Available features in EKrishi
- How to guide users to features
- Agriculture domain context

### **3. Non-Agriculture Query Rejection**

**Implementation**: 
- Use LangChain's output parsers to detect query type
- Two-stage approach:
  1. Quick classification (agriculture vs non-agriculture)
  2. If non-agriculture, return polite rejection message

**Rejection Template**:
```
I'm specialized in agriculture and farming topics. I can help you with:
- Crop management and disease diagnosis
- Irrigation systems and water management
- Pest and disease identification
- Soil analysis and improvement
- Equipment recommendations
- Farming best practices

How can I assist you with your farming needs today?
```

---

## Files to Create/Modify

### **Backend Files**

#### **NEW**: `backend/services/chatbotService.js`
- LangChain OpenAI integration
- Prompt template management
- Agriculture domain filtering
- Conversation context handling

#### **NEW**: `backend/controllers/chatbotController.js`
- Handle POST `/api/chatbot/message`
- Handle GET `/api/chatbot/history`
- Handle DELETE `/api/chatbot/history/:sessionId`
- Input validation
- Response formatting

#### **NEW**: `backend/routes/chatbotRoutes.js`
- Define chatbot routes
- Apply authentication middleware

#### **NEW**: `backend/models/chatbotConversation.js`
- MongoDB schema for conversations
- Store messages, session data, metadata

#### **MODIFY**: `backend/index.js`
- Mount chatbot routes (line ~93)
- Add route: `app.use('/api/chatbot', chatbotRoutes);`

#### **MODIFY**: `backend/package.json`
- Add dependencies:
  - `langchain`: ^0.1.0 (or latest)
  - `openai`: ^4.0.0 (or latest)
  - `@langchain/openai`: Latest version

### **Frontend Files**

#### **NEW**: `NewsCalendar/lib/services/chatbot_service.dart`
- API communication methods
- Error handling
- Response parsing

#### **MODIFY**: `NewsCalendar/lib/screens/chatbot_screen.dart`
- Replace placeholder response (lines 49-62)
- Add API integration
- Add loading states
- Add error handling

---

## Dependencies to Install

### **Backend**
```bash
npm install langchain @langchain/openai openai
```

### **Frontend**
No new dependencies needed (already has `http` package)

---

## Environment Variables

### **Backend** (`.env`)
```env
OPENAI_API_KEY=your_openai_api_key_here
CHATBOT_MODEL=gpt-3.5-turbo  # or gpt-4 for better quality
CHATBOT_MAX_TOKENS=500
CHATBOT_TEMPERATURE=0.7
```

---

## API Endpoints

### **POST** `/api/chatbot/message`
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
  "response": "To detect crop diseases in EKrishi...",
  "sessionId": "session-id",
  "isRejected": false
}
```

### **GET** `/api/chatbot/history?sessionId=xxx`
**Response**:
```json
{
  "success": true,
  "messages": [
    {
      "role": "user",
      "content": "...",
      "timestamp": "..."
    },
    {
      "role": "assistant",
      "content": "...",
      "timestamp": "..."
    }
  ]
}
```

### **DELETE** `/api/chatbot/history/:sessionId`
**Response**:
```json
{
  "success": true,
  "message": "Conversation history cleared"
}
```

---

## Implementation Steps

1. **Install Dependencies**
   - Add LangChain and OpenAI packages
   - Update package.json

2. **Create Database Model**
   - ChatbotConversation schema
   - Indexes for efficient queries

3. **Create Service Layer**
   - LangChain prompt templates
   - Agriculture filtering logic
   - OpenAI integration

4. **Create Controller**
   - Request handlers
   - Response formatting

5. **Create Routes**
   - Define endpoints
   - Apply middleware

6. **Update Backend Index**
   - Mount routes

7. **Create Frontend Service**
   - API communication layer

8. **Update Frontend Screen**
   - Integrate API calls
   - Add UI states

9. **Testing**
   - Agriculture queries
   - Non-agriculture rejection
   - App feature questions

---

## Testing Scenarios

### **Agriculture Queries** (Should Answer)
- "How do I detect crop diseases?"
- "What's the best irrigation schedule for tomatoes?"
- "How do I use the irrigation feature?"
- "What pests affect rice crops?"
- "How to improve soil quality?"

### **Non-Agriculture Queries** (Should Reject)
- "What's the weather today?" (unless farming-related)
- "Tell me a joke"
- "What's the capital of France?"
- "How do I cook pasta?"

### **App Feature Queries** (Should Answer)
- "How does crop analysis work?"
- "How do I add irrigation devices?"
- "Where is the equipment marketplace?"

---

## Cost Estimation

### **OpenAI API Costs**
- **GPT-3.5-turbo**: ~$0.002 per 1K tokens
- **GPT-4**: ~$0.03-0.06 per 1K tokens
- **Average conversation**: 500-2000 tokens per exchange

**Monthly Estimate** (assuming 1000 conversations/day, 1500 tokens avg):
- GPT-3.5-turbo: ~$90/month
- GPT-4: ~$1,350/month

**Recommendation**: Start with GPT-3.5-turbo, upgrade to GPT-4 if needed.

---

## Security Considerations

1. **Rate Limiting**: Add rate limiting to prevent abuse
2. **Input Sanitization**: Validate and sanitize user inputs
3. **Token Management**: Store API key securely in environment variables
4. **Cost Controls**: Implement token usage limits per user/session
5. **Error Handling**: Don't expose API keys in error messages

---

## Next Steps After Implementation

1. **Monitor Usage**: Track token usage and costs
2. **Gather Feedback**: Collect user feedback on responses
3. **Fine-tune Prompts**: Improve prompts based on usage patterns
4. **Add Caching**: Cache common responses to reduce costs
5. **Analytics**: Track popular questions and improve responses

---

## Questions Before Implementation

1. Do you have an OpenAI API key? (If not, need to create account at platform.openai.com)
2. Preferred model: GPT-3.5-turbo (cheaper) or GPT-4 (better quality)?
3. Should we store conversation history in database? (Recommended for context)
4. Rate limiting preferences? (e.g., 20 requests per minute per user)

---

## Notes

- LangChain provides better prompt management and chain composition
- Agriculture filtering is done via prompt engineering (no separate classification model needed initially)
- Can add RAG (vector database) later for better app knowledge retrieval
- Conversation history helps maintain context across messages

