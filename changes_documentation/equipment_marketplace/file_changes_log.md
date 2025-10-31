File Change Log (Cumulative)

1) backend/models/equipment.js
   - Added lines 1-59 (new file) defining `Equipment` schema.

2) backend/controllers/equipmentController.js
   - Added lines 1-160 (new file) implementing CRUD and image handling.

3) backend/routes/equipmentRoutes.js
   - Added lines 1-44 (new file) configuring multer and routes.

4) backend/index.js
   - Added import for equipmentRoutes near top (around line 20).
   - Added static serving for equipment images (around lines 93-95).
   - Mounted `/api/equipment` routes (around lines 95-96).

5) NewsCalendar/lib/screens/equipment_markeplace_screen.dart
   - Added import for utils/imports.dart (top of file).
   - Added state: `_isLoading`, `_errorMessage`, `_equipmentList`.
   - Added method `_fetchEquipment()`.
   - Replaced simulated submit with real POST to `/api/equipment`.
   - Browse tab now shows loader/error with Retry and renders `_equipmentList`.
   - Added `_currentUserId`, `_loadCurrentUser()`, `_refreshMyTools()`.
   - `My Tools` now filtered from fetched list by `ownerId`.
   - Edit uses `PUT /api/equipment/:id`; Delete uses `DELETE /api/equipment/:id`.

Documentation files added/updated:
- changes_documentation/equipment_marketplace/01_backend_model_equipment.md
- changes_documentation/equipment_marketplace/02_backend_routes_controller_equipment.md
- changes_documentation/equipment_marketplace/03_backend_index_route_mount.md
- changes_documentation/equipment_marketplace/04_frontend_equipment_screen_wiring.md
 - changes_documentation/equipment_marketplace/05_frontend_my_tools_filter_edit_delete.md


