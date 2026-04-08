# Action Items

**Last updated:** 2026-04-09
**Updated by:** Engineering team (post-document-upload deploy)

> This file is the persistent action item tracker. It answers: WHAT are all the things we still need to do, where did each one come from, and what's the priority?
>
> Every action item mentioned in any session — from formal planning to casual "we should also fix X" — gets captured here and tracked from first mention to completion.

---

## Format

Each action item uses this structure for AI parseability:

```
### [AI-NNN] Title
- **Status:** open | in-progress | blocked | done
- **Priority:** critical | high | medium | low
- **Category:** feature | bug | debt | ops | research | docs
- **Source:** [Where this came from — session date, inbox file, verbal, plan file, etc.]
- **Created:** YYYY-MM-DD
- **Updated:** YYYY-MM-DD
- **Blocked by:** [If blocked, what's blocking it]
- **Completed:** YYYY-MM-DD [Only when done]
- **Notes:** [Any additional context]
```

---

## Open

### [AI-001] Eugene self-tests the live demo before sharing with Nicolaas
- **Status:** open
- **Priority:** critical
- **Category:** ops
- **Source:** 2026-04-07 build session — Rule 1 of Eugene's workflow preferences
- **Created:** 2026-04-07
- **Updated:** 2026-04-09
- **Notes:** Now also includes the document upload feature. Run the 5-step Bank Albilad walkthrough AND drag-drop the AIveda PDF + ask "summarize this" + ask a follow-up like "what's the price for Phase 1?" at https://simah-ai-search-control.vercel.app (password `qarar-2026`). Verify all the boxes from the original test PLUS: PDF chip appears, preview modal shows filtered doc text, sticky context works on follow-ups. Eugene tested locally during the build session — needs to confirm the production deploy after the unpdf swap is also working before sending to CEO.

### [AI-002] Send demo URL + password to Nicolaas (COO)
- **Status:** open
- **Priority:** high
- **Category:** ops
- **Source:** 2026-04-07 build session
- **Created:** 2026-04-07
- **Updated:** 2026-04-07
- **Notes:** Use the suggested message drafted in the build session ("Nicolaas — I've put together a working prototype..."). Include URL, password, and a recommended demo prompt. Frame as a prototype validating the BRD concept, not as production. Blocks on AI-001 completing.

### [AI-003] Write HANDOFF.md for Qarar IT (Phase 0 → Phase 1 swap)
- **Status:** open
- **Priority:** high
- **Category:** docs
- **Source:** 2026-04-07 build session — last remaining Phase 0 todo
- **Created:** 2026-04-07
- **Updated:** 2026-04-07
- **Notes:** Document: (1) the 3-line env-var change to swap from Groq to local Ollama; (2) where to install Ollama on Qarar's Linux+GPU box; (3) the recommended Qwen 2.5 7B model pull; (4) how to swap the in-memory audit log for the SQLCipher version from the original plan; (5) how to swap the shared-password gate for Qarar's Azure AD or equivalent. This is what Robert (Head of Product Dev) reads when greenlit for Phase 1.

### [AI-004] Wire Vercel ↔ GitHub auto-deploy
- **Status:** open
- **Priority:** medium
- **Category:** ops
- **Source:** 2026-04-07 build session — failed during initial `vercel link`
- **Created:** 2026-04-07
- **Updated:** 2026-04-07
- **Notes:** Currently every deploy is manual via `vercel --prod --yes` from `web/`. To enable auto-deploy on `git push origin main`, install the Vercel GitHub app in the QararAIAgent GitHub org and grant access to the `simah-ai-search-control` repo. Then re-run `vercel link` and the connection will succeed. Not blocking any work — manual deploy is fine for a low-traffic demo.

### [AI-005] Revoke unused Together AI key
- **Status:** open
- **Priority:** medium
- **Category:** ops
- **Source:** 2026-04-07 build session — Eugene pasted the key in chat before we pivoted to Groq
- **Created:** 2026-04-07
- **Updated:** 2026-04-07
- **Notes:** Eugene's Together AI key (`tgp_v1_zzaf0wtigMgxNqA5DssJrKbWpyYcIyFh2FsO79DM2Q0`) is in this conversation's history. It hit a 402 credit-limit error and was never used in production. Revoke it from https://api.together.xyz/settings/api-keys for hygiene. Or delete the Together account entirely.

### [AI-006] Address Phase 1 hallucinated client name gap (NER)
- **Status:** open
- **Priority:** medium
- **Category:** feature
- **Source:** Original plan §4.7 + BRD V2 §9.3
- **Created:** 2026-04-07
- **Updated:** 2026-04-07
- **Notes:** The current dictionary catches the 12 major KSA banks. If the LLM hallucinates a bank name not in the dictionary, the output filter misses it. Real fix is NER (Microsoft Presidio + CAMeL Tools for Arabic). Defer to Phase 2 — for the board demo, the current rule-based approach plus the seeded SAMA bank list catches the 80% case. Documented as a known residual risk in the BRD compliance story.

### [AI-007] Replace in-memory audit log with SQLCipher (Phase 1)
- **Status:** open
- **Priority:** medium
- **Category:** feature
- **Source:** Original plan §1.7
- **Created:** 2026-04-07
- **Updated:** 2026-04-07
- **Notes:** Phase 0 uses an in-memory ring buffer (last 100 events, wiped on cold start). Phase 1 swaps to the SQLCipher + AES-GCM two-key design from the original plan. Same `record()` and `recent()` interface — should be a one-file change. Includes the PDPL Article 18 erase script.

### [AI-008] Add real RBAC / SSO (Phase 1)
- **Status:** open
- **Priority:** medium
- **Category:** feature
- **Source:** Original plan + BRD §4.3
- **Created:** 2026-04-07
- **Updated:** 2026-04-07
- **Notes:** Phase 0 uses a single shared password. Phase 1 needs per-user authentication tied to Qarar's identity provider (likely Azure AD). Roles: admin, analyst, read-only. Audit log records user_id; this becomes meaningful only when user_id is actually unique.

### [AI-009] Production memory: conversation persistence (Phase 1)
- **Status:** open
- **Priority:** medium
- **Category:** feature
- **Source:** 2026-04-07 build session — Eugene's "what does the production version look like" question
- **Created:** 2026-04-07
- **Updated:** 2026-04-07
- **Notes:** Phase 0 has session memory (chat history within one conversation, lost on refresh). Production needs (a) Postgres/Supabase persistence per conversation, (b) sliding-window summarization for long chats, (c) optionally cross-conversation profile memory via Mem0/Letta. Layer A naturally piggybacks on the SQLCipher audit log table from AI-007.

### [AI-010] Resurrect Phase 1 Docker stack
- **Status:** open
- **Priority:** medium
- **Category:** feature
- **Source:** Original plan + 2026-04-07 build session pivot
- **Created:** 2026-04-07
- **Updated:** 2026-04-07
- **Notes:** When the board approves Phase 1, pull the original Docker + on-prem Ollama + SQLCipher plan from `~/.claude-work/plans/eventual-puzzling-haven.md` and finish what we started in `phase1-qarar/`. The provider-abstraction in `web/src/lib/llm.ts` means the Phase 0 frontend can be the Phase 1 frontend with zero code changes — the Docker stack just provides a different `LLM_BASE_URL`.

### [AI-011] Brand the demo with Qarar/SIMAH visual identity
- **Status:** open
- **Priority:** low
- **Category:** feature
- **Source:** 2026-04-07 build session — deferred polish
- **Created:** 2026-04-07
- **Updated:** 2026-04-07
- **Notes:** Currently uses default Tailwind stone palette and "SIMAH AI Search Control" text title. Once Eugene has logo + brand colors from the Qarar design team, swap them in. Five-minute change: edit `globals.css`, add a logo to `public/`, update the header in `Chat.tsx` and `LoginGate.tsx`.

### [AI-012] Prompt suggestions per BRD use case
- **Status:** open
- **Priority:** low
- **Category:** feature
- **Source:** 2026-04-07 build session — discussed but deferred
- **Created:** 2026-04-07
- **Updated:** 2026-04-07
- **Notes:** The empty-state already has 3 example prompts. Could expand to a 4-tab grid: Proposal Drafting / PPT Content / HR Documents / General Writing. Each tab has 3-5 starter prompts. Helps board demo flow — they don't have to think of what to ask, they just click a tile.

### [AI-014] Upgrade Groq to paid tier before board demo
- **Status:** open
- **Priority:** high
- **Category:** ops
- **Source:** 2026-04-09 document-upload session — Eugene asked about rate limits
- **Created:** 2026-04-09
- **Updated:** 2026-04-09
- **Notes:** Free tier limits for `qwen/qwen3-32b`: 60 RPM, 1000 RPD, **6000 TPM (the bottleneck)**, 500k TPD. A single PDF question burns ~6.5k tokens. CEO using it solo is fine on free tier (he'll naturally pace under the limit). Board demo with multiple users hitting it concurrently will trip the 6k TPM cap and people will see the friendly "AI service unavailable" error. Paid pricing: $0.29/M input + $0.59/M output → ~1.2 cents per typical conversation. **$5 of Groq credit covers the whole evaluation period.** Two-minute setup: Groq dashboard → Settings → Billing → add card → prepay $5. No code changes needed; rate limits scale up automatically for the same account.

### [AI-015] Refactor Chat.tsx — now over 800-line soft cap
- **Status:** open
- **Priority:** low
- **Category:** debt
- **Source:** 2026-04-09 document-upload session, Wave 1 reconciliation deviation
- **Created:** 2026-04-09
- **Updated:** 2026-04-09
- **Notes:** `web/src/components/Chat.tsx` is now ~870 lines after the document upload extensions (drag-drop, paperclip button, chip, modal extension, error handling). Crosses the 800-line cap in `.claude/rules/coding-style.md`. Should be split into `ChatHeader.tsx`, `ChatInput.tsx`, `ChatComposer.tsx`, `EmptyState.tsx`, `MessageBubble.tsx`, `PreviewModal.tsx`. Pure refactor — no behavior change. Yuki's territory. NOT blocking; the code works fine. Do when there's a quiet day.

### [AI-016] Pre-existing lint warning in admin/page.tsx
- **Status:** open
- **Priority:** low
- **Category:** debt
- **Source:** 2026-04-09 document-upload session — flagged in every wave reconciliation
- **Created:** 2026-04-09
- **Updated:** 2026-04-09
- **Notes:** `src/app/admin/page.tsx:188` uses `<a href="/">` instead of `<Link>` from `next/link`. ESLint flag `@next/next/no-html-link-for-pages`. Pre-existed before this session; flagged but never touched because all our changes were scoped to other files. One-line fix when convenient.

### [AI-017] (Optional) Filter foreign phone numbers as well
- **Status:** open
- **Priority:** low
- **Category:** feature
- **Source:** 2026-04-09 document-upload session — Eugene noticed the AIveda PDF's Indian phone +91-9310094589 wasn't redacted
- **Created:** 2026-04-09
- **Updated:** 2026-04-09
- **Notes:** Current filter regex only catches Saudi mobile numbers (+966 5X / 05X). The AIveda PDF contains an Indian vendor phone number which slipped through. Defensible decision: foreign vendor contact info is NOT sensitive client data. But if compliance wants to be conservative, a 2-line addition to `web/src/lib/filter.ts` regex array catches international `+\d{1,3}` patterns. Eugene was OK leaving it; capturing for the record.

### [AI-013] Prepare Alveda vendor questionnaire
- **Status:** open
- **Priority:** medium
- **Category:** docs
- **Source:** Original plan §6.2 (12 questions)
- **Created:** 2026-04-07
- **Updated:** 2026-04-07
- **Notes:** The 12 questions in the original plan §6.2 should be exported to a clean PDF/markdown doc Eugene can take into the Alveda meeting. Currently they live in `~/.claude-work/plans/eventual-puzzling-haven.md`. Should also live in `web/docs/VENDOR_QUESTIONS.md` so it ships with the repo.

---

## In Progress

_No items currently in progress — document-upload build session just wrapped, all waves complete and shipped to production._

---

## Blocked

_No blocked items._

---

## Done (Recent)

### [AI-D01] Phase 0 cloud demo built and deployed
- **Status:** done
- **Priority:** critical
- **Category:** feature
- **Source:** 2026-04-07 build session
- **Created:** 2026-04-07
- **Completed:** 2026-04-07
- **Notes:** Live at https://simah-ai-search-control.vercel.app. Full pipeline: shared-password auth → bilingual chat UI with EN/AR toggle and RTL flip → input filter (regex + dictionary) with preview-and-confirm modal → Groq Qwen 3 32B → output filter → in-memory audit log → markdown rendering → session memory. 14 source files, ~900 lines. 10/10 filter unit tests passing.

### [AI-D02] Read and digest BRD V2
- **Status:** done
- **Priority:** critical
- **Category:** research
- **Source:** Earlier session
- **Created:** 2026-04-07
- **Completed:** 2026-04-07
- **Notes:** Full BRD V2 (sections 1-10) read and indexed. Stored in memory as `reference_brd_v2.md`. The 4 use cases, 5-layer architecture, compliance constraints, and Path 1/2/3 implementation paths are all loaded.

### [AI-D03] Write the Phase 0/1 master plan
- **Status:** done
- **Priority:** critical
- **Category:** docs
- **Source:** 2026-04-07 build session
- **Created:** 2026-04-07
- **Completed:** 2026-04-07
- **Notes:** Lives at `~/.claude-work/plans/eventual-puzzling-haven.md`. 11 sections including architecture, hardware sizing, build complexity, 12 stress tests / edge cases, handoff plan, board demo script, vendor questionnaire, deferred-features list. The Phase 0 build referenced this plan throughout.

### [AI-D04] Build provider-agnostic LLM client (swap-the-brain architecture)
- **Status:** done
- **Priority:** critical
- **Category:** feature
- **Source:** 2026-04-07 build session — BRD §9.1 architecture requirement
- **Created:** 2026-04-07
- **Completed:** 2026-04-07
- **Notes:** `web/src/lib/llm.ts` reads `LLM_BASE_URL`, `LLM_API_KEY`, `LLM_MODEL`, `LLM_PROVIDER_LABEL` from env vars. Phase 1 swap to local Ollama is a 3-line env change. Documented inline with a routing table.

### [AI-D05] Build PII filter (regex + dictionary + Arabic normalization)
- **Status:** done
- **Priority:** critical
- **Category:** feature
- **Source:** 2026-04-07 build session — BRD §9.3 + plan §1.5
- **Created:** 2026-04-07
- **Completed:** 2026-04-07
- **Notes:** `web/src/lib/filter.ts` — 12 KSA banks seeded, regex for NID/IBAN/phone/email/SAR amounts, full Arabic normalization (alef variants, ya/alef-maqsura, tatweel, diacritics). 10/10 unit tests in `web/scripts/test-filter.ts`. Output filter catches hallucinated names that ARE in the dictionary.

### [AI-D06] Push code to private GitHub repo
- **Status:** done
- **Priority:** high
- **Category:** ops
- **Source:** 2026-04-07 build session
- **Created:** 2026-04-07
- **Completed:** 2026-04-07
- **Notes:** `QararAIAgent/simah-ai-search-control` (private). Initial commit + 4 follow-up commits (filter false-positive fix, output buffering, session memory, markdown rendering). All authored as `aiagent@qarar.org` to satisfy Vercel's team-access check.

### [AI-D07] Fix Bug: streaming bypassed output filter (compliance)
- **Status:** done
- **Priority:** critical
- **Category:** bug
- **Source:** 2026-04-07 build session — Eugene's first live test
- **Created:** 2026-04-07
- **Completed:** 2026-04-07
- **Notes:** Original implementation streamed LLM tokens directly to the client. Output filter only ran after the stream closed. The audit log got the filtered version but the user still SAW the raw text. Compliance breach. Fix: buffer the full LLM response, run output filter, emit filtered text. Groq is fast enough that perceived latency is identical.

### [AI-D08] Fix Bug: Qarar/SIMAH false positive in filter
- **Status:** done
- **Priority:** high
- **Category:** bug
- **Source:** 2026-04-07 build session — Eugene's first live test
- **Created:** 2026-04-07
- **Completed:** 2026-04-07
- **Notes:** Dictionary had Qarar and SIMAH as `[INTERNAL]` placeholders. They're the BUILDER and EMPLOYER, not client data. A user writing "from the SIMAH team" is normal, not a leak. Removed both entries; updated test deck to assert SIMAH self-mentions are NOT redacted.

### [AI-D09] Build session memory MVP (chat history)
- **Status:** done
- **Priority:** high
- **Category:** feature
- **Source:** 2026-04-07 build session — Eugene flagged "the chat has no memory"
- **Created:** 2026-04-07
- **Completed:** 2026-04-07
- **Notes:** Frontend ships filtered conversation history with each request. Server prepends to LLM messages. Hard cap 50 turns. User turns are always the FILTERED version (no PII can leak through history). Verified live on production with a "what is the capital → what is its population" follow-up test.

### [AI-D11] Document upload feature (Path C, all 4 waves)
- **Status:** done
- **Priority:** critical
- **Category:** feature
- **Source:** 2026-04-08/09 document-upload build session
- **Created:** 2026-04-08
- **Completed:** 2026-04-09
- **Notes:** Drag-and-drop PDF/DOCX/TXT into chat, filtered by existing PII pipeline, sticky context across follow-ups. Match ChatGPT/Claude UX (chip moves into message bubble after send). Live on https://simah-ai-search-control.vercel.app at HEAD `497c2f6`. 86 vitest tests passing (12 extract + 12 filter-on-doc + 10 upload route integration + 50 greetings + 2 chat classifier-skip pinning). Initially built with `pdf-parse` which broke Vercel serverless three different ways → swapped to `unpdf` (zero-dep, serverless-native). Path C chosen up-front after researching 6 OSS chat clones: stay custom, borrow patterns from Vercel AI Chatbot + LibreChat instead of forking. All 4 wave RESULT files in `context/builds/`.

### [AI-D12] IBAN regex hotfix — real 24-char Saudi IBANs now caught
- **Status:** done
- **Priority:** critical
- **Category:** bug
- **Source:** 2026-04-09 document-upload session — discovered while writing filter-on-doc tests
- **Created:** 2026-04-09
- **Completed:** 2026-04-09
- **Notes:** Pre-existing bug. The IBAN regex in `web/src/lib/filter.ts` only matched 22-char IBANs (SA + 20 digits) but real Saudi IBANs are 24 chars (SA + 22 digits). Real client IBANs pasted into the live demo were silently slipping past the filter. One-line regex fix: `\bSA\d{2}(?:\s?\d{4}){5}\b`. 2 new tests added (compact form + bank-statement spaced form). Authorized by Eugene mid-session.

### [AI-D13] Greeting fast-path — "hi" no longer rejected by classifier
- **Status:** done
- **Priority:** high
- **Category:** bug
- **Source:** 2026-04-09 document-upload session — Eugene tested "hi" and got refused
- **Created:** 2026-04-09
- **Completed:** 2026-04-09
- **Notes:** Topic classifier was correctly per its prompt rejecting greetings as "off-topic" but the bot felt robotic during a board demo dry run. Fix: short-circuit with a regex match BEFORE the classifier runs. Greetings (English + Arabic + transliterated) get a canned bilingual reply WITHOUT calling classifier or LLM. Cheaper, faster, friendlier. New file `web/src/lib/greetings.ts` + 50 unit tests.

### [AI-D14] Skip topic classifier when document is attached
- **Status:** done
- **Priority:** critical
- **Category:** bug
- **Source:** 2026-04-09 document-upload session — Eugene uploaded a PDF, asked "read this", classifier refused
- **Created:** 2026-04-09
- **Completed:** 2026-04-09
- **Notes:** When a document was attached, the classifier was rejecting prompts like "read this and summarize it" because it couldn't see the attachment and thought "read what?" Fix: skip the classifier entirely when `documentContext` is present. Document upload is an explicit user action — strong enough work-intent signal that the second-opinion classifier isn't needed. Pinning test added at `web/src/app/api/chat/__tests__/chat-classifier-skip.test.ts` so it can never regress.

### [AI-D15] Replaced pdf-parse with unpdf for Vercel serverless compatibility
- **Status:** done
- **Priority:** critical
- **Category:** debt
- **Source:** 2026-04-09 document-upload session — three Vercel deploy failures in a row
- **Created:** 2026-04-09
- **Completed:** 2026-04-09
- **Notes:** `pdf-parse` works perfectly on the laptop but pulls in `pdfjs-dist` (~30 MB) which broke Vercel three ways: (a) NFT trace missed pdfjs files entirely, (b) `outputFileTracingIncludes` glob fix exposed the pnpm symlink issue ("framework produced an invalid deployment package"), (c) flat node_modules via `node-linker=hoisted` exposed function size limit. Final fix: swapped to `unpdf` — 2024 library purpose-built for serverless, zero deps, ships its own slim pdfjs build, no worker file. Drop-in API change in `extract.ts`. All 86 tests still pass. Documented as a referenced cheat sheet in memory.

### [AI-D10] Render markdown in assistant messages
- **Status:** done
- **Priority:** high
- **Category:** feature
- **Source:** 2026-04-07 build session — Eugene flagged "the AI is replying with all the ** and stuff"
- **Created:** 2026-04-07
- **Completed:** 2026-04-07
- **Notes:** react-markdown + remark-gfm + @tailwindcss/typography. Assistant bubbles get a custom prose-* style. User messages stay plain. Trailing redaction warning is split off into its own amber alert box.

---

## Archive

_Empty — first session, nothing to archive yet._

---

## Stale Review Queue

_Empty — first session, nothing is stale._

---

## Counter

<!-- Machine-readable. Do not edit manually. -->
`next_id: 18`
