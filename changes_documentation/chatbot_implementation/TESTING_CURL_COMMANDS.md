# Chatbot Backend - cURL Testing Commands

## Prerequisites

1. **Get JWT Token**: First, you need to authenticate and get a JWT token. You can get this by:
   - Logging in through the Flutter app and checking the stored token
   - Or using your existing login endpoint to get a token

2. **Backend URL**: Replace `http://localhost:3001` with your actual backend URL if different
   - Default: `http://localhost:3001` or `http://192.168.29.64:3001` (based on your constants)

---

## 1. Send Message (Main Endpoint)

### Basic Message
```bash
curl -X POST http://localhost:3001/api/chatbot/message \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -d '{
    "message": "How do I detect crop diseases?",
    "sessionId": null
  }'
```

### With Existing Session
```bash
curl -X POST http://localhost:3001/api/chatbot/message \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -d '{
    "message": "What about irrigation scheduling?",
    "sessionId": "userId_1234567890"
  }'
```

### Agriculture-Specific Query
```bash
curl -X POST http://localhost:3001/api/chatbot/message \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -d '{
    "message": "How do I use the crop disease detection feature in EKrishi?",
    "sessionId": null
  }'
```

### Test Non-Agriculture Rejection
```bash
curl -X POST http://localhost:3001/api/chatbot/message \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -d '{
    "message": "Tell me a joke",
    "sessionId": null
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "response": "I'm specialized in agriculture and farming topics...",
  "sessionId": "userId_1234567890",
  "provider": "gemini",
  "metadata": {
    "tokensUsed": 150
  }
}
```

---

## 2. Get Conversation History

### Get History by Session ID
```bash
curl -X GET "http://localhost:3001/api/chatbot/history?sessionId=userId_1234567890" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

**Expected Response:**
```json
{
  "success": true,
  "sessionId": "userId_1234567890",
  "messages": [
    {
      "role": "user",
      "content": "How do I detect crop diseases?",
      "timestamp": "2025-01-XX...",
      "provider": null
    },
    {
      "role": "assistant",
      "content": "To detect crop diseases in EKrishi...",
      "timestamp": "2025-01-XX...",
      "provider": "gemini"
    }
  ],
  "metadata": {
    "totalTokensGemini": 150,
    "totalTokensOpenAI": 0,
    "fallbackCount": 0,
    "lastProvider": "gemini"
  }
}
```

---

## 3. List All Conversations

### Get All User Conversations
```bash
curl -X GET http://localhost:3001/api/chatbot/conversations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

**Expected Response:**
```json
{
  "success": true,
  "conversations": [
    {
      "sessionId": "userId_1234567890",
      "messageCount": 4,
      "lastMessage": "What about irrigation scheduling?",
      "createdAt": "2025-01-XX...",
      "updatedAt": "2025-01-XX...",
      "metadata": {
        "totalTokensGemini": 450,
        "totalTokensOpenAI": 0,
        "fallbackCount": 0,
        "lastProvider": "gemini"
      }
    }
  ]
}
```

---

## 4. Delete Conversation

### Delete by Session ID
```bash
curl -X DELETE http://localhost:3001/api/chatbot/history/userId_1234567890 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Conversation history deleted successfully"
}
```

---

## Complete Testing Flow

### Step 1: Send First Message (New Session)
```bash
curl -X POST http://localhost:3001/api/chatbot/message \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -d '{
    "message": "Hello! How can you help me with farming?",
    "sessionId": null
  }'
```

**Save the `sessionId` from the response!**

### Step 2: Send Follow-up Message (Same Session)
```bash
# Replace SESSION_ID with the sessionId from Step 1
curl -X POST http://localhost:3001/api/chatbot/message \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -d '{
    "message": "How do I detect crop diseases?",
    "sessionId": "SESSION_ID"
  }'
```

### Step 3: Get Conversation History
```bash
# Replace SESSION_ID with the sessionId from Step 1
curl -X GET "http://localhost:3001/api/chatbot/history?sessionId=SESSION_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

### Step 4: List All Conversations
```bash
curl -X GET http://localhost:3001/api/chatbot/conversations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

### Step 5: Clean Up - Delete Conversation
```bash
# Replace SESSION_ID with the sessionId from Step 1
curl -X DELETE http://localhost:3001/api/chatbot/history/SESSION_ID \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

---

## Error Testing

### Test Without Authentication
```bash
curl -X POST http://localhost:3001/api/chatbot/message \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Test message"
  }'
```

**Expected Response (401):**
```json
{
  "success": false,
  "error": "Please authenticate"
}
```

### Test Invalid Token
```bash
curl -X POST http://localhost:3001/api/chatbot/message \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer invalid_token_here" \
  -d '{
    "message": "Test message"
  }'
```

**Expected Response (401):**
```json
{
  "success": false,
  "error": "Please authenticate"
}
```

### Test Empty Message
```bash
curl -X POST http://localhost:3001/api/chatbot/message \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -d '{
    "message": "",
    "sessionId": null
  }'
```

**Expected Response (400):**
```json
{
  "success": false,
  "message": "Message is required and must be a non-empty string"
}
```

### Test Missing Message Field
```bash
curl -X POST http://localhost:3001/api/chatbot/message \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -d '{
    "sessionId": null
  }'
```

**Expected Response (400):**
```json
{
  "success": false,
  "message": "Message is required and must be a non-empty string"
}
```

---

## Quick Test Script

Create a file `test_chatbot.sh`:

```bash
#!/bin/bash

# Configuration
BASE_URL="http://localhost:3001"
TOKEN="YOUR_JWT_TOKEN_HERE"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Testing Chatbot Backend..."
echo ""

# Test 1: Send Message
echo -e "${GREEN}Test 1: Send Message${NC}"
RESPONSE=$(curl -s -X POST "$BASE_URL/api/chatbot/message" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "How do I detect crop diseases?",
    "sessionId": null
  }')

echo "$RESPONSE" | python -m json.tool
SESSION_ID=$(echo "$RESPONSE" | grep -o '"sessionId":"[^"]*' | cut -d'"' -f4)
echo "Session ID: $SESSION_ID"
echo ""

# Test 2: Get History
echo -e "${GREEN}Test 2: Get History${NC}"
curl -s -X GET "$BASE_URL/api/chatbot/history?sessionId=$SESSION_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" | python -m json.tool
echo ""

# Test 3: List Conversations
echo -e "${GREEN}Test 3: List All Conversations${NC}"
curl -s -X GET "$BASE_URL/api/chatbot/conversations" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" | python -m json.tool
echo ""

echo -e "${GREEN}Tests completed!${NC}"
```

**Usage:**
```bash
chmod +x test_chatbot.sh
# Edit the script to add your JWT token
./test_chatbot.sh
```

---

## Getting JWT Token

### Option 1: From Flutter App
1. Log in through the app
2. Check FlutterSecureStorage or app logs for the token

### Option 2: From Login Endpoint
```bash
# Replace with your actual login endpoint
curl -X POST http://localhost:3001/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "your_email@example.com",
    "password": "your_password"
  }'
```

Extract the token from the response and use it in subsequent requests.

---

## Tips

1. **Pretty Print JSON**: Add `| python -m json.tool` or `| jq` to pretty print responses
2. **Save Session ID**: Save the sessionId from first response to test conversation continuity
3. **Check Logs**: Monitor backend console for service logs and errors
4. **Test Fallback**: To test OpenAI fallback, you may need to hit Gemini rate limits or temporarily disable Gemini API key

---

## Troubleshooting

### Connection Refused
- Ensure backend server is running: `cd backend && npm start`
- Check if port is correct (default: 3001)

### 401 Unauthorized
- Check JWT token is valid and not expired
- Ensure token is included in Authorization header with "Bearer " prefix

### 500 Internal Server Error
- Check backend logs for detailed error
- Verify API keys are set in `.env`
- Ensure MongoDB is connected

### No Response / Timeout
- Check internet connection (for Gemini/OpenAI API calls)
- Verify API keys are valid
- Check if backend is processing (look at logs)

---

## Environment-Specific URLs

Based on your constants file, you might need to use:
- Local: `http://localhost:3001`
- Network: `http://192.168.29.64:3001`

Adjust the BASE_URL in commands accordingly.

