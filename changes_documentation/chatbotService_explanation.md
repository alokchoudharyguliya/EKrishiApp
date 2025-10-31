# ChatbotService.js - Detailed Explanation

## Date
2025-01-XX

---

## Overview

The `chatbotService.js` file is a service layer that handles communication with AI language models (Gemini and OpenAI). The `callGeminiAPI` function is **a method we create ourselves** that uses LangChain's Google Gemini package.

---

## Where Does `callGeminiAPI` Come From?

### **Answer: We Create It!**

`callGeminiAPI` is **NOT a built-in function**. It's a **custom method we write** in the `chatbotService.js` class that:
1. Uses LangChain's `@langchain/google-genai` package
2. Wraps the Gemini API call with error handling
3. Formats the response consistently

---

## Complete File Structure

Here's how `chatbotService.js` will look:

```javascript
/**
 * Chatbot Service - Handles AI chat interactions
 * Uses LangChain with Gemini (primary) and OpenAI (fallback)
 */
const { ChatGoogleGenerativeAI } = require("@langchain/google-genai");
const { ChatOpenAI } = require("@langchain/openai");
const ChatbotConversation = require("../models/chatbotConversation");

class ChatbotService {
  constructor() {
    // Initialize Gemini LLM (Primary)
    this.geminiLLM = new ChatGoogleGenerativeAI({
      modelName: process.env.GEMINI_MODEL || "gemini-pro",
      temperature: parseFloat(process.env.CHATBOT_TEMPERATURE || "0.7"),
      apiKey: process.env.GOOGLE_API_KEY, // ← This is where Gemini API key goes
    });
    
    // Initialize OpenAI LLM (Fallback)
    this.openaiLLM = new ChatOpenAI({
      modelName: process.env.OPENAI_MODEL || "gpt-3.5-turbo",
      temperature: parseFloat(process.env.CHATBOT_TEMPERATURE || "0.7"),
      openAIApiKey: process.env.OPENAI_API_KEY, // ← OpenAI API key
    });
    
    // System prompt for agriculture-specific bot
    this.systemPrompt = this.buildSystemPrompt();
    
    console.log("[ChatbotService] Initialized with Gemini and OpenAI");
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

Always use agriculture terminology and provide practical, actionable advice.`;
  }
  
  /**
   * CALL GEMINI API - This is where callGeminiAPI comes from!
   * It's a method we create in this class
   */
  async callGeminiAPI(userMessage, conversationHistory) {
    try {
      // Build message array for LangChain
      const messages = [
        { role: "system", content: this.systemPrompt },
        ...conversationHistory, // Previous messages for context
        { role: "user", content: userMessage } // New user message
      ];
      
      // Call Gemini via LangChain
      const response = await this.geminiLLM.invoke(messages);
      
      // Extract response text
      const responseText = response.content;
      
      // Estimate tokens (approximate)
      const tokensUsed = Math.ceil((responseText.length + userMessage.length) / 4);
      
      return {
        content: responseText,
        provider: "gemini",
        tokensUsed: tokensUsed,
        success: true
      };
    } catch (error) {
      // Check if it's a rate limit error
      if (error.message?.includes("429") || error.message?.includes("rate limit")) {
        error.isRateLimit = true;
      }
      
      throw error;
    }
  }
  
  /**
   * CALL OPENAI API - Fallback method
   */
  async callOpenAITAPI(userMessage, conversationHistory) {
    try {
      // Build message array for LangChain (same format!)
      const messages = [
        { role: "system", content: this.systemPrompt },
        ...conversationHistory,
        { role: "user", content: userMessage }
      ];
      
      // Call OpenAI via LangChain
      const response = await this.openaiLLM.invoke(messages);
      
      const responseText = response.content;
      const tokensUsed = Math.ceil((responseText.length + userMessage.length) / 4);
      
      return {
        content: responseText,
        provider: "openai",
        tokensUsed: tokensUsed,
        success: true
      };
    } catch (error) {
      throw error;
    }
  }
  
  /**
   * Get conversation history from database
   */
  async getConversationHistory(sessionId) {
    const conversation = await ChatbotConversation.findOne({ sessionId });
    
    if (!conversation || !conversation.messages) {
      return [];
    }
    
    // Convert DB messages to LangChain format
    return conversation.messages
      .filter(msg => msg.role !== "system") // Remove system messages
      .map(msg => ({
        role: msg.role,
        content: msg.content
      }));
  }
  
  /**
   * Main method: Get response with fallback logic
   */
  async getResponse(userMessage, sessionId, userId) {
    // Step 1: Load conversation history
    const conversationHistory = await this.getConversationHistory(sessionId);
    
    let response;
    let providerUsed;
    
    // Step 2: Try Gemini first
    try {
      console.log(`[ChatbotService] Attempting Gemini for session ${sessionId}`);
      response = await this.callGeminiAPI(userMessage, conversationHistory);
      providerUsed = "gemini";
    } catch (error) {
      // Step 3: Check if rate limited, then fallback to OpenAI
      if (error.isRateLimit || error.message?.includes("429")) {
        console.log(`[ChatbotService] Gemini rate limited, falling back to OpenAI`);
        try {
          response = await this.callOpenAITAPI(userMessage, conversationHistory);
          providerUsed = "openai";
        } catch (openaiError) {
          console.error("[ChatbotService] Both APIs failed:", openaiError);
          throw new Error("AI service temporarily unavailable. Please try again later.");
        }
      } else {
        // Non-rate-limit error, re-throw
        throw error;
      }
    }
    
    return {
      ...response,
      sessionId: sessionId,
      provider: providerUsed
    };
  }
  
  /**
   * Save message to database
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
        conversation.metadata.fallbackCount += 1;
      }
      
      conversation.metadata.lastProvider = provider || conversation.metadata.lastProvider;
      conversation.updatedAt = new Date();
      
      await conversation.save();
    } catch (error) {
      console.error("[ChatbotService] Error saving message:", error);
      // Don't throw - saving is non-critical
    }
  }
}

// Export singleton instance
module.exports = new ChatbotService();
```

---

## Flow Diagram

```
User sends message
    ↓
chatbotController.js receives request
    ↓
chatbotService.getResponse(message, sessionId, userId)
    ↓
Load conversation history from DB
    ↓
Try: callGeminiAPI()  ← This is our custom method!
    ├─→ Uses: this.geminiLLM.invoke()  ← LangChain's method
    │   └─→ Which uses: @langchain/google-genai  ← Package we install
    │       └─→ Which calls: Google Gemini API  ← Google's API
    │
    └─→ Success? Return response
    └─→ Rate limited? → Try callOpenAITAPI()
                            └─→ Uses: this.openaiLLM.invoke()
                                └─→ @langchain/openai
                                    └─→ OpenAI API
```

---

## Key Points

### **1. `callGeminiAPI` is OUR function**
- Defined in the `ChatbotService` class
- Uses LangChain's `ChatGoogleGenerativeAI` class
- Wraps the actual API call with error handling

### **2. LangChain Provides the Bridge**
- `ChatGoogleGenerativeAI` is from `@langchain/google-genai` package
- It handles the HTTP requests to Google's API
- We don't write HTTP code ourselves - LangChain does it

### **3. Package Dependencies**
```json
{
  "dependencies": {
    "@langchain/google-genai": "^0.0.20",  // For Gemini
    "@langchain/openai": "^0.0.20",        // For OpenAI
    "langchain": "^0.1.0"                  // Core LangChain
  }
}
```

### **4. Installation**
```bash
npm install langchain @langchain/google-genai @langchain/openai
```

---

## Step-by-Step: How `callGeminiAPI` Works

### **Step 1: Initialize in Constructor**
```javascript
constructor() {
  // This creates the Gemini client using LangChain
  this.geminiLLM = new ChatGoogleGenerativeAI({
    modelName: "gemini-pro",
    apiKey: process.env.GOOGLE_API_KEY,  // Your API key from Google
  });
}
```

### **Step 2: Define the Method**
```javascript
async callGeminiAPI(userMessage, conversationHistory) {
  // Build messages array
  const messages = [
    { role: "system", content: this.systemPrompt },
    ...conversationHistory,
    { role: "user", content: userMessage }
  ];
  
  // Call LangChain's invoke method
  // This internally makes HTTP request to Google's API
  const response = await this.geminiLLM.invoke(messages);
  
  // Return formatted response
  return {
    content: response.content,
    provider: "gemini",
    tokensUsed: estimatedTokens
  };
}
```

### **Step 3: LangChain Handles the HTTP**
When you call `this.geminiLLM.invoke(messages)`, LangChain:
1. Formats messages according to Gemini's API spec
2. Makes HTTP POST request to `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent`
3. Includes your API key in headers
4. Parses the response
5. Returns a standardized format

**You never see this HTTP code - LangChain does it all!**

---

## Complete Call Stack

```
Your Code:
  chatbotService.callGeminiAPI(message, history)
    ↓
LangChain Method:
  geminiLLM.invoke(messages)
    ↓
LangChain Internal:
  HTTP POST to Google API
    ↓
Google Gemini API:
  Processes request, returns response
    ↓
LangChain:
  Parses response, returns object
    ↓
Your Code:
  Receives { content: "...", ... }
```

---

## Environment Variables Needed

```env
# .env file
GOOGLE_API_KEY=your_google_api_key_here
OPENAI_API_KEY=your_openai_api_key_here  # Optional, for fallback

GEMINI_MODEL=gemini-pro
OPENAI_MODEL=gpt-3.5-turbo
CHATBOT_TEMPERATURE=0.7
```

**To get Google API Key:**
1. Go to https://makersuite.google.com/app/apikey
2. Create API key
3. Add to `.env` file

---

## Summary

**Question**: Where does `callGeminiAPI` come from?  
**Answer**: **We create it!** It's a custom method in `chatbotService.js` that:
- Uses LangChain's `ChatGoogleGenerativeAI` class
- Wraps the API call with error handling
- Formats responses consistently

**The actual API communication is handled by LangChain**, which uses the `@langchain/google-genai` package under the hood.

---

## Next Steps

When I implement this, I'll create:
1. ✅ `chatbotService.js` with `callGeminiAPI` method
2. ✅ Install required packages
3. ✅ Set up environment variables
4. ✅ Integrate with database for history

Would you like me to proceed with the implementation now?

