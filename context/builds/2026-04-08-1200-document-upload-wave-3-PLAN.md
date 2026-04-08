---
topic: document-upload
date: 2026-04-08
time: 12:00
wave: 3
wave_name: Polish + edge cases — errors, token budget, E2E
depends_on: [wave-0, wave-1, wave-2]
master_plan: 2026-04-08-1200-document-upload-PLAN.md
status: complete
---

## What This Wave Builds

The polish layer that turns a working feature into a board-demo-ready feature. Clear error messages for every failure path, a visible token-budget warning when documents are truncated, and a Playwright end-to-end test that proves the whole flow works from drag to AI response. After this wave, the feature ships.

## Context for a Fresh Session

Waves 0-2 built the full document upload feature: extraction, filter, upload route, drag-drop UI, file chip, preview modal extension, sticky context across turns, message badges. Everything works on the happy path. This wave hardens the unhappy paths and adds the test that proves it.

The app uses Vitest for unit tests. If Playwright is not yet installed, install it as a dev dependency in this wave (it's a minimal addition and Wave 0's test fixtures can be reused).

## Tasks

### Task 11: Error handling — every failure path
**Files:**
- `web/src/app/chat/ChatPage.tsx`
- `web/src/app/chat/ChatDropZone.tsx`
- new `web/src/app/chat/UploadErrorToast.tsx` if a toast component doesn't already exist

**Dependencies:** Wave 2 complete

**What to do:**
- Add clear, friendly error messages for every failure path:
  - Unsupported file type → "PDF, Word, or TXT files only"
  - File too large → "File too large — max 4 MB"
  - Extraction failed (corrupt PDF) → "Couldn't read this document. Try saving it as PDF again, or paste the text directly."
  - Empty extraction (scanned PDF) → "No text found — this looks like a scanned image. Scanned documents aren't supported yet."
  - Filter rejected the doc (defense-in-depth catch from Task 8) → "This document contains sensitive data we couldn't safely filter. Please review and remove it manually."
  - LLM timeout / network error → "The AI took too long to respond. Try again in a moment."
- All errors must be dismissible and never block the chat from continuing.
- Errors must not leak server-side details (stack traces, paths, internal field names).

**Acceptance Criteria:**
- Given each failure path above / When triggered / Then the user sees the exact friendly message specified
- Given an error toast is showing / When the user clicks dismiss / Then it disappears and the chat is still usable
- Given any error / When inspected in the browser network tab / Then no stack traces or internal paths leak in the response body

### Task 12: Token budget warning in the preview modal
**Files:**
- existing preview-and-confirm modal component
- `web/src/app/chat/ChatPage.tsx` (pass `truncated` flag through)

**Dependencies:** Task 11

**What to do:**
- If `truncated: true` came back from `/api/upload`, show a visible yellow warning banner in the preview modal: `"⚠ Large document — only the first ~30 pages were sent to the AI. The rest was cut to fit the AI's reading limit."`
- Banner must be impossible to miss (top of modal, distinct background color).
- Banner is dismissible only by the user proceeding or canceling.

**Acceptance Criteria:**
- Given a document was truncated at upload / When the preview modal opens / Then the warning banner is visible at the top
- Given a document was NOT truncated / When the preview modal opens / Then no banner appears
- Given the banner is showing / When the user presses Send / Then the document still sends (truncation is a warning, not a block)

### Task 13: Playwright E2E test for the full flow
**Files:**
- `web/tests/e2e/document-upload.spec.ts` (new)
- `web/tests/fixtures/sample.pdf` (new — small synthetic test fixture)
- `web/playwright.config.ts` (new if Playwright not yet installed)
- `web/package.json` (add `@playwright/test` if not present)

**Dependencies:** Tasks 11, 12

**What to do:**
- Install Playwright if not already in the project. Minimal config — Chromium only is fine for Phase 0.
- Write one E2E test that exercises the full user journey:
  1. Log in with the demo password
  2. Drop a small fixture PDF into the chat
  3. Verify the chip appears with the correct filename
  4. Type a prompt: `"What is this document about?"`
  5. Press Send
  6. Verify the preview-and-confirm modal opens with the filtered document
  7. Click Send in the modal
  8. Verify a response from the AI appears in the chat
  9. Verify the user message has the filename badge
  10. Send a follow-up: `"Translate the summary to Arabic"`
  11. Verify a second response appears (proves stickiness from Wave 2)
- Use a tiny hand-crafted PDF fixture (one paragraph of fake business content with one fake phone number to verify filtering).

**Acceptance Criteria:**
- Given the test runs against the dev server / When all steps execute / Then all assertions pass
- Given the test runs in CI / When triggered / Then it completes in under 60 seconds
- Given the fixture PDF contains a fake phone number / When filtered / Then the response in the chat does not contain that phone number anywhere

## Boundaries (DO NOT CHANGE)

- **Do not add OCR.** Scanned PDF support is explicitly out of scope for Phase 0.
- **Do not add a retry mechanism for LLM failures.** A single clear error message is enough.
- **Do not add multi-file support.** One file at a time, period, in Phase 0.
- **Do not add a document history or "recently uploaded" list.** Out of scope.
- **Playwright config must be minimal.** No screenshot diffing, no visual regression, no video recording — just functional E2E.

## Files Touched in This Wave

- `web/src/app/chat/ChatPage.tsx` (extend)
- `web/src/app/chat/ChatDropZone.tsx` (extend)
- `web/src/app/chat/UploadErrorToast.tsx` (new — if no existing toast)
- existing preview-and-confirm modal (extend)
- `web/tests/e2e/document-upload.spec.ts` (new)
- `web/tests/fixtures/sample.pdf` (new)
- `web/playwright.config.ts` (new if needed)
- `web/package.json` (add Playwright if needed)
