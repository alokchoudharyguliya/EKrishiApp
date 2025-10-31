# Camera Configuration Usage Guide

## Quick Start

### 1. Adding Cameras to Configuration

Edit the file: `NewsCalendar/assets/config/cameras.json`

Example configuration:
```json
{
  "cameras": [
    {
      "id": "camera-1",
      "name": "North Field",
      "streamId": "0b28d19f-e82f-4a46-af52-655deecaa5b8",
      "enabled": true,
      "description": "Main camera for north field monitoring"
    },
    {
      "id": "camera-2",
      "name": "South Field",
      "streamId": "7a874af7-20ed-440b-9ab4-e9abedf9d5ea",
      "enabled": true
    },
    {
      "id": "camera-3",
      "name": "East Gate",
      "streamId": "another-stream-id-here",
      "enabled": false,
      "description": "Temporarily disabled"
    }
  ]
}
```

### 2. Configuration Fields Explained

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Unique identifier for the camera |
| `name` | string | Yes | Display name shown in the UI |
| `streamId` | string | Yes | WebRTC stream ID from your server |
| `enabled` | boolean | No (default: true) | Whether camera appears in the list |
| `description` | string | No | Optional description/location info |

### 3. After Adding Cameras

1. Save the `cameras.json` file
2. Hot restart your Flutter app (not just hot reload)
3. Navigate to the FarmCCTV section
4. Your cameras should now appear in the grid

### 4. USB Camera Setup on Server

For each USB camera connected to your server:

1. **Assign a WebRTC Stream ID**: Your server should assign a unique stream ID for each camera
2. **Add to Config**: Add an entry in `cameras.json` with that stream ID
3. **Test Connection**: Verify the stream ID works by checking the camera feed

### 5. Common Scenarios

#### Temporarily Disable a Camera
Set `"enabled": false` in the camera's configuration. It won't appear in the UI but will remain in the config file.

#### Add a New Camera
1. Connect the USB camera to your server
2. Get the WebRTC stream ID from your server
3. Add a new entry to `cameras.json`
4. Restart the app

#### Remove a Camera
1. Delete the camera entry from `cameras.json`
2. Restart the app

#### Rename a Camera
1. Update the `"name"` field in `cameras.json`
2. Hot restart the app

### 6. Troubleshooting

**Problem**: No cameras showing up
- Check that `cameras.json` has valid JSON syntax
- Verify all cameras have `"enabled": true` if you want them visible
- Make sure the file path is correct: `assets/config/cameras.json`

**Problem**: Camera not connecting
- Verify the `streamId` matches what your server provides
- Check your WebRTC server is running
- Ensure network connectivity

**Problem**: Changes not appearing
- You must **hot restart** (not hot reload) after changing the JSON file
- Verify the file was saved
- Check for JSON syntax errors

### 7. Example: Multiple USB Cameras

If you have 4 USB cameras connected to your server:

```json
{
  "cameras": [
    {
      "id": "usb-cam-1",
      "name": "USB Camera 1 - Entrance",
      "streamId": "stream-id-from-server-for-camera-1",
      "enabled": true
    },
    {
      "id": "usb-cam-2",
      "name": "USB Camera 2 - Field View",
      "streamId": "stream-id-from-server-for-camera-2",
      "enabled": true
    },
    {
      "id": "usb-cam-3",
      "name": "USB Camera 3 - Storage Area",
      "streamId": "stream-id-from-server-for-camera-3",
      "enabled": true
    },
    {
      "id": "usb-cam-4",
      "name": "USB Camera 4 - Back Gate",
      "streamId": "stream-id-from-server-for-camera-4",
      "enabled": true
    }
  ]
}
```

### 8. Best Practices

1. **Use Descriptive Names**: Camera names should clearly indicate location/purpose
2. **Unique IDs**: Each camera ID should be unique and meaningful
3. **Keep Config Valid**: Always validate JSON syntax before saving
4. **Backup Config**: Keep a backup of your working configuration
5. **Document Stream IDs**: Keep track of which stream ID corresponds to which physical camera

### 9. Future Integration Points

When implementing WebRTC connection in `_connectToCamera()` method, you'll use:
```dart
camera.streamId  // This is the WebRTC stream ID from your config
```

The `streamId` field is what connects your Flutter app to the camera feed served by your backend server.

