const express = require('express');
const router = express.Router();
const authMiddleware = require('../utils/auth');
const notificationController = require('../controllers/notificationController');

router.use(authMiddleware);

router.get('/pending', notificationController.getPendingNotifications);
router.post('/mark-notified', notificationController.markAsNotified);
router.get('/check', notificationController.checkNotifications);

module.exports = router;

