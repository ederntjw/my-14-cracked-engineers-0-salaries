# SIMAH AI Search Control — Project Status

**Last updated:** 2026-04-09
**Updated by:** Engineering team (document upload + UX polish LIVE on Vercel)

---

## What Is SIMAH AI Search Control

A localized, KSA-compliant AI productivity tool for Qarar / SIMAH employees. Provides ChatGPT-style drafting for proposals, presentations, HR documents, and general business writing — but every prompt is filtered to strip client names, financial figures, and personal data BEFORE it reaches the language model. The production version will run entirely on Qarar infrastructure inside Saudi Arabia (PDPL / SDAIA / SAMA / NCA compliant). The current Phase 0 demo runs on cloud infrastructure as a board-facing prototype.

---

## Who Is Involved

| Person | Role | Context |
|--------|------|---------|
| **Eugene Zhang** | Project lead / builder | Non-technical Qarar founder. Wrote BRD V2. Building MVP himself partly to be sharper in the Alveda vendor meeting. Has M5 Pro Mac with Ollama installed. |
| **Nicolaas (COO)** | Executive sponsor | Approved BRD. Will receive the demo URL to share with the SIMAH board. |
| **Robert (Head of Product Dev)** | Technical lead post-BRD | Will own Phase 1 production deployment at Qarar. |
| **Alveda** | External AI vendor (India) | Submitting a proposal based on the BRD. Eugene's MVP is the reference benchmark for evaluating their proposal. |

---

## Current Status

**Phase:** Phase 0 — Cloud demo LIVE. Awaiting board feedback before greenlighting Phase 1.

**Live demo:**
- URL: **https://simah-ai-search-control.vercel.app**
- Password: `qarar-2026`
- Hosted on Vercel under the `qararaiagent` account
- LLM: Groq-hosted Qwen 3 32B (sub-second responses, free tier)
- Code: https://github.com/QararAIAgent/simah-ai-search-control (private)

**Timeline:**
1. ✅ Phase 0 cloud demo built and shipped (2026-04-07)
2. ⏳ Eugene shares URL with Nicolaas / SIMAH board for feedback
3. ⏳ Alveda vendor meeting — Eugene uses the demo + 12-question vendor questionnaire (in `~/.claude-work/plans/eventual-puzzling-haven.md` §6.2)
4. ⏳ Board approval to move to Phase 1
5. ⏳ Phase 1 — Qarar production pilot on KSA infrastructure (original Docker + on-prem Ollama plan)

---

## What Comes Next

1. **✅ SHIPPED TO PROD — Document Upload feature + UX polish (HEAD: 497c2f6)** — drag-and-drop PDF/DOCX/TXT into chat, filtered by existing PII pipeline, sticky across follow-ups. Live on https://simah-ai-search-control.vercel.app as of 2026-04-09. **Final state:** 86 tests pass across 5 test files, build clean, `/api/upload` verified live (returns 401 without auth, 200 with file). **Bonus fixes shipped in same session:** IBAN hotfix (real 24-char Saudi IBANs), greeting fast-path (hi/hello/salam → canned bilingual reply, no LLM cost), classifier-skip when document attached, granular PDF error mapping, Enter-to-confirm in preview modal, chip-disappears-after-send UX, document-side defense-in-depth re-filter. All 4 wave RESULT files in `context/builds/`.

   **Vercel deploy gotchas learned this session (write these down forever):**

   **Gotcha 1 — Git author check (re-confirms STATUS decision #8):** First deploy failed silently with `"Unexpected error"`. Real reason was buried in Vercel API `readyStateReason`: *"Git author eugenezhang@eugenezhangco-spec.com must have access to the team qararaiagent's projects."* Fix: commit with team author. Recovery command:
   ```
   git -c user.name="QararAIAgent" -c user.email="aiagent@qarar.org" commit --allow-empty -m "chore: trigger Vercel deploy"
   ```
   Also: gh CLI has TWO accounts (`eugenezhangco-spec` and `QararAIAgent`). The push uses whichever is active. Switch with `gh auth switch -u QararAIAgent -h github.com`.

   **Gotcha 2 — pdf-parse crashes Vercel serverless:** Initially used `pdf-parse` for PDF extraction. It pulls in pdfjs-dist (~30 MB) which broke the Vercel function bundle three different ways: (a) NFT trace missed pdfjs files entirely (bundled directory but no contents), (b) `outputFileTracingIncludes` glob fix exposed the pnpm symlink issue (`"framework produced an invalid deployment package"`), (c) flat node_modules via `node-linker=hoisted` exposed function size limit. **Final fix:** swapped to `unpdf` (zero-dep, serverless-native, ships its own slim pdfjs build, no worker file). One-line API change in `extract.ts`. **Lesson for future PDF/DOCX work on Vercel:** start with serverless-native libraries (`unpdf`, `mammoth` is OK because it's flagged in `serverExternalPackages`). Avoid anything that pulls in pdfjs-dist directly.

   **Gotcha 3 — Vercel error messages are useless until you query the API:** `vercel --prod --yes` returned empty `"Unexpected error. Please try again later."` for both gotchas above. The real errors only surfaced via the Vercel API endpoint `https://api.vercel.com/v13/deployments/<id>?teamId=<team>` in the `readyStateReason` field. When a Vercel deploy fails silently, always check the API directly.
2. **Eugene tests the demo himself** — runs the 5-step Bank Albilad walkthrough to validate the experience end-to-end before sharing with anyone
3. **Eugene sends URL + password to Nicolaas** with the suggested message (in conversation history)
4. **Write `HANDOFF.md`** documenting how Qarar IT swaps the brain to local Ollama for Phase 1 (one-line config change)
5. **Wire Vercel → GitHub auto-deploy** — currently requires installing the Vercel GitHub app in the QararAIAgent org. Right now deploys are manual via `vercel --prod --yes`.
6. **Optional polish:** Qarar/SIMAH branding (logo, colors), conversation persistence sidebar, prompt suggestions per use case

---

## App Build Status

| Component | Status | Notes |
|-----------|--------|-------|
| Next.js 16 scaffold + Tailwind 4 | ✅ Done | `web/` folder, React 19 |
| Provider-agnostic LLM client (`src/lib/llm.ts`) | ✅ Done | Reads `LLM_BASE_URL`, `LLM_API_KEY`, `LLM_MODEL` from env. Phase 1 swap is a 3-line env change. |
| Input + output PII filter (`src/lib/filter.ts`) | ✅ Done | Regex (NID, IBAN, phone, email, SAR amounts) + dictionary (12 KSA banks) + Arabic normalization (alef variants, ya/alef-maqsura, tatweel, diacritics) |
| Filter unit tests | ✅ 10/10 passing | Covers EN, AR, code-switched, false-positive shield |
| Audit log (`src/lib/audit.ts`) | ✅ Done (Phase 0 only) | In-memory ring buffer, last 100 events. Phase 1 swaps to SQLCipher per original plan. |
| Chat API route (`src/app/api/chat/route.ts`) | ✅ Done | Filter → preview-and-confirm → LLM → output filter → audit. Buffered (not streamed) so output filter can run before user sees text. |
| Login API + auth gate | ✅ Done | Single shared password via httpOnly cookie. Phase 1 swaps to Azure AD or whatever Qarar IdP is. |
| Chat UI with EN/AR toggle + RTL flip | ✅ Done | Geist for Latin, Noto Sans Arabic for Arabic. Full RTL flip on toggle. |
| Filter preview-and-confirm modal | ✅ Done | User sees redacted version BEFORE prompt is sent to LLM. The user is the last line of defense, by design. |
| Markdown rendering for assistant messages | ✅ Done | react-markdown + remark-gfm + @tailwindcss/typography. Tables, headings, bold, lists, dividers. |
| Session memory (chat history) | ✅ Done | Frontend ships history with each request. Server prepends to LLM messages. Hard cap 50 turns. Filtered versions only — no PII leaks via history. |
| GitHub repo (private) | ✅ Done | `QararAIAgent/simah-ai-search-control` |
| Vercel deploy | ✅ Live | Manual `vercel --prod --yes` from `web/` folder. Auto-deploy from GitHub push not yet wired. |
| **HANDOFF.md for Qarar IT** | ⏳ Pending | Documents the Phase 0 → Phase 1 swap: env vars to change, where Ollama goes, how to run the Phase 1 audit log. |
| **Phase 1 Docker stack** | ⏳ Deferred | Lives in `phase1-qarar/` (just `docker-compose.yml` for now). Resurrected from the original plan when board approves Phase 1. |

---

## Engineering Team Decisions (this session)

| # | Decision | Why |
|---|----------|-----|
| 1 | **Pivot from Docker-on-Mac to Cloud Next.js** | Eugene needs a URL his CEO can open without Eugene's Mac being on 24/7. Docker on Mac is the right answer for Phase 1 (Qarar's KSA server) but wrong for a board demo. |
| 2 | **Use Groq + Qwen 3 32B for the demo brain** | Eugene's local `qwen3.5:latest` was a thinking model that hung for 2+ minutes on trivial prompts. Groq hosts the same Qwen family with sub-second responses on a free tier. The provider-abstraction architecture means Phase 1 swap to local Ollama is a 3-line env change. |
| 3 | **Buffer the LLM response, don't stream** | Original streaming let raw LLM output reach the user before the output filter could redact it. Compliance breach. Now we buffer the full response, run the filter, then emit. Groq is fast enough that perceived latency is identical. |
| 4 | **Remove Qarar / SIMAH from the dictionary** | They are the BUILDER and EMPLOYER, not client data. A user writing "from the SIMAH team" is normal business behavior, not a leak. The filter exists to protect CLIENT data, not the user's own brand. |
| 5 | **Session memory MVP via shipped history** | The chat had no memory between turns — follow-ups like "make it shorter" failed. Fix: frontend ships filtered history with each request. Production version (deferred) adds Postgres persistence + sliding-window summarization + cross-conversation memory. |
| 6 | **Markdown rendering for assistant messages only** | The model uses `**bold**`, `## headings`, `---`, lists, tables — board members expect ChatGPT-style formatting, not raw asterisks. User messages stay plain (no markdown). |
| 7 | **Demo password approach for auth** | Single shared password (`qarar-2026`) for board access. Phase 1 swaps to real Qarar IdP (Azure AD likely). Good enough for a 10-person board demo, NOT good enough for production. |
| 8 | **Vercel CLI must commit as `aiagent@qarar.org`** | Vercel rejects deploys whose git author isn't tied to a team member. Documented in memory. |

---

## Known Issues

| Issue | Severity | Notes |
|-------|----------|-------|
| Vercel ↔ GitHub auto-deploy not wired | Low | Requires installing the Vercel GitHub app in the QararAIAgent org. Manual deploys work fine in the meantime. |
| Audit log is in-memory only | Low (Phase 0) | Cold starts wipe the buffer. Acceptable for a board demo. Phase 1 has the SQLCipher plan. |
| No rate limiting on the demo | Low | If the URL is shared widely, free tier could exhaust. For board distribution this is fine — don't tweet the link. |
| Together AI key in conversation history (unused) | Low | Eugene pasted `tgp_v1_zzaf...` before we pivoted to Groq. Should be revoked from Together dashboard at some point. |
| Hallucinated client names not in dictionary | Medium (known) | A bank name the AI invents that ISN'T in `client_names` slips through. Phase 2 fix is NER (Microsoft Presidio + CAMeL Tools). Documented as a known residual risk in the BRD/COMPLIANCE story. |
| Filter false-positive: streaming/code-switching edge cases | Low | A few code-switched prompts where the same name appears in both scripts can produce weird redaction. Mitigated by preview-and-confirm gate (user sees what gets stripped). |

---

## Context Map

### Plan files
- **Phase 0/1 master plan:** `~/.claude-work/plans/eventual-puzzling-haven.md` (the full architecture, stress tests, vendor questions, hardware sizing — written before the Phase 0 cloud pivot but still 95% relevant for Phase 1)

### BRD
- **BRD V2 source:** `~/Downloads/SIMAH_AI_Search_Control_BRD_V2.0.docx` (March 2026, Eugene Zhang)

### Repos
- **Phase 0 code:** https://github.com/QararAIAgent/simah-ai-search-control (private)
- **Phase 1 docker stub:** `phase1-qarar/docker-compose.yml` in this project

### Live deployments
- **Phase 0 demo:** https://simah-ai-search-control.vercel.app (password `qarar-2026`)
