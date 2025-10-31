Title: Backend index.js Route Mounts and Static Serving

Summary:
- Mounted equipment routes under `/api/equipment`.
- Exposed static equipment image serving under `/equipment`.

Files changed:
- backend/index.js (edited)
  - Around line 20: `const equipmentRoutes = require('./routes/equipmentRoutes.js');`
  - Around lines 93-96: `app.use('/api/equipment', equipmentRoutes);`
  - Around lines 93-95: `app.use('/equipment', express.static(path.join(__dirname, 'uploads', 'equipment')));`

Impact:
- Frontend can fetch items at `GET /api/equipment` and render images from `/equipment/<filename>`.




