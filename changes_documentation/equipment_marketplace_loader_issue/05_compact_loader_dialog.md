# Compact Loader Dialog - UI Improvement

## Issue
The CircularProgressIndicator was taking the entire screen as a full-screen blocking dialog, which provided a poor user experience.

## Solution
Replaced the full-screen dialog with a compact, centered dialog box that:
- Shows a small white container with rounded corners
- Has a semi-transparent dark background overlay
- Displays the CircularProgressIndicator with descriptive text
- Takes minimal screen space while still being visible

## File Changed
- `NewsCalendar/lib/screens/equipment_markeplace_screen.dart`

## Changes Made

### Lines 598-629 (Previously 598-609)

**Before:**
```dart
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => const Center(
    child: CircularProgressIndicator(),
  ),
);
```

**After:**
```dart
showDialog(
  context: context,
  barrierDismissible: false,
  barrierColor: Colors.black54,  // Semi-transparent overlay
  builder: (context) => Center(
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            isEditing
                ? 'Updating equipment...'
                : 'Adding equipment...',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    ),
  ),
);
```

## Improvements
1. **Compact Design**: Small white container instead of full-screen indicator
2. **Better UX**: Users can still see the screen context (dimmed)
3. **Informative**: Includes text indicating what's happening
4. **Professional Look**: Rounded corners and proper padding
5. **Context-Aware**: Shows "Adding equipment..." or "Updating equipment..." based on operation

## Visual Difference
- **Before**: Full-screen with just a spinner in the center
- **After**: Small white box in center with spinner + text, semi-transparent dark overlay

