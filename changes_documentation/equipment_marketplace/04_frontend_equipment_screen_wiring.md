Title: Frontend Equipment Screen Wiring (GET with Loader/Retry, POST with Image)

Summary:
- Added networking to fetch equipment list from backend with loader and retry.
- Implemented multipart POST to create equipment with optional image and auth token.

Files changed:
- NewsCalendar/lib/screens/equipment_markeplace_screen.dart (edited)
  - Import: added `package:newscalendar/utils/imports.dart` for `BASE_URL` and `AuthService`.
  - State: added `_isLoading`, `_errorMessage`, `_equipmentList`.
  - Init: call `_fetchEquipment()` in `initState`.
  - New method: `_fetchEquipment()` performs `GET $BASE_URL/api/equipment` and populates `_equipmentList`.
  - Dialog submission: replaced simulated submission with real `POST $BASE_URL/api/equipment` using Dio, multipart, and `Authorization: Bearer <token>` if available.
  - UI: Browse tab shows loader, error with Retry button, or list from `_equipmentList`; price rendered with `₹` prefix.

Line-level highlights (approximate due to file size):
- Added imports near top.
- Added state fields after `_tabController` declaration.
- Added `_fetchEquipment` method near other helpers.
- Replaced simulated submit block inside dialog `onPressed` with actual API call and list insertion.
- Reworked Browse tab body to conditionally render loader/error/retry or list.


