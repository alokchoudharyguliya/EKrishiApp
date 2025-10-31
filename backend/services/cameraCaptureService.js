// services/cameraCaptureService.js
const { spawn } = require('child_process');
const { EventEmitter } = require('events');
const cameraDetectionService = require('./cameraDetectionService');

/**
 * Service to capture video from USB cameras using FFmpeg
 * Converts camera feed to RTSP stream or WebRTC-compatible format
 */
class CameraCaptureService extends EventEmitter {
  constructor() {
    super();
    this.activeStreams = new Map(); // Map<streamId, {process, camera, output}>
    this.ffmpegPath = null;
  }

  /**
   * Initialize FFmpeg path
   */
  async initialize() {
    if (this.ffmpegPath) return;

    try {
      // Try to find ffmpeg
      const { exec } = require('child_process');
      const { promisify } = require('util');
      const execAsync = promisify(exec);
      const path = require('path');

      const possiblePaths = [
        'ffmpeg',
        path.join(__dirname, '../bin/ffmpeg.exe'),
        'C:\\ffmpeg\\bin\\ffmpeg.exe',
      ];

      for (const ffmpegPath of possiblePaths) {
        try {
          await execAsync(`"${ffmpegPath}" -version`);
          this.ffmpegPath = ffmpegPath;
          console.log(`FFmpeg found at: ${ffmpegPath}`);
          return;
        } catch (e) {
          continue;
        }
      }

      throw new Error('FFmpeg not found');
    } catch (error) {
      console.error('FFmpeg initialization error:', error);
      throw error;
    }
  }

  /**
   * Start capturing from a camera and create a stream
   * @param {string} streamId - Unique stream ID for this camera feed
   * @param {Object} camera - Camera object from detection service
   * @returns {Promise<string>} Stream URL or connection info
   */
  async startStream(streamId, camera) {
    await this.initialize();

    if (this.activeStreams.has(streamId)) {
      console.log(`Stream ${streamId} already active`);
      return this.activeStreams.get(streamId).output;
    }

    try {
      // FFmpeg command to capture from DirectShow camera on Windows
      // Output to stdout as raw video stream (H264)
      const args = [
        '-f', 'dshow',                          // Input format: DirectShow
        '-i', `video="${camera.deviceName}"`,   // Camera device
        '-video_size', '1280x720',              // Resolution
        '-framerate', '30',                     // Frame rate
        '-vcodec', 'libx264',                   // Video codec
        '-preset', 'ultrafast',                 // Encoding preset
        '-tune', 'zerolatency',                 // Low latency
        '-pix_fmt', 'yuv420p',                  // Pixel format
        '-f', 'h264',                           // Output format
        'pipe:1'                                // Output to stdout
      ];

      console.log(`Starting camera stream: ${camera.name} (${streamId})`);
      console.log(`FFmpeg command: ${this.ffmpegPath} ${args.join(' ')}`);

      const ffmpegProcess = spawn(this.ffmpegPath, args, {
        stdio: ['ignore', 'pipe', 'pipe']
      });

      // Handle FFmpeg output
      let errorBuffer = '';
      ffmpegProcess.stderr.on('data', (data) => {
        errorBuffer += data.toString();
        
        // Check for errors
        if (data.toString().includes('error') || data.toString().includes('Error')) {
          console.error(`FFmpeg error for ${streamId}:`, data.toString());
        }
      });

      ffmpegProcess.stdout.on('data', (data) => {
        // Emit video data for WebRTC processing
        this.emit('video-data', { streamId, data });
      });

      ffmpegProcess.on('close', (code) => {
        console.log(`FFmpeg process closed for ${streamId} with code ${code}`);
        this.activeStreams.delete(streamId);
        this.emit('stream-ended', streamId);
        
        if (code !== 0 && code !== null) {
          console.error(`FFmpeg process error for ${streamId}:`, errorBuffer);
        }
      });

      ffmpegProcess.on('error', (error) => {
        console.error(`FFmpeg spawn error for ${streamId}:`, error);
        this.activeStreams.delete(streamId);
        this.emit('stream-error', { streamId, error });
      });

      // Store stream info
      const streamInfo = {
        process: ffmpegProcess,
        camera: camera,
        output: {
          streamId: streamId,
          cameraId: camera.id,
          cameraName: camera.name,
          format: 'h264',
          status: 'active'
        }
      };

      this.activeStreams.set(streamId, streamInfo);
      this.emit('stream-started', streamInfo);

      return streamInfo.output;
    } catch (error) {
      console.error(`Error starting stream ${streamId}:`, error);
      throw error;
    }
  }

  /**
   * Stop a camera stream
   */
  stopStream(streamId) {
    const streamInfo = this.activeStreams.get(streamId);
    if (!streamInfo) {
      console.log(`Stream ${streamId} not found`);
      return;
    }

    console.log(`Stopping stream ${streamId}`);
    streamInfo.process.kill('SIGTERM');
    this.activeStreams.delete(streamId);
    this.emit('stream-stopped', streamId);
  }

  /**
   * Stop all streams
   */
  stopAllStreams() {
    console.log(`Stopping all ${this.activeStreams.size} streams`);
    for (const [streamId] of this.activeStreams) {
      this.stopStream(streamId);
    }
  }

  /**
   * Get active streams
   */
  getActiveStreams() {
    return Array.from(this.activeStreams.values()).map(s => s.output);
  }

  /**
   * Check if stream is active
   */
  isStreamActive(streamId) {
    return this.activeStreams.has(streamId);
  }

  /**
   * Get stream info
   */
  getStreamInfo(streamId) {
    return this.activeStreams.get(streamId)?.output;
  }
}

module.exports = new CameraCaptureService();

