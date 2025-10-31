Title: Frontend - My Tools Filter and Edit/Delete Integration

Summary:
- Filtered "My Tools" from fetched equipment using current user ID.
- Implemented edit (PUT) and delete (DELETE) endpoints with auth.

Files changed:
- NewsCalendar/lib/screens/equipment_markeplace_screen.dart (edited)
  - State: added `_currentUserId`; converted `_myTools` to dynamic; removed hardcoded lists.
  - Init: load current user via `UserService.getUserId()` then fetch equipment.
  - Added `_loadCurrentUser()` and `_refreshMyTools()` helpers.
  - After GET load, call `_refreshMyTools()`.
  - Dialog submit: conditionally `POST /api/equipment` or `PUT /api/equipment/:id` with multipart; update list and refresh my tools.
  - Delete: call `DELETE /api/equipment/:id` with auth, update lists and refresh my tools.
  - Browse tab: compute `isMyTool` by comparing `ownerId` with `_currentUserId`; show 'Your Tool' badge if true.

Impact:
- Users see their own items under "My Tools" automatically.
- Edit/Delete operations now hit backend with owner checks.


