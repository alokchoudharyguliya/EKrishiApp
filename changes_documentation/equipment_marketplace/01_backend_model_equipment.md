Title: Backend Equipment Model Added

Summary:
- Created Mongoose model `Equipment` with fields and validations per requirements.

Files changed:
- backend/models/equipment.js (added)
  - Lines 1-59: New schema with fields name, description, price (Number), contact (10 digits), location, isAvailable, imageUrl, owner (ref User), timestamps.

Notes:
- `price` stored as a single number; no currency/unit.
- `contact` validated to exactly 10 digits.
- `owner` required and references `User`.

Related tasks:
- Will be used by equipment controller and routes for CRUD.




