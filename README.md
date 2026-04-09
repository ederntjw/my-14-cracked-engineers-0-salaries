# Eugene's Engineering Team

**An AI engineering team that builds production-grade software. You describe what you want. 14 specialists plan, build, test, review, and ship it.**

I built this with no CS degree. I have a Master's in Accounting and Financial Management. Today I use this exact team to build and sell software solutions worth tens of thousands to hundreds of thousands of dollars — and growing. This is the same system I use every day, now available so you can do the same.

---

## What's in the box

When you download this folder and open it in Claude Code, you get:

- **14 specialist agents** — a strategist, planner, architect, builders, security expert, code reviewers, testers, and more
- **White-glove auto-routing** — you never type a command. Say "I want to build a marketplace" and the right specialists activate automatically. Say "it's broken" and the debugger starts triaging. The team reads your intent and acts.
- **Idea refinement** — vague ideas get sharpened before planning begins. The team defines what version 1 looks like AND what's deliberately left out (the "Not Doing" list that prevents scope creep)
- **Self-healing QA** — the team finds bugs, fixes them, and re-verifies automatically. You only get pulled in when a human decision is genuinely needed
- **7-check evidence protocol** — every "it works" claim comes with actual command output as proof (BUILD, TEST, LINT, FUNCTIONALITY, ARCHITECT, TODO, ERROR_FREE)
- **Anti-rationalization tables** — built into every critical workflow. The team catches itself before taking shortcuts like "this is too simple to need tests" or "I'll verify later"
- **Structured debugging** — a six-step triage protocol (reproduce, localize, reduce, fix root cause, guard with a test, verify end-to-end). No guessing. No patching symptoms.
- **Incremental builds** — never more than 100 lines without testing. Code gets built in vertical slices (one complete feature at a time), not horizontal layers
- **3-tier plan boundaries** — every plan defines what to Always Do, what to Ask First, and what to Never Do. Clear guardrails that prevent drift during builds
- **Architecture Decision Records** — every significant technical choice gets documented with context, alternatives considered, and consequences. Decisions never get lost between sessions
- **Production-ready deploy checklist** — security headers, rate limiting, env vars, health endpoints, no debug mode, and a rollback plan before anything goes live
- **Clean removal discipline** — when something gets replaced, the old version is fully deleted. No zombie code, no commented-out blocks, no orphaned files
- **Smart model routing** — simple tasks run on cheaper models, complex tasks get the heavy reasoning. Signal-based, not static. Your bill stays low without sacrificing quality
- **Auto-detection** — drop the team into any codebase and it figures out the tech stack, test runner, and build commands without asking
- **Auto-recovery** — build fails? Tests break? The team handles it internally and only escalates after 3 failed attempts
- **Auto-checkpoint** — context saves at every major milestone automatically. Sessions can crash and nothing is lost
- **A context system** that reads your documents, emails, and notes — and never forgets what you told it
- **Long-term memory (MemPalace)** — decisions, preferences, rejected approaches, and stakeholder constraints persist across sessions. The team remembers what you told it three months ago. No re-explaining.
- **Codebase knowledge graph (Graphify)** — maps every module, relationship, and core abstraction in your codebase. New sessions understand the full architecture in seconds, not minutes. Auto-rebuilds on every commit.
- **Graph-first navigation** — agents consult the knowledge graph before exploring files. No more blind grepping through unfamiliar code.
- **Memory-informed decisions** — before making architectural choices, agents check institutional memory for prior decisions on the same topic. No repeating past mistakes.
- **Crash recovery** — if a session dies unexpectedly, the next session automatically recovers unmined memories from the transcript. Nothing is lost.
- **The PAUL method** baked into the workflow — Plan, Act, Update, Learn — a continuous improvement cycle that runs on every build

## What makes this different

This isn't a prompt template or a chatbot wrapper. It's a complete engineering operation with the same quality controls used by professional software teams:

- **Nothing ships without proof.** Every verification claim has actual command output attached. The team doesn't say "tests pass" — it shows you the test output.
- **Nothing ships without review.** Code gets debated, security-checked, and tested before it goes anywhere. The QA chain runs 7 named checks and verifies every acceptance criterion from the plan.
- **Nothing gets forgotten.** Action items, decisions, and architecture choices persist across sessions. Long-term memory (MemPalace) remembers your preferences, past failures, and stakeholder requirements across weeks and months. A codebase knowledge graph (Graphify) maps how everything connects. Auto-checkpointing means even crashed sessions don't lose progress.
- **Nothing gets built without your approval.** The team shows you the plan and waits. You're always in control.
- **The team fixes its own mistakes.** When something breaks, the right specialist gets routed in automatically with a structured debugging protocol. You experience a smooth pipeline, not a series of error reports.
- **The team catches its own shortcuts.** Anti-rationalization tables are built into every critical workflow. If the team is about to skip testing, skip review, or skip verification, the tables call it out before it happens.
- **You never need to learn commands.** Every discipline auto-triggers based on what you say. Vague idea? The team refines it. Error pasted? The debugger starts triaging. Code just written? The reviewer activates. Ready to ship? The deploy checklist runs.

I use this to deliver production software to paying clients. The same guardrails protecting my builds now protect yours.

---

## How it works

The entire workflow runs on the **PAUL method** — a continuous cycle baked into every build session:

```
    ┌───────────────────────────────────────────┐
    │              THE PAUL CYCLE                │
    │                                            │
    │   P  PLAN ──────> Break work into steps.   │
    │                   Define what "done" looks  │
    │                   like. Get approval.       │
    │                         |                   │
    │   A  ACT ───────> Tests first, then code.  │
    │                   Build what was approved.  │
    │                   Review. Verify.           │
    │                         |                   │
    │   U  UPDATE ────> Save everything.         │
    │                   Decisions, progress,      │
    │                   context. Nothing lost.    │
    │                         |                   │
    │   L  LEARN ─────> Explain what was built   │
    │                   and why. You learn the    │
    │                   craft as you build.       │
    │                         |                   │
    │              ┌──────────┘                   │
    │              v                              │
    │         NEXT CYCLE                          │
    └───────────────────────────────────────────┘
```

Each cycle through the pipeline makes the project more robust and makes you more technically literate. The team teaches while it builds — every decision gets explained in plain English.

---

## The build pipeline (detailed)

Every build session follows this flow. The team handles failures internally and only pulls you in when it needs a human decision.

```
  START HERE
      |
      v
  /status ............... "Where are we? What's next?"
      |                   (auto-detects tech stack on first contact)
      v
  /inbox ................ "Any new documents or notes to process?"
      |
      v
  /pull ................. "Load decisions from a brainstorm session"
      |
      v
  /refine (auto) ........ "Sharpen the idea. What's in? What's out?"
      |                   (only runs when the idea is vague)
      v
  /plan ................. "Break the work into steps. Show me the plan."
      |                              ┐
      v                              │
  YOU APPROVE THE PLAN               │  P - PLAN
      |         (auto-checkpoint)    │
      v                              ┘
  [BUILD] ............... Tests first, then code.        ┐
      |                                                   │
      v                                                   │
  VERIFY LOOP .......... build → verify → fix → verify   │  A - ACT
      |                  (loops until all 7 checks pass   │
      |                   with actual evidence)            │
      v                                                   │
  QA CHAIN (auto) ...... Self-healing: finds issues,     │
      |                  fixes them, re-verifies.          │
      |                  Up to 3 cycles before asking you. │
      |                  7-check protocol + acceptance     │
      |                  criteria from the plan.           │
      v                                                   ┘
  HUMAN CHECK .......... "Verify these 3-5 specific things"
      |
      v
  SHIP / HOLD           (SHIP only with evidence + your OK)
      |         (auto-checkpoint)
      v
  /update ............... "Save everything for next time"    U - UPDATE
      |
      v
  TEACHING MODE ......... Every action explained in          L - LEARN
      |                   plain English as you go
      v
    DONE
```

**What runs automatically (you don't trigger these):**
- Tech stack detection on first contact
- Idea refinement when requests are vague (before planning)
- Model routing (cheaper models for simple tasks)
- Structured debugging when errors occur (six-step triage)
- Auto-recovery when builds/tests fail
- Auto-checkpointing at every milestone
- Progress narration ("Max finished tests. Nina is reviewing.")
- Evidence collection on every verification claim
- Anti-rationalization checks (team catches itself before skipping steps)
- Architecture decisions documented automatically
- Clean removal of replaced code (no zombie code)
- Graph rebuilt on every commit (Graphify AST, free, no LLM cost)
- Conversation mined to long-term memory on session end (MemPalace)
- Crash recovery — next session auto-recovers unmined memories

---

## Get started (3 steps)

### 1. Install Claude Code

If you don't have Claude Code yet, install it:

```
npm install -g @anthropic-ai/claude-code
```

(Need npm? Install [Node.js](https://nodejs.org/) first — download the LTS version and run the installer.)

### 2. Install long-term memory (optional, recommended)

```
pip install graphifyy[all] mempalace
```

This gives the team persistent memory across sessions and a map of your codebase. Without it, the team still works — it just starts fresh each session. With it, the team remembers everything and understands your architecture from the first second.

### 3. Download and open

Download this folder (or clone the repo), then open it in Claude Code:

```
cd path/to/Eugenes-Engineering-Team
claude
```

Or open the folder in VS Code / Cursor with the Claude Code extension.

### 4. Say hello

That's it. Just send your first message. The team detects it's a fresh setup and walks you through onboarding automatically. It asks two questions:

1. **Are you building something new?** — The team helps you plan from scratch.
2. **Do you have existing code?** — The team audits what you have, finds issues, and helps you improve it.

No commands to memorize. No config files to edit. Just talk to it.

---

## Using this as a template

This folder is designed to be copied — the same way I copy it for each new client engagement. Keep the original clean, make a copy for each project:

```
Eugenes-Engineering-Team/              <-- the template (keep clean)
Eugenes-Engineering-Team-MyApp/        <-- your copy for MyApp
Eugenes-Engineering-Team-ClientWork/   <-- your copy for client work
```

Each copy gets its own project context, its own status, its own memory. They don't interfere with each other. I run multiple projects simultaneously this way.

---

## Who this is for

- **Non-technical founders** who want to build and sell software without hiring a dev team
- **VibeCoding practitioners** who want professional guardrails around their builds
- **Solo builders** shipping MVPs to paying clients
- **Anyone with an existing codebase** (from VibeCoding, another AI, or a developer) who wants to harden it for production

If you can describe what you want to build, this team can build it. If you already have code, this team can audit it, fix it, and make it production-ready.

---

## Documentation

- **[START-HERE.md](docs/START-HERE.md)** — Detailed onboarding guide (read this if you want the full picture)
- **[PLAYBOOK.md](docs/PLAYBOOK.md)** — Command reference and workflow cheat sheet (keep this open while building)

---

## Built by

**Eugene Zhang** — non-technical founder using VibeCoding to build and sell production software.

[![Instagram](https://img.shields.io/badge/Instagram-E4405F?logo=instagram&logoColor=white)](https://www.instagram.com/eugenezhang__/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?logo=linkedin&logoColor=white)](https://www.linkedin.com/in/eugenezhangco/)

If this saves you time or makes you money, a star or a follow goes a long way.

---

## License

Proprietary — personal use only. You may use and modify the Software for your own personal or business purposes. Redistribution, reselling, and public posting are not permitted. See [LICENSE](LICENSE) for full terms.
