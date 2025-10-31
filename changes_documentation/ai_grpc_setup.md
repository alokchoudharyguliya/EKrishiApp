# AI gRPC Setup - Change Documentation

## Overview
Set up Python gRPC server for AI crop analysis and integrated it with Node.js backend.

## Files Created

### AI Folder (Python Backend)

#### 1. `AI/protos/crop_analysis.proto`
**Purpose:** Protocol buffer definition for gRPC service
**Lines:** 1-54 (entire file is new)
- Defines `CropAnalysisService` with `AnalyzeCrop` and `HealthCheck` methods
- Message types: `CropAnalysisRequest`, `CropAnalysisResponse`, `Treatment`, `HealthRequest`, `HealthResponse`

#### 2. `AI/server.py`
**Purpose:** Python gRPC server implementation
**Lines:** 1-218 (entire file is new)
- Implements `CropAnalysisServiceServicer`
- `AnalyzeCrop()` method: Processes crop images (lines 27-93)
- `HealthCheck()` method: Health check endpoint (lines 95-100)
- `_generate_mock_diagnosis()`: Mock AI logic (lines 102-161)
- `serve()`: Server startup (lines 164-189)
- Currently returns mock responses; TODO: Replace with actual AI model

#### 3. `AI/requirements.txt`
**Purpose:** Python dependencies
**Lines:** 1-3 (entire file is new)
- grpcio==1.60.0
- grpcio-tools==1.60.0
- protobuf==4.25.1

#### 4. `AI/README.md`
**Purpose:** Setup and usage documentation
**Lines:** 1-35 (entire file is new)
- Installation instructions
- gRPC code generation steps
- Server startup instructions
- Testing guide

### Backend Folder (Node.js Integration)

#### 5. `backend/protos/crop_analysis.proto`
**Purpose:** Proto file copy for Node.js gRPC client
**Lines:** 1-54 (entire file is new)
- Same as AI/protos/crop_analysis.proto
- Required for generating Node.js gRPC client code

#### 6. `backend/services/aiService.js`
**Purpose:** gRPC client service for communicating with Python backend
**Lines:** 1-109 (entire file is new)
- **Constructor (lines 9-30):** Initializes gRPC client
- **analyzeCrop() method (lines 36-89):** Sends image and context to Python server
- **healthCheck() method (lines 95-109):** Checks AI service health
- Error handling for timeout and unavailable errors

#### 7. `backend/controllers/aiController.js`
**Purpose:** Express controller for AI endpoints
**Lines:** 1-170 (entire file is new)
- **analyzeCrop() method (lines 11-79):** Main endpoint handler
  - Validates image file (line 18-23)
  - Prepares context (lines 33-42)
  - Calls AI service (line 47)
  - Saves to database (lines 49-63)
  - Returns response (lines 66-78)
- **getSuggestion() method (lines 84-107):** Retrieves cached analysis
- **healthCheck() method (lines 112-129):** AI service health check

#### 8. `backend/models/cropAnalysis.js`
**Purpose:** MongoDB model for storing analysis results
**Lines:** 1-40 (entire file is new)
- Schema definition (lines 5-32)
- Pre-save hook for updatedAt (lines 34-37)
- Fields: userId, imageName, imageSize, context, result, status, timestamps

#### 9. `backend/routes/aiRoutes.js`
**Purpose:** Express routes for AI endpoints
**Lines:** 1-30 (entire file is new)
- Multer configuration (lines 8-18): Memory storage for gRPC
- POST `/api/ai/crop-analysis` (line 21)
- GET `/api/ai/suggestions/:requestId` (line 24)
- GET `/api/ai/health` (line 27)

## Files Modified

### 10. `backend/index.js`
**Changes:**
- **Line 18:** Added import for aiRoutes
  ```javascript
  const aiRoutes = require('./routes/aiRoutes.js');
  ```
- **Line 89:** Added AI routes to Express app
  ```javascript
  app.use('/api/ai', aiRoutes);
  ```

### 11. `backend/package.json`
**Changes:**
- **Lines 14-15:** Added gRPC dependencies
  ```json
  "@grpc/grpc-js": "^1.9.14",
  "@grpc/proto-loader": "^0.7.10"
  ```

## Integration Flow

```
Flutter App
    ↓ HTTP POST /api/ai/crop-analysis
Node.js Backend (Express)
    ↓ Route: aiRoutes.js → Controller: aiController.js
    ↓ gRPC Client: aiService.js
Python gRPC Server (server.py)
    ↓ Processes image and context
    ↓ Returns analysis result
Node.js Backend
    ↓ Saves to MongoDB (CropAnalysis model)
    ↓ Returns JSON response
Flutter App
```

## API Endpoints Created

1. **POST `/api/ai/crop-analysis`**
   - Requires: Authentication, image file (multipart/form-data)
   - Body: image (file), imageType, cropType, problem, plantAge, recentWeather
   - Returns: Analysis result with diagnosis, suggestions, treatment

2. **GET `/api/ai/suggestions/:requestId`**
   - Requires: Authentication
   - Returns: Cached analysis result by request ID

3. **GET `/api/ai/health`**
   - Public endpoint
   - Returns: AI service health status

## Environment Variables

### Python Backend
- `GRPC_PORT`: Port for gRPC server (default: 50051)
- `MAX_WORKERS`: Maximum worker threads (default: 10)

### Node.js Backend
- `PYTHON_GRPC_URL`: Python gRPC server URL (default: localhost:50051)
- `GRPC_TIMEOUT`: Request timeout in ms (default: 60000)

## Next Steps

1. Generate Python gRPC code:
   ```bash
   cd AI
   python -m grpc_tools.protoc -I./protos --python_out=./protos --grpc_python_out=./protos ./protos/crop_analysis.proto
   ```

2. Install Node.js dependencies:
   ```bash
   cd backend
   npm install
   ```

3. Install Python dependencies:
   ```bash
   cd AI
   pip install -r requirements.txt
   ```

4. Start Python gRPC server:
   ```bash
   cd AI
   python server.py
   ```

5. Start Node.js backend:
   ```bash
   cd backend
   npm start
   ```

## Notes

- Python server currently returns mock responses
- Replace `_generate_mock_diagnosis()` in `server.py` with actual AI model
- Proto file must be in sync between AI and backend folders
- Images are stored in memory (multer.memoryStorage) for efficient gRPC transmission

