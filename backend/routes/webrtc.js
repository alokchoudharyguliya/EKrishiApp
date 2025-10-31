// routes/webrtc.js
const express = require('express');
const router = express.Router();
const webrtcController = require('../controllers/webrtcController');

// Generate a unique stream ID
router.get('/stream-id', webrtcController.generateStreamId);

// Get WebRTC configuration
router.get('/config', webrtcController.getConfig);

// Camera management endpoints
router.get('/cameras', webrtcController.listCameras.bind(webrtcController));
router.post('/cameras/start', webrtcController.startCameraStream.bind(webrtcController));
router.post('/cameras/stop', webrtcController.stopCameraStream.bind(webrtcController));
router.post('/cameras/start-all', webrtcController.startAllCameras.bind(webrtcController));
router.get('/cameras/streams', webrtcController.getActiveStreams.bind(webrtcController));

module.exports = router;