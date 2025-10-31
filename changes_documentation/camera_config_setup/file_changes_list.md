# Camera Config Setup - Detailed File Changes List

## Files Modified/Created with Line Numbers

---

## 📄 NEW FILES CREATED

### 1. `NewsCalendar/assets/config/cameras.json`
- **Status**: New file created
- **Purpose**: JSON configuration for camera list
- **Lines**: Entire file (3 lines)
  - Line 1: `{`
  - Line 2: `  "cameras": []`
  - Line 3: `}`

### 2. `NewsCalendar/lib/config/camera_config.dart`
- **Status**: New file created
- **Purpose**: Camera configuration model and service
- **Total Lines**: 125 lines
- **Key Sections**:
  - Lines 1-3: Imports
  - Lines 5-43: `CameraConfig` model class
    - Line 6-10: Class properties
    - Line 12: Constructor
    - Lines 15-24: `fromJson` factory method
    - Lines 27-35: `toJson` method
  - Lines 46-124: `CameraConfigService` class
    - Lines 47-49: Private fields
    - Lines 51-54: `getCameras()` method
    - Lines 57-60: `getEnabledCameras()` method
    - Lines 63-70: `getCameraById()` method
    - Lines 73-80: `getCameraByStreamId()` method
    - Lines 84-99: `loadCameras()` method
    - Lines 102-105: `reloadCameras()` method

---

## 📝 MODIFIED FILES

### 3. `NewsCalendar/lib/widgets/farm_cctv.dart`
- **Status**: Modified
- **Original Size**: ~449 lines (with comments)
- **Changes Breakdown**:

#### **Line 4 - Added Import**
```dart
import 'package:newscalendar/config/camera_config.dart';
```

#### **Lines 13-20 - State Variable Changes**
- **Removed** (old Line 13): `int _selectedCamera = 1;`
- **Removed** (old Line 14): `final int _cameraCount = 4;`
- **Added** (new Line 14): `final CameraConfigService _cameraService = CameraConfigService();`
- **Added** (new Line 15): `List<CameraConfig> _cameras = [];`
- **Added** (new Line 16): `bool _isLoading = true;`
- **Added** (new Line 17): `CameraConfig? _selectedCamera;`

#### **Lines 22-28 - initState() Method**
- **Line 26**: Changed from:
  ```dart
  _connectToCamera(_selectedCamera);
  ```
  To:
  ```dart
  _loadCameras();
  ```

#### **Lines 30-54 - New Method Added: _loadCameras()**
- Entirely new method (25 lines)
- Lines 32-34: Set loading state
- Lines 37-46: Load cameras and select first
- Lines 47-53: Error handling

#### **Lines 81-88 - Modified Method: _connectToCamera()**
- **Line 81**: Parameter changed from `int cameraNumber` to `CameraConfig camera`
- **Line 83**: Changed from `_selectedCamera = cameraNumber;` to `_selectedCamera = camera;`
- **Line 87**: Updated comment to reference `camera.streamId`

#### **Lines 90-276 - Modified Method: build()**
- **Lines 98-103**: Added loading indicator widget (6 lines)
- **Lines 104-130**: Added empty state message (27 lines)
- **Line 131**: Changed from single widget to conditional spread operator `else ...[`
- **Line 161**: Changed text from `'Camera $_selectedCamera'` to `_selectedCamera?.name ?? 'No Camera Selected'`
- **Line 203**: Changed from `itemCount: _cameraCount` to `itemCount: _cameras.length`
- **Line 211**: Changed from:
  ```dart
  final camNum = index + 1;
  ```
  To:
  ```dart
  final camera = _cameras[index];
  ```
- **Line 212**: Changed from:
  ```dart
  final isSelected = camNum == _selectedCamera;
  ```
  To:
  ```dart
  final isSelected = _selectedCamera?.id == camera.id;
  ```
- **Line 214**: Changed from:
  ```dart
  onTap: () => _connectToCamera(camNum),
  ```
  To:
  ```dart
  onTap: () => _connectToCamera(camera),
  ```
- **Lines 250-264**: Modified camera name display section
  - **Line 253**: Changed from `'Cam $camNum'` to `camera.name`
  - **Line 262**: Added `overflow: TextOverflow.ellipsis,`
  - **Line 263**: Added `maxLines: 1,`

---

### 4. `NewsCalendar/pubspec.yaml`
- **Status**: Modified
- **Line 104 - Added Asset Entry**
- **Before**:
  ```yaml
  assets:
    - assets/bamboo-research-452705-u8-6ebb1bbd471a.json
    - .env
    - assets/images/
  ```
- **After**:
  ```yaml
  assets:
    - assets/bamboo-research-452705-u8-6ebb1bbd471a.json
    - .env
    - assets/images/
    - assets/config/cameras.json
  ```
- **Change**: Added `- assets/config/cameras.json` on Line 104

---

## 📊 Summary Statistics

- **New Files Created**: 2
- **Files Modified**: 2
- **Total Lines Added**: ~200 lines
- **Total Lines Modified**: ~30 lines
- **Total Lines Removed**: ~5 lines

---

## 🔍 Verification Checklist

After these changes:
- ✅ All syntax errors resolved
- ✅ Linter errors resolved
- ✅ Imports are correct
- ✅ Asset file properly registered
- ✅ Widget properly uses configuration service
- ✅ Error handling in place
- ✅ Loading states handled
- ✅ Empty state handled gracefully

---

## 📝 Notes

1. The commented-out code at the bottom of `farm_cctv.dart` (lines 279-520) was left intact as it may contain future reference implementations.

2. The camera configuration system is designed to be flexible - users can add/remove cameras by editing the JSON file without code changes.

3. The `CameraConfigService` uses a singleton-like pattern with instance caching to avoid reloading the config file multiple times.

4. The system only loads cameras with `enabled: true`, making it easy to temporarily disable cameras without removing them from the config.

