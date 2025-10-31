/**
 * Chatbot Controller - Handles chatbot API requests
 */
const chatbotService = require('../services/chatbotService');
const ChatbotConversation = require('../models/chatbotConversation');

/**
 * Send a message and get AI response
 * POST /api/chatbot/message
 */
exports.sendMessage = async (req, res) => {
  try {
    const userId = req.user?.id || req.user?.userId || req.user?._id;
    
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'User authentication required'
      });
    }
    
    const { message, sessionId } = req.body;
    
    // Validate input
    if (!message || typeof message !== 'string' || message.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Message is required and must be a non-empty string'
      });
    }
    
    // Generate or use provided session ID
    const finalSessionId = chatbotService.generateSessionId(userId, sessionId);
    
    // Truncate message if too long (prevent abuse)
    const truncatedMessage = message.trim().substring(0, 2000);
    
    console.log(`[ChatbotController] Processing message from user ${userId}, session ${finalSessionId}`);
    
    // Step 1: Save user message to database
    await chatbotService.saveMessage(
      finalSessionId,
      userId,
      'user',
      truncatedMessage,
      null, // User messages don't have provider
      0
    );
    
    // Step 2: Get AI response
    const aiResponse = await chatbotService.getResponse(
      truncatedMessage,
      finalSessionId,
      userId
    );
    
    // Step 3: Save assistant response to database
    await chatbotService.saveMessage(
      finalSessionId,
      userId,
      'assistant',
      aiResponse.content,
      aiResponse.provider,
      aiResponse.tokensUsed || 0
    );
    
    // Step 4: Return response
    res.status(200).json({
      success: true,
      response: aiResponse.content,
      sessionId: finalSessionId,
      provider: aiResponse.provider,
      metadata: {
        tokensUsed: aiResponse.tokensUsed || 0
      }
    });
    
  } catch (error) {
    console.error('[ChatbotController] Error:', error);
    
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to process message',
      error: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
};

/**
 * Get conversation history
 * GET /api/chatbot/history?sessionId=xxx
 */
exports.getHistory = async (req, res) => {
  try {
    const userId = req.user?.id || req.user?.userId || req.user?._id;
    
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'User authentication required'
      });
    }
    
    const { sessionId } = req.query;
    
    if (!sessionId) {
      return res.status(400).json({
        success: false,
        message: 'sessionId query parameter is required'
      });
    }
    
    // Find conversation, ensuring it belongs to the user
    const conversation = await ChatbotConversation.findOne({
      sessionId: sessionId,
      userId: userId
    });
    
    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: 'Conversation not found'
      });
    }
    
    // Format messages for frontend
    const messages = conversation.messages.map(msg => ({
      role: msg.role,
      content: msg.content,
      timestamp: msg.timestamp,
      provider: msg.provider
    }));
    
    res.status(200).json({
      success: true,
      sessionId: conversation.sessionId,
      messages: messages,
      metadata: conversation.metadata,
      createdAt: conversation.createdAt,
      updatedAt: conversation.updatedAt
    });
    
  } catch (error) {
    console.error('[ChatbotController] Error fetching history:', error);
    
    res.status(500).json({
      success: false,
      message: 'Failed to fetch conversation history',
      error: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
};

/**
 * Delete conversation history
 * DELETE /api/chatbot/history/:sessionId
 */
exports.deleteHistory = async (req, res) => {
  try {
    const userId = req.user?.id || req.user?.userId || req.user?._id;
    
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'User authentication required'
      });
    }
    
    const { sessionId } = req.params;
    
    if (!sessionId) {
      return res.status(400).json({
        success: false,
        message: 'sessionId is required'
      });
    }
    
    // Delete conversation, ensuring it belongs to the user
    const result = await ChatbotConversation.deleteOne({
      sessionId: sessionId,
      userId: userId
    });
    
    if (result.deletedCount === 0) {
      return res.status(404).json({
        success: false,
        message: 'Conversation not found'
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'Conversation history deleted successfully'
    });
    
  } catch (error) {
    console.error('[ChatbotController] Error deleting history:', error);
    
    res.status(500).json({
      success: false,
      message: 'Failed to delete conversation history',
      error: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
};

/**
 * Get all user's conversations (list of sessions)
 * GET /api/chatbot/conversations
 */
exports.getConversations = async (req, res) => {
  try {
    const userId = req.user?.id || req.user?.userId || req.user?._id;
    
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'User authentication required'
      });
    }
    
    // Find all conversations for user
    const conversations = await ChatbotConversation.find({
      userId: userId
    }).sort({ updatedAt: -1 }).select('sessionId createdAt updatedAt metadata messages').limit(50);
    
    // Format response
    const sessions = conversations.map(conv => ({
      sessionId: conv.sessionId,
      messageCount: conv.messages.length,
      lastMessage: conv.messages.length > 0 ? conv.messages[conv.messages.length - 1].content.substring(0, 100) : '',
      createdAt: conv.createdAt,
      updatedAt: conv.updatedAt,
      metadata: conv.metadata
    }));
    
    res.status(200).json({
      success: true,
      conversations: sessions
    });
    
  } catch (error) {
    console.error('[ChatbotController] Error fetching conversations:', error);
    
    res.status(500).json({
      success: false,
      message: 'Failed to fetch conversations',
      error: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
};

