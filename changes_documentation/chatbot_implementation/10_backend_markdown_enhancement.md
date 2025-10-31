# Backend System Prompt - Markdown Formatting Enhancement

## File Changed
- `backend/services/chatbotService.js`

## Change Type
MODIFY - Enhanced system prompt to encourage markdown formatting

## Line Numbers Changed
- **Lines 66-68**: Added markdown formatting instructions to system prompt

## Details

### Before (Lines 66-68)
```javascript
If a user asks about non-agriculture topics (general questions, unrelated subjects), politely decline and suggest how you can help with farming instead.

Always use agriculture terminology and provide practical, actionable advice.`;
```

### After (Lines 66-78)
```javascript
If a user asks about non-agriculture topics (general questions, unrelated subjects), politely decline and suggest how you can help with farming instead.

Always use agriculture terminology and provide practical, actionable advice.

Response Formatting:
- Use **bold** (double asterisks) for important terms, key points, or emphasis
- Use *italic* (single asterisk) for subtle emphasis or technical terms
- Use numbered lists (1., 2., 3.) or bullet points (-) for multiple items or steps
- Use line breaks for better readability in longer responses
- Structure your responses with clear sections when appropriate
- Use markdown formatting to make your responses more readable and professional`;
```

### What Was Added
A new "Response Formatting" section that instructs the LLM (Gemini/OpenAI) to:
1. Use **bold** for important terms and emphasis
2. Use *italic* for subtle emphasis or technical terms
3. Use numbered or bulleted lists for multiple items/steps
4. Use line breaks for better readability
5. Structure responses with clear sections
6. Overall encouragement to use markdown formatting

---

## Impact
- ✅ LLM will now consistently use markdown formatting
- ✅ Responses will be more structured and readable
- ✅ Better user experience with formatted responses
- ✅ Works seamlessly with frontend markdown rendering

---

## Testing
After this change, test with queries like:
- "How do I detect crop diseases?" → Should return formatted response with lists/bold
- "What are the steps for irrigation?" → Should use numbered or bulleted lists
- "Tell me about pest control" → Should use bold for important terms

