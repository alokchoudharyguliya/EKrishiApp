/**
 * Chatbot Routes
 */
const express = require('express');
const router = express.Router();
const authMiddleware = require('../utils/auth');
const chatbotController = require('../controllers/chatbotController');

// All routes require authentication
router.post('/message',  chatbotController.sendMessage);
router.get('/history', authMiddleware, chatbotController.getHistory);
router.delete('/history/:sessionId', authMiddleware, chatbotController.deleteHistory);
router.get('/conversations', authMiddleware, chatbotController.getConversations);

module.exports = router;

