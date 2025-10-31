# File Changes Log - Image Upload Error Fix

## Date
2025-10-31

## Issue
Error: "Only image files are allowed" when uploading equipment images from Flutter app.

## Root Cause
Missing `contentType` parameter in `MultipartFile.fromFile()` call, causing multer to not receive proper MIME type information.

## Files Modified

### 1. NewsCalendar/lib/screens/equipment_markeplace_screen.dart

**Line 6:** Added import
```dart
import 'package:http_parser/http_parser.dart';
```

**Line 7:** Added import
```dart
import 'package:path/path.dart' as path;
```

**Lines 141-158:** Added helper function
```dart
MediaType _getImageMediaType(String filePath)
```

**Lines 647-661:** Modified image upload code
- Added image type detection
- Added contentType parameter to MultipartFile.fromFile()
- Improved filename to preserve original extension

## Testing Checklist
- [ ] Test JPEG image upload
- [ ] Test PNG image upload
- [ ] Test GIF image upload (if supported)
- [ ] Test WebP image upload (if supported)
- [ ] Test create new equipment with image
- [ ] Test update equipment with new image
- [ ] Verify backend receives correct mimetype
- [ ] Verify files saved with correct extensions

## Notes
- Backend file filter is correctly implemented and should now work with the fix
- Similar code in profile_screen.dart already uses contentType correctly

