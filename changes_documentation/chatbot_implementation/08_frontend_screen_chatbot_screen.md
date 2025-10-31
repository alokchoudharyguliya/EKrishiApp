# Frontend Screen - ChatbotScreen Integration

## File Changed
- `NewsCalendar/lib/screens/chatbot_screen.dart`

## Change Type
MODIFY - Integrated backend API calls

## Line Numbers Changed

### Imports Added
- **Lines 2-4**: Added imports for Provider, ChatbotService, and AuthService

### State Variables Added
- **Line 17**: Added `_sessionId` for conversation continuity
- **Line 18**: Added `_isLoading` for loading state

### Welcome Message Updated
- **Line 26**: Changed welcome message to agriculture-specific

### `_sendMessage()` Method Replaced
- **Lines 40-108**: Completely replaced placeholder with real API integration
  - **Lines 44-50**: Add user message and set loading state
  - **Lines 56-62**: Call backend API via ChatbotService
  - **Lines 64-67**: Update sessionId from response
  - **Lines 69-82**: Add bot response to UI
  - **Lines 83-107**: Error handling with user-friendly messages

### Send Button Updated
- **Lines 201-212**: Added loading indicator in send button
  - Shows CircularProgressIndicator when `_isLoading` is true
  - Disables button during API call

## Details

### Before
- Placeholder response with `Future.delayed()`
- No actual API calls
- No error handling

### After
- Real API integration with ChatbotService
- Loading states
- Error handling with user feedback
- Session management for conversation continuity
- Proper async/await pattern

### User Experience Improvements
- Loading indicator during API call
- Error messages displayed in chat and snackbar
- Maintains conversation context via sessionId
- Prevents multiple simultaneous requests

---

## Impact
- Chatbot now functional with real AI responses
- Better UX with loading states and error handling
- Conversation continuity maintained

