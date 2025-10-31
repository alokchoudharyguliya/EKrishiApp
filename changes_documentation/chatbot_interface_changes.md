# Chatbot Interface Implementation - Changes Documentation

## Summary
Replaced the Profile tab in the bottom navigation with a Chatbot interface. The chatbot provides a minimalistic chat interface with placeholder functionality, designed to be easily integrated with a backend API in the future.

## Date
[Current Date]

---

## Files Changed

### 1. **NEW FILE**: `NewsCalendar/lib/screens/chatbot_screen.dart`
   - **Status**: Created new file
   - **Purpose**: Chatbot screen with minimalistic chat interface
   - **Features**:
     - Simple two-person chat interface (user and bot)
     - Message bubbles with different styling for user (right, blue) and bot (left, grey)
     - Text input field with send button
     - Auto-scroll to bottom on new messages
     - Welcome message on initialization
     - Placeholder bot responses (ready for API integration)
     - **No AppBar** - Designed to work as a widget within bottom navigation system
   - **Line Count**: ~215 lines (AppBar removed in update)

---

### 2. **MODIFIED**: `NewsCalendar/lib/widgets/custom_bottom_nav_bar.dart`
   - **Change Type**: Icon and label replacement
   - **Line #39**: 
     - **Before**: `_buildNavItem(context, Icons.person, 3, 'Profile'),`
     - **After**: `_buildNavItem(context, Icons.chat_bubble, 3, 'Chatbot'),`
   - **Description**: Changed the fourth navigation item from Profile (person icon) to Chatbot (chat bubble icon)

---

### 3. **MODIFIED**: `NewsCalendar/lib/homepage.dart`
   - **Change Type**: Added import and added chatbot screen to pages list
   
   - **Line #16**: Added import statement
     - **Added**: `import './screens/chatbot_screen.dart';`
     - **Description**: Import statement for the new ChatbotScreen widget
   
   - **Line #31**: Added ChatbotScreen to _pages list
     - **Before**: 
       ```dart
       final List<Widget> _pages = [
         Container(),
         FarmCCTV(),
         NewsPage(),
       ];
       ```
     - **After**: 
       ```dart
       final List<Widget> _pages = [
         Container(),
         FarmCCTV(),
         NewsPage(),
         ChatbotScreen(),
       ];
       ```
     - **Description**: Added ChatbotScreen() as the fourth page (index 3) to match the bottom navigation tab

---

## Design Details

### Chat Interface Design:
- **User Messages**: 
  - Position: Right-aligned
  - Color: Primary theme color (blue)
  - Text: White
  - Border radius: Rounded with small corner on bottom-right

- **Bot Messages**:
  - Position: Left-aligned
  - Color: Light grey (#E0E0E0)
  - Text: Dark grey/black
  - Border radius: Rounded with small corner on bottom-left

- **Input Field**:
  - Rounded text field (24px border radius)
  - Circular send button with primary theme color
  - Supports multi-line input
  - Enter key submits message

- **Layout**:
  - No AppBar (integrated with bottom navigation bar)
  - Scrollable message list with padding
  - Fixed input area at bottom with SafeArea

---

## Future Integration Points

### Backend API Integration:
The `_sendMessage()` method in `chatbot_screen.dart` (line 36-66) currently uses a placeholder response. To integrate with backend API:

1. **Replace placeholder response** (lines 55-65) with actual API call
2. **Suggested API structure**:
   ```dart
   Future<void> _sendMessage() async {
     final text = _messageController.text.trim();
     if (text.isEmpty) return;
     
     // Add user message
     setState(() {
       _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
     });
     
     _messageController.clear();
     _scrollToBottom();
     
     // API call (replace placeholder)
     try {
       final response = await http.post(
         Uri.parse('$BASE_URL/chatbot'),
         headers: {'Authorization': 'Bearer $authToken', 'Content-Type': 'application/json'},
         body: jsonEncode({'message': text}),
       );
       
       final responseData = jsonDecode(response.body);
       setState(() {
         _messages.add(ChatMessage(
           text: responseData['response'],
           isUser: false,
           timestamp: DateTime.now(),
         ));
       });
       _scrollToBottom();
     } catch (e) {
       // Handle error
     }
   }
   ```

3. **Constants**:
   - Use `BASE_URL` from `constants/constants.dart` for API endpoint

---

## Testing Checklist
- [ ] Bottom navigation shows Chatbot tab (4th position)
- [ ] Chatbot screen loads when Chatbot tab is tapped
- [ ] User can type and send messages
- [ ] Messages appear in correct bubble styling (user right/blue, bot left/grey)
- [ ] Chat auto-scrolls to bottom on new messages
- [ ] Welcome message appears on first load
- [ ] Input field clears after sending
- [ ] Send button works
- [ ] Enter key submits message

---

## Notes
- The chatbot screen is designed to match the existing app theme and color scheme
- Uses Material Design components consistent with the rest of the app
- Profile functionality is still accessible via the drawer menu (line 320-330 in homepage.dart)
- The interface is minimalistic as requested, focusing on core chat functionality
- **Update**: AppBar removed - chatbot screen works as a widget within the bottom navigation system, no standalone AppBar needed

## Change History
- **Initial Implementation**: Created chatbot screen with AppBar
- **Update 1**: Removed AppBar (lines 80-87 in original) as the screen is used within bottom navigation bar system
- **Update 2**: Added keyboard handling - input box now moves up when keyboard appears (lines 79-83, 113-118)
  - Added `resizeToAvoidBottomInset: true` to Scaffold
  - Modified input area padding to use `MediaQuery.viewInsets.bottom` to position input above keyboard
  - Updated SafeArea to not apply top padding

