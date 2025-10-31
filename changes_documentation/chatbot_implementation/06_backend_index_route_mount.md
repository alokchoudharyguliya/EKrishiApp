# Backend Index - Route Mounting

## File Changed
- `backend/index.js`

## Change Type
MODIFY - Added chatbot route import and mounting

## Line Numbers
- Line 21: Added import statement
- Line 95: Added route mounting

## Details

### Changes Made

#### Import Statement (Line 21)
```javascript
const chatbotRoutes = require('./routes/chatbotRoutes.js');
```

#### Route Mounting (Line 95)
```javascript
app.use('/api/chatbot', chatbotRoutes);
```

### Context
The chatbot routes are mounted after other API routes:
- Equipment routes
- User routes
- File routes
- Event routes
- WebRTC routes
- AI routes
- Irrigation routes
- **Chatbot routes** ← New addition

### Route Path
All chatbot endpoints are accessible under `/api/chatbot/*`

---

## Impact
- Makes chatbot API endpoints available
- Integrated with existing Express app structure

