/**
 * Irrigation Routes
 * API endpoints for irrigation system management
 */
const express = require('express');
const router = express.Router();
const authMiddleware = require('../utils/auth');
const irrigationController = require('../controllers/irrigationController');

// All routes require authentication
router.use(authMiddleware);

// Device management
router.get('/device', irrigationController.getDevice);
router.post('/device/register', irrigationController.registerDevice);

// Pump control
router.post('/pump/toggle', irrigationController.togglePump);
router.get('/pump/timings', irrigationController.getPumpTimings);

// Sensor operations
router.get('/sensor/read', irrigationController.readSensor);
router.get('/sensor/history', irrigationController.getSensorHistory);

// System status
router.get('/status', irrigationController.getStatus);

// Schedule management
router.get('/schedule/next', irrigationController.getNextScheduled);
router.post('/schedule', irrigationController.createIrrigationSchedule);
router.get('/schedules', irrigationController.getIrrigationSchedules);
router.put('/schedule/:id', irrigationController.updateIrrigationSchedule);
router.delete('/schedule/:id', irrigationController.deleteIrrigationSchedule);
router.post('/schedule/:id/toggle', irrigationController.toggleSchedule);

module.exports = router;


