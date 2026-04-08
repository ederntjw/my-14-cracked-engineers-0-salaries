---
topic: document-upload
date: 2026-04-08
time: 12:00
wave: 2
wave_name: Document-aware conversation — sticky context across turns
depends_on: [wave-0, wave-1]
master_plan: 2026-04-08-1200-document-upload-PLAN.md
status: complete
---

## What This Wave Builds

Wires the attached document into the actual LLM conversation. After this wave, a user can drop a PDF, ask "summarize the key risks", get an answer, then ask "now translate the summary to Arabic" — and the AI still has the document context without the user re-uploading. The document stays sticky for the entire conversation until the user removes it or starts a new chat.

## Context for a Fresh Session

Wave 0 built the backend extraction + filter pipeline. Wave 1 built the upload UI, file chip, and extended preview modal — but pressing Send in Wave 1 does NOT yet include document text in the LLM call. This wave closes that gap.

The chat API lives at `web/src/app/api/chat/route.ts`. It already accepts a `messages` array (the conversation history) and runs filter → LLM → output filter → audit. Frontend chat state lives in `web/src/app/chat/ChatPage.tsx` (or equivalent).

The contract: when a document is attached, the frontend includes a `documentContext` field on every chat request until the user removes the file. The server prepends this context to the LLM messages as a system note. Filtering already happened at upload time, so we use the `filteredText` we already have — we do NOT re-filter on every turn.

## Tasks

### Task 8: Wire document text into the chat API
**Files:**
- `web/src/app/api/chat/route.ts` (extend)
- `web/src/lib/llm.ts` (touch only if message construction lives there)

**Dependencies:** Wave 1 complete

**What to do:**
- Extend the chat API request schema to accept an optional `documentContext: { filename: string; filteredText: string }`.
- When present, prepend a system message to the LLM call: `"The user has attached a document named '{filename}'. The full filtered content follows:\n\n{filteredText}"`.
- Validate the field — the `filteredText` must already be filtered (it was, at upload time). Do NOT re-run the filter (wasted compute) but DO sanity-check that no obvious PII patterns slipped through (defense in depth).
- Extend the audit log entry for chat to record `document_attached: true` and the filename.

**Acceptance Criteria:**
- Given a chat request with `documentContext` / When sent to the LLM / Then the system prompt contains the document text
- Given a chat request without `documentContext` / When sent to the LLM / Then behavior is unchanged from before this wave
- Given a chat request with a document attached / When the audit log is written / Then it records `document_attached` and the filename
- Given a `documentContext.filteredText` containing an obvious PII pattern (defense-in-depth check fails) / When the route runs / Then it returns HTTP 400 with a clear error

### Task 9: Sticky document across conversation turns
**Files:**
- `web/src/app/chat/ChatPage.tsx` (extend state)

**Dependencies:** Task 8

**What to do:**
- Store the attached document (filename + filteredText + redactionSummary) in chat page state.
- Every chat request automatically includes `documentContext` from state until the user removes the chip.
- "New chat" button (existing) clears the document along with the conversation history.
- The chip stays visible for the entire conversation while the document is attached, so the user always knows the AI has it in context.

**Acceptance Criteria:**
- Given a user attaches a document and asks a question / When they ask a follow-up / Then the second request also includes the document context (verify in network tab)
- Given a user removes the document chip mid-conversation / When they ask the next question / Then the request does NOT include document context
- Given a user clicks "New chat" / When clicked / Then both conversation history AND attached document are cleared
- Given the chip is visible / When the user looks at the UI / Then it is always clear which document is currently in context

### Task 10: Visual indicator on messages with attachments
**Files:**
- `web/src/app/chat/ChatMessage.tsx` (or equivalent message component)
- `web/src/app/chat/ChatPage.tsx` (track per-message attachment state)

**Dependencies:** Task 9

**What to do:**
- When a user message is sent with a document attached, render a small `📎 filename.pdf` badge under the message bubble in the chat history.
- The badge is informational only — clicking it does nothing in this wave (could open the doc in a future wave).
- Badge respects RTL — flips to the correct side when Arabic mode is on.

**Acceptance Criteria:**
- Given a prompt was sent with a document attached / When rendered in the chat history / Then the user message shows a filename badge
- Given a prompt was sent without a document / When rendered / Then no badge appears
- Given Arabic mode is on / When the badge renders / Then it appears on the correct side (mirrored)

## Boundaries (DO NOT CHANGE)

- **Do not re-run extraction on every turn.** The text was extracted and filtered once at upload. Reuse it.
- **Do not store documents server-side between requests.** Frontend ships the context with each request — same pattern as the existing session memory.
- **Do not change how the existing chat history is shipped.** Document context is a separate field, additive to the existing `messages` array.
- **The existing 50-turn hard cap on chat history still applies.** Document context does NOT count against the turn cap, but the truncation guard from Wave 0 still caps the document text size.
- **Do not add a "view document" button or any document inspection UI.** Out of scope.

## Files Touched in This Wave

- `web/src/app/api/chat/route.ts` (extend)
- `web/src/lib/audit.ts` (extend chat event type)
- `web/src/app/chat/ChatPage.tsx` (extend state)
- `web/src/app/chat/ChatMessage.tsx` (add badge)
- chat API tests (extend if they exist)
