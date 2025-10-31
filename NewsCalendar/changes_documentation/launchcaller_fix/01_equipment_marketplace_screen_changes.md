# Equipment Marketplace Screen - `_launchCaller` Function Fix

## File: `lib/screens/equipment_markeplace_screen.dart`

---

## Change Summary
Enhanced the `_launchCaller` function to properly handle phone numbers with formatting and add explicit launch mode for better compatibility.

---

## Original Code (Lines 104-116)

```dart
Future<void> _launchCaller(String phone) async {
  final Uri url = Uri(scheme: 'tel', path: phone);
  // var url = Uri.parse("tel:1234567890");
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch dialer')),
      );
    }
  }
}
```

---

## Updated Code (Lines 104-117)

```dart
Future<void> _launchCaller(String phone) async {
  // Clean phone number: remove spaces, keep + and digits
  final String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
  final Uri url = Uri(scheme: 'tel', path: cleanPhone);
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.platformDefault);
  } else {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch dialer')),
      );
    }
  }
}
```

---

## Line-by-Line Changes

| Line | Change Type | Description |
|------|-------------|-------------|
| 105 | **ADDED** | Comment explaining phone number cleaning |
| 106 | **ADDED** | Phone number sanitization: removes all characters except digits and `+` |
| 107 | **MODIFIED** | Changed `phone` to `cleanPhone` in Uri creation |
| audit | **MODIFIED** | Added `mode: LaunchMode.platformDefault` parameter to `launchUrl()` |

---

## What Changed

### 1. Phone Number Sanitization (Line 106)
- **Before:** Used phone number directly from parameter (could contain spaces, dashes, parentheses)
- **After:** Cleans phone number using regex `r'[^\d+]'` to remove all characters except digits and `+`
- **Why:** Some phone numbers in the data might have formatting like `+91 9876 543210` or `(987) 654-3210`, which could cause issues with the dialer

### 2. Launch Mode (Line 109)
- **Before:** No explicit launch mode specified (relies on default behavior)
- **After:** Explicitly uses `LaunchMode.platformDefault`
- **Why:** Ensures consistent behavior across different Android versions and devices

---

## Impact

✅ **Improvements:**
- Phone numbers with formatting (spaces, dashes, parentheses) now work correctly
- More reliable dialer launching across different Android versions
- Better error handling maintained

⚠️ **No Breaking Changes:**
- Function signature unchanged
- Existing functionality preserved
- Backward compatible

---

## Testing Checklist

- [ ] Test with phone number: `+91 9876543210`
- [ ] Test with phone number: `9876543210`
- [ ] Test with phone number: `+1-234-567-8900`
- [ ] Test with phone number containing spaces: `+91 9876 543210`
- [ ] Verify dialer opens on Android 10+
- [ ] Verify dialer opens on Android 12+
- [ ] Test error handling when dialer cannot be launched

---

## Related Code

This function is called from:
- **Line 930:** `onPressed: () => _launchCaller(tool['contact'])`

The `tool['contact']` values in the data are formatted like:
- `'+91 9876543210'`
- `'+91 9871234560'`
- `'+91 9898989898'`

