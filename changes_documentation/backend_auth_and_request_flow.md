## Backend Authentication and Request Flow

### Overview
- This document summarizes how JWT tokens are issued and validated, and how HTTP and WebSocket requests flow through the backend.
- Key files: `backend/index.js`, `backend/routes/userRoutes.js`, `backend/controllers/userControllers.js`, `backend/utils/auth.js`, `backend/routes/equipmentRoutes.js`, `backend/controllers/equipmentController.js`.

### Token lifecycle (JWT)
1. Token issuance
   - On signup (`POST /signup`) and login (`POST /login`), the backend issues a JWT signed with `process.env.JWT_SECRET` containing `{ id, email }`.
   - Source: `backend/controllers/userControllers.js`

2. Token verification (endpoint)
   - `POST /verify-token` expects `Authorization: Bearer <token>` and verifies it, returning the corresponding user (without password fields).
   - Source: `backend/controllers/userControllers.js` → `exports.verifyToken`

3. Token verification (middleware)
   - Current state: `backend/utils/auth.js` is a no-op; verification code is commented out. Protected routes relying on `req.user` will not receive user info unless this middleware is implemented.
   - Expected behavior: Extract `Authorization` header, verify the token, set `req.user = decoded`, call `next()`; otherwise return `401`.

### Password handling
- `backend/models/user.js` hashes passwords with bcrypt on save.
- `backend/controllers/userControllers.js` currently compares `password === user.password` on login and should be updated to use `user.comparePassword(password)` for secure verification.

### HTTP request flow
1. Express setup and middleware
   - `backend/index.js` sets up JSON parsing, URL-encoded parsing, CORS, file upload handling, and mounts routes.
   - CORS allows `Authorization` header and common methods.

2. Route mounting
   - Users: `app.use(userRoutes)`
   - Files: `app.use(fileRoutes)`
   - Events: `app.use(eventRoutes)`
   - WebRTC: `app.use('/api/webrtc', webrtcRoutes)`
   - AI: `app.use('/api/ai', aiRoutes)`
   - Irrigation: `app.use('/api/irrigation', irrigationRoutes)`
   - Equipment: static image serving `app.use('/equipment', express.static(...))`, API under `app.use('/api/equipment', equipmentRoutes)`

3. Protected routes expectation
   - `backend/routes/equipmentRoutes.js` protects `POST /`, `PUT /:id`, `DELETE /:id` with `authMiddleware` and uses multipart upload for `image`.
   - Controllers (e.g., `createEquipment`) require `req.user.id` as `owner`. If `authMiddleware` doesn’t set `req.user`, the request will be rejected with `401`.

4. Equipment controller highlights
   - Create: Validates input, builds `imageUrl` from request host, persists `Equipment` with `owner` from `req.user.id`.
   - List: Pagination with `page`, `limit`; returns `{ data, page, limit, total }`.
   - Update/Delete: Enforces ownership (`existing.owner === req.user.id`), handles image replacement/removal on disk.

### WebSocket request flow
1. Server initialization
   - `backend/index.js` creates an HTTP server and attaches a WebSocket server (`ws`).

2. Authentication (current state)
   - The connection handler currently verifies a hard-coded token instead of reading the client’s `Authorization` header.
   - Expected behavior: Read `Authorization: Bearer <token>` from `req.headers` (or via subprotocol/query), verify with `JWT_SECRET`, and associate `userId` with the WS connection.

3. Messaging
   - Handles stream-related actions (`join-stream`, `offer`, `answer`, `ice-candidate`) and event CRUD via WS (`createEvent`, `updateEvent`, `deleteEvent`).
   - Broadcasts events to connected, authenticated clients.

### What works now
- JWT issuance at signup/login.
- Token verification via `POST /verify-token`.
- Public equipment endpoints: `GET /api/equipment` and `GET /api/equipment/:id`.
- Static serving of equipment images at `/equipment/*`.
- MongoDB connection and server startup.

### Gaps to address
1. Implement `authMiddleware` (`backend/utils/auth.js`) to verify Bearer tokens and populate `req.user`.
2. Replace plaintext password comparison in login with bcrypt compare (`user.comparePassword`).
3. Remove hard-coded WebSocket token; verify from the incoming request (header/subprotocol/query).

### Frontend integration notes
- Send `Authorization: Bearer <jwt>` header for all protected HTTP requests.
- For equipment create/update with an image:
  - Use `multipart/form-data`; field name for the image is `image`.
  - Include other fields as standard form fields (`name`, `price`, `contact`, `location`, `isAvailable`).
- For WebSocket authentication:
  - Provide the JWT on connect via `Authorization` header (if the client supports it) or via subprotocol/query param, and update the server to read/verify it.

### Environment variables
- `MONGODB_URI`: MongoDB connection string.
- `JWT_SECRET`: Secret for signing/verifying JWTs.
- `BASE_URL`: Used for constructing public URLs (e.g., uploaded images, profile photos).

### Suggested code adjustments (high level)
1. `backend/utils/auth.js`
   - Parse `Authorization` header, verify with `jwt.verify`, assign `req.user`, handle errors with `401`.

2. `backend/controllers/userControllers.js`
   - In `postLogIn`, replace equality check with `await user.comparePassword(password)`.

3. `backend/index.js` (WebSocket)
   - Replace hard-coded token with extraction from `req.headers['authorization']` and call `jwt.verify`.

These changes will make token-protected routes and WebSocket authentication work end-to-end.


