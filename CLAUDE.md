# Eugene's Engineering Team

This is Eugene's engineering team. Open Claude Code in any project and you get 14 specialist agents that strategize, plan, build, review, test, and ship production software. Every agent teaches while it works, so you learn the craft as you build.

> **First time here?** Run `/setup` for a guided first-run that populates your project context and STATUS.md.
> Or fill in the `PROJECT CONTEXT` section below manually, then run `/status` to get started.

---

## PROJECT CONTEXT

> **Fill this section in before your first build session.**
> Replace every [PLACEHOLDER] with your project's real information.
> This section is the only thing that changes between projects. Everything else is generic.

**Project name:** [PROJECT NAME]
**What it is:** [What the project does — 1-2 sentences. What problem it solves, for whom.]
**Current phase:** [Phase description — e.g., "Greenfield build, starting from scratch" / "MVP done, now scaling" / "Existing codebase, taking over development"]
**Key stakeholders:** [Your Name] (CTO/Builder), [Partner/Client Name] (Domain/Commercial)

### The Story So Far

[Write 2-3 sentences about how this project came to be. Who had the idea, why it matters, what's been confirmed. This grounds the team in the project's origin and motivation.]

### What Exists Today

[Describe what's already built. If starting from scratch: "Nothing yet — greenfield build." If MVP done: list key components, tech stack, what works. If taking over: describe the existing codebase.]

### What Comes Next

[List the next 3-5 milestones in order. Be specific: "Connect [Data Source]", "Build landing page", "Deploy to staging", etc.]

### Onboarding Checklist

When the engineering team opens this project:
1. Read `context/STATUS.md` first (the living source of truth — project status, decisions, what's next)
2. Read `context/ACTION-ITEMS.md` (all outstanding action items — what needs doing, priority, source)
3. Check `context/inbox/` for any unprocessed documents
4. Check `context/sessions/` for any handoff files with `status: ready` — load with `/pull` before planning
5. Review the codebase for current state (if one exists)
6. Check `context/decisions/` for architectural and scope decisions already made
7. Resume work from where the team left off

---

## Core Principles

| Principle | What It Means |
|-----------|---------------|
| Agent-first | Every task has a specialist. Describe what you want. The right agent activates. |
| Test-driven | Tests get written BEFORE code. If it is not tested, it does not exist. |
| Security-first | No shortcuts. Secrets stay in .env. Inputs get validated. Queries get parameterized. Always. |
| Teach while building | Every agent explains what it did and why, in plain English. You are learning engineering by building real things. |
| Production-first | Nothing ships half-baked. Error handling, loading states, edge cases from day one. |

---

## Available Agents

Each agent lives in `agents/[name].md`. Claude reads them automatically when the task matches.

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| **strategist** | **Translate business context into phased build plans** | **New context arrives, "figure out how to build this"** |
| **codebase-auditor** | **Audit existing codebases for quality, security, and improvement opportunities** | **"Review the codebase", "What needs fixing?", onboarding to existing code** |
| **ui-builder** | **Build responsive landing pages, dashboards, and web interfaces** | **Any frontend work** |
| planner | Break features into buildable steps | "I want to add [feature]", "Plan this out" |
| architect | Design system structure and data flow | "How should I structure this?", "Design the backend for X" |
| tdd-guide | Write tests before writing code | "Let's build X with tests", "Write tests for this feature" |
| code-reviewer | Review code for quality and bugs | "Review this code", "Is this good?", after any significant build |
| security-reviewer | Find security holes before they become problems | "Check security", "Is this safe?", before any deploy |
| build-fixer | Fix TypeScript errors and broken builds | "Build is failing", "Fix these errors", red terminal output |
| e2e-runner | Run and manage Playwright browser tests | "Run the tests", "Test the login flow" |
| refactor-cleaner | Remove dead code, fix duplicates, clean structure | "Clean this up", "There is duplicate code" |
| doc-updater | Keep docs in sync with code changes | "Update the docs", after API or schema changes |
| database-reviewer | Optimize PostgreSQL/Supabase queries and schemas | "Review my database", "This query is slow" |
| data-engineer | Build data connectors, ETL pipelines, entity resolution | Pipeline work, new data sources, data ingestion |

---

## Session Types

There are two types of sessions. Know which one you're in before doing anything.

**Brainstorm session** — thinking, deciding, exploring. No structure required. Ends with `/wrap [topic]`, which exports all decisions to `context/sessions/` as a structured handoff file for import into a build session.

**Build session** — executing. Always follows the workflow below in order. Never skip steps.

---

## Development Workflow

Every build session follows this pipeline in order. No skipping steps.

```
/status → /inbox → /pull → /plan → [BUILD] → /devils-advocate → /review → /verify → /update
```

1. **`/status`**: Read STATUS.md. Check for unprocessed inbox files and ready brainstorm handoffs in `context/sessions/`.
2. **`/inbox`**: Process any new documents in `context/inbox/`. If build-relevant, write an AI brief to `context/sessions/`.
3. **`/pull`**: If a handoff file exists in `context/sessions/` with `status: ready`, load it and route to /plan.
4. **`/plan`** (planner + architect): Break work into tasks with Given/When/Then acceptance criteria and a Boundaries list. Write a PLAN file to `context/builds/` once approved. **No code before approval.**
5. **Build** (tdd-guide + ui-builder): Tests first, then code. On completion, run automatic reconciliation — PLAN vs. delivered. Flag every deviation and get sign-off before proceeding.
6. **`/devils-advocate`**: Adversarial review before tests. Two engineers debate the diff across six topics: correctness → error handling → performance → security → maintainability → testing gaps.
7. **`/review`** (code-reviewer + security-reviewer): Checklist pass — security, quality, project-specific patterns. Verdict: APPROVE / WARNING / BLOCK.
8. **`/verify`**: Run tests AND check every acceptance criterion from the PLAN file. Write RESULT to `context/builds/`. Verdict: PASS / PARTIAL / FAIL. This replaces running `/test` separately.
9. **`/update`**: Save all decisions, progress, and context to STATUS.md and memory. Last command of every session. Never skip.

**Periodic commands** (not every build): `/audit` (spec compliance), `/pipeline` (data ingestion), `/deploy` (ship), `/milestone` (progress report).

---

## Context System

The project's knowledge base lives in `context/`. It handles all incoming documents, decisions, and evolving requirements.

### How It Works

1. **Drop files into `context/inbox/`** — PDFs, Word docs, Excel, PowerPoints, email threads, screenshots, anything
2. **Say "check the inbox"** (or "new stuff", "read the updates", etc.)
3. **The strategist reads everything**, briefs you in plain English, and asks clarifying questions
4. **Files get sorted** into the right folder and **STATUS.md gets updated**
5. If scope or direction changed, the **planner** updates the build plan
6. All decisions are logged in `context/decisions/` so the team can trace why something was built a certain way

### Verbal context works too

Share notes from conversations, lunches, phone calls, or text messages directly in chat. The team captures these and files them properly (usually in `context/communications/`).

### Folder Structure

| Folder | Purpose |
|--------|---------|
| `context/STATUS.md` | **THE source of truth. Always current. Read this first every session.** |
| `context/ACTION-ITEMS.md` | **Persistent action item tracker. Every task from first mention to completion.** |
| `context/inbox/` | Drop zone. Unprocessed files go here. |
| `context/sessions/` | Brainstorm handoff files. Written by `/wrap`, loaded by `/pull`. Check for `status: ready` at session start. |
| `context/builds/` | Build records. PLAN files (written after /plan approval) and RESULT files (written by /verify). |
| `context/stakeholders/` | Profiles of people involved in the project |
| `context/decisions/` | Key decisions and WHY they were made |
| `context/requirements/` | What needs to be built, organized by phase |
| `context/communications/` | Email threads, meeting notes, conversation summaries |
| `context/archive/` | Historical documents (read once, reference later) |

Folders are **dynamic** — new ones can be added as the project evolves.

See `context/README.md` for the full guide.

---

## Coding Style Rules

These apply to every line of code every agent writes.

### Files
- One component per file. One function per function. Small and focused.
- File names: kebab-case.ts for utilities, PascalCase.tsx for React components.
- Maximum 300 lines per file. If longer, split it.

### TypeScript
- Strict mode always. No "any" types unless absolutely unavoidable (and commented why).
- Use "const" by default. Never "var". Use "let" only when reassignment is required.
- Prefer immutable patterns: spread operators, .map(), .filter() over mutation.
- Every function has explicit return types. No implicit "any".
- Use descriptive names. getUserById not getUser. isAuthenticated not check.

### React / Next.js
- Server Components by default. Client Components only when you need interactivity (onClick, useState, useEffect).
- Use the App Router (app/ directory). Never Pages Router for new projects.
- Loading and error states for every async operation. No blank screens.
- Validate all form inputs on both client and server.

### Error Handling
- Every async function gets a try/catch or .catch().
- User-facing errors get friendly messages. Technical details go to logs.
- Never swallow errors silently. Log them, handle them, or rethrow them.
- Use error boundaries in React for graceful failure.

### Code Organization

Recommended project structure:

- src/app/ for Next.js routes and pages
- src/components/ for reusable UI components
- src/lib/ for business logic, utilities, helpers
- src/types/ for TypeScript type definitions
- src/hooks/ for custom React hooks (client-side only)
- src/actions/ for server actions
- src/middleware.ts for auth, redirects, rate limiting

---

## Security Rules

Non-negotiable. Every agent enforces these.

| Rule | Why |
|------|-----|
| No hardcoded secrets | Secrets in code get leaked. Always use .env files and process.env. |
| Validate all inputs | Users send garbage. APIs send garbage. Validate everything with Zod or similar. |
| Parameterized queries | SQL injection is the #1 database attack. Never concatenate user input into queries. |
| Sanitize outputs | Cross-site scripting (XSS) lets attackers inject code into your pages. Sanitize all user-generated content. |
| Auth on every protected route | Check authentication server-side. Never trust the client. |
| Rate limiting on APIs | Without limits, anyone can spam your endpoints and run up your bill or crash your app. |
| HTTPS only | Unencrypted traffic can be intercepted. Force HTTPS everywhere. |
| .env in .gitignore | Never commit secrets to git. Ever. Check .gitignore before first commit. |

---

## Testing Requirements

- Target: 80% code coverage minimum. Not vanity. Safety.
- TDD workflow: Write the test. Watch it fail (red). Write the code. Watch it pass (green). Clean up (refactor).
- Unit tests: Every utility function, every business logic function.
- Integration tests: API routes, database queries, form submissions.
- E2E tests: Critical user flows (sign up, log in, core feature, payment).
- Test file naming: [filename].test.ts or [filename].spec.ts, colocated with the source file.

---

## Git Workflow

Conventional commits. Every commit message follows this pattern:

type(scope): short description

Examples:
- feat(auth): add Google OAuth login
- fix(dashboard): resolve chart rendering on mobile
- test(api): add integration tests for user endpoints
- docs(readme): update setup instructions
- refactor(lib): extract validation into shared utility

Types: feat, fix, test, docs, refactor, chore, style, perf

Branch naming: feat/feature-name, fix/bug-name, refactor/what-changed

---

## How This Works

Here is what is actually happening, in plain English.

**What is this folder?**
Think of it as hiring an engineering team that lives inside your computer. Instead of one AI assistant, you get 14 specialists. A planner, an architect, a security expert, a tester, and so on. Each one knows their job and does it well.

**What happens when you open Claude Code here?**
Claude reads this file (CLAUDE.md) first. It is like a briefing document. Claude now knows: what the project is, what has been built, what agents are available, what coding standards to follow, and what security rules to enforce. Every conversation starts with Claude already knowing the playbook.

**How do agents get invoked?**
You do not need to memorize commands. Just describe what you want in normal English:
- "I want to build a dashboard" triggers the planner, then the architect
- "This is broken" triggers the build-fixer
- "Is this secure?" triggers the security-reviewer
- "What did you just do?" triggers the explainer

Claude reads the agent files and follows their instructions. You stay in the driver seat.

**What about documents and files?**
Drop them into `context/inbox/`. Tell the team "check the inbox". The strategist reads them, briefs you in plain English, and the team adjusts the plan accordingly. You do not need to translate business documents into technical requirements. That is the team's job.

**What if something breaks?**
Say "the build is failing" or paste the error. The build-fixer agent reads the errors and fixes them. You do not need to understand the error messages yourself. The agents translate.

**What happens the very first time?**
The team detects it is a fresh download (STATUS.md still has placeholder text) and starts onboarding automatically. It asks whether you are building something new or have an existing project, then guides you through setup. This only happens once — after setup, every new session picks up where the last one left off.

---

## Folder Structure

- CLAUDE.md — This file. The team briefing document.
- agents/ — 14 specialist agents
- .claude/ — Rules, skills, hooks, commands
- context/ — Project knowledge base
  - STATUS.md — THE source of truth. Read first every session.
  - ACTION-ITEMS.md — Persistent action item tracker. Every task from mention to completion.
  - inbox/ — Drop zone for new files
  - sessions/ — Brainstorm handoff files
  - builds/ — PLAN and RESULT files per build
  - stakeholders/ — People profiles
  - decisions/ — Key decisions and rationale
  - requirements/ — What to build, by phase
  - communications/ — Emails, meeting notes
  - archive/ — Historical documents
- docs/ — Setup guides and team documentation

---

## Reference Files

- Agent definitions: agents/*.md
- Start here (onboarding guide): docs/START-HERE.md
- Playbook (command reference): docs/PLAYBOOK.md
- Skills: .claude/skills/
- Rules: .claude/rules/
- Project status (source of truth): context/STATUS.md
- Action items (persistent tracker): context/ACTION-ITEMS.md
- Context system guide: context/README.md
