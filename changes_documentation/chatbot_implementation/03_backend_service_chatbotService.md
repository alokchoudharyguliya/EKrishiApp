# Backend Service - ChatbotService

## File Changed
- `backend/services/chatbotService.js`

## Change Type
NEW FILE - Created chatbot service

## Line Numbers
- Entire file (new file, ~350 lines)

## Details

### Purpose
Core service layer that handles AI chat interactions with Gemini (primary) and OpenAI (fallback).

### Key Methods

#### `constructor()`
- **Lines 13-53**: Initializes Gemini and OpenAI LLMs
- Checks for API keys in environment variables
- Builds agriculture-specific system prompt

#### `buildSystemPrompt()`
- **Lines 55-74**: Creates agriculture-focused system prompt
- Defines bot role as agriculture expert
- Lists EKrishi app features
- Instructions for rejecting non-agriculture queries

#### `callGeminiAPI(userMessage, conversationHistory)`
- **Lines 79-119**: Calls Google Gemini API via LangChain
- Handles errors and rate limiting
- Estimates token usage
- Returns formatted response

#### `callOpenAITAPI(userMessage, conversationHistory)`
- **Lines 126-162**: Calls OpenAI API via LangChain (fallback)
- Same interface as Gemini for seamless switching
- Handles errors

#### `getConversationHistory(sessionId)`
- **Lines 168-192**: Loads conversation from database
- Converts to LangChain message format
- Filters out system messages and errors

#### `getResponse(userMessage, sessionId, userId)`
- **Lines 198-248**: Main method with fallback logic
- Tries Gemini first
- Falls back to OpenAI on rate limit or error
- Returns unified response format

#### `saveMessage(sessionId, userId, role, content, provider, tokensUsed)`
- **Lines 253-310**: Saves messages to database
- Updates metadata (token counts, fallback count)
- Creates new conversation if needed

#### `generateSessionId(userId, sessionId)`
- **Lines 315-323**: Generates or returns session ID
- Format: `userId_timestamp`

### Error Handling
- Rate limit detection for Gemini
- Automatic fallback to OpenAI
- Graceful error handling
- Logging for debugging

---

## Impact
- Enables hybrid Gemini + OpenAI chatbot
- Agriculture-specific responses
- Automatic fallback on errors
- Conversation context management

