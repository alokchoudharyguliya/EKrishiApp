
const express = require('express');
const router = express.Router();
// const admin = require('firebase-admin');
// const { getAuth, createUserWithEmailAndPassword } = require('firebase/auth');
// const { initializeApp } = require('firebase/app');
const eventController=require('../controllers/eventController');
router.post('/add-event',eventController.addEvent);
router.delete('/delete-event',eventController.deleteEvent);
router.get('/get-event/:eventId',eventController.getEventByEventId);
router.get('/get-events',eventController.getEvents);
module.exports = router;