# My 14 Cracked Engineers, 0 Salaries

**You talk. They build. 14 AI specialists that plan, build, test, review, and ship production software.**

Built by a non-technical founder with no CS degree. This is the same system used to build and sell software solutions worth hundreds of thousands to millions of dollars. Now available so you can do the same.

---

## The team

```
                         ┌─────────────────┐
                         │    YOU (Boss)    │
                         └────────┬────────┘
                                  │
              ┌───────────────────┼───────────────────┐
              │                   │                   │
     ┌────────┴────────┐ ┌───────┴───────┐ ┌────────┴────────┐
     │  Maya            │ │  Jake          │ │  Sara            │
     │  Strategy        │ │  Planning      │ │  Architecture    │
     └────────┬────────┘ └───────┬───────┘ └────────┬────────┘
              │                   │                   │
   ┌──────────┴───────────────────┴───────────────────┘
   │
   │  BUILD         Max (Testing) · Nina (Code Review) · Elena (Security)
   │                Liam (Frontend) · Tom (DevOps) · Aisha (QA)
   │                Yuki (Refactoring) · Rachel (Docs)
   │
   │  DATA          Andre (Database) · Fatima (Pipelines)
   │
   │  AUDIT         Dave (Codebase Auditor)
   │
```

You never manage them. Describe what you want and the right people show up. Say "build me a landing page" and Liam activates. Say "it's broken" and Tom starts triaging. Say "I have an idea" and Maya sharpens it before anyone writes code.

---

## Three things that matter

### 1. Quality controls that real engineering teams use

| Discipline | What it does |
|---|---|
| **7-check evidence protocol** | Every "it works" claim has actual command output as proof. BUILD, TEST, LINT, FUNCTIONALITY, ARCHITECT, TODO, ERROR_FREE. |
| **Tests before code** | Max writes failing tests first, then builds the feature. Never more than 100 lines without testing. |
| **Self-healing QA** | Aisha finds bugs, fixes them, re-verifies. Up to 3 cycles before pulling you in. |
| **Structured debugging** | Six-step triage: reproduce, localize, reduce, fix root cause, guard with test, verify end-to-end. No guessing. |
| **Security review** | Elena scans every change before it ships. Hardcoded secrets, injection, auth bypasses. |
| **Anti-rationalization** | Built into every workflow. The team catches itself before skipping steps like "this is too simple to test." |
| **Code review** | Nina reviews every change for quality, performance, and blast radius. |
| **Deploy checklist** | Security headers, rate limiting, env vars, health endpoints, rollback plan. Nothing goes live without it. |

### 2. Long-term memory that survives across sessions

The biggest problem with AI engineering: every new session starts with amnesia. Not anymore.

| System | What it remembers | How |
|---|---|---|
| **MemPalace** | Decisions, preferences, rejected approaches, stakeholder constraints | The team explicitly saves to MemPalace via `/update` (or whenever you say "save this"). Persists across weeks and months. |
| **Graphify** | Every module, relationship, and core abstraction in your codebase | Knowledge graph auto-rebuilds on every commit via a Git post-commit hook installed during `/setup`. New sessions understand the architecture in seconds. |
| **STATUS.md** | What was built, what's next, current phase | Auto-checkpointed at every milestone. |
| **Architecture Decision Records** | Why you chose X over Y, what alternatives were considered | Written automatically when significant decisions are made. |
| **Crash recovery** | Whether the previous session ended cleanly | Next session detects unclean closes and warns the user that recent context may not have been saved. |

Session 1: the team knows nothing. Session 20: the team knows your codebase, your preferences, your stakeholder requirements, what you tried and rejected, and why the architecture is shaped the way it is.

### 3. Automation that runs without you asking

| Trigger | What happens |
|---|---|
| You say something vague | Maya sharpens the idea into a clear scope before anyone plans |
| You paste an error | Tom starts the six-step debugging protocol immediately |
| Code gets written | Nina reviews it, Elena checks security (in parallel) |
| A build wave completes | Aisha runs the full QA chain automatically |
| A git commit happens | Graphify rebuilds the codebase map (free, no LLM cost) |
| A session ends | Stop hook saves metadata. The team explicitly persists key items to MemPalace via `/update` (it's not auto-mined) |
| A session crashes | Next session recovers unmined context |
| You say "save" or "done for today" | Full save to STATUS.md, action items, and long-term memory |
| 20+ tool uses since last save | Auto-checkpoint fires without being asked |
| An architectural decision is made | ADR written to context/decisions/ automatically |

You never type a command. You never trigger a workflow. The team reads your intent and acts.

---

## Get started

### 1. Install Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

Need npm? Install [Node.js](https://nodejs.org/) first (LTS version).

### 2. Open and say hello

```bash
cd path/to/this/folder
claude
```

Or open the folder in VS Code / Cursor with the Claude Code extension.

The team detects it's a fresh setup and walks you through onboarding. The first run handles everything else automatically — including installing long-term memory if you want it.

### Optional: long-term memory (the team installs this for you on first run)

The team uses two Python tools for cross-session memory and codebase mapping:
- **MemPalace** — remembers decisions, preferences, and prior work between sessions
- **Graphify** — maps your codebase so the team understands architecture instantly

You don't install these yourself. During `/setup`, the team:
1. Creates an isolated Python virtualenv at `~/.claude-tools` (doesn't touch your system Python)
2. Installs both tools into that venv
3. Wires them up to the MCP servers defined in `.mcp.json`

Without this step, the team still works — it just starts fresh each session. With it, the team remembers everything and understands your architecture from the first second.

If you want to install manually (advanced), this is what `/setup` runs:
```bash
python3 -m venv ~/.claude-tools
~/.claude-tools/bin/python3 -m pip install --upgrade pip
~/.claude-tools/bin/python3 -m pip install mempalace 'graphifyy[all]'
```

---

## Use it as a template

This folder is designed to be copied. Keep the original clean, make a copy for each project:

```
Engineering-Team/              <-- the template (keep clean)
Engineering-Team-MyApp/        <-- copy for your app
Engineering-Team-ClientWork/   <-- copy for client work
```

Each copy gets its own context, its own status, its own memory. They don't interfere. I run multiple projects this way.

---

## Who this is for

| You are | This helps you |
|---|---|
| **Non-technical founder** | Build and sell software without hiring a dev team |
| **VibeCoder** | Add professional guardrails around your AI-generated code |
| **Solo builder** | Ship MVPs to paying clients with production-grade quality |
| **Taking over a codebase** | Audit existing code, find issues, harden it for production |

If you can describe what you want, this team can build it. If you already have code, this team can audit it, fix it, and ship it.

---

## Documentation

| Doc | What it covers |
|---|---|
| **[START-HERE.md](docs/START-HERE.md)** | Full onboarding guide |
| **[PLAYBOOK.md](docs/PLAYBOOK.md)** | Build pipeline, command reference, workflow cheat sheet |
| **[TEAM.md](docs/TEAM.md)** | The full roster, org chart, and how agents work together |

---

## Built by

**Eugene Zhang**

Non-technical founder. Master's in Accounting. Building and selling production software with this team every day.

[![Instagram](https://img.shields.io/badge/Instagram-E4405F?logo=instagram&logoColor=white)](https://www.instagram.com/eugenezhang__/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?logo=linkedin&logoColor=white)](https://www.linkedin.com/in/eugenezhangco/)

If this saves you time or makes you money, a star goes a long way.

---

## License

Proprietary. Personal use only. You may use and modify for your own personal or business purposes. Redistribution, reselling, and public posting are not permitted. See [LICENSE](LICENSE) for full terms.
