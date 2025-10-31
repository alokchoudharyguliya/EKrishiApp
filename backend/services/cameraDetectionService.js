// services/cameraDetectionService.js
const { exec } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(exec);
const path = require('path');

/**
 * Service to detect USB cameras on Windows using FFmpeg
 * Uses DirectShow on Windows to enumerate video capture devices
 */
class CameraDetectionService {
  constructor() {
    this.detectedCameras = [];
    this.isDetecting = false;
  }

  /**
   * Get FFmpeg path - tries multiple locations
   */
  async getFFmpegPath() {
    // Try to find ffmpeg in common locations
    const possiblePaths = [
      'ffmpeg', // System PATH
      path.join(__dirname, '../bin/ffmpeg.exe'),
      'C:\\ffmpeg\\bin\\ffmpeg.exe',
      'C:\\Program Files\\ffmpeg\\bin\\ffmpeg.exe',
    ];

    for (const ffmpegPath of possiblePaths) {
      try {
        await execAsync(`"${ffmpegPath}" -version`);
        return ffmpegPath;
      } catch (e) {
        continue;
      }
    }

    throw new Error(
      'FFmpeg not found. Please install FFmpeg and add it to PATH, ' +
      'or place ffmpeg.exe in backend/bin/ directory. ' +
      'Download from: https://ffmpeg.org/download.html'
    );
  }

  /**
   * List all DirectShow video devices on Windows
   * Returns array of camera objects with name and device index
   */
  async detectCameras() {
    if (this.isDetecting) {
      console.log('Camera detection already in progress...');
      return this.detectedCameras;
    }

    this.isDetecting = true;
    try {
      const ffmpegPath = await this.getFFmpegPath();
      
      // Use ffmpeg to list DirectShow devices on Windows
      // Command: ffmpeg -list_devices true -f dshow -i dummy
      const command = `"${ffmpegPath}" -list_devices true -f dshow -i dummy 2>&1`;
      
      console.log('Detecting USB cameras...');
      const { stdout, stderr } = await execAsync(command, {
        maxBuffer: 10 * 1024 * 1024, // 10MB buffer
        timeout: 10000
      });

      // FFmpeg outputs device list to stderr on Windows
      const output = stderr || stdout;
      const cameras = this.parseDirectShowDevices(output);

      this.detectedCameras = cameras;
      console.log(`Detected ${cameras.length} camera(s):`, cameras.map(c => c.name));
      
      return cameras;
    } catch (error) {
      console.error('Error detecting cameras:', error.message);
      
      // If FFmpeg not found, return empty array with helpful error
      if (error.message.includes('not found') || error.code === 'ENOENT') {
        throw new Error(
          'FFmpeg is required for camera detection. ' +
          'Please install FFmpeg from https://ffmpeg.org/download.html ' +
          'or use npm install @ffmpeg-installer/ffmpeg'
        );
      }
      
      // Return empty array on other errors (cameras might not be accessible)
      return [];
    } finally {
      this.isDetecting = false;
    }
  }

  /**
   * Parse DirectShow device list from FFmpeg output
   */
  parseDirectShowDevices(output) {
    const cameras = [];
    const lines = output.split('\n');
    
    let inVideoDevices = false;
    let deviceIndex = 0;

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim();

      // Check if we're in the video devices section
      if (line.includes('DirectShow video devices')) {
        inVideoDevices = true;
        continue;
      }

      // Stop if we hit audio devices section
      if (line.includes('DirectShow audio devices')) {
        break;
      }

      // Parse device entries (format: "  \"Device Name\"")
      if (inVideoDevices && line.startsWith('"') && line.endsWith('"')) {
        const deviceName = line.slice(1, -1); // Remove quotes
        
        // Skip "dummy" device
        if (deviceName.toLowerCase() === 'dummy') {
          continue;
        }

        cameras.push({
          id: `camera-${deviceIndex}`,
          index: deviceIndex,
          name: deviceName,
          deviceName: deviceName, // For DirectShow device selection
          platform: 'windows-dshow'
        });

        deviceIndex++;
      }
    }

    return cameras;
  }

  /**
   * Get list of detected cameras
   */
  getDetectedCameras() {
    return this.detectedCameras;
  }

  /**
   * Get camera by ID
   */
  getCameraById(id) {
    return this.detectedCameras.find(cam => cam.id === id);
  }

  /**
   * Get camera by index
   */
  getCameraByIndex(index) {
    return this.detectedCameras.find(cam => cam.index === index);
  }

  /**
   * Refresh camera list
   */
  async refresh() {
    return await this.detectCameras();
  }
}

module.exports = new CameraDetectionService();

