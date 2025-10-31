# Missing Equipment Model Import Fix

## Issue
Compilation errors occurred after refactoring code to use `Equipment` model class instead of `Map<String, dynamic>`:

```
Error: Type 'Equipment' not found.
Error: 'Equipment' isn't a type.
```

## Root Cause
The `Equipment` model class exists at `lib/models/equipment.dart` but was not imported in the `equipment_markeplace_screen.dart` file.

## Solution
Added the missing import statement to `equipment_markeplace_screen.dart`.

## Changes Made

### File: `NewsCalendar/lib/screens/equipment_markeplace_screen.dart`

**Line 9:** Added import
```dart
import 'package:newscalendar/models/equipment.dart';
```

## Files Changed

| File | Line | Change |
|------|------|--------|
| `NewsCalendar/lib/screens/equipment_markeplace_screen.dart` | 9 | Added Equipment model import |

## Status
✅ **FIXED** - Import added, compilation errors should be resolved.

## Notes
- The `Equipment` model class was already properly defined with:
  - `fromJson()` factory constructor
  - Properties matching the code usage: `id`, `name`, `description`, `price`, `contact`, `location`, `isAvailable`, `imageUrl`, `ownerId`
  - All code was already using dot notation correctly (e.g., `tool.name`, `tool.price`)

