# Eugene's Engineering Team

**An AI engineering team that builds production-grade software. You describe what you want. 14 specialists plan, build, test, review, and ship it.**

I built this with no CS degree. I have a Master's in Accounting and Financial Management. Today I use this exact team to build and sell software solutions worth tens of thousands to hundreds of thousands of dollars — and growing. This is the same system I use every day, open-sourced so you can do the same.

---

## What's in the box

When you download this folder and open it in Claude Code, you get:

- **14 specialist agents** — a strategist, planner, architect, builders, security expert, code reviewers, testers, and more
- **A 9-step build workflow** with quality gates that catch bugs, security holes, and broken code before anything ships
- **An adversarial code review** where two AI engineers debate your code before it gets tested
- **A context system** that reads your documents, emails, and notes — and never forgets what you told it
- **Session-to-session memory** — the team picks up exactly where you left off, every time
- **The PAUL method** baked into the workflow — Plan, Act, Update, Learn — a continuous improvement cycle that runs on every build

## What makes this different

This isn't a prompt template or a chatbot wrapper. It's a complete engineering operation with the same quality controls used by professional software teams:

- **Nothing ships without review.** Code gets debated, security-checked, and tested before it goes anywhere.
- **Nothing gets forgotten.** Action items, decisions, and context persist across sessions. Come back in a week — the team knows exactly where you left off.
- **Nothing gets built without your approval.** The team shows you the plan and waits. You're always in control.

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

Every build session follows this flow. Each step checks the work before passing it forward.

```
  START HERE
      |
      v
  /status ............... "Where are we? What's next?"
      |
      v
  /inbox ................ "Any new documents or notes to process?"
      |
      v
  /pull ................. "Load decisions from a brainstorm session"
      |
      v
  /plan ................. "Break the work into steps. Show me the plan."
      |                              ┐
      v                              │
  YOU APPROVE THE PLAN               │  P - PLAN
      |                              │
      v                              ┘
  [BUILD] ............... Tests first, then code.        ┐
      |                                                   │
      v                                                   │
  /devils-advocate ...... "Two engineers argue about it"  │  A - ACT
      |                                                   │
      v                                                   │
  /review ............... "Security + quality checklist"  │
      |                                                   │
      v                                                   │
  /verify ............... "Run tests + check everything"  ┘
      |
      v
  /update ............... "Save everything for next time"    U - UPDATE
      |
      v
  TEACHING MODE ......... Every action explained in          L - LEARN
      |                   plain English as you go
      v
    DONE
```

---

## Get started (3 steps)

### 1. Install Claude Code

If you don't have Claude Code yet, install it:

```
npm install -g @anthropic-ai/claude-code
```

(Need npm? Install [Node.js](https://nodejs.org/) first — download the LTS version and run the installer.)

### 2. Download and open

Download this folder (or clone the repo), then open it in Claude Code:

```
cd path/to/Eugenes-Engineering-Team
claude
```

Or open the folder in VS Code / Cursor with the Claude Code extension.

### 3. Say hello

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

MIT — use it, copy it, modify it, sell what you build with it.
