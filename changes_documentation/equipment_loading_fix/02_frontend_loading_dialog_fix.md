# Frontend Loading Dialog and Error Handling Fix

## File Changed
`NewsCalendar/lib/screens/equipment_markeplace_screen.dart`

## Problem
1. Loading dialog could remain open indefinitely if an exception occurred before dialog closure
2. Error messages were generic and didn't clearly indicate if equipment creation/update failed
3. Dialog closing logic was not robust against all error scenarios

## Changes Made

### Line 611: Added dialog tracking variable
**Added:**
```dart
bool dialogClosed = false;
```
- Tracks whether the loading dialog has been closed to prevent double-closing

### Lines 667-672: Improved dialog closure timing
**Before:**
```dart
print("response: $response");
if (context.mounted) {
  Navigator.pop(context); // Close loading dialog
}
```

**After:**
```dart
// Close loading dialog
if (context.mounted && !dialogClosed) {
  Navigator.pop(context);
  dialogClosed = true;
}
```
- Checks dialog state before closing to prevent errors
- Marks dialog as closed after closing

### Line 677: Added null check for response.data
**Before:**
```dart
response.data['success'] == true;
```

**After:**
```dart
response.data != null &&
response.data['success'] == true;
```
- Prevents null pointer exceptions when response data is missing

### Lines 716-720: Improved error message for failed responses
**Before:**
```dart
} else {
  throw Exception('Failed to save equipment');
}
```

**After:**
```dart
} else {
  // Equipment was not added/updated
  String actionText = isEditing ? 'updated' : 'added';
  throw Exception('Failed to $actionText equipment. Please try again.');
}
```
- More specific error message based on create vs update operation

### Lines 721-726: Ensure dialog closure in catch block
**Before:**
```dart
} catch (e) {
  if (context.mounted) {
    Navigator.pop(context); // Close loading dialog
```

**After:**
```dart
} catch (e) {
  // Ensure loading dialog is closed
  if (context.mounted && !dialogClosed) {
    Navigator.pop(context);
    dialogClosed = true;
  }
```
- Prevents double-closing the dialog
- Ensures dialog is closed even if exception occurred before normal closure

### Lines 728-731: Improved default error messages
**Before:**
```dart
String errorMessage =
    'An error occurred. Please try again.';
```

**After:**
```dart
String errorMessage = isEditing
    ? 'Equipment could not be updated. Please try again.'
    : 'Equipment could not be added. Please try again.';
```
- Action-specific default error messages

### Lines 738-765: Enhanced error parsing and status code handling
**Added comprehensive error handling:**
- **Lines 738-751**: Better parsing of error responses (handles both 'message' and 'error' fields)
- **Lines 744-747**: Special handling for authentication errors
- **Lines 754-765**: Specific error messages for different HTTP status codes:
  - 401: Authentication required
  - 403: Permission denied
  - 404: Equipment not found (for updates)
  - 400: Validation errors (uses message from response)

### Lines 769-783: Enhanced network error messages
**Improved error messages for network issues:**
- Timeout errors now specify whether create or update failed
- Connection errors include action context
- All messages clearly state that equipment was not added/updated

### Line 799: Increased error message duration
**Before:**
```dart
duration: const Duration(seconds: 4),
```

**After:**
```dart
duration: const Duration(seconds: 5),
```
- Longer display time for error messages to ensure user can read them

## Impact
1. **Loading Dialog**: Always closes properly, preventing infinite loading
2. **Error Messages**: Clear, action-specific messages that tell users exactly what failed
3. **User Experience**: Better feedback for authentication, permission, and validation errors
4. **Robustness**: Handles edge cases like null responses and various error types

## Line Numbers Changed
- **Line 611**: Added dialog tracking variable
- **Lines 667-672**: Improved dialog closure logic
- **Line 677**: Added null check
- **Lines 716-720**: Improved failed response error message
- **Lines 721-726**: Enhanced catch block dialog closure
- **Lines 728-803**: Complete rewrite of error handling with better messages

