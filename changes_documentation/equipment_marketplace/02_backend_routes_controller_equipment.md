Title: Backend Equipment Routes and Controller

Summary:
- Added equipment controller with CRUD and image handling.
- Added equipment routes with multer storage to `uploads/equipment`.
- Mounted routes and static serving in `backend/index.js`.

Files changed:
- backend/controllers/equipmentController.js (added)
  - Lines 1-8: Imports and helper to build image URL.
  - Lines 10-47: `createEquipment` with validations (price number, 10-digit contact), owner from `req.user`, image handling.
  - Lines 50-66: `listEquipment` with pagination and total count.
  - Lines 68-77: `getEquipmentById`.
  - Lines 80-131: `updateEquipment` with ownership check, optional image replace and cleanup.
  - Lines 133-157: `deleteEquipment` with ownership check and image cleanup.

- backend/routes/equipmentRoutes.js (added)
  - Lines 1-7: Imports and router setup.
  - Lines 10-23: Multer disk storage to `uploads/equipment` and filename strategy.
  - Lines 25-28: File filter (images only).
  - Lines 30-41: Public GET routes and protected POST/PUT/DELETE routes.

- backend/index.js (edited)
  - Import: added `const equipmentRoutes = require('./routes/equipmentRoutes.js');` near other route imports.
  - Mount: added `app.use('/api/equipment', equipmentRoutes);` after irrigation routes.
  - Static: added `app.use('/equipment', express.static(path.join(__dirname, 'uploads', 'equipment')));` to serve image files.

Notes:
- Public read access; create/update/delete require auth via `authMiddleware`.
- Image URLs returned as `http(s)://<host>/equipment/<filename>`.

Title: Backend Equipment Routes and Controller Added

Summary:
- Added controller with CRUD for equipment and image handling.
- Added routes with Multer (uploads to `uploads/equipment`) and auth protection for write ops.
- Mounted routes and static file serving in `index.js`.

Files changed:
- backend/controllers/equipmentController.js (added)
  - Lines 1-160: Controller with `createEquipment`, `listEquipment`, `getEquipmentById`, `updateEquipment`, `deleteEquipment`. Builds `imageUrl` as `/equipment/<filename>` absolute URL.
- backend/routes/equipmentRoutes.js (added)
  - Lines 1-43: Express router, Multer disk storage to `uploads/equipment`, file filter for images, CRUD routes. `POST/PUT/DELETE` use `authMiddleware`.
- backend/index.js (modified)
  - Around line 20: `const equipmentRoutes = require('./routes/equipmentRoutes.js');`
  - Around lines 93-96: `app.use('/equipment', express.static(...))` and `app.use('/api/equipment', equipmentRoutes);`

API endpoints:
- GET `/api/equipment` (public, pagination via `page`, `limit`)
- GET `/api/equipment/:id` (public)
- POST `/api/equipment` (auth, multipart `image` optional)
- PUT `/api/equipment/:id` (auth, multipart `image` optional)
- DELETE `/api/equipment/:id` (auth)

Validations:
- `price` must be non-negative number
- `contact` must be exactly 10 digits
- `owner` enforced from token (`req.user.id`)


