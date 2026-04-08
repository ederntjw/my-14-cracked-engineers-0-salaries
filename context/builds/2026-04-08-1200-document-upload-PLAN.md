---
topic: document-upload
date: 2026-04-08
time: 12:00
phase: Phase 0 — Cloud demo, feature expansion
status: complete
type: master
total_waves: 4
path_chosen: Path C (stay custom, borrow patterns from Vercel AI Chatbot + LibreChat)
---

## What We're Building

Drag-and-drop document upload in the SIMAH AI Search Control chat, just like ChatGPT and Claude. User drops a PDF, Word doc, or text file into the chat, the server pulls the text out, runs it through the existing PII filter (same filter as chat prompts), shows the redacted version in the existing preview-and-confirm modal, and then sends the cleaned document text plus the user's prompt to the LLM. The document stays attached across follow-up questions in the same conversation — upload once, ask many questions. The PII filter remains the core compliance gate and must run on all document text before any LLM sees it.

## Why Path C (not a fork)

We reviewed six major open-source AI chat projects. Only Vercel AI Chatbot matches our stack, but forking it means ripping out their auth, database, and storage layers we don't need — roughly a week of integration surgery, then ongoing merge tax forever. Instead we stay on our own compliant foundation and borrow the best UX patterns from Vercel AI Chatbot (drag-drop, file chips) and LibreChat (text extraction pipeline). Faster, cheaper, zero fork tax.

## Wave Map

| Wave | Name | Tasks | Depends On | Status |
|------|------|-------|------------|--------|
| 0 | Foundation — extraction + filter integration | 1, 2, 3, 4 | — | complete |
| 1 | Upload UI — drag-drop + file chip + preview modal | 5, 6, 7 | Wave 0 | complete |
| 2 | Document-aware conversation — sticky context | 8, 9, 10 | Wave 1 | complete |
| 3 | Polish + edge cases — errors, token budget, E2E | 11, 12, 13 | Wave 2 | complete |

## Pattern Research (Path C extra step)

Before Wave 0 builds: researcher pulls text-extraction patterns from LibreChat (`api/app/clients/tools/structured/` and RAG module) so we adopt their battle-tested PDF/DOCX handling.

Before Wave 1 builds: researcher pulls drag-drop + file-chip UI patterns from Vercel AI Chatbot (`components/multimodal-input.tsx` and attachment handling) so our UI feels ChatGPT-grade.

Research is read-only — we adapt patterns into our own code, we don't copy-paste verbatim or add new dependencies beyond what we actually need.

## Boundaries (DO NOT CHANGE — applies to ALL waves)

- **PII filter pipeline is sacred.** Document text goes through the exact same filter as chat prompts. No bypass, no shortcut, no "trusted uploads".
- **Preview-and-confirm modal is mandatory** for documents, identical contract to chat prompts. User is the last line of defense.
- **No document storage in Phase 0.** Files live in browser memory only. No disk writes, no database, no blob storage. Phase 1 adds encrypted storage on Qarar's KSA server.
- **Don't touch existing chat, filter, audit, or auth code except to extend it.** No refactors, no "while I'm here" cleanup.
- **Qwen 3 on Groq stays the brain.** No LLM changes.
- **Language toggle, RTL, markdown rendering, session history, audit log** all continue to work exactly as they do today.
- **No new runtime dependencies** beyond `pdf-parse`, `mammoth`, and whatever minimal libraries the team actually needs. No vector DB, no embedding service, no RAG framework.
- **Vercel free tier constraints apply** — 4.5MB request body limit, serverless cold starts. Design for them, don't fight them.

## Risks

- **Large PDFs blow the LLM context window.** Qwen 3 32B on Groq caps around 32k tokens. A 100-page legal doc can exceed that. Mitigation: hard truncation with clear user warning (Tasks 3 + 12).
- **Scanned PDFs extract as empty or garbage.** Images of text need OCR, which Phase 0 will not do. Mitigation: detect empty extract and show "No text found — is this a scanned image?" error.
- **Filter edge cases specific to long documents.** Long business documents will surface PII patterns not seen in short chats. Mitigation: unit tests on realistic fixtures + the preview-and-confirm gate catches anything we miss.
- **Vercel 4.5MB body limit.** Rejects large presentations. Mitigation: client-side file size check, clear error message.
- **Drift from upstream Next.js / AI SDK.** Adopting AI SDK patterns means we're exposed to their API changes. Mitigation: pin versions, only adapt stable patterns.

## Success Criteria for the Whole Build

1. A board member can drag a PDF from their desktop into the chat, see it get filtered, send a prompt, and get a useful answer — in under 10 seconds end-to-end.
2. The PII filter catches all the same patterns in the document that it catches in chat prompts (tested with fixtures).
3. No document text ever reaches the LLM without passing through the filter.
4. Follow-up questions about the same document work without re-uploading.
5. All 7 checks in the evidence protocol pass (BUILD, TEST, LINT, FUNCTIONALITY, ARCHITECT, TODO, ERROR_FREE).
