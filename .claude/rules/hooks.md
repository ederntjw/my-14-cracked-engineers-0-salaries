---
description: "Hook system guidelines: lifecycle hooks, security hooks, session management"
---
# Hooks System

## Hook Types

- **PreToolUse**: Before tool execution (validation, parameter modification)
- **PostToolUse**: After tool execution (auto-format, checks)
- **Stop**: When session ends (final verification)

## Session Hooks (Installed)

All hooks live in `.claude/hooks/` and share Python detection via `lib-python.sh`, which finds the venv at `~/.claude-tools` (matching `.mcp.json`).

- **SessionStart** (`session-start.sh`): Always-on. Loads:
  - `context/STATUS.md` (first 100 lines, source of truth)
  - Soft MemPalace guidance (when installed) — agent uses judgment about when to query, not a hard mandate
  - Knowledge graph summary (top 25 lines of GRAPH_REPORT.md, lazy-loaded; agent reads full report on demand)
  - `.in-progress` crash recovery notice (only if newer than STATUS.md, indicating /update didn't run since the marker was written)
  - `.session-count` audit suggestion (when 10+ sessions have passed since last `/audit` reset the counter)
  - Last-session flags (memory_saved, status_stale, clean_close)
  - ACTION-ITEMS.md summary (open / in-progress / blocked / critical counts)
  - Triggers `/setup` automatically on first run (placeholder text in STATUS.md)
- **Stop** (`session-stop.sh`): Writes `context/.last-session` with end time and a `memory_saved: likely|unlikely` flag based on whether STATUS.md was updated recently (proxy for whether `/update` ran). Increments `context/.session-count` for the audit-suggestion mechanism. Note: does NOT auto-mine the transcript — MemPalace's API doesn't expose a mining function. Memory persistence happens only via explicit `mempalace_add_drawer` calls during `/update`.
- **PreToolUse / Glob|Grep** (inline in settings.json): When a Graphify graph exists, injects a reminder to consult GRAPH_REPORT.md before searching raw files.
- **PreToolUse / Bash** (`pre-bash-search-detect.sh`): Same reminder, but fires when the agent uses `Bash(grep|find|rg|ag)` to search code, since those bypass the Glob|Grep matcher.
- **PostToolUse** (`post-tooluse-commit-detect.sh`): After `git commit` commands, checks whether the Graphify git post-commit hook is installed. If yes, the AST rebuild already ran. If no, prompts the user to run `graphify hook install`. Always reminds the agent to update STATUS.md (save-before-deliver pattern).

## Per-User State Files (in `context/`, all gitignored)

| File | Written by | Read by | Purpose |
|---|---|---|---|
| `.last-session` | session-stop | session-start | End time, stop reason, status_stale flag, memory_saved flag |
| `.in-progress` | agents (per `in-progress-tracking.md` rule) | session-start | Crash recovery — what was being worked on when session ended |
| `.session-count` | session-stop (increments) | session-start (checks against threshold), `/audit` (resets to 0) | Triggers `/audit` suggestion every 10 sessions |
| `.mempalace-mine.log` | (legacy diagnostic) | manual | Historical diagnostic, no longer actively written |
| `.graphify-rebuild.log` | post-tooluse-commit-detect (graphify hook fallback path) | manual | Diagnostic for failed graphify rebuilds |

## MCP Servers (Configured in .mcp.json)

- **MemPalace**: Persistent cross-session memory. Stores decisions, preferences, discoveries, institutional knowledge. Tools: mempalace_search, mempalace_recall, mempalace_status, and 16 more. Runs locally, no API cost for core operations.
- **Graphify**: Codebase knowledge graph. Maps module relationships, god nodes, communities. Tools: query_graph, get_node, get_neighbors, get_community, god_nodes, graph_stats, shortest_path. Runs locally from graph.json.

## Auto-Checkpoint (MANDATORY)

The team MUST save context to `context/STATUS.md` automatically at key moments. Do not wait for the user to ask. Do not skip this. Context loss between sessions is unacceptable for a founder who depends on continuity.

**Checkpoint triggers (auto-save STATUS.md when ANY of these happen):**
- After a PLAN is approved by the user
- After each completed build wave or major task
- After the QA chain produces a verdict (SHIP or HOLD)
- Before switching to a different feature or domain
- After any architectural decision
- When 20+ tool uses have passed since the last checkpoint
- When the conversation is approaching context compression

**What to save (update STATUS.md every time):**
- What was built or changed (summary with file names)
- Key decisions made and why
- Current pipeline position (where in the build flow)
- Open items or blockers
- Any unfinished work that should be resumed next session

**Format:** Update STATUS.md silently. Tell the user in one line: "Checkpointed." Then keep working. Do not make a production out of it.

**Why this matters:** If a session dies, the next session starts from the last checkpoint. The founder should never have to re-explain what was happening. STATUS.md is the team's memory between sessions — treat it like saving a game.

## Auto-Accept Permissions

Use with caution:
- Enable for trusted, well-defined plans
- Disable for exploratory work
- Never use dangerously-skip-permissions flag
- Configure `allowedTools` in `~/.claude.json` instead

## TodoWrite Best Practices

Use TodoWrite tool to:
- Track progress on multi-step tasks
- Verify understanding of instructions
- Enable real-time steering
- Show granular implementation steps

Todo list reveals:
- Out of order steps
- Missing items
- Extra unnecessary items
- Wrong granularity
- Misinterpreted requirements
