# Quick cURL Commands for Chatbot Testing

## Quick Reference

### 1. Send Message (Most Important)
```bash
curl -X POST http://localhost:3001/api/chatbot/message \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -d '{"message": "How do I detect crop diseases?", "sessionId": null}'
```

### 2. Get Conversation History
```bash
curl -X GET "http://localhost:3001/api/chatbot/history?sessionId=SESSION_ID" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

### 3. List All Conversations
```bash
curl -X GET http://localhost:3001/api/chatbot/conversations \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

### 4. Delete Conversation
```bash
curl -X DELETE http://localhost:3001/api/chatbot/history/SESSION_ID \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

---

## Get JWT Token First

### Option 1: Login Endpoint
```bash
curl -X POST http://localhost:3001/login \
  -H "Content-Type: application/json" \
  -d '{"email": "your_email@example.com", "password": "your_password"}'
```

Extract the `token` from the response and use it in the Authorization header.

### Option 2: Use Token from Flutter App
- Log in through Flutter app
- Get token from FlutterSecureStorage or app logs

---

## Complete Test Sequence

```bash
# 1. Get Token (replace with your credentials)
TOKEN=$(curl -s -X POST http://localhost:3001/login \
  -H "Content-Type: application/json" \
  -d '{"email": "your_email@example.com", "password": "your_password"}' \
  | grep -o '"token":"[^"]*' | cut -d'"' -f4)

# 2. Send Message
RESPONSE=$(curl -s -X POST http://localhost:3001/api/chatbot/message \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"message": "Hello! How can you help with farming?", "sessionId": null}')

# 3. Extract Session ID
SESSION_ID=$(echo "$RESPONSE" | grep -o '"sessionId":"[^"]*' | cut -d'"' -f4)
echo "Session ID: $SESSION_ID"

# 4. Get History
curl -X GET "http://localhost:3001/api/chatbot/history?sessionId=$SESSION_ID" \
  -H "Authorization: Bearer $TOKEN" | python -m json.tool
```

---

## Network URL (If testing from different device)

Replace `localhost:3001` with your network IP:
```bash
curl -X POST http://192.168.29.64:3001/api/chatbot/message \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -d '{"message": "How do I detect crop diseases?", "sessionId": null}'
```

