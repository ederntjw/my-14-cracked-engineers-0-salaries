---
topic: document-upload
date: 2026-04-08
wave: 2
wave_name: Document-aware conversation — sticky context across turns
plan_file: 2026-04-08-1200-document-upload-wave-2-PLAN.md
status: complete
verdict: CLEAN
---

# Wave 2 Result — Document Context Wired Into Chat

## Reconciliation

| Task | Status | Notes |
|------|--------|-------|
| 8 — Wire document text into /api/chat | ✅ Built as planned | New optional `documentContext` field on the request schema (Zod). When present, prepended as a SECOND system message (after the primary system prompt). Defense-in-depth re-filter rejects requests where obviously sensitive patterns slip through. Audit log records `documentFilename` so Compliance can see which documents were used in which conversations. |
| 9 — Sticky document across turns | ✅ Built as planned | The frontend ships `documentContext` on EVERY chat request as long as `attachedFile` is in state. Removing the chip clears it. "New chat" clears both messages and the attached file. |
| 10 — Visual indicator on messages with attachments | ✅ Built as planned | `MessageBubble` now renders a small paperclip + filename pill under user messages that were sent with a doc attached. Stored in `Message.attachedFilename` so the indicator survives a localStorage rehydrate. Pill respects RTL via the existing parent `dir` attribute. |

## 7-Check Verification

| # | Check | Status | Evidence |
|---|-------|--------|----------|
| 1 | BUILD | ✅ PASS | `pnpm build` → `Compiled successfully`. Both `/api/chat` and `/api/upload` build. |
| 2 | TEST | ✅ PASS | `pnpm test` → 24/24 passing. No regressions. |
| 3 | LINT | ✅ PASS (Wave 2 scope) | `tsc --noEmit` → 0 errors. `pnpm lint` → 1 pre-existing error in `admin/page.tsx`. Zero new lint errors from Wave 2. |
| 4 | FUNCTIONALITY | ✅ PASS | Chat now includes document context on every turn the user has a file attached. Defense-in-depth re-filter active. Filename badge renders on user bubbles. Sticky behavior verified by code path inspection (no per-turn "did the user attach this turn?" check — the existence of `attachedFile` is the only condition). |
| 5 | ARCHITECT | ✅ PASS | All changes confined to `web/src/app/api/chat/route.ts` (extended) and `web/src/components/Chat.tsx` (extended). No new files. No refactors. The system prompt format ("--- DOCUMENT START / END ---" sentinels) is the lightest workable scaffolding for the LLM to recognize the doc as a separate input. |
| 6 | TODO | ✅ PASS | Zero TODO/FIXME/HACK in any modified code. |
| 7 | ERROR_FREE | ✅ PASS | New 400 error path: `document_context_unsafe` returned when defense-in-depth re-filter catches anything. Existing chat error paths unchanged. |

Self-healing cycles: 0
Issues fixed internally: none

## What's Working Now

The full happy path is live (still on local dev — Vercel deploy is manual):
1. Drop a PDF onto the chat
2. See it filtered + previewed
3. Send a question — the AI gets the document AND the question, returns a useful answer
4. Ask a follow-up — the AI still has the document, no re-upload needed
5. The user message bubbles show a 📎 badge with the filename
6. Click "New chat" → document AND history clear
7. Click X on the chip → document clears, future questions go without it

## Files Touched (Wave 2)

| File | Change | Notes |
|------|--------|-------|
| `web/src/app/api/chat/route.ts` | Extended | + `DocumentContextSchema`, + defense-in-depth re-filter, + system message construction with `--- DOCUMENT START / END ---` sentinels, + audit log filename. |
| `web/src/components/Chat.tsx` | Extended | + `attachedFilename` on `Message`, + `documentContext` on the chat fetch, + paperclip badge inside `MessageBubble`. |

## What's Next

**Wave 3 — Polish + edge cases.** Three tasks: tighten error messages, surface the truncation warning in the modal, write a Playwright E2E test. I'm continuing straight into it in this session.

Verdict: **CLEAN — Wave 2 done. Continuing immediately to Wave 3.**
