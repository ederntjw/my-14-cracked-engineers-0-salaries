# Memory Protocol — What Goes Where

## The Five Persistence Layers

The team has five places to store information. Every piece of data has exactly one primary home. When in doubt, use this table:

| You need to know... | Query this | Not this |
|---|---|---|
| What the codebase looks like structurally | **Graphify MCP** | Don't grep around exploring |
| What modules connect to what you're changing | **Graphify MCP** (get_neighbors, shortest_path) | Don't read every import manually |
| Why a past decision was made | **MemPalace MCP** (mempalace_search) | Don't hope it's in an ADR |
| What the user prefers or dislikes | **MemPalace MCP** | Don't ask the user again |
| What was tried and failed before | **MemPalace MCP** | Don't repeat the experiment |
| What's currently in progress | **STATUS.md** | Don't query MemPalace for session-level state |
| What the next tasks are | **ACTION-ITEMS.md** | Don't query MemPalace for task lists |
| The formal rationale for a major choice | **context/decisions/ ADR** | MemPalace has the informal version |

**Simple rule:** "What does the code look like?" → Graphify. "What happened in the past?" → MemPalace. "What's happening right now?" → STATUS.md.

## What Goes Where (Routing Table)

| What happened | Where it goes | When saved | Who saves it |
|---|---|---|---|
| Task completed or started | STATUS.md | Immediately after completion | Agent who finished |
| Specific next step exists | ACTION-ITEMS.md | When identified | Agent who identifies it |
| Architectural choice made | context/decisions/ ADR AND MemPalace | ADR: immediately. MemPalace: session-end mining | Sara (ADR), stop hook (MemPalace) |
| User stated a preference | MemPalace only | Auto-mined at session end | Stop hook |
| Something tried and rejected | MemPalace only | Auto-mined at session end | Stop hook |
| Stakeholder constraint mentioned | MemPalace AND ACTION-ITEMS.md if actionable | Auto + immediately | Stop hook + relevant agent |
| Code committed | Graphify AST rebuild | Automatically via post-commit hook | Hook (no agent involved) |
| Docs or architecture changed significantly | Graphify semantic re-extraction | Manually triggered or during /audit | Dave or Sara |
| Build plan approved | context/builds/ PLAN file AND STATUS.md | Immediately after approval | Jake |
| QA produced a verdict | context/builds/ RESULT file AND STATUS.md | Immediately after verdict | Aisha |
| Brainstorm session ended | context/sessions/ wrap file | When user says "let's stop" | Maya |
| New documents processed | Sorted from context/inbox/ | During /inbox processing | Maya |

## Save-Before-Deliver Pattern (MANDATORY)

When an agent completes a meaningful piece of work (build wave, plan, QA verdict), it MUST update STATUS.md BEFORE presenting results to the user. This ensures that if the session dies after the user sees the output, the context is already saved.

**Flow:**
```
Agent completes work
  → Update STATUS.md (what was built, what's next)
  → Update ACTION-ITEMS.md (remaining tasks)
  → THEN present results to the user
```

This is not optional. It is the same weight as "no code without tests."

## When to Query MemPalace

Query MemPalace BEFORE:
- Making architectural decisions (check for prior decisions on the same topic)
- Suggesting a technology, library, or approach (check if it was tried and rejected)
- Planning a feature (check for related past work, user preferences, stakeholder constraints)
- Starting work in a domain you haven't touched this session (check for context from prior sessions)

Do NOT query MemPalace for:
- Current session state (use STATUS.md)
- Code structure (use Graphify)
- Things you can see in the code (read the file instead)

## When to Query Graphify

Query Graphify BEFORE:
- Exploring unfamiliar parts of the codebase (read GRAPH_REPORT.md first)
- Planning changes that might affect multiple modules (use get_neighbors to check blast radius)
- Debugging (use shortest_path to trace dependency chains)
- Building new features (check which community the new code belongs to, what god nodes it should connect to)

Do NOT query Graphify for:
- Small, localized changes where you already know the file
- Non-code tasks (documentation, planning, brainstorming)
- When the graph hasn't been built yet (fall back to normal file exploration)

## MemPalace Wing/Room Convention

Each project gets one **wing**. Rooms are created automatically from conversation topics. The default rooms defined in `mempalace.yaml` are:
- architecture, decisions, preferences, stakeholders, bugs, features, performance, security, deployment, data

When explicitly saving to MemPalace (during /update), use the most specific room that fits. If none fits, let MemPalace auto-categorize.

## Graceful Degradation

If MemPalace is not installed: fall back to context/decisions/ ADRs and STATUS.md. The team still works — it just doesn't have cross-session institutional memory.

If Graphify is not installed: fall back to normal file exploration (Glob, Grep, Read). The team still works — it just explores the codebase from scratch each session.

Neither tool is required for the team to function. They are upgrades that make the team dramatically more effective over time, not hard dependencies.
