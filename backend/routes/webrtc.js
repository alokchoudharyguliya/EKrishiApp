// routes/webrtc.js
const express = require('express');
const router = express.Router();
const webrtcController = require('../controllers/webrtcController');

// Generate a unique stream ID
router.get('/stream-id', webrtcController.generateStreamId);

// Get WebRTC configuration
router.get('/config', webrtcController.getConfig);

module.exports = router;