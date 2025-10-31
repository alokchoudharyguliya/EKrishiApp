# Incompatibilities Summary
## Quick Reference - Critical Issues Found

---

## 🔴 CRITICAL INCOMPATIBILITIES (Must Fix)

### 1. Event Model - Type Mismatches

**Issue:** Backend uses String types where frontend expects Boolean/DateTime

| Field | Backend Type | Frontend Type | Fix Required |
|-------|--------------|---------------|--------------|
| `isDeleted` | String | bool | Change backend to Boolean |
| `lastUpdated` | String | DateTime | Change backend to Date |
| `isSynced` | Boolean (undefined default) | bool (false default) | Align defaults |

**Files Affected:**
- `backend/models/event.js` (lines 26-29)
- `NewsCalendar/lib/models/events.dart` (lines 23-24)

**Impact:** Runtime errors, data corruption, sync issues

---

### 2. Event Model - Field Name Variations

**Issue:** Frontend handles multiple field name variations indicating inconsistent API

**Variations Handled:**
- `start_date` / `startDate`
- `end_date` / `endDate`
- `userId` / `user_id` / `createdBy`
- `createdAt` / `created_at`
- `updatedAt` / `updated_at`
- `last_updated` / `lastUpdated`

**Files Affected:**
- `NewsCalendar/lib/models/events.dart` (lines 67-97)

**Impact:** Maintenance burden, potential bugs, unclear API contract

**Fix:** Standardize API field names to camelCase

---

## 🟡 MEDIUM PRIORITY INCOMPATIBILITIES

### 3. Equipment Model - Price Type Conversion

**Issue:** Backend stores Number, frontend converts to String for display

| Backend | Frontend |
|---------|----------|
| `price: Number` | `'price': e['price']?.toString() ?? '0'` |

**Files Affected:**
- `backend/models/equipment.js` (line 19)
- `NewsCalendar/lib/screens/equipment_markeplace_screen.dart` (line 86)

**Impact:** Minor - handled in presentation layer, but could cause issues if not converted

**Recommendation:** Keep as Number in backend, handle conversion in UI only

---

### 4. Equipment Model - Field Name Mapping

**Issue:** Different field names between backend and frontend

| Backend Field | Frontend Field |
|---------------|----------------|
| `owner` (ObjectId) | `ownerId` (String) |
| `imageUrl` | `image` |

**Files Affected:**
- `NewsCalendar/lib/screens/equipment_markeplace_screen.dart` (lines 87-90)

**Impact:** Mapping logic needed, potential for bugs

**Fix:** Standardize field names or create proper mapping layer

---

### 5. User Model - DOB Storage

**Issue:** Date of birth stored as String instead of Date

| Field | Current Type | Recommended Type |
|-------|--------------|------------------|
| `dob` | String | Date |

**Files Affected:**
- `backend/models/user.js` (line 22-24)

**Impact:** Difficult to perform date operations, age calculations

---

### 6. Crop Analysis - Naming Convention Mismatch

**Issue:** Backend uses camelCase, AI service uses snake_case

| Backend | AI Service |
|---------|------------|
| `plantAge` | `plant_age_days` |
| `recentWeatherEvent` | `recent_weather_event` |

**Files Affected:**
- `backend/models/cropAnalysis.js` (line 22)
- `AI/protos/crop_analysis.proto` (lines 19-20)

**Impact:** Requires transformation layer

---

## 🔵 LOW PRIORITY / ARCHITECTURAL ISSUES

### 7. Missing Typed Models in Frontend

**Issue:** Most frontend data structures use `Map<String, dynamic>` instead of typed classes

**Affected Models:**
- Equipment (no Dart class)
- User (no Dart class)
- IrrigationDevice (no Dart class)
- CropAnalysis (no Dart class)
- ChatbotMessage (basic class exists)

**Impact:**
- No type safety
- No compile-time validation
- Harder to maintain
- Potential runtime errors

**Recommendation:** Create typed Dart models with json_serializable

---

### 8. Missing Frontend Models

**Issue:** Some backend models have no frontend representation

**Missing:**
- IrrigationEvent (no frontend model)
- SensorReading (no frontend model)

**Impact:** These features may not be fully implemented in UI

---

### 9. Empty Model Files

**Issue:** Model files exist but are empty

**Files:**
- `backend/models/remainders.js` (empty)
- `backend/models/shared_collections.js` (empty)

**Impact:** Planned features not implemented

---

### 10. Date/Time Inconsistencies

**Issue:** Inconsistent date handling across the stack

| Location | Type | Format |
|----------|------|--------|
| MongoDB | Date | ISO 8601 |
| API JSON | String | ISO 8601 |
| Flutter | DateTime | ISO 8601 |
| Event.lastUpdated | **String** | Unknown |

**Fix:** Ensure all date fields use Date type consistently

---

## 📊 COMPATIBILITY MATRIX

| Model | Backend | Frontend | AI Service | Compatibility |
|-------|---------|----------|------------|---------------|
| **User** | ✅ Complete | ⚠️ Map-based | ❌ N/A | ⚠️ Partial |
| **Event** | ✅ Complete | ✅ Class exists | ❌ N/A | ⚠️ **Type mismatches** |
| **Equipment** | ✅ Complete | ⚠️ Map-based | ❌ N/A | ⚠️ Field name differences |
| **IrrigationDevice** | ✅ Complete | ⚠️ Map-based | ❌ N/A | ✅ Compatible |
| **IrrigationEvent** | ✅ Complete | ❌ Missing | ❌ N/A | ❌ Not used |
| **SensorReading** | ✅ Complete | ❌ Missing | ❌ N/A | ❌ Not used |
| **CropAnalysis** | ✅ Complete | ⚠️ Map-based | ✅ Complete | ⚠️ Naming differences |
| **ChatbotConversation** | ✅ Complete | ⚠️ Map-based | ❌ N/A | ✅ Compatible |

---

## 🎯 FIX PRIORITY RANKING

### Priority 1 (Critical - Fix Immediately)
1. ✅ **Event Model Type Mismatches** (isDeleted, lastUpdated)
2. ✅ **Standardize Event API Field Names**

### Priority 2 (Important - Fix Soon)
3. ✅ **Create Typed Dart Models** for all entities
4. ✅ **Fix User DOB Type** (String → Date)
5. ✅ **Standardize Equipment Field Names**

### Priority 3 (Improvement - Plan for Next Sprint)
6. ✅ **Create Frontend Models** for IrrigationEvent, SensorReading
7. ✅ **Implement Missing Models** (Remainders, Shared Collections)
8. ✅ **Standardize Naming Conventions** (camelCase vs snake_case)
9. ✅ **Add Validation** consistency across layers
10. ✅ **API Versioning Strategy**

---

## 🔧 QUICK FIX GUIDE

### Fix 1: Event Model Type Mismatches

**Backend Change:**
```javascript
// backend/models/event.js
const eventSchema = new mongoose.Schema({
  // ... other fields
  isDeleted: {
    type: Boolean,  // Changed from String
    default: false
  },
  lastUpdated: {
    type: Date,  // Changed from String
    default: Date.now
  },
  isSynced: {
    type: Boolean,
    default: false  // Added default
  },
  // ...
});
```

### Fix 2: Standardize Event API Field Names

**Backend:** Always use camelCase in API responses
**Frontend:** Remove field name variations, use single format

### Fix 3: Create Typed Dart Models

**Example for Equipment:**
```dart
// lib/models/equipment.dart
@JsonSerializable()
class Equipment {
  final String id;
  final String name;
  final String description;
  final double price;  // Number, not String
  final String contact;
  final String location;
  final bool isAvailable;
  final String imageUrl;  // Standardized name
  final String ownerId;  // Standardized name
  
  // ... constructors, fromJson, toJson
}
```

---

## END OF SUMMARY

