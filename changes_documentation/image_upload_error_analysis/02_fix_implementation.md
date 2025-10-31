# Image Upload Error Fix Implementation

## Summary
Fixed the image upload error by adding explicit `contentType` parameter to `MultipartFile.fromFile()` call in the equipment marketplace screen. This ensures the correct MIME type is sent in the HTTP request headers, allowing the backend multer file filter to properly validate the file.

## Root Cause
The frontend code was creating `MultipartFile` without specifying the `contentType` parameter, which resulted in missing or incorrect `Content-Type` headers. The backend multer file filter requires `file.mimetype` to be set and start with `'image/'` to accept the file.

## Changes Made

### File: `NewsCalendar/lib/screens/equipment_markeplace_screen.dart`

#### 1. Added Imports (Lines 6-7)
- Added `package:http_parser/http_parser.dart` for `MediaType` support
- Added `package:path/path.dart` as `path` for file extension detection

**Before:**
```dart
import 'package:dio/dio.dart';
import 'package:newscalendar/utils/imports.dart';
```

**After:**
```dart
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:newscalendar/utils/imports.dart';
```

#### 2. Added Helper Function (Lines 141-158)
Created `_getImageMediaType()` function to detect image type from file extension:

```dart
/// Helper function to detect MediaType from file extension
MediaType _getImageMediaType(String filePath) {
  final extension = path.extension(filePath).toLowerCase();
  switch (extension) {
    case '.jpg':
    case '.jpeg':
      return MediaType('image', 'jpeg');
    case '.png':
      return MediaType('image', 'png');
    case '.gif':
      return MediaType('image', 'gif');
    case '.webp':
      return MediaType('image', 'webp');
    default:
      // Default to jpeg if extension is unknown
      return MediaType('image', 'jpeg');
  }
}
```

**Purpose:** Dynamically detects the image type from the file extension, supporting jpeg, png, gif, and webp formats. Defaults to jpeg if extension is unknown.

#### 3. Updated Image Upload Code (Lines 647-661)
Modified the `MultipartFile.fromFile()` call to include `contentType` parameter and improved filename generation:

**Before:**
```dart
if (selectedImageFile != null) {
  final multipartFile = await MultipartFile.fromFile(
    selectedImageFile!.path,
    filename: 'equipment_${DateTime.now().millisecondsSinceEpoch}.jpg',
  );
  formData.files.add(
    MapEntry('image', multipartFile),
  );
}
```

**After:**
```dart
if (selectedImageFile != null) {
  // Detect image type from file extension
  final imageMediaType = _getImageMediaType(selectedImageFile!.path);
  final fileExtension = path.extension(selectedImageFile!.path);
  final filename = 'equipment_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
  
  final multipartFile = await MultipartFile.fromFile(
    selectedImageFile!.path,
    filename: filename,
    contentType: imageMediaType,
  );
  formData.files.add(
    MapEntry('image', multipartFile),
  );
}
```

**Improvements:**
1. Explicitly sets `contentType` using the detected MediaType
2. Preserves original file extension in the filename instead of hardcoding `.jpg`
3. Supports multiple image formats (jpeg, png, gif, webp)

## Files Changed

| File | Lines Changed | Change Type |
|------|---------------|-------------|
| `NewsCalendar/lib/screens/equipment_markeplace_screen.dart` | 6-7 | Added imports |
| `NewsCalendar/lib/screens/equipment_markeplace_screen.dart` | 141-158 | Added helper function |
| `NewsCalendar/lib/screens/equipment_markeplace_screen.dart` | 647-661 | Modified upload logic |

## Testing Recommendations

1. **Test with different image formats:**
   - JPEG (.jpg, .jpeg)
   - PNG (.png)
   - GIF (.gif) - if backend supports
   - WebP (.webp) - if backend supports

2. **Test upload scenarios:**
   - New equipment creation with image
   - Equipment update with new image
   - Equipment update without changing image

3. **Verify backend receives correct mimetype:**
   - Check server logs to confirm `file.mimetype` is set correctly
   - Verify files are saved with correct extensions

## Backend Compatibility

The backend file filter in `backend/routes/equipmentRoutes.js` (line 26) checks:
```javascript
if (file.mimetype && file.mimetype.startsWith('image/'))
```

This fix ensures that `file.mimetype` will be properly set by multer when it receives the `Content-Type` header from the frontend.

## Related Issues

- Similar pattern found in `profile_screen.dart` (line 298) which already uses `contentType: MediaType('image', 'jpeg')` - works correctly
- Potential improvement: Consider making backend file filter more defensive by also checking file extension as fallback

## Status
✅ Fix implemented and ready for testing

