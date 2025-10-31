# Backend Dependencies - Chatbot Implementation

## File Changed
- `backend/package.json`

## Change Type
MODIFY - Added new dependencies

## Line Numbers
- Lines 16-17: Added `@langchain/google-genai` and `@langchain/openai`
- Line 29: Added `langchain` core package

## Details

### Dependencies Added
```json
"@langchain/google-genai": "^0.0.21",
"@langchain/openai": "^0.1.0",
"langchain": "^0.1.20"
```

### Purpose
- `langchain`: Core LangChain library for LLM orchestration
- `@langchain/google-genai`: Integration with Google Gemini API
- `@langchain/openai`: Integration with OpenAI API (fallback)

### Installation
Run `npm install` to install the new dependencies.

---

## Impact
- Enables chatbot service to use LangChain for AI interactions
- Supports both Gemini (primary) and OpenAI (fallback) APIs

