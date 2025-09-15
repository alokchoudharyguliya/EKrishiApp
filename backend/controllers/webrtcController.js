// controllers/webrtcController.js
const { v4: uuidv4 } = require('uuid');

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
}

module.exports = new WebRTCController();