---
topic: document-upload
date: 2026-04-08
time: 12:00
wave: 0
wave_name: Foundation — extraction + filter integration
depends_on: []
master_plan: 2026-04-08-1200-document-upload-PLAN.md
status: complete
---

## What This Wave Builds

Pure backend foundation: the ability to take a PDF, Word, or text file, pull clean text out of it, run the existing PII filter on that text, and return the filtered result. No UI in this wave — just the server plumbing and tests. If this wave lands clean, every later wave is just wiring and polish.

## Context for a Fresh Session

SIMAH AI Search Control is a Next.js 16 + React 19 + TypeScript chat app for a Saudi financial company (Qarar/SIMAH). The core feature is a PII filter at `web/src/lib/filter.ts` that runs regex + a KSA bank dictionary + Arabic normalization on all prompts before they reach the LLM (Groq-hosted Qwen 3 32B via OpenAI-compatible endpoint at `web/src/lib/llm.ts`). Responses are buffered (not streamed) so the filter can run on the full output before the user sees anything. Chat lives at `web/src/app/api/chat/route.ts`. There is a preview-and-confirm modal that shows the user the redacted version of their prompt before it is sent. The app is deployed on Vercel; Phase 1 will self-host on Qarar's KSA infrastructure.

This wave adds document upload. We are on **Path C** — stay custom, borrow extraction patterns from LibreChat. Before you start building, there is a pattern-research brief in the conversation context with notes on how LibreChat handles PDF/DOCX extraction. Adapt those patterns into our own code. Do not add heavy dependencies like vector databases or RAG frameworks.

## Tasks

### Task 1: Text extraction module
**Files:**
- `web/src/lib/extract.ts` (new)
- `web/package.json` (add `pdf-parse` and `mammoth` as dependencies)

**Dependencies:** none

**What to do:**
- Install `pdf-parse` (for PDFs) and `mammoth` (for .docx).
- Create `extract.ts` exporting `extractText(file: Buffer, mimeType: string, filename: string): Promise<ExtractResult>`.
- `ExtractResult` should include `{ text: string; pageCount?: number; truncated: boolean; warning?: string }`.
- Handle `.pdf`, `.docx`, `.txt` as first-class. Reject other types with a clear error.
- Use the patterns from the LibreChat research brief for PDF page iteration and DOCX text joining.

**Acceptance Criteria:**
- Given a valid .docx buffer / When `extractText()` is called / Then it returns the full body text as a string with `truncated: false`
- Given a valid .pdf buffer / When extraction runs / Then it returns text from all pages plus `pageCount`
- Given a valid .txt buffer / When extraction runs / Then it returns the raw text
- Given an unsupported mime type / When called / Then it throws `UnsupportedFileTypeError` with a clear message listing allowed types
- Given a corrupted PDF / When extraction fails / Then it throws `ExtractionFailedError` with the underlying reason
- Given a scanned PDF that produces no text / When extraction runs / Then it returns `{ text: '', warning: 'No text found — is this a scanned image?' }`

### Task 2: Upload API route
**Files:**
- `web/src/app/api/upload/route.ts` (new)

**Dependencies:** Task 1

**What to do:**
- Create a `POST` handler that accepts `multipart/form-data` with a `file` field.
- Enforce a 4MB size limit before extraction. Return HTTP 413 with a clear error if exceeded.
- Call `extractText()` from Task 1.
- Call the existing PII filter from `web/src/lib/filter.ts` on the extracted text.
- Write an audit log entry via `web/src/lib/audit.ts` (new event type: `document_uploaded`).
- Return JSON: `{ originalText, filteredText, redactionSummary, truncated, warning?, filename, mimeType }`.
- Require authentication (same cookie gate as `/api/chat`).

**Acceptance Criteria:**
- Given a valid .pdf uploaded / When the route runs / Then response includes `filteredText` and `redactionSummary`
- Given a file over 4MB / When upload attempted / Then returns HTTP 413 with a JSON error
- Given an unsupported file type / When uploaded / Then returns HTTP 415 with a clear error
- Given extraction fails / When the route runs / Then returns HTTP 422 with a clear error
- Given a request with no auth cookie / When called / Then returns HTTP 401
- Given any successful or failed upload / When the route finishes / Then an audit log entry is written

### Task 3: Filter integration for long document text
**Files:**
- `web/src/lib/filter.ts` (extend only — do not refactor existing behavior)
- `web/src/lib/extract.ts` (add token budget guard)

**Dependencies:** Task 1

**What to do:**
- Add a `MAX_DOCUMENT_CHARS` constant (start at 100000 — roughly 25k tokens, leaves headroom for the prompt + response in Qwen 3's 32k window).
- In `extract.ts`, if extracted text exceeds the limit, truncate and set `truncated: true` with a warning message.
- Verify the existing filter handles multi-page text correctly. Add any needed adjustments to regex anchors or dictionary matching so that document-length input works the same as chat-length input. No behavior changes for existing chat prompts.

**Acceptance Criteria:**
- Given a 50-page PDF extracting to ~40k chars / When filtered / Then all known PII patterns (NID, IBAN, phone, email, SAR amounts, KSA bank names, Arabic variants) are redacted across the full text
- Given a 200-page PDF extracting to ~250k chars / When processed / Then text is truncated at the limit with `truncated: true` and a visible warning
- Given an existing chat prompt / When filtered / Then behavior is unchanged from before this wave (regression check)

### Task 4: Unit tests
**Files:**
- `web/src/lib/__tests__/extract.test.ts` (new)
- `web/src/lib/__tests__/filter-doc.test.ts` (new)
- `web/src/lib/__tests__/fixtures/` (new — sample files for tests)

**Dependencies:** Tasks 1, 2, 3

**What to do:**
- Write unit tests covering extraction for each file type (PDF, DOCX, TXT).
- Write tests covering the filter on document-length input (PII in long English, PII in long Arabic, PII in code-switched text, oversized input truncation, scanned-PDF empty case).
- Include small synthetic fixtures in `fixtures/` (hand-crafted, not real client data).
- Aim for 12+ new passing tests. Do not modify existing filter tests.

**Acceptance Criteria:**
- Given `npm test` is run / When all tests execute / Then 12+ new tests pass and 0 existing tests regress
- Given a fixture PDF with a known NID and phone number / When extracted and filtered / Then both PII patterns are redacted
- Given a fixture DOCX in mixed Arabic and English with a KSA bank name / When filtered / Then the bank name is redacted in both scripts

## Boundaries (DO NOT CHANGE)

- **Do not touch `web/src/app/api/chat/route.ts` in this wave.** Wiring documents into chat happens in Wave 2.
- **Do not change existing filter behavior for chat prompts.** Only extend for documents.
- **No UI changes.** This wave is backend-only.
- **No new dependencies beyond `pdf-parse` and `mammoth`.** If you think you need something else, stop and ask.
- **No document storage.** Process in memory, return, done. No disk, no database, no blob.
- **Keep Arabic normalization intact** (alef variants, ya/alef-maqsura, tatweel, diacritics).

## Files Touched in This Wave

- `web/src/lib/extract.ts` (new)
- `web/src/lib/filter.ts` (extend)
- `web/src/lib/audit.ts` (add new event type only)
- `web/src/app/api/upload/route.ts` (new)
- `web/src/lib/__tests__/extract.test.ts` (new)
- `web/src/lib/__tests__/filter-doc.test.ts` (new)
- `web/src/lib/__tests__/fixtures/*` (new)
- `web/package.json` (add 2 dependencies)
- `web/package-lock.json` (auto-updated)
