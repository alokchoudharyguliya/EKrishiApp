# Fix: Android Core Library Desugaring

**File:** `NewsCalendar/android/app/build.gradle.kts`
**Type:** Build Configuration Fix
**Date:** Current Session

---

## Issue

`flutter_local_notifications` requires core library desugaring to be enabled for Android builds. Error message:
```
Dependency ':flutter_local_notifications' requires core library desugaring to be enabled
```

---

## Fix Applied

### 1. Updated compileSdk to 36
- Changed from `flutter.compileSdkVersion` to `36` (fixes SDK version warning)

### 2. Enabled Core Library Desugaring
- Added `isCoreLibraryDesugaringEnabled = true` to `compileOptions` block

### 3. Added Desugaring Dependency
- Added `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")` to dependencies

---

## Changes Made

**Line 12:** Updated `compileSdk = 36`  
**Line 18:** Added `isCoreLibraryDesugaringEnabled = true`  
**Lines 48-50:** Added dependencies block with desugaring library

---

## What is Core Library Desugaring?

Core library desugaring allows newer Java language APIs (Java 8+) to be used on older Android versions (API level 23+). The `flutter_local_notifications` plugin requires this feature.

---

## Notes

- Uses desugar_jdk_libs version 2.0.4 (latest stable)
- Compatible with minSdk 23
- Required for flutter_local_notifications to work properly

