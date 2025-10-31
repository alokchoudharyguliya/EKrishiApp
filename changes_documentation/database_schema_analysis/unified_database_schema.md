# Unified Database Schema Analysis
## EKrishi Project - Complete Database Model Schema

**Date:** Analysis Date
**Scope:** Frontend (Flutter), Backend (Node.js/MongoDB), AI Service (Python/gRPC)

---

## 1. BACKEND MODELS (MongoDB/Mongoose)

### 1.1 User Model
**Location:** `backend/models/user.js`

| Attribute | Type | Required | Default | Constraints | Notes |
|-----------|------|----------|---------|-------------|-------|
| `_id` | ObjectId | Yes | Auto | Unique | MongoDB ID |
| `email` | String | Yes | - | Unique, Email regex | Primary identifier |
| `password` | String | Yes | - | - | Hashed (bcrypt) |
| `photoUrl` | String | No | - | - | Profile photo URL |
| `name` | String | No | - | - | User's full name |
| `dob` | String | No | - | - | Date of birth (stored as String) |
| `phone` | String | No | - | - | Phone number |
| `role` | String | No | 'student' | Enum: ['student', 'faculty', 'other', 'admin'] | User role |
| `createdAt` | Date | Yes | Date.now | - | Creation timestamp |
| `updatedAt` | Date | Yes | Date.now | - | Update timestamp |

**Indexes:** `email` (unique)

---

### 1.2 Event Model
**Location:** `backend/models/event.js`

| Attribute | Type | Required | Default | Constraints | Notes |
|-----------|------|----------|---------|-------------|-------|
| `_id` | ObjectId | Yes | Auto | Unique | MongoDB ID |
| `title` | String | Yes | - | Max 100 chars | Event title |
| `userId` | ObjectId | Yes | - | Ref: User | Owner of event |
| `start_date` | Date | Yes | - | - | Event start date |
| `end_date` | Date | No | - | - | Event end date (optional) |
| `description` | String | No | - | - | Event description |
| `isDeleted` | String | No | - | - | Soft delete flag (String type) |
| `changeType` | String | No | - | - | Type of change |
| `lastUpdated` | String | No | - | - | Last update time (String) |
| `isSynced` | Boolean | No | - | - | Sync status |
| `createdAt` | Date | Yes | Date.now | - | Creation timestamp |
| `updatedAt` | Date | Yes | Date.now | - | Update timestamp |

**Indexes:** `userId`

---

### 1.3 Equipment Model
**Location:** `backend/models/equipment.js`

| Attribute | Type | Required | Default | Constraints | Notes |
|-----------|------|----------|---------|-------------|-------|
| `_id` | ObjectId | Yes | Auto | Unique | MongoDB ID |
| `name` | String | Yes | - | 2-120 chars | Equipment name |
| `description` | String | No | '' | Max 2000 chars | Description |
| `price` | Number | Yes | - | Min 0 | Price in rupees |
| `contact` | String | Yes | - | Exactly 10 digits | Contact number |
| `location` | String | No | '' | Max 200 chars | Location |
| `isAvailable` | Boolean | No | true | - | Availability status |
| `imageUrl` | String | No | '' | - | Image URL |
| `owner` | ObjectId | Yes | - | Ref: User | Equipment owner |
| `createdAt` | Date | Yes | Date.now | - | Creation timestamp |
| `updatedAt` | Date | Yes | Date.now | - | Update timestamp |

**Indexes:** `owner`

---

### 1.4 IrrigationDevice Model
**Location:** `backend/models/irrigationDevice.js`

| Attribute | Type | Required | Default | Constraints | Notes |
|-----------|------|----------|---------|-------------|-------|
| `_id` | ObjectId | Yes | Auto | Unique | MongoDB ID |
| `userId` | ObjectId | Yes | - | Ref: User, Indexed | Device owner |
| `deviceId` | String | Yes | - | Unique, Indexed | Device identifier |
| `deviceName` | String | No | 'Irrigation Device' | - | Device display name |
| `piUrl` | String | Yes | - | WebSocket URL format (ws://...) | Raspberry Pi WebSocket URL |
| `location` | String | No | '' | - | Device location |
| `isActive` | Boolean | No | true | - | Active status |
| `lastSeen` | Date | No | Date.now | - | Last connection time |
| `createdAt` | Date | Yes | Date.now | - | Creation timestamp |
| `updatedAt` | Date | Yes | Date.now | - | Update timestamp |

**Indexes:** 
- `userId` (index)
- `deviceId` (unique, index)
- `{ userId: 1, isActive: 1 }` (compound)

---

### 1.5 IrrigationEvent Model
**Location:** `backend/models/irrigationEvent.js`

| Attribute | Type | Required | Default | Constraints | Notes |
|-----------|------|----------|---------|-------------|-------|
| `_id` | ObjectId | Yes | Auto | Unique | MongoDB ID |
| `userId` | ObjectId | Yes | - | Ref: User, Indexed | Event owner |
| `deviceId` | String | Yes | - | Indexed | Device identifier |
| `action` | String | Yes | - | Enum: ['pump_on', 'pump_off', 'pump_toggle'] | Action type |
| `state` | Boolean | Yes | - | - | Pump state (true=on, false=off) |
| `triggeredBy` | String | No | 'user' | Enum: ['user', 'schedule', 'sensor', 'manual'] | Trigger source |
| `duration` | Number | No | null | - | Duration in seconds (optional) |
| `metadata` | Mixed | No | {} | - | Additional data |
| `createdAt` | Date | Yes | Date.now | - | Event timestamp, Indexed |

**Indexes:**
- `userId` (index)
- `deviceId` (index)
- `createdAt` (index)
- `{ userId: 1, createdAt: -1 }` (compound)
- `{ deviceId: 1, createdAt: -1 }` (compound)

---

### 1.6 SensorReading Model
**Location:** `backend/models/sensorReading.js`

| Attribute | Type | Required | Default | Constraints | Notes |
|-----------|------|----------|---------|-------------|-------|
| `_id` | ObjectId | Yes | Auto | Unique | MongoDB ID |
| `userId` | ObjectId | Yes | - | Ref: User, Indexed | Reading owner |
| `deviceId` | String | Yes | - | Indexed | Device identifier |
| `sensorType` | String | Yes | - | Enum: ['temperature', 'moisture', 'humidity'], Indexed | Sensor type |
| `value` | Number | Yes | - | - | Sensor value |
| `unit` | String | No | '' | - | Unit of measurement |
| `timestamp` | Date | Yes | Date.now | Indexed | Reading timestamp |
| `metadata` | Mixed | No | {} | - | Additional metadata |

**Indexes:**
- `userId` (index)
- `deviceId` (index)
- `sensorType` (index)
- `timestamp` (index)
- `{ userId: 1, sensorType: 1, timestamp: -1 }` (compound)
- `{ deviceId: 1, sensorType: 1, timestamp: -1 }` (compound)
- `{ deviceId: 1, timestamp: -1 }` (compound)

---

### 1.7 CropAnalysis Model
**Location:** `backend/models/cropAnalysis.js`

| Attribute | Type | Required | Default | Constraints | Notes |
|-----------|------|----------|---------|-------------|-------|
| `_id` | ObjectId | Yes | Auto | Unique | MongoDB ID |
| `userId` | ObjectId | No | - | Ref: User | Optional for anonymous |
| `imageName` | String | Yes | - | - | Original filename |
| `imageSize` | Number | No | - | - | Size in bytes |
| `context` | Object | No | - | - | Analysis context (nested) |
| `context.imageType` | String | No | - | - | Type: Leaf, Stem, Soil, Whole Plant |
| `context.cropType` | String | No | - | - | Crop name |
| `context.observedProblem` | String | No | - | - | User's problem description |
| `context.plantAge` | Number | No | - | - | Plant age in days |
| `context.recentWeatherEvent` | Boolean | No | - | - | Weather event flag |
| `result` | Mixed | Yes | - | - | Full AI response (nested object) |
| `status` | String | No | 'processing' | Enum: ['pending', 'processing', 'completed', 'failed'] | Analysis status |
| `createdAt` | Date | Yes | Date.now | - | Creation timestamp |
| `updatedAt` | Date | Yes | Date.now | - | Update timestamp |

**Indexes:** None explicitly defined

---

### 1.8 ChatbotConversation Model
**Location:** `backend/models/chatbotConversation.js`

| Attribute | Type | Required | Default | Constraints | Notes |
|-----------|------|----------|---------|-------------|-------|
| `_id` | ObjectId | Yes | Auto | Unique | MongoDB ID |
| `userId` | ObjectId | Yes | - | Ref: User, Indexed | Conversation owner |
| `sessionId` | String | Yes | - | Indexed | Session identifier |
| `messages` | Array | Yes | [] | - | Array of message objects |
| `messages[].role` | String | Yes | - | Enum: ['user', 'assistant', 'system'] | Message role |
| `messages[].content` | String | Yes | - | - | Message content |
| `messages[].provider` | String | No | null | Enum: ['gemini', 'openai', 'error', null] | AI provider used |
| `messages[].tokensUsed` | Number | No | 0 | - | Token count |
| `messages[].timestamp` | Date | Yes | Date.now | - | Message timestamp |
| `messages[].isError` | Boolean | No | false | - | Error flag |
| `metadata` | Object | No | - | - | Conversation metadata |
| `metadata.totalTokensGemini` | Number | No | 0 | - | Total Gemini tokens |
| `metadata.totalTokensOpenAI` | Number | No | 0 | - | Total OpenAI tokens |
| `metadata.fallbackCount` | Number | No | 0 | - | Fallback count |
| `metadata.lastProvider` | String | No | null | Enum: ['gemini', 'openai', null] | Last provider used |
| `createdAt` | Date | Yes | Date.now | - | Creation timestamp |
| `updatedAt` | Date | Yes | Date.now | - | Update timestamp |

**Indexes:**
- `userId` (index)
- `sessionId` (index)
- `{ userId: 1, sessionId: 1 }` (compound)
- `{ userId: 1, 'messages.timestamp': -1 }` (compound)

---

### 1.9 Remainders Model
**Location:** `backend/models/remainders.js`

**Status:** File exists but appears to be empty

---

### 1.10 Shared Collections Model
**Location:** `backend/models/shared_collections.js`

**Status:** File exists but appears to be empty

---

## 2. FRONTEND MODELS (Flutter/Dart)

### 2.1 Event Model
**Location:** `NewsCalendar/lib/models/events.dart`

| Attribute | Type | Required | Default | Notes |
|-----------|------|----------|---------|-------|
| `id` | String | Yes | - | Event ID (MongoDB _id) |
| `title` | String | Yes | - | Event title |
| `userId` | String | Yes | - | User ID (MongoDB _id) |
| `startDate` | DateTime | Yes | - | Start date |
| `endDate` | DateTime? | No | null | End date (nullable) |
| `description` | String? | No | null | Description (nullable) |
| `createdAt` | DateTime | Yes | - | Creation timestamp |
| `updatedAt` | DateTime | Yes | - | Update timestamp |
| `isSynced` | bool | No | false | Sync status |
| `lastUpdated` | DateTime | Yes | - | Last update timestamp |
| `version` | int | No | 0 | Version number for sync |
| `isDeleted` | bool | No | false | Soft delete flag |
| `changeType` | String? | No | null | Type of change |

**Serialization:** 
- `toJson()`: Maps to backend format
- `fromJson()`: Handles multiple field name variations (`start_date`/`startDate`, `userId`/`user_id`/`createdBy`)

---

### 2.2 Equipment Data Structure (Map-based)
**Location:** `NewsCalendar/lib/screens/equipment_markeplace_screen.dart`

Equipment is represented as `Map<String, dynamic>` with the following keys:

| Key | Type | Notes |
|-----|------|-------|
| `id` | String | Equipment ID |
| `name` | String | Equipment name |
| `description` | String | Description |
| `price` | String | Price as string |
| `image` | String | Image URL (mapped from `imageUrl`) |
| `contact` | String | Contact number |
| `location` | String | Location |
| `ownerId` | String | Owner ID (mapped from `owner`) |
| `isAvailable` | bool | Availability status |

**Note:** No dedicated Dart class model, uses Map structure

---

### 2.3 User Data Structure (Map-based)
**Location:** `NewsCalendar/lib/services/user_service.dart`

User data is stored as `Map<String, dynamic>` with keys from backend:
- `_id` (ObjectId as String)
- `email`
- `name`
- `photoUrl`
- `dob`
- `phone`
- `role`
- `createdAt`
- `updatedAt`

---

### 2.4 Chatbot Message Structure
**Location:** `NewsCalendar/lib/screens/chatbot_screen.dart`

| Attribute | Type | Notes |
|-----------|------|-------|
| `text` | String | Message content |
| `isUser` | bool | True if user message |
| `timestamp` | DateTime | Message timestamp |

**API Response Format:**
```dart
{
  'success': bool,
  'response': String,
  'sessionId': String,
  'provider': String?
}
```

---

### 2.5 Irrigation Device Data Structure (Map-based)
**Location:** `NewsCalendar/lib/screens/irrigation_screen.dart`

Device data as `Map<String, dynamic>`:
- `deviceId`
- `deviceName`
- `piUrl`
- `location`
- `isActive`
- `lastSeen`

---

### 2.6 AI Crop Analysis Response Structure
**Location:** `NewsCalendar/lib/screens/ai_crop_assistance_screen.dart`

Expected response structure (from backend API):
```dart
{
  'success': bool,
  'requestId': String,
  'analysis': {
    'diagnosis': String,
    'confidence': double,
    'disease': String,
    'severity': String,
    'suggestions': List<String>,
    'treatment': List<Map>,
    'prevention': List<String>,
    'references': List<String>
  },
  'metadata': {
    'modelUsed': String,
    'processingTime': double,
    'timestamp': String
  }
}
```

---

## 3. AI SERVICE DATA STRUCTURES (gRPC Protocol Buffers)

### 3.1 CropAnalysisRequest (Protocol Buffer)
**Location:** `AI/protos/crop_analysis.proto`

| Field | Type | Number | Notes |
|-------|------|--------|-------|
| `image_data` | bytes | 1 | Raw image bytes |
| `image_name` | string | 2 | Original filename |
| `image_type` | string | 3 | Type: Leaf, Stem, Soil, Whole Plant |
| `crop_type` | string | 4 | Crop name (Wheat, Rice, etc.) |
| `observed_problem` | string | 5 | User's problem description |
| `plant_age_days` | int32 | 6 | Age in days |
| `recent_weather_event` | bool | 7 | Weather event flag |
| `user_id` | string | 8 | Optional user ID for tracking |

---

### 3.2 CropAnalysisResponse (Protocol Buffer)
**Location:** `AI/protos/crop_analysis.proto`

| Field | Type | Number | Notes |
|-------|------|--------|-------|
| `success` | bool | 1 | Success flag |
| `diagnosis` | string | 2 | Main diagnosis text |
| `confidence` | double | 3 | Confidence score (0.0-1.0) |
| `disease` | string | 4 | Disease name |
| `severity` | string | 5 | low, moderate, high |
| `suggestions` | repeated string | 6 | Treatment suggestions |
| `treatment` | repeated Treatment | 7 | Treatment details array |
| `prevention` | repeated string | 8 | Prevention tips |
| `references` | repeated string | 9 | Reference URLs |
| `processing_time` | double | 10 | Time in seconds |
| `model_used` | string | 11 | Model identifier |
| `error_message` | string | 12 | Error message if failed |

### 3.3 Treatment (Protocol Buffer)
**Location:** `AI/protos/crop_analysis.proto`

| Field | Type | Number | Notes |
|-------|------|--------|-------|
| `product` | string | 1 | Product name |
| `application` | string | 2 | How to apply |
| `duration` | string | 3 | Treatment duration |

---

## 4. UNIFIED SCHEMA SUMMARY

### Core Entities:
1. **User** - User accounts and authentication
2. **Event** - Calendar events
3. **Equipment** - Equipment marketplace items
4. **IrrigationDevice** - Registered irrigation devices
5. **IrrigationEvent** - Pump control events
6. **SensorReading** - IoT sensor data
7. **CropAnalysis** - AI crop analysis results
8. **ChatbotConversation** - Chatbot conversation history

---

## 5. INCOMPATIBILITIES & ISSUES

### 5.1 Critical Incompatibilities

#### 5.1.1 Event Model - Field Type Mismatches
**Severity:** HIGH

| Issue | Backend | Frontend | Impact |
|-------|---------|----------|--------|
| `isDeleted` type | String | bool | Type mismatch - backend uses String, frontend uses bool |
| `lastUpdated` type | String | DateTime | Backend stores as String, frontend expects DateTime |
| `changeType` | String (nullable) | String? (nullable) | Compatible but inconsistent handling |
| `isSynced` | Boolean | bool | Compatible but default differs (backend: undefined, frontend: false) |

**Location:**
- Backend: `backend/models/event.js` (line 26-29)
- Frontend: `NewsCalendar/lib/models/events.dart` (line 23-31)

---

#### 5.1.2 Event Model - Field Name Variations
**Severity:** MEDIUM

The frontend `fromJson()` handles multiple field name variations:
- `start_date` / `startDate`
- `end_date` / `endDate`
- `userId` / `user_id` / `createdBy`
- `createdAt` / `created_at`
- `updatedAt` / `updated_at`
- `last_updated` / `lastUpdated`

This indicates **inconsistent API responses** or **multiple API versions**.

---

#### 5.1.3 Equipment Model - Price Type Mismatch
**Severity:** MEDIUM

| Issue | Backend | Frontend | Impact |
|-------|---------|----------|--------|
| `price` type | Number | String | Backend stores as Number, frontend converts to String for display |

**Location:**
- Backend: `backend/models/equipment.js` (line 18-22)
- Frontend: `NewsCalendar/lib/screens/equipment_markeplace_screen.dart` (line 86)

---

#### 5.1.4 Equipment Model - Field Name Mapping
**Severity:** LOW

| Backend Field | Frontend Field | Notes |
|---------------|----------------|-------|
| `owner` | `ownerId` | Frontend maps ObjectId to String |
| `imageUrl` | `image` | Different field name |

**Location:**
- Frontend: `NewsCalendar/lib/screens/equipment_markeplace_screen.dart` (line 87-90)

---

#### 5.1.5 User Model - Date Field Type
**Severity:** MEDIUM

| Issue | Backend | Frontend | Impact |
|-------|---------|----------|--------|
| `dob` type | String | N/A (not explicitly handled) | Backend stores DOB as String, not Date |

**Location:**
- Backend: `backend/models/user.js` (line 22-24)

**Recommendation:** Consider using Date type for better date operations.

---

#### 5.1.6 Crop Analysis - Context Structure
**Severity:** LOW

| Issue | Backend | AI Service | Impact |
|-------|---------|------------|--------|
| `plantAge` naming | `context.plantAge` (Number) | `plant_age_days` (int32) | Different naming convention |
| `recentWeatherEvent` naming | `context.recentWeatherEvent` (Boolean) | `recent_weather_event` (bool) | Snake_case vs camelCase |

**Location:**
- Backend: `backend/models/cropAnalysis.js` (line 22)
- AI Service: `AI/protos/crop_analysis.proto` (line 19-20)

---

### 5.2 Missing Models/Features

#### 5.2.1 Remainders Model
**Status:** Empty file
**Location:** `backend/models/remainders.js`
**Impact:** Feature may be planned but not implemented

---

#### 5.2.2 Shared Collections Model
**Status:** Empty file
**Location:** `backend/models/shared_collections.js`
**Impact:** Feature may be planned but not implemented

---

#### 5.2.3 Frontend Model Classes
**Issue:** Most frontend data structures use `Map<String, dynamic>` instead of typed Dart classes
**Affected Models:**
- Equipment (no Dart class)
- User (no Dart class)
- IrrigationDevice (no Dart class)
- CropAnalysis (no Dart class)

**Impact:** 
- No type safety
- No compile-time validation
- Harder to maintain
- Potential runtime errors

---

### 5.3 Data Type Inconsistencies

#### 5.3.1 ID Field Representations
| Context | Type | Notes |
|---------|------|-------|
| MongoDB `_id` | ObjectId | Native MongoDB type |
| API Response `_id` | String | JSON serialization converts to string |
| Frontend `id` | String | Dart uses String |
| API Request `userId` | String | Usually string representation |

**Recommendation:** Ensure consistent handling across all layers.

---

#### 5.3.2 Date/Time Handling
| Context | Type | Format | Notes |
|---------|------|--------|-------|
| MongoDB Date | Date | ISO 8601 | Native Date object |
| API Response | String | ISO 8601 | JSON serialization |
| Flutter DateTime | DateTime | ISO 8601 | Dart DateTime |
| Event `lastUpdated` (Backend) | String | Unknown | Should be Date |

**Issues:**
- Event model uses `String` for `lastUpdated` instead of `Date`
- Inconsistent date parsing in frontend

---

### 5.4 Validation Inconsistencies

#### 5.4.1 Contact Number Validation
- **Backend:** Validates exactly 10 digits (`/^\d{10}$/`)
- **Frontend:** No explicit validation visible (may be handled in form)

**Location:** `backend/models/equipment.js` (line 26-31)

---

#### 5.4.2 Email Validation
- **Backend:** Email regex validation (`/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/`)
- **Frontend:** Not visible in models (may be handled in forms)

**Location:** `backend/models/user.js` (line 10)

---

### 5.5 API Contract Issues

#### 5.5.1 Event API Field Variations
The frontend `Event.fromJson()` handles multiple field name variations, suggesting:
1. API versioning issues
2. Inconsistent backend responses
3. Multiple data sources

**Recommendation:** Standardize API field names.

---

#### 5.5.2 Error Response Format
Not consistently defined across all endpoints. Standardize error response structure.

---

## 6. RECOMMENDATIONS

### 6.1 Immediate Fixes (High Priority)

1. **Fix Event Model Type Mismatches:**
   - Change `isDeleted` from String to Boolean in backend
   - Change `lastUpdated` from String to Date in backend
   - Update frontend to handle Date type consistently

2. **Standardize Field Names:**
   - Use consistent naming convention (camelCase for JavaScript, snake_case for API if needed)
   - Remove field name variations in frontend parsing

3. **Create Typed Dart Models:**
   - Create Dart classes for Equipment, User, IrrigationDevice, CropAnalysis
   - Use code generation (json_serializable) for consistency

### 6.2 Medium Priority

1. **Fix Equipment Price Type:**
   - Keep Number in backend (correct)
   - Handle conversion in frontend presentation layer only

2. **Standardize Date Handling:**
   - Ensure all date fields use Date type in backend
   - Use consistent ISO 8601 format

3. **Implement Missing Models:**
   - Implement Remainders model if feature is needed
   - Implement Shared Collections model if feature is needed

### 6.3 Long-term Improvements

1. **API Versioning:**
   - Implement API versioning strategy
   - Document API contracts

2. **Validation:**
   - Add frontend validation matching backend rules
   - Use shared validation schemas

3. **Type Safety:**
   - Move from Map-based to typed models in Flutter
   - Use TypeScript for backend (if possible) or JSDoc types

---

## 7. COMPATIBILITY MATRIX

| Model | Backend Complete | Frontend Complete | AI Service Complete | Compatible |
|-------|-----------------|-------------------|---------------------|------------|
| User | ✅ | ⚠️ (Map-based) | ❌ | ⚠️ Partial |
| Event | ✅ | ✅ | ❌ | ⚠️ Type mismatches |
| Equipment | ✅ | ⚠️ (Map-based) | ❌ | ⚠️ Field name differences |
| IrrigationDevice | ✅ | ⚠️ (Map-based) | ❌ | ✅ Compatible |
| IrrigationEvent | ✅ | ❌ | ❌ | ❌ Not used in frontend |
| SensorReading | ✅ | ❌ | ❌ | ❌ Not used in frontend |
| CropAnalysis | ✅ | ⚠️ (Map-based) | ✅ | ⚠️ Naming differences |
| ChatbotConversation | ✅ | ⚠️ (Map-based) | ❌ | ✅ Compatible |

**Legend:**
- ✅ Complete/Compatible
- ⚠️ Partial/Issues
- ❌ Missing/Incomplete

---

## 8. DATABASE INDEXES SUMMARY

### User Collection
- `email` (unique)

### Event Collection
- `userId`

### Equipment Collection
- `owner`

### IrrigationDevice Collection
- `userId`
- `deviceId` (unique)
- `{ userId: 1, isActive: 1 }` (compound)

### IrrigationEvent Collection
- `userId`
- `deviceId`
- `createdAt`
- `{ userId: 1, createdAt: -1 }` (compound)
- `{ deviceId: 1, createdAt: -1 }` (compound)

### SensorReading Collection
- `userId`
- `deviceId`
- `sensorType`
- `timestamp`
- `{ userId: 1, sensorType: 1, timestamp: -1 }` (compound)
- `{ deviceId: 1, sensorType: 1, timestamp: -1 }` (compound)
- `{ deviceId: 1, timestamp: -1 }` (compound)

### ChatbotConversation Collection
- `userId`
- `sessionId`
- `{ userId: 1, sessionId: 1 }` (compound)
- `{ userId: 1, 'messages.timestamp': -1 }` (compound)

### CropAnalysis Collection
- No explicit indexes defined (consider adding `userId`, `createdAt` indexes)

---

## END OF ANALYSIS

