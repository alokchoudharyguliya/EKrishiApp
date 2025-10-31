// controllers/webrtcController.js
const { v4: uuidv4 } = require('uuid');
const cameraDetectionService = require('../services/cameraDetectionService');
const cameraCaptureService = require('../services/cameraCaptureService');

class WebRTCController {
  // Generate a unique stream ID
  generateStreamId(req, res) {
    try {
      const streamId = uuidv4();
      res.json({
        success: true,
        streamId: streamId
      });
    } catch (error) {
      console.error('Error generating stream ID:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to generate stream ID'
      });
    }
  }

  // Get WebRTC configuration
  getConfig(req, res) {
    try {
      const config = require('../config/webrtc');
      res.json({
        success: true,
        config: config
      });
    } catch (error) {
      console.error('Error getting WebRTC config:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get WebRTC configuration'
      });
    }
  }

  // Detect and list all available USB cameras
  async listCameras(req, res) {
    try {
      const cameras = await cameraDetectionService.detectCameras();
      res.json({
        success: true,
        cameras: cameras.map(cam => ({
          id: cam.id,
          name: cam.name,
          index: cam.index
        })),
        count: cameras.length
      });
    } catch (error) {
      console.error('Error listing cameras:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to detect cameras',
        hint: error.message.includes('FFmpeg') 
          ? 'Please install FFmpeg from https://ffmpeg.org/download.html'
          : null
      });
    }
  }

  // Start streaming from a specific camera
  async startCameraStream(req, res) {
    try {
      const { cameraId } = req.body;
      
      if (!cameraId) {
        return res.status(400).json({
          success: false,
          message: 'Camera ID is required'
        });
      }

      // Get camera from detection service
      const camera = cameraDetectionService.getCameraById(cameraId);
      if (!camera) {
        return res.status(404).json({
          success: false,
          message: `Camera with ID ${cameraId} not found`
        });
      }

      // Generate stream ID for this camera
      const streamId = uuidv4();

      // Start camera capture
      const streamInfo = await cameraCaptureService.startStream(streamId, camera);

      res.json({
        success: true,
        streamId: streamId,
        camera: {
          id: camera.id,
          name: camera.name
        },
        message: `Camera stream started successfully`
      });
    } catch (error) {
      console.error('Error starting camera stream:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to start camera stream'
      });
    }
  }

  // Stop a camera stream
  stopCameraStream(req, res) {
    try {
      const { streamId } = req.body;
      
      if (!streamId) {
        return res.status(400).json({
          success: false,
          message: 'Stream ID is required'
        });
      }

      cameraCaptureService.stopStream(streamId);

      res.json({
        success: true,
        message: `Camera stream ${streamId} stopped successfully`
      });
    } catch (error) {
      console.error('Error stopping camera stream:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to stop camera stream'
      });
    }
  }

  // Get active camera streams
  getActiveStreams(req, res) {
    try {
      const streams = cameraCaptureService.getActiveStreams();
      res.json({
        success: true,
        streams: streams,
        count: streams.length
      });
    } catch (error) {
      console.error('Error getting active streams:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get active streams'
      });
    }
  }

  // Auto-start streams for all detected cameras (for 4 cameras)
  async startAllCameras(req, res) {
    try {
      // Detect cameras first
      const cameras = await cameraDetectionService.detectCameras();
      
      if (cameras.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'No cameras detected'
        });
      }

      const startedStreams = [];

      // Start stream for each camera
      for (const camera of cameras) {
        try {
          const streamId = uuidv4();
          await cameraCaptureService.startStream(streamId, camera);
          startedStreams.push({
            streamId: streamId,
            cameraId: camera.id,
            cameraName: camera.name
          });
        } catch (error) {
          console.error(`Error starting stream for camera ${camera.name}:`, error);
          // Continue with other cameras even if one fails
        }
      }

      res.json({
        success: true,
        streams: startedStreams,
        count: startedStreams.length,
        message: `Started ${startedStreams.length} out of ${cameras.length} camera(s)`
      });
    } catch (error) {
      console.error('Error starting all cameras:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to start cameras'
      });
    }
  }
}

module.exports = new WebRTCController();