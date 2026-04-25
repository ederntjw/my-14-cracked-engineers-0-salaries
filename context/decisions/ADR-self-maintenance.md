# ADR: Self-Maintenance Architecture for the Engineering Team

**Status:** Accepted
**Date:** 2026-04-26

## Context

The engineering team is used over weeks-to-months of daily sessions to build production software. Three pressures shape what "self-maintenance" can realistically look like:

1. **No autonomous awareness.** Agents cannot run between user messages. The only automatic execution layer is hooks (SessionStart, Stop, PreToolUse, PostToolUse). Hooks are shell scripts — they cannot reason.
2. **No post-response hook exists in Claude Code.** We cannot enforce "scan agent response before delivery." Anything that requires agent judgment must be a rule, not enforcement.
3. **Tokens cost money and time.** Every MCP call, every line of injected context, every hook fire has a cost. Conservative defaults compound across thousands of sessions.

The user has explicitly accepted that some user discipline is required (saying `/update`, `/audit`, etc.) — the goal is not full autonomy, but reliability. When the user does the simple thing, the team should reliably execute everything that needs to happen.

## Decision

Adopt a single design principle:

> **User triggers are atomic. Agent decisions are automatic. The team self-maintains between user touches via lightweight signals, not autonomous reasoning.**

Concretely, four mechanisms implement this:

### 1. Lazy GRAPH_REPORT load
SessionStart injects a 25-line summary of `graphify-out/GRAPH_REPORT.md` (top stats + god nodes), not the full 80 lines. Agents read the full report on demand for architecture work.
- **Rationale:** Most sessions don't need the full graph. ~70% token savings on graph context.

### 2. Soft MemPalace guidance
SessionStart provides judgment-based guidance ("query when relevant, skip for trivial requests"), not a hard "MANDATORY FIRST ACTION" mandate.
- **Rationale:** Mandate forced wasted MCP calls on simple sessions and fresh projects. Trust the agent to use the rule in `.claude/rules/memory-protocol.md` when relevant.

### 3. `.in-progress` crash recovery
Agents write a one-line marker to `context/.in-progress` when starting multi-step tasks (per `.claude/rules/in-progress-tracking.md`). SessionStart surfaces it only if newer than `STATUS.md` — meaning `/update` hasn't run since, suggesting a crash.
- **Rationale:** Real crash recovery without the cost of continuous breadcrumbs. Cleared by `/update` (the natural "everything is saved" boundary).

### 4. Session counter for `/audit` suggestion
session-stop increments `context/.session-count`. SessionStart suggests `/audit` when count ≥ 10. `/audit` resets to 0.
- **Rationale:** Self-maintenance cadence becomes automatic without forcing. Suggestion, not mandate — user can defer.

## Alternatives Considered (and why rejected)

These were battle-tested and dropped:

### Auto-save on every "decision moment" → REJECTED
Rule that agents must call `mempalace_add_drawer` immediately after any architectural choice / preference statement / rejected approach.
- **Failure:** Decision boundaries are too fuzzy. "Let's go with X" could be a real choice or a tentative thought. Risks polluting MemPalace with junk. Plus token cost (~5-10 extra MCP calls per session).
- **Replacement:** Rely on `/update` as the explicit save boundary. Trust user discipline.

### Cascading checkpoints (every STATUS.md checkpoint also saves to MemPalace) → REJECTED
- **Failure:** Redundant with auto-save (which we also rejected), and doubles up on the same scan-and-save cost.

### Inline memory gardening (invalidate stale entries when retrieved) → REJECTED
- **Failure:** "Notice contradiction" requires deep reasoning per memory access. False positives could invalidate good memories. Doesn't address the graveyard problem (memories that don't contradict but became irrelevant).
- **Replacement:** Accept that gardening is explicit — `/audit memory` when the user wants cleanup.

### Continuous breadcrumbs to STATUS.md every 5 tool calls → REJECTED
- **Failure:** Write contention from parallel agents. Self-counted "5 tool calls" trigger doesn't fire reliably. Real cost (~10 extra tool calls per task). Breadcrumbs aren't real recovery — they hint, but don't preserve what was tried/failed.
- **Replacement:** Single `.in-progress` file, one write per task start, one clear per task end.

## Consequences

**Wins:**
- ~1,000 tokens saved per session with a graph (lazy load)
- 1 MCP call saved per simple session (soft mandate)
- Real crash recovery via `.in-progress`
- Self-suggested maintenance cadence via session counter
- User vocabulary stays at the same 3-trigger model: "build X" / "save" / "what's going on?"

**Trade-offs:**
- `.in-progress` reliability depends on agent discipline (writing the marker, clearing on completion). The hook can only observe state, not enforce.
- Audit suggestions can be deferred indefinitely by the user. The counter just keeps incrementing past 10 — they reappear next session.
- Without auto-save, decisions made between `/update` calls are lost if the session crashes. This is accepted as a reasonable cost in exchange for token efficiency and avoiding MemPalace junk.

**What this is NOT:**
- Not autonomous. The team cannot run between user messages.
- Not enforced. Agent rule discipline is the limiting factor for `.in-progress` writes and decision-time MemPalace queries.
- Not gardening. MemPalace cleanup remains an explicit `/audit memory` operation.

## References
- `.claude/rules/in-progress-tracking.md` — protocol for the .in-progress file
- `.claude/rules/hooks.md` — full hook documentation
- `.claude/rules/memory-protocol.md` — MemPalace usage guidelines
- `context/decisions/ADR-memory-system.md` — original memory system design
