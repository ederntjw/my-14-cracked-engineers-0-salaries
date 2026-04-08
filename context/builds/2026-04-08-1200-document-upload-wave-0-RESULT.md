---
topic: document-upload
date: 2026-04-08
wave: 0
wave_name: Foundation — extraction + filter integration
plan_file: 2026-04-08-1200-document-upload-wave-0-PLAN.md
status: complete
verdict: CLEAN with one CRITICAL pre-existing finding to escalate
---

# Wave 0 Result — Document Upload Foundation

## Reconciliation

| Task | Status | Notes |
|------|--------|-------|
| 1 — Text extraction module (`extract.ts`) | ✅ Built as planned | Uses `pdf-parse` v2 (class API), `mammoth.extractRawText`. Detects octet-stream by extension fallback. |
| 2 — `/api/upload` route | ✅ Built as planned | Multipart `formData()`, 4 MB cap, auth cookie, audit hook, returns filtered text only. |
| 3 — Filter integration / token budget | ✅ Built as planned | `MAX_DOCUMENT_CHARS = 100_000` lives in `extract.ts` (cleaner than touching `filter.ts`). Existing filter behavior unchanged — verified by regression tests. |
| 4 — Unit tests | ✅ Built — 13 new tests pass | Plus 1 `it.todo` documenting the IBAN bug below. |

## 7-Check Verification

| # | Check | Status | Evidence |
|---|-------|--------|----------|
| 1 | BUILD | ✅ PASS | `pnpm build` → `Compiled successfully in 2.2s`. `/api/upload` appears in route list. |
| 2 | TEST | ✅ PASS | `pnpm test` → `2 files passed, 23 passed, 1 todo`. |
| 3 | LINT | ✅ PASS (for Wave 0 files) | `npx tsc --noEmit` → 0 errors. `pnpm lint` → 2 errors, both in pre-existing files (`admin/page.tsx`, `components/Chat.tsx`) confirmed via `git stash` to exist on `main` BEFORE Wave 0. Zero new lint errors introduced. |
| 4 | FUNCTIONALITY | ✅ PASS | Every Wave 0 acceptance criterion has a corresponding passing test. PDF/DOCX/TXT extraction, mime-type detection with extension fallback, document budget truncation, error classes (`UnsupportedFileTypeError`, `ExtractionFailedError`), scanned-PDF empty-text warning, regression check on existing filter behavior. |
| 5 | ARCHITECT | ✅ PASS | All changes confined to: `web/src/lib/extract.ts` (new), `web/src/lib/__tests__/*` (new), `web/src/app/api/upload/route.ts` (new), `web/vitest.config.ts` (new), `web/src/lib/audit.ts` (extended — additive only, all new fields optional, backward compatible with existing `record()` callers in `/api/chat`), `web/package.json` (test scripts + deps). One justified deviation: token-budget constant lives in `extract.ts` not `filter.ts` because the filter has no concept of "documents" and the budget is an extraction-time concern. |
| 6 | TODO | ✅ PASS | `grep TODO\|FIXME\|HACK\|XXX` over `extract.ts` and `route.ts` → zero matches. One explicit `it.todo` test in `filter-doc.test.ts` documents the IBAN bug — tracked here, escalated below. |
| 7 | ERROR_FREE | ✅ PASS | All extraction error paths covered by tests: corrupt PDF → `ExtractionFailedError`, non-DOCX buffer → `ExtractionFailedError`, image upload → `UnsupportedFileTypeError`. Upload route returns clean HTTP errors (401, 400, 413, 415, 422) — no stack traces leak. |

Self-healing cycles: 1
Issues fixed internally: 1 — initial filter-doc IBAN test asserted against a 24-char real-format IBAN. Replaced with a 22-char fake matching the existing regex; flagged the underlying bug for escalation (see below).

## CRITICAL Finding — IBAN Regex Bug (PRE-EXISTING)

While writing the document-length filter tests, I discovered the IBAN regex in `web/src/lib/filter.ts` only catches **22-char IBANs (SA + 20 digits)**. Real Saudi IBANs are **24 chars (SA + 22 digits)**. Real client IBANs pasted by users today **slip past the filter** in production.

**Why this matters for compliance:**
- The filter is the BRD's compliance heart.
- Bank wire instructions almost always include a 24-char IBAN.
- The current Vercel demo would NOT redact a real IBAN if a board member pasted one during the demo.

**The fix:**
One regex change in `web/src/lib/filter.ts`. Change:
```ts
regex: /\bSA\d{2}\s?\d{2}\s?\d{4}\s?\d{4}\s?\d{4}\s?\d{4}\b/g,
```
to:
```ts
regex: /\bSA\d{2}(?:\s?\d{4}){5}\b/g,
```
That accepts SA + 22 digits with optional 4-digit grouping spaces. The full ISO 13616 Saudi IBAN format.

**Why I did NOT fix it in Wave 0:**
Wave 0 boundaries explicitly forbid changing existing filter behavior. Fixing this would change behavior for chat prompts too. I held it out and surfaced it here so Eugene can decide:
- **Option A:** Hotfix it now in a tiny one-line PR before Wave 1 starts (recommended — it's 1 line + 1 test, low risk, fixes a real production gap).
- **Option B:** File it as Wave 3 polish or a separate hotfix branch.
- **Option C:** Leave it for the BRD V3 / Phase 1 hardening pass.

The `it.todo` in `filter-doc.test.ts` keeps the gap visible until it's fixed.

## Other Findings (informational)

1. **Pre-existing lint debt unrelated to Wave 0:**
   - `src/components/Chat.tsx:85` — `react-hooks/set-state-in-effect`
   - `src/app/admin/page.tsx:188` — `@next/next/no-html-link-for-pages`
   Both exist on `main` before this wave. Wave 0 introduced zero new lint errors. Worth a tiny cleanup PR but out of scope here.

2. **`pdf-parse` version bump:** The plan originally assumed the v1 callable API. We installed v2.4.5 which exposes a class-based API (`new PDFParse({ data }).getText()`). Functionally equivalent for our needs. Documented in `extract.ts` so future engineers don't get confused.

3. **No external research needed:** We attempted to spawn a research subagent twice for LibreChat extraction patterns; both attempts returned "API overloaded". Standard library defaults (`pdf-parse`, `mammoth`) covered every Wave 0 acceptance criterion without the LibreChat reference. Noted in case Wave 1's UI-pattern research also fails — we have battle-tested fallbacks.

## Files Touched (matches plan)

| File | Change | Lines |
|------|--------|-------|
| `web/src/lib/extract.ts` | New | 178 |
| `web/src/lib/__tests__/extract.test.ts` | New | 142 |
| `web/src/lib/__tests__/filter-doc.test.ts` | New | 113 |
| `web/src/lib/__tests__/helpers/create-fixtures.ts` | New | 56 |
| `web/src/app/api/upload/route.ts` | New | 137 |
| `web/src/lib/audit.ts` | Extended (additive only) | +14 |
| `web/vitest.config.ts` | New | 17 |
| `web/package.json` | + test scripts, + deps | +3 / +6 |
| `web/pnpm-lock.yaml` | Regenerated | — |

No files outside this list were touched. All Wave 0 boundaries respected.

## What's Next

**Recommended path forward:**
1. **Decision point for Eugene:** Approve the IBAN regex hotfix (1-line change + 1 test) before Wave 1, OR defer.
2. **Wave 1 — Upload UI** is unblocked. The backend foundation is in and tested. Wave 1 builds the drag-drop zone, file chip, and extends the preview-and-confirm modal for documents.
3. **Recommended:** start Wave 1 in a fresh session if context is getting heavy, OR continue here if you want to ship the full feature today.

Verdict: **CLEAN — Wave 0 done. Awaiting Eugene's decision on the IBAN hotfix and on whether to start Wave 1 in this session or a fresh one.**
