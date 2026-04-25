#!/bin/bash
# SessionStart hook: inject STATUS.md + MemPalace directives + Graphify content into every session.
# MemPalace and Graphify checks run FIRST — before first-run detection — so they always fire.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
STATUS_FILE="$PROJECT_DIR/context/STATUS.md"
ACTION_ITEMS_FILE="$PROJECT_DIR/context/ACTION-ITEMS.md"
LAST_SESSION="$PROJECT_DIR/context/.last-session"
IN_PROGRESS="$PROJECT_DIR/context/.in-progress"
SESSION_COUNT="$PROJECT_DIR/context/.session-count"
GRAPH_REPORT="$PROJECT_DIR/graphify-out/GRAPH_REPORT.md"
AUDIT_THRESHOLD=10

# Source the shared Python detection helper.
# This finds the venv interpreter that .mcp.json actually uses,
# so we don't lie about MemPalace/Graphify being "not installed" when they are.
HOOK_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=lib-python.sh
source "$HOOK_DIR/lib-python.sh"

CONTEXT=""

# --- MEMPALACE (always runs, even on first session) ---
# Softer guidance: agent uses judgment rather than calling on every session.
# Avoids wasted MCP calls on simple status queries / fresh projects.
if [ "$(mempalace_available)" = "yes" ]; then
  CONTEXT="${CONTEXT}--- MEMORY SYSTEM (MemPalace available) ---
Use MemPalace MCP tools when:
  - The user asks about architectural choices, prior decisions, or past work
  - You're about to make a non-trivial decision (call mempalace_search first to check for prior decisions on the topic)
  - The user references something from a previous session
  - Starting work in an unfamiliar domain area
Skip for: simple status queries, trivial requests, brand-new projects with no prior history.
Saves happen explicitly via /update — do not save mid-conversation unless the user says so.\n\n"
else
  CONTEXT="${CONTEXT}--- MEMORY SYSTEM ---
MemPalace: NOT INSTALLED. Cross-session memory unavailable.
To enable: run /setup (the team handles venv creation + install).\n\n"
fi

# --- GRAPHIFY (always runs, even on first session) ---
# When a graph exists, inject the actual GRAPH_REPORT content — not just metadata.
# This gives real architecture data upfront instead of telling Claude to go find it.
PY_FOR_GRAPH=$(find_python_with graphify 2>/dev/null || echo "python3")
if [ -f "$PROJECT_DIR/graphify-out/graph.json" ]; then
  GRAPH_MOD=$(stat -f '%Sm' -t '%Y-%m-%d %H:%M' "$PROJECT_DIR/graphify-out/graph.json" 2>/dev/null \
    || stat -c '%y' "$PROJECT_DIR/graphify-out/graph.json" 2>/dev/null | cut -d'.' -f1)
  NODE_COUNT=$("$PY_FOR_GRAPH" -c "import json; g=json.load(open('$PROJECT_DIR/graphify-out/graph.json')); print(len(g.get('nodes',[])))" 2>/dev/null)

  if [ -f "$GRAPH_REPORT" ]; then
    # Lazy-load: only inject the first ~25 lines (stats + god nodes section).
    # Agents read the full report on demand for architecture work.
    REPORT_SUMMARY=$(head -25 "$GRAPH_REPORT")
    CONTEXT="${CONTEXT}--- KNOWLEDGE GRAPH (ACTIVE) ---
Graph last rebuilt: $GRAPH_MOD | Nodes: ${NODE_COUNT:-unknown}
Before searching code with grep/glob, consult the graph: read graphify-out/GRAPH_REPORT.md in full,
or use Graphify MCP tools (get_neighbors, shortest_path, query_graph) for targeted lookups.

Summary (top of GRAPH_REPORT.md):
${REPORT_SUMMARY}
--- END KNOWLEDGE GRAPH ---\n\n"
  else
    CONTEXT="${CONTEXT}--- KNOWLEDGE GRAPH ---
Graphify: ACTIVE. Last rebuilt: $GRAPH_MOD. Nodes: ${NODE_COUNT:-unknown}.
GRAPH_REPORT.md missing — run 'graphify $PROJECT_DIR' to regenerate.\n\n"
  fi
elif [ "$(graphify_available)" = "yes" ]; then
  CONTEXT="${CONTEXT}--- KNOWLEDGE GRAPH ---
Graphify: INSTALLED but no graph built yet.
Run '$(find_cli graphify) $PROJECT_DIR' to build the initial knowledge graph.\n\n"
else
  CONTEXT="${CONTEXT}--- KNOWLEDGE GRAPH ---
Graphify: NOT INSTALLED. Codebase graph unavailable.
To enable: run /setup (the team handles venv creation + install).\n\n"
fi

# --- FIRST-RUN DETECTION ---
# Runs AFTER memory/graph checks so those are always included in context.
if [ -f "$STATUS_FILE" ]; then
  HAS_PLACEHOLDER=$(grep '\[PROJECT NAME\]' "$STATUS_FILE" 2>/dev/null)
  if [ -n "$HAS_PLACEHOLDER" ]; then
    ONBOARD_MSG="FIRST_RUN_DETECTED: This is a fresh engineering team — STATUS.md still has placeholder text. The user has never been set up. Do NOT wait for them to ask. Do NOT mention slash commands or technical concepts. Immediately start the onboarding flow by running the /setup command. Greet them like a friendly colleague who is genuinely happy to meet them. They may be completely non-technical and possibly overwhelmed by AI — your job is to make them feel like they're in good hands. Lead them. Ask simple questions one at a time. Never present a menu of options. Always move them forward.

${CONTEXT}"
    ESCAPED=$(echo "$ONBOARD_MSG" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")
    echo "{\"hookSpecificOutput\":{\"additionalContext\":$ESCAPED}}"
    exit 0
  fi
fi

# --- NORMAL SESSION LOAD ---

# --- IN-PROGRESS CRASH RECOVERY ---
# .in-progress is written by agents starting multi-step tasks (see in-progress-tracking.md rule).
# It's only meaningful if STATUS.md hasn't been updated since — otherwise /update has run and cleared things.
if [ -f "$IN_PROGRESS" ]; then
  IP_MOD=$(stat -f %m "$IN_PROGRESS" 2>/dev/null || stat -c %Y "$IN_PROGRESS" 2>/dev/null || echo 0)
  STATUS_MOD=0
  if [ -f "$STATUS_FILE" ]; then
    STATUS_MOD=$(stat -f %m "$STATUS_FILE" 2>/dev/null || stat -c %Y "$STATUS_FILE" 2>/dev/null || echo 0)
  fi
  if [ "$IP_MOD" -gt "$STATUS_MOD" ]; then
    IP_CONTENT=$(cat "$IN_PROGRESS" 2>/dev/null)
    CONTEXT="${CONTEXT}--- CRASH RECOVERY ---
Previous session may have ended mid-task. The .in-progress marker says:
  ${IP_CONTENT}
Ask the user if this work was completed or if they want to resume. Either clear .in-progress
(if done/abandoned) or pick up where it left off.\n\n"
  fi
  # If STATUS.md is newer, /update ran — silently leave the file alone (user can clear via /update again or manually)
fi

# --- SESSION COUNTER + AUDIT SUGGESTION ---
# Counter increments on session-stop. When it crosses the threshold, suggest /audit.
# /audit resets the counter back to 0 (see audit.md skill).
if [ -f "$SESSION_COUNT" ]; then
  COUNT=$(cat "$SESSION_COUNT" 2>/dev/null | tr -d '[:space:]')
  # Defensive: default to 0 if file is empty or non-numeric
  case "$COUNT" in
    ''|*[!0-9]*) COUNT=0 ;;
  esac
  if [ "$COUNT" -ge "$AUDIT_THRESHOLD" ]; then
    CONTEXT="${CONTEXT}--- MAINTENANCE SUGGESTION ---
$COUNT sessions have passed since the last codebase audit.
When convenient, mention to the user: 'It's been a while since we did a health check — want me to run a quick audit?'
If they agree, run /audit (which will reset this counter). If they decline or you forget,
no harm done — this notice will appear again next session.\n\n"
  fi
fi

# Last-session flags
if [ -f "$LAST_SESSION" ]; then
  STALE=$(grep 'status_stale: true' "$LAST_SESSION" 2>/dev/null)
  LAST_ENDED=$(grep 'last_ended:' "$LAST_SESSION" | cut -d' ' -f2-)
  CLEAN_CLOSE=$(grep 'clean_close: true' "$LAST_SESSION" 2>/dev/null)

  SESSION_NOTICE=""
  if [ -n "$STALE" ]; then
    SESSION_NOTICE="NOTICE: Last session ended at $LAST_ENDED WITHOUT running /update. STATUS.md may be stale. Check with the user or run /status.\n\n"
  elif [ -n "$LAST_ENDED" ]; then
    SESSION_NOTICE="Last session ended: $LAST_ENDED\n\n"
  fi

  if [ -z "$CLEAN_CLOSE" ] && [ -n "$LAST_ENDED" ]; then
    SESSION_NOTICE="${SESSION_NOTICE}MEMORY_RECOVERY: Last session did not close cleanly. After calling mempalace_status, ask the user what they were working on and offer to /update to save anything important.\n\n"
  fi

  # Check if last session ended without /update running
  MEMORY_UNLIKELY=$(grep 'memory_saved: unlikely' "$LAST_SESSION" 2>/dev/null)
  if [ -n "$MEMORY_UNLIKELY" ]; then
    SESSION_NOTICE="${SESSION_NOTICE}MEMORY_GAP: Previous session ended without running /update — important context may not have been saved to MemPalace. After loading status, consider asking the user what they were working on and whether anything still needs to be remembered.\n\n"
  fi

  CONTEXT="${SESSION_NOTICE}${CONTEXT}"
  rm -f "$LAST_SESSION"
fi

# STATUS.md (first 100 lines — source of truth for current session)
if [ -f "$STATUS_FILE" ]; then
  STATUS_CONTENT=$(head -100 "$STATUS_FILE")
  CONTEXT="${STATUS_CONTENT}\n\n${CONTEXT}"
fi

# ACTION-ITEMS.md summary
if [ -f "$ACTION_ITEMS_FILE" ]; then
  OPEN_COUNT=$(grep -c '^\- \*\*Status:\*\* open' "$ACTION_ITEMS_FILE" 2>/dev/null || echo 0)
  IN_PROGRESS_COUNT=$(grep -c '^\- \*\*Status:\*\* in-progress' "$ACTION_ITEMS_FILE" 2>/dev/null || echo 0)
  BLOCKED_COUNT=$(grep -c '^\- \*\*Status:\*\* blocked' "$ACTION_ITEMS_FILE" 2>/dev/null || echo 0)
  CRITICAL_COUNT=$(grep -B1 '^\- \*\*Priority:\*\* critical' "$ACTION_ITEMS_FILE" 2>/dev/null | grep -c '^\### \[AI-' || echo 0)

  if [ "$OPEN_COUNT" -gt 0 ] || [ "$IN_PROGRESS_COUNT" -gt 0 ] || [ "$BLOCKED_COUNT" -gt 0 ]; then
    CONTEXT="${CONTEXT}\n--- ACTION ITEMS ---\nOpen: $OPEN_COUNT | In Progress: $IN_PROGRESS_COUNT | Blocked: $BLOCKED_COUNT | Critical: $CRITICAL_COUNT\nRead context/ACTION-ITEMS.md for full details.\n"
  fi
fi

if [ -n "$CONTEXT" ]; then
  ESCAPED=$(echo "$CONTEXT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")
  echo "{\"hookSpecificOutput\":{\"additionalContext\":$ESCAPED}}"
fi
