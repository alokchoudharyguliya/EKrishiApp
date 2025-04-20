
const express = require('express');
const router = express.Router();
const authMiddleware = require('../utils/auth');
const eventController=require('../controllers/eventController');
// const admin = require('firebase-admin');
// const { getAuth, createUserWithEmailAndPassword } = require('firebase/auth');
// const { initializeApp } = require('firebase/app');

router.use(authMiddleware);
router.delete('/delete-event',eventController.deleteEvent);
router.get('/get-event/:eventId',eventController.getEventByEventId);
router.get('/get-events',eventController.getEvents);
router.post('/add-events',eventController.addEvents);
router.post('/',eventController.addEvent);
router.put('/:id', eventController.updateEvent);
router.delete('/', eventController.deleteEvent);

module.exports = router;
module.exports = router;