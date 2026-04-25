# Meet the Team

Your 14 engineers. Each one has a name, a specialty, and a playbook in `agents/`.

```
                         ┌─────────────────┐
                         │    YOU (Boss)    │
                         └────────┬────────┘
                                  │
              ┌───────────────────┼───────────────────┐
              │                   │                   │
     ┌────────┴────────┐ ┌───────┴───────┐ ┌────────┴────────┐
     │  Maya            │ │  Jake          │ │  Sara            │
     │  Head of Strategy│ │  Lead Planner  │ │  Lead Architect  │
     └────────┬────────┘ └───────┬───────┘ └────────┬────────┘
              │                   │                   │
              │          ┌────────┴────────────────────┘
              │          │
   ┌──────────┴──────────┴──────────────────────────────────────┐
   │                      THE BUILD TEAM                         │
   │                                                             │
   │  Max (Testing)    Nina (Code Review)    Elena (Security)    │
   │  Liam (Frontend)  Tom (Build/DevOps)    Aisha (E2E/QA)     │
   │  Yuki (Refactor)  Rachel (Docs)                             │
   │                                                             │
   ├─────────────────────────────────────────────────────────────┤
   │                     THE DATA TEAM                            │
   │                                                             │
   │  Andre (Database)   Fatima (Data Pipelines)                 │
   │                                                             │
   ├─────────────────────────────────────────────────────────────┤
   │                     AUDITING                                 │
   │                                                             │
   │  Dave (Codebase Auditor)                                    │
   └─────────────────────────────────────────────────────────────┘
```

## The roster

| Name | Role | Playbook | When they show up |
|------|------|----------|-------------------|
| **Maya** | Head of Strategy | `agents/strategist.md` | New project kickoff, new requirements, "figure out how to build this" |
| **Jake** | Lead Planner | `agents/planner.md` | "Plan this out", breaking features into steps |
| **Sara** | Lead Architect | `agents/architect.md` | System design, "how should I structure this?" |
| **Max** | Test Engineer | `agents/tdd-guide.md` | Writing tests, TDD workflow, new features |
| **Nina** | Code Reviewer | `agents/code-reviewer.md` | "Review this code", after any build |
| **Elena** | Security Lead | `agents/security-reviewer.md` | "Is this safe?", before deploys, auth/API work |
| **Tom** | Build/DevOps Engineer | `agents/build-fixer.md` | "Build is failing", TypeScript errors, red terminal |
| **Aisha** | QA Lead | `agents/e2e-runner.md` | "Run the tests", "test the login flow" |
| **Liam** | Frontend Engineer | `agents/ui-builder.md` | Any UI work — landing pages, dashboards, components |
| **Yuki** | Refactor Specialist | `agents/refactor-cleaner.md` | "Clean this up", dead code, duplicates |
| **Rachel** | Technical Writer | `agents/doc-updater.md` | "Update the docs", after API/schema changes |
| **Andre** | Database Architect | `agents/database-reviewer.md` | "This query is slow", schema design, DB review |
| **Fatima** | Data Engineer | `agents/data-engineer.md` | Pipelines, new data sources, ETL, entity resolution |
| **Dave** | Codebase Auditor | `agents/codebase-auditor.md` | "Review the codebase", "what needs fixing?" |

## How the team communicates

When a team member activates, they introduce themselves at the start:

> **Nina here** — reviewing your latest changes.

> **Tom here** — let me look at that build error.

You always know who is working on what. If multiple people are needed (like Jake and Sara for planning), they both check in.

## How they work together

The build pipeline moves work through the team:

1. **Maya** reads new context and sets direction
2. **Jake** breaks it into tasks, **Sara** designs the architecture — both query the knowledge graph (Graphify) for affected modules and institutional memory (MemPalace) for prior decisions
3. **Max** writes tests, **Liam** builds the frontend, **Fatima** handles data pipelines
4. **Nina** reviews the code (using the graph for blast radius assessment), **Elena** checks security
5. **Aisha** runs E2E tests, **Tom** fixes any build errors (using the graph to trace dependency chains and memory for similar past bugs)
6. **Rachel** updates the docs, **Andre** optimizes the database
7. **Dave** audits the whole thing when you need a health check — using the full knowledge graph as his primary navigation tool

You don't manage them. Describe what you want and the right people show up.

## Long-term memory

The team has two systems that persist knowledge across sessions:

- **MemPalace** — stores decisions, preferences, rejected approaches, stakeholder constraints, and institutional knowledge. The team explicitly persists key items via `mempalace_add_drawer` during `/update` (there is no auto-mining). A new session knows what you told the team three months ago.
- **Graphify** — maps the codebase structure: how modules connect, which are core abstractions, which areas are tightly coupled. Auto-rebuilds on every commit via a Git post-commit hook installed during `/setup`. A new session understands the architecture in seconds, not minutes.

Both are optional. The first-run `/setup` flow installs them into an isolated virtualenv at `~/.claude-tools` (matching `.mcp.json`) — you never touch system Python.
