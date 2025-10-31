const express = require('express');
const router = express.Router();
const multer = require('multer');
const authMiddleware = require('../utils/auth');
const aiController = require('../controllers/aiController');

// Configure multer for AI image uploads (store in memory for gRPC)
const aiUpload = multer({
  storage: multer.memoryStorage(), // Store in memory for gRPC transmission
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  }
});

// POST /api/ai/crop-analysis - Main endpoint for crop analysis
router.post('/crop-analysis', authMiddleware, aiUpload.single('image'), aiController.analyzeCrop);

// GET /api/ai/suggestions/:requestId - Get cached analysis result
router.get('/suggestions/:requestId', authMiddleware, aiController.getSuggestion);

// GET /api/ai/health - Health check for AI service
router.get('/health', aiController.healthCheck);

module.exports = router;

