# Camera Configuration Setup - Changes Summary

## Overview
This document tracks all changes made to implement camera configuration management for the FarmCCTV section. The system now uses a JSON-based configuration file to manage multiple USB camera feeds via WebRTC stream IDs.

## Date: October 31, 2025

---

## Files Changed

### 1. New File: `NewsCalendar/assets/config/cameras.json`
**Purpose**: JSON configuration file to store camera configurations
**Status**: Created

**Content Structure**:
```json
{
  "cameras": []
}
```

**Details**:
- Initially created with empty cameras array
- Users will add camera configurations here
- Each camera entry will contain: id, name, streamId (WebRTC), enabled status, and optional description

**Line Numbers**: N/A (new file)

---

### 2. New File: `NewsCalendar/lib/config/camera_config.dart`
**Purpose**: Dart model class and service to manage camera configurations
**Status**: Created

**Contents**:
- `CameraConfig` class (lines 4-43): Model representing a camera configuration
- `CameraConfigService` class (lines 46-124): Service to load and manage cameras from JSON

**Key Features**:
- Loads cameras from JSON file using Flutter's rootBundle
- Provides methods to get all cameras, enabled cameras only, or cameras by ID/streamId
- Includes error handling for missing or invalid config files

**Line Numbers**:
- CameraConfig class: Lines 4-43
- CameraConfigService class: Lines 46-124
- fromJson factory: Lines 16-24
- toJson method: Lines 27-35
- getCameras method: Lines 51-54
- getEnabledCameras method: Lines 57-60
- getCameraById method: Lines 63-70
- getCameraByStreamId method: Lines 73-80
- loadCameras method: Lines 84-99
- reloadCameras method: Lines 102-105

---

### 3. Modified File: `NewsCalendar/lib/widgets/farm_cctv.dart`
**Purpose**: Updated FarmCCTV widget to load cameras from configuration instead of hardcoded values
**Status**: Modified

**Changes Made**:

#### Import Addition (Line 4):
- **Added**: `import 'package:newscalendar/config/camera_config.dart';`

#### State Variables Changed (Lines 13-20):
- **Removed**: `int _selectedCamera = 1;`
- **Removed**: `final int _cameraCount = 4;`
- **Added**: `final CameraConfigService _cameraService = CameraConfigService();`
- **Added**: `List<CameraConfig> _cameras = [];`
- **Added**: `bool _isLoading = true;`
- **Added**: `CameraConfig? _selectedCamera;`

#### initState Method (Lines 22-28):
- **Modified Line 26**: Changed from `_connectToCamera(_selectedCamera);` to `_loadCameras();`

#### New Method: _loadCameras (Lines 30-54):
- **Added**: Method to asynchronously load cameras from configuration
- Loads only enabled cameras
- Automatically selects first camera if available
- Includes error handling

#### Modified Method: _connectToCamera (Lines 81-88):
- **Changed Parameter**: From `int cameraNumber` to `CameraConfig camera`
- **Updated Line 82**: Uses `camera` object instead of integer
- **Updated Comment Line 86**: Notes that `camera.streamId` should be used for WebRTC connection

#### Modified Method: build (Lines 90-276):
- **Added Lines 98-103**: Loading indicator when cameras are being loaded
- **Added Lines 104-130**: Empty state message when no cameras are configured
- **Modified Lines 131-272**: Main camera display section (only shown if cameras exist)
- **Line 161**: Changed from `'Camera $_selectedCamera'` to `_selectedCamera?.name ?? 'No Camera Selected'`
- **Line 203**: Changed from `itemCount: _cameraCount` to `itemCount: _cameras.length`
- **Line 211**: Changed from `final camNum = index + 1;` to `final camera = _cameras[index];`
- **Line 212**: Changed from `final isSelected = camNum == _selectedCamera;` to `final isSelected = _selectedCamera?.id == camera.id;`
- **Line 214**: Changed from `onTap: () => _connectToCamera(camNum),` to `onTap: () => _connectToCamera(camera),`
- **Line 253**: Changed from `'Cam $camNum'` to `camera.name`

**Line Numbers Summary**:
- Line 4: Added import
- Lines 13-20: State variable changes
- Line 26: Modified initState
- Lines 30-54: New _loadCameras method
- Lines 81-88: Modified _connectToCamera method
- Lines 90-276: Modified build method (multiple changes within)

---

### 4. Modified File: `NewsCalendar/pubspec.yaml`
**Purpose**: Added cameras.json to assets list so it can be loaded by the app
**Status**: Modified

**Changes Made**:
- **Line 104**: Added `- assets/config/cameras.json` to the assets list

**Before**:
```yaml
  assets:
    - assets/bamboo-research-452705-u8-6ebb1bbd471a.json
    - .env
    - assets/images/
```

**After**:
```yaml
  assets:
    - assets/bamboo-research-452705-u8-6ebb1bbd471a.json
    - .env
    - assets/images/
    - assets/config/cameras.json
```

**Line Numbers**: Line 104

---

## New Directories Created

1. **NewsCalendar/lib/config/** - Created for configuration management classes
2. **NewsCalendar/assets/config/** - Created for configuration JSON files
3. **changes_documentation/camera_config_setup/** - Created for this documentation

---

## How to Use

### Adding Cameras to Configuration

Edit `NewsCalendar/assets/config/cameras.json` and add camera entries:

```json
{
  "cameras": [
    {
      "id": "camera-1",
      "name": "North Field Camera",
      "streamId": "your-webrtc-stream-id-here",
      "enabled": true,
      "description": "Camera monitoring the north field area"
    },
    {
      "id": "camera-2",
      "name": "South Field Camera",
      "streamId": "another-webrtc-stream-id",
      "enabled": true
    }
  ]
}
```

### Camera Configuration Fields

- **id** (required): Unique identifier for the camera
- **name** (required): Display name for the camera
- **streamId** (required): WebRTC stream ID to connect to the camera feed
- **enabled** (optional, default: true): Whether the camera should be displayed
- **description** (optional): Additional description of the camera location/purpose

### Notes

- Only cameras with `enabled: true` will be displayed in the FarmCCTV widget
- The widget automatically selects the first enabled camera on load
- If no cameras are configured, a helpful message is displayed
- The system is designed to work with USB cameras connected to a server that serves footage via WebRTC

---

## Testing Checklist

- [ ] Verify cameras.json file is loaded correctly
- [ ] Test with empty cameras array (should show "No cameras configured" message)
- [ ] Test with multiple enabled cameras
- [ ] Test with some cameras disabled (should not appear in grid)
- [ ] Verify camera selection works correctly
- [ ] Verify camera names are displayed correctly
- [ ] Test loading indicator appears during camera load

---

## Future Enhancements (Optional)

- Add ability to reload cameras without restarting app
- Add camera preview thumbnails in grid
- Add camera status indicators (online/offline)
- Add camera management UI to add/edit/delete cameras
- Support for camera groups/categories
- Camera recording/snapshot functionality

