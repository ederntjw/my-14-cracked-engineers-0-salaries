---
topic: document-upload
date: 2026-04-08
time: 12:00
wave: 1
wave_name: Upload UI — drag-drop + file chip + preview modal
depends_on: [wave-0]
master_plan: 2026-04-08-1200-document-upload-PLAN.md
status: complete
---

## What This Wave Builds

The user-facing side of document upload. A drag-and-drop zone over the chat input, a file picker button, an attached-file chip showing the filename and a remove button, and an extension to the existing preview-and-confirm modal so it shows the redacted document text alongside the redacted prompt before sending. After this wave, a user can drop a file, see it filtered, and press send — but the document text is not yet attached to the LLM call (that's Wave 2).

## Context for a Fresh Session

Wave 0 has built the backend: `web/src/lib/extract.ts` pulls text from PDF/DOCX/TXT, `web/src/app/api/upload/route.ts` accepts a multipart upload and returns filtered text, and the existing PII filter has been extended to handle long document text. All Wave 0 tests pass.

This wave is pure frontend. Before you start, there is a pattern-research brief in the conversation context with notes from the Vercel AI Chatbot repo on how they handle drag-drop + file chips (see `components/multimodal-input.tsx` patterns). Adapt their approach into our existing chat UI — do not copy verbatim, do not import their components, do not add the AI SDK as a dependency. We're learning from how they structured it, not running their code.

Existing chat UI lives at `web/src/app/chat/` (or wherever the page component is — confirm by reading the directory). The preview-and-confirm modal already exists for chat prompts. We are extending it, not replacing it.

## Tasks

### Task 5: Drag-and-drop zone + file picker
**Files:**
- `web/src/app/chat/ChatInput.tsx` (existing — extend)
- `web/src/app/chat/ChatDropZone.tsx` (new)

**Dependencies:** Wave 0 complete

**What to do:**
- Add a drop zone wrapping the chat input area. When a user drags a file over the chat, the zone visually highlights.
- Add a paperclip button next to the send button that opens the native file picker.
- Accept only `.pdf`, `.docx`, `.txt` (set `accept` attribute and validate on drop).
- On valid drop or select, POST to `/api/upload`, show a loading state, then store the response in chat page state.
- Show a clear inline error if upload fails (size, type, extraction).

**Acceptance Criteria:**
- Given a user drags a valid file over the chat / When over the drop zone / Then the zone highlights with a clear visual indicator
- Given a user drops or picks a valid file / When the upload starts / Then a spinner appears next to the input
- Given an invalid file type / When dropped or picked / Then UI shows "PDF, Word, or TXT only"
- Given upload fails with HTTP 413 / When the response returns / Then UI shows "File too large — max 4 MB"
- Given upload succeeds / When the response returns / Then the file enters chat state ready for the chip (Task 6)

### Task 6: Attached-file chip
**Files:**
- `web/src/app/chat/AttachedFileChip.tsx` (new)
- `web/src/app/chat/ChatPage.tsx` (or equivalent — update state shape)

**Dependencies:** Task 5

**What to do:**
- Render a small chip above the input area showing `📎 filename.pdf · 124 KB`.
- Include a circular X button to remove the attachment.
- Removing clears the document state — no half-attached limbo.
- Only one attachment at a time in this wave (multi-file is deferred to Wave 3 if requested).

**Acceptance Criteria:**
- Given a file uploaded successfully / When the response returns / Then the chip appears above the input with filename and size
- Given a user clicks the X button on the chip / When clicked / Then the chip disappears and document state is cleared
- Given a user uploads a second file while one is already attached / When dropped / Then the new file replaces the old one (with a brief confirmation)

### Task 7: Extend the preview-and-confirm modal for documents
**Files:**
- existing preview-and-confirm modal component (find it via grep — likely in `web/src/app/chat/`)
- `web/src/app/chat/ChatPage.tsx` (or equivalent — pass document data to the modal)

**Dependencies:** Tasks 5, 6

**What to do:**
- When the user presses send with a file attached, the preview modal must show:
  1. The filtered prompt (already does this)
  2. A new section: "Attached document: [filename]" with a scrollable view of the **filtered** document text
  3. The redaction summary for the document (count of redactions by type)
  4. Existing Send / Cancel buttons
- Modal must clearly distinguish original vs filtered for the document text (same UX pattern as the existing prompt preview).
- Cancel must abort cleanly — nothing reaches the LLM, document stays attached for retry.

**Acceptance Criteria:**
- Given a user sends a prompt with a file attached / When the send button is pressed / Then the modal shows BOTH the filtered prompt AND the filtered document text
- Given the modal is open / When the user clicks Cancel / Then nothing is sent and the file remains attached
- Given the document had redactions / When the modal renders / Then the redaction summary shows count by type (e.g., "2 phone numbers, 1 IBAN, 3 bank names redacted")
- Given a document with no redactions / When the modal renders / Then it shows "No PII detected" clearly

## Boundaries (DO NOT CHANGE)

- **Do not import any third-party file-upload library.** Native HTML drag-drop + fetch is enough.
- **Do not change the existing preview modal contract for chat-only prompts.** Extend it, don't replace it.
- **Do not call the LLM yet.** Wave 1 ends with the document filtered and previewed, but pressing Send in this wave should NOT yet include the document text in the chat API call. That happens in Wave 2.
- **Single file at a time.** Multi-file is out of scope.
- **No styling overhaul.** Match the existing chat UI's look and feel exactly. Tailwind classes only, same color palette, same spacing scale.
- **RTL must keep working** — the drop zone and chip must flip correctly when Arabic mode is on.

## Files Touched in This Wave

- `web/src/app/chat/ChatInput.tsx` (extend)
- `web/src/app/chat/ChatDropZone.tsx` (new)
- `web/src/app/chat/AttachedFileChip.tsx` (new)
- `web/src/app/chat/ChatPage.tsx` (extend state)
- existing preview-and-confirm modal component (extend)
- new component tests as appropriate
