# Fix: CircularProgressIndicator Closing Logic

## Issue Identified
The CircularProgressIndicator dialog was closing immediately after receiving the API response (line 668-672), before verifying if the response was successful. This could cause the dialog to remain open if there were issues with response parsing.

## Backend Response Format (Confirmed)
- **Create Equipment**: `{ success: true, data: equipment }` with status `201`
- **Update Equipment**: `{ success: true, data: saved }` with status `200`

## Solution
Move the dialog closing logic to AFTER the response validation is complete, ensuring it only closes when:
1. Response has valid status code (200 or 201)
2. Response has `success: true`
3. Response data exists and is accessible

## Files to Change
- `NewsCalendar/lib/screens/equipment_markeplace_screen.dart`

## Changes Required
1. Remove dialog closing from lines 668-672 (before response validation)
2. Add dialog closing AFTER successful response validation (after line 678, before line 679)
3. Ensure dialog also closes in error cases (already handled at lines 725-728)

