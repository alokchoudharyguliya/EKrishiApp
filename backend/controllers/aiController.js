/**
 * AI Controller - Handles AI crop analysis requests
 */
const aiService = require('../services/aiService');
const CropAnalysis = require('../models/cropAnalysis');

/**
 * Analyze crop image with context
 * POST /api/ai/crop-analysis
 */
exports.analyzeCrop = async (req, res) => {
  try {
    // Extract user ID (from auth middleware)
    const userId = req.user?.id || req.user?.userId || null;
    
    // Validate image file
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Image file is required'
      });
    }
    
    // Extract context from request body
    const {
      imageType,
      cropType,
      problem,
      plantAge,
      recentWeather
    } = req.body;
    
    // Prepare context for AI service
    const context = {
      userId: userId || '',
      imageName: req.file.originalname,
      imageType: imageType || 'Whole Plant',
      cropType: cropType || '',
      observedProblem: problem || '',
      plantAge: plantAge || null,
      recentWeatherEvent: recentWeather === 'true' || recentWeather === true || false
    };
    
    console.log(`[AIController] Processing crop analysis for user: ${userId}`);
    console.log(`[AIController] Context:`, context);
    
    // Call Python AI service via gRPC
    const aiResult = await aiService.analyzeCrop(req.file.buffer, context);
    
    // Save analysis to database
    const analysisRecord = new CropAnalysis({
      userId: userId,
      imageName: req.file.originalname,
      imageSize: req.file.size,
      context: {
        imageType: context.imageType,
        cropType: context.cropType,
        observedProblem: context.observedProblem,
        plantAge: context.plantAge,
        recentWeatherEvent: context.recentWeatherEvent
      },
      result: aiResult,
      status: aiResult.success ? 'completed' : 'failed',
      createdAt: new Date()
    });
    
    await analysisRecord.save();
    
    // Return response
    if (aiResult.success) {
      res.status(200).json({
        success: true,
        requestId: analysisRecord._id,
        analysis: {
          diagnosis: aiResult.diagnosis,
          confidence: aiResult.confidence,
          disease: aiResult.disease,
          severity: aiResult.severity,
          suggestions: aiResult.suggestions,
          treatment: aiResult.treatment,
          prevention: aiResult.prevention,
          references: aiResult.references
        },
        metadata: {
          modelUsed: aiResult.modelUsed,
          processingTime: aiResult.processingTime,
          timestamp: new Date().toISOString()
        }
      });
    } else {
      res.status(500).json({
        success: false,
        message: aiResult.errorMessage || 'Analysis failed',
        error: aiResult.errorMessage
      });
    }
    
  } catch (error) {
    console.error('[AIController] Error:', error);
    
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to analyze crop',
      error: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
};

/**
 * Get analysis result by ID
 * GET /api/ai/suggestions/:requestId
 */
exports.getSuggestion = async (req, res) => {
  try {
    const { requestId } = req.params;
    const userId = req.user?.id || req.user?.userId || null;
    
    const analysis = await CropAnalysis.findOne({
      _id: requestId,
      ...(userId && { userId: userId }) // Only filter by userId if authenticated
    });
    
    if (!analysis) {
      return res.status(404).json({
        success: false,
        message: 'Analysis not found'
      });
    }
    
    res.status(200).json({
      success: true,
      requestId: analysis._id,
      analysis: analysis.result,
      context: analysis.context,
      status: analysis.status,
      createdAt: analysis.createdAt
    });
    
  } catch (error) {
    console.error('[AIController] Error fetching suggestion:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch analysis'
    });
  }
};

/**
 * Health check for AI service
 * GET /api/ai/health
 */
exports.healthCheck = async (req, res) => {
  try {
    const health = await aiService.healthCheck();
    
    res.status(health.healthy ? 200 : 503).json({
      success: health.healthy,
      service: 'ai-crop-analysis',
      ...health
    });
  } catch (error) {
    res.status(503).json({
      success: false,
      service: 'ai-crop-analysis',
      error: error.message
    });
  }
};

