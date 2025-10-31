# Quick Start Guide - USB Camera Setup

## ⚠️ Important: Install FFmpeg First!

Before using camera features, you **must** install FFmpeg on Windows.

### Step 1: Install FFmpeg
1. Download from: https://www.gyan.dev/ffmpeg/builds/ (Windows builds)
2. Extract to `C:\ffmpeg\` (or any folder)
3. Add `C:\ffmpeg\bin` to Windows PATH:
   - Search "Environment Variables" in Windows
   - Edit "Path" variable
   - Add `C:\ffmpeg\bin`
   - Click OK

4. Verify installation:
   ```bash
   ffmpeg -version
   ```

### Step 2: Connect USB Cameras
Connect up to 4 USB cameras to your computer.

### Step 3: Start Your Server
```bash
cd backend
npm start
```

Check the console output - you should see:
```
📷 Camera Detection: Found 4 USB camera(s)
   1. USB Camera 1 (ID: camera-0)
   2. USB Camera 2 (ID: camera-1)
   3. USB Camera 3 (ID: camera-2)
   4. USB Camera 4 (ID: camera-3)
```

### Step 4: Start Camera Streams

#### Option A: Start All Cameras at Once
```bash
POST http://localhost:3000/api/webrtc/cameras/start-all
```

This will return stream IDs for all cameras.

#### Option B: Start Individual Cameras
1. List cameras:
   ```bash
   GET http://localhost:3000/api/webrtc/cameras
   ```

2. Start specific camera:
   ```bash
   POST http://localhost:3000/api/webrtc/cameras/start
   Body: { "cameraId": "camera-0" }
   ```

### Step 5: Update Flutter Config

Copy the `streamId` values from the API response and update `NewsCalendar/assets/config/cameras.json`:

```json
{
  "cameras": [
    {
      "id": "camera-0",
      "name": "USB Camera 1",
      "streamId": "paste-stream-id-here",
      "enabled": true
    },
    {
      "id": "camera-1",
      "name": "USB Camera 2",
      "streamId": "paste-stream-id-here",
      "enabled": true
    },
    {
      "id": "camera-2",
      "name": "USB Camera 3",
      "streamId": "paste-stream-id-here",
      "enabled": true
    },
    {
      "id": "camera-3",
      "name": "USB Camera 4",
      "streamId": "paste-stream-id-here",
      "enabled": true
    }
  ]
}
```

### Step 6: Restart Flutter App
Hot restart the Flutter app to load the new camera configurations.

---

## 📋 API Endpoints Quick Reference

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/webrtc/cameras` | GET | List all detected cameras |
| `/api/webrtc/cameras/start` | POST | Start streaming from a camera |
| `/api/webrtc/cameras/start-all` | POST | Start all cameras automatically |
| `/api/webrtc/cameras/stop` | POST | Stop a camera stream |
| `/api/webrtc/cameras/streams` | GET | Get active streams |

---

## 🔧 Troubleshooting

**Problem**: No cameras detected
- ✅ Check FFmpeg is installed: `ffmpeg -version`
- ✅ Check cameras are connected and Windows recognizes them
- ✅ Restart server after installing FFmpeg

**Problem**: Stream won't start
- ✅ Check camera isn't being used by another app (Teams, Zoom, etc.)
- ✅ Check Windows camera privacy settings allow camera access
- ✅ Try different camera resolution in `cameraCaptureService.js`

**Problem**: High CPU usage
- ✅ Reduce resolution or frame rate in capture settings
- ✅ Only start cameras you actually need

---

## 📝 Next Steps

**Current Status:**
- ✅ Camera detection working
- ✅ FFmpeg capture working (H264 stream)
- ⚠️ **WebRTC conversion needed** - Streams are captured but need WebRTC integration

**To Complete WebRTC Integration:**
The H264 streams from FFmpeg need to be converted to WebRTC MediaStreams. This requires additional implementation with `wrtc` or `mediasoup` package.

---

## 🎯 What's Working Now

1. ✅ Automatic USB camera detection on Windows
2. ✅ Camera listing via API
3. ✅ Starting/stopping camera streams
4. ✅ Multiple camera support (up to 4)
5. ✅ Stream ID generation for each camera
6. ✅ Camera configuration ready for Flutter app

---

## 📚 Full Documentation

See `backend_usb_camera_setup.md` for detailed documentation.

