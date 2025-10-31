# Frontend Service - ChatbotService

## File Changed
- `NewsCalendar/lib/services/chatbot_service.dart`

## Change Type
NEW FILE - Created Flutter chatbot service

## Line Numbers
- Entire file (new file, ~150 lines)

## Details

### Purpose
Dart service layer for communicating with chatbot backend API.

### Key Methods

#### `sendMessage(BuildContext, String, {String? sessionId})`
- **Lines 12-58**: Sends message to backend
- Gets auth token from AuthService
- Makes POST request to `/api/chatbot/message`
- Handles timeouts (30 seconds)
- Returns response with sessionId

**Response Format**:
```dart
{
  'success': true,
  'response': 'AI response text',
  'sessionId': 'session-id',
  'provider': 'gemini'
}
```

#### `getHistory(BuildContext, String sessionId)`
- **Lines 64-103**: Retrieves conversation history
- Gets auth token
- Makes GET request to `/api/chatbot/history`
- Returns list of messages

#### `deleteHistory(BuildContext, String sessionId)`
- **Lines 109-148**: Deletes conversation history
- Gets auth token
- Makes DELETE request to `/api/chatbot/history/:sessionId`

### Error Handling
- Authentication checks
- Timeout handling (10-30 seconds)
- Network error handling
- JSON parsing error handling

### Dependencies Used
- `http` package (already in pubspec.yaml)
- `provider` for AuthService access
- Uses `BASE_URL` from constants

---

## Impact
- Provides clean API for Flutter app
- Handles authentication automatically
- Comprehensive error handling

