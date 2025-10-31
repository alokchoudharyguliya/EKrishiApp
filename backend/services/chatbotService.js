/**
 * Chatbot Service - Handles AI chat interactions
 * Uses LangChain with Gemini (primary) and OpenAI (fallback)
 * Agriculture-specific bot with app knowledge and query filtering
 */
const { ChatGoogleGenerativeAI } = require("@langchain/google-genai");
const { ChatOpenAI } = require("@langchain/openai");
const ChatbotConversation = require("../models/chatbotConversation");

class ChatbotService {
  constructor() {
    // Initialize Gemini LLM (Primary)
    if (process.env.GOOGLE_API_KEY) {
      this.geminiLLM = new ChatGoogleGenerativeAI({
        modelName: process.env.GEMINI_MODEL || "gemini-2.5-flash",
        temperature: parseFloat(process.env.CHATBOT_TEMPERATURE || "0.7"),
        apiKey: process.env.GOOGLE_API_KEY,
      });
      console.log("[ChatbotService] Gemini initialized");
    } else {
      console.warn("[ChatbotService] GOOGLE_API_KEY not found, Gemini disabled");
      this.geminiLLM = null;
    }
    
    // Initialize OpenAI LLM (Fallback)
    if (process.env.OPENAI_API_KEY) {
      this.openaiLLM = new ChatOpenAI({
        modelName: process.env.OPENAI_MODEL || "gpt-3.5-turbo",
        temperature: parseFloat(process.env.CHATBOT_TEMPERATURE || "0.7"),
        openAIApiKey: process.env.OPENAI_API_KEY,
      });
      console.log("[ChatbotService] OpenAI initialized");
    } else {
      console.warn("[ChatbotService] OPENAI_API_KEY not found, OpenAI disabled");
      this.openaiLLM = null;
    }
    
    // System prompt for agriculture-specific bot
    this.systemPrompt = this.buildSystemPrompt();
    
    if (this.geminiLLM || this.openaiLLM) {
      console.log("[ChatbotService] Chatbot service ready");
    } else {
      console.error("[ChatbotService] No LLM providers configured! Please set GOOGLE_API_KEY or OPENAI_API_KEY");
    }
  }
  
  /**
   * Build the agriculture-specific system prompt
   */
  buildSystemPrompt() {
    return `You are an agriculture expert assistant for EKrishi, a comprehensive farming application.

Your role:
- Answer questions about farming, crops, irrigation, pests, diseases, soil management, and agricultural equipment
- Provide guidance on using EKrishi app features
- Reject non-agriculture related queries politely and redirect to agriculture topics

EKrishi App Features:
1. Crop Disease Detection - Upload crop images for AI-powered disease diagnosis
2. Irrigation Management - Monitor and control irrigation devices with sensor data
3. Equipment Marketplace - Buy/sell farming equipment
4. Event Calendar - Manage farming activities and schedules
5. AI Crop Assistance - Get crop analysis and recommendations

If a user asks about non-agriculture topics (general questions, unrelated subjects), politely decline and suggest how you can help with farming instead.

Always use agriculture terminology and provide practical, actionable advice.

Response Formatting:
- Use **bold** (double asterisks) for important terms, key points, or emphasis
- Use *italic* (single asterisk) for subtle emphasis or technical terms
- Use numbered lists (1., 2., 3.) or bullet points (-) for multiple items or steps
- Use line breaks for better readability in longer responses
- Structure your responses with clear sections when appropriate
- Use markdown formatting to make your responses more readable and professional`;
  }
  
  /**
   * Call Gemini API
   * @param {string} userMessage - User's message
   * @param {Array} conversationHistory - Previous messages for context
   * @returns {Promise<Object>} Response with content, provider, tokensUsed
   */
  async callGeminiAPI(userMessage, conversationHistory) {
    if (!this.geminiLLM) {
      throw new Error("Gemini API not configured. Please set GOOGLE_API_KEY environment variable.");
    }
    
    try {
      // Build message array for LangChain
      const messages = [
        { role: "system", content: this.systemPrompt },
        ...conversationHistory, // Previous messages for context
        { role: "user", content: userMessage } // New user message
      ];
      
      console.log(`[ChatbotService] Calling Gemini API...`);
      
      // Call Gemini via LangChain
      const response = await this.geminiLLM.invoke(messages);
      
      // Extract response text
      const responseText = response.content;
      
      // Estimate tokens (approximate: 1 token ≈ 4 characters)
      const tokensUsed = Math.ceil((responseText.length + userMessage.length + this.systemPrompt.length) / 4);
      
      console.log(`[ChatbotService] Gemini response received (${tokensUsed} tokens)`);
      
      return {
        content: responseText,
        provider: "gemini",
        tokensUsed: tokensUsed,
        success: true
      };
    } catch (error) {
      console.error("[ChatbotService] Gemini API error:", error.message);
      
      // Check if it's a rate limit error
      if (error.message?.includes("429") || 
          error.message?.includes("rate limit") || 
          error.message?.includes("RESOURCE_EXHAUSTED") ||
          error.status === 429) {
        error.isRateLimit = true;
      }
      
      throw error;
    }
  }
  
  /**
   * Call OpenAI API (Fallback)
   * @param {string} userMessage - User's message
   * @param {Array} conversationHistory - Previous messages for context
   * @returns {Promise<Object>} Response with content, provider, tokensUsed
   */
  async callOpenAITAPI(userMessage, conversationHistory) {
    if (!this.openaiLLM) {
      throw new Error("OpenAI API not configured. Please set OPENAI_API_KEY environment variable.");
    }
    
    try {
      // Build message array for LangChain (same format!)
      const messages = [
        { role: "system", content: this.systemPrompt },
        ...conversationHistory,
        { role: "user", content: userMessage }
      ];
      
      console.log(`[ChatbotService] Calling OpenAI API...`);
      
      // Call OpenAI via LangChain
      const response = await this.openaiLLM.invoke(messages);
      
      const responseText = response.content;
      
      // Estimate tokens
      const tokensUsed = Math.ceil((responseText.length + userMessage.length + this.systemPrompt.length) / 4);
      
      console.log(`[ChatbotService] OpenAI response received (${tokensUsed} tokens)`);
      
      return {
        content: responseText,
        provider: "openai",
        tokensUsed: tokensUsed,
        success: true
      };
    } catch (error) {
      console.error("[ChatbotService] OpenAI API error:", error.message);
      throw error;
    }
  }
  
  /**
   * Get conversation history from database
   * @param {string} sessionId - Session ID
   * @returns {Promise<Array>} Conversation history in LangChain format
   */
  async getConversationHistory(sessionId) {
    try {
      const conversation = await ChatbotConversation.findOne({ sessionId });
      
      if (!conversation || !conversation.messages || conversation.messages.length === 0) {
        return [];
      }
      
      // Convert DB messages to LangChain format
      // Filter out system messages and errors, keep user and assistant
      return conversation.messages
        .filter(msg => msg.role !== "system" && !msg.isError)
        .map(msg => ({
          role: msg.role,
          content: msg.content
        }));
    } catch (error) {
      console.error("[ChatbotService] Error loading conversation history:", error);
      return [];
    }
  }
  
  /**
   * Main method: Get response with fallback logic
   * @param {string} userMessage - User's message
   * @param {string} sessionId - Session ID for conversation continuity
   * @param {string} userId - User ID
   * @returns {Promise<Object>} Response object
   */
  async getResponse(userMessage, sessionId, userId) {
    // Step 1: Load conversation history
    const conversationHistory = await this.getConversationHistory(sessionId);
    
    let response;
    let providerUsed;
    
    // Step 2: Try Gemini first (if available)
    if (this.geminiLLM) {
      try {
        console.log(`[ChatbotService] Attempting Gemini for session ${sessionId}`);
        response = await this.callGeminiAPI(userMessage, conversationHistory);
        providerUsed = "gemini";
      } catch (error) {
        // Step 3: Check if rate limited, then fallback to OpenAI
        if (error.isRateLimit && this.openaiLLM) {
          console.log(`[ChatbotService] Gemini rate limited, falling back to OpenAI`);
          try {
            response = await this.callOpenAITAPI(userMessage, conversationHistory);
            providerUsed = "openai";
          } catch (openaiError) {
            console.error("[ChatbotService] Both APIs failed:", openaiError);
            throw new Error("AI service temporarily unavailable. Please try again later.");
          }
        } else if (this.openaiLLM) {
          // Non-rate-limit error, try OpenAI as fallback
          console.log(`[ChatbotService] Gemini error, trying OpenAI fallback`);
          try {
            response = await this.callOpenAITAPI(userMessage, conversationHistory);
            providerUsed = "openai";
          } catch (openaiError) {
            console.error("[ChatbotService] Both APIs failed:", openaiError);
            throw new Error("AI service temporarily unavailable. Please try again later.");
          }
        } else {
          // No fallback available, throw error
          throw error;
        }
      }
    } else if (this.openaiLLM) {
      // Only OpenAI available, use it directly
      console.log(`[ChatbotService] Using OpenAI (Gemini not available)`);
      try {
        response = await this.callOpenAITAPI(userMessage, conversationHistory);
        providerUsed = "openai";
      } catch (error) {
        console.error("[ChatbotService] OpenAI API failed:", error);
        throw new Error("AI service temporarily unavailable. Please try again later.");
      }
    } else {
      throw new Error("No AI service configured. Please set GOOGLE_API_KEY or OPENAI_API_KEY.");
    }
    
    return {
      ...response,
      sessionId: sessionId,
      provider: providerUsed
    };
  }
  
  /**
   * Save message to database
   * @param {string} sessionId - Session ID
   * @param {string} userId - User ID
   * @param {string} role - Message role (user/assistant)
   * @param {string} content - Message content
   * @param {string|null} provider - Provider used (gemini/openai/null)
   * @param {number} tokensUsed - Tokens used
   */
  async saveMessage(sessionId, userId, role, content, provider = null, tokensUsed = 0) {
    try {
      let conversation = await ChatbotConversation.findOne({ sessionId });
      
      if (!conversation) {
        // Create new conversation
        conversation = new ChatbotConversation({
          userId: userId,
          sessionId: sessionId,
          messages: [],
          metadata: {
            totalTokensGemini: 0,
            totalTokensOpenAI: 0,
            fallbackCount: 0
          }
        });
      }
      
      // Add message
      conversation.messages.push({
        role: role,
        content: content,
        provider: provider,
        tokensUsed: tokensUsed,
        timestamp: new Date()
      });
      
      // Update metadata
      if (provider === "gemini") {
        conversation.metadata.totalTokensGemini += tokensUsed;
      } else if (provider === "openai") {
        conversation.metadata.totalTokensOpenAI += tokensUsed;
        if (conversation.metadata.lastProvider === "gemini") {
          conversation.metadata.fallbackCount += 1;
        }
      }
      
      conversation.metadata.lastProvider = provider || conversation.metadata.lastProvider;
      conversation.updatedAt = new Date();
      
      await conversation.save();
      console.log(`[ChatbotService] Message saved to database (role: ${role}, provider: ${provider})`);
    } catch (error) {
      console.error("[ChatbotService] Error saving message:", error);
      // Don't throw - saving is non-critical, conversation can continue
    }
  }
  
  /**
   * Generate or get session ID
   * @param {string} userId - User ID
   * @param {string} sessionId - Optional existing session ID
   * @returns {string} Session ID
   */
  generateSessionId(userId, sessionId = null) {
    if (sessionId) {
      return sessionId;
    }
    // Generate new session ID: userId_timestamp
    return `${userId}_${Date.now()}`;
  }
}

// Export singleton instance
module.exports = new ChatbotService();

