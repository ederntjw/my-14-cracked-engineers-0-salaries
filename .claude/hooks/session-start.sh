#!/bin/bash
# SessionStart hook: inject STATUS.md + MemPalace memory + Graphify status into every new session
# The engineering team picks up where it left off — with full institutional memory and codebase awareness.
# On first-ever run (STATUS.md still has placeholders), triggers auto-onboarding.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
STATUS_FILE="$PROJECT_DIR/context/STATUS.md"
ACTION_ITEMS_FILE="$PROJECT_DIR/context/ACTION-ITEMS.md"
LAST_SESSION="$PROJECT_DIR/context/.last-session"
GRAPH_REPORT="$PROJECT_DIR/graphify-out/GRAPH_REPORT.md"
MEMPALACE_CONFIG="$PROJECT_DIR/mempalace.yaml"

CONTEXT=""

# --- FIRST-RUN DETECTION ---
# If STATUS.md still has placeholder text, this is a brand new download.
# Trigger auto-onboarding instead of the normal session load.
if [ -f "$STATUS_FILE" ]; then
  HAS_PLACEHOLDER=$(grep '\[PROJECT NAME\]' "$STATUS_FILE" 2>/dev/null)
  if [ -n "$HAS_PLACEHOLDER" ]; then
    ONBOARD_MSG="FIRST_RUN_DETECTED: This is a fresh engineering team — STATUS.md still has placeholder text. The user has never been set up. Do NOT wait for them to ask. Do NOT mention slash commands or technical concepts. Immediately start the onboarding flow by running the /setup command. Greet them like a friendly colleague who is genuinely happy to meet them. They may be completely non-technical and possibly overwhelmed by AI — your job is to make them feel like they're in good hands. Lead them. Ask simple questions one at a time. Never present a menu of options. Always move them forward."
    ESCAPED=$(echo "$ONBOARD_MSG" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")
    echo "{\"hookSpecificOutput\":{\"additionalContext\":$ESCAPED}}"
    exit 0
  fi
fi

# --- NORMAL SESSION LOAD ---

# Load last-session flag if it exists
if [ -f "$LAST_SESSION" ]; then
  STALE=$(grep 'status_stale: true' "$LAST_SESSION" 2>/dev/null)
  LAST_ENDED=$(grep 'last_ended:' "$LAST_SESSION" | cut -d' ' -f2-)
  CLEAN_CLOSE=$(grep 'clean_close: true' "$LAST_SESSION" 2>/dev/null)

  if [ -n "$STALE" ]; then
    CONTEXT="NOTICE: Last session ended at $LAST_ENDED WITHOUT running /update. STATUS.md may be stale. Ask the user what was worked on or run /status to check.\n\n"
  elif [ -n "$LAST_ENDED" ]; then
    CONTEXT="Last session ended: $LAST_ENDED\n\n"
  fi

  # --- RECOVERY MINING ---
  # If last session didn't close cleanly, flag it for memory recovery.
  # The team should query MemPalace to check if memories were mined from the last session.
  # If not, offer to mine the transcript from ~/.claude/projects/
  if [ -z "$CLEAN_CLOSE" ] && [ -n "$LAST_ENDED" ]; then
    CONTEXT="${CONTEXT}MEMORY_RECOVERY: Last session may not have been mined to MemPalace (no clean close detected). If MemPalace MCP is available, check mempalace_status to verify last mine timestamp. If the last mine is older than the last session, consider mining the previous session transcript from ~/.claude/projects/ to recover any lost institutional memory.\n\n"
  fi

  rm -f "$LAST_SESSION"
fi

# Load STATUS.md (first 100 lines)
if [ -f "$STATUS_FILE" ]; then
  STATUS_CONTENT=$(head -100 "$STATUS_FILE")
  CONTEXT="${CONTEXT}${STATUS_CONTENT}"
fi

# Load ACTION-ITEMS.md summary (open + in-progress + blocked sections)
if [ -f "$ACTION_ITEMS_FILE" ]; then
  OPEN_COUNT=$(grep -c '^\- \*\*Status:\*\* open' "$ACTION_ITEMS_FILE" 2>/dev/null || echo 0)
  IN_PROGRESS_COUNT=$(grep -c '^\- \*\*Status:\*\* in-progress' "$ACTION_ITEMS_FILE" 2>/dev/null || echo 0)
  BLOCKED_COUNT=$(grep -c '^\- \*\*Status:\*\* blocked' "$ACTION_ITEMS_FILE" 2>/dev/null || echo 0)
  CRITICAL_COUNT=$(grep -B1 '^\- \*\*Priority:\*\* critical' "$ACTION_ITEMS_FILE" 2>/dev/null | grep -c '^\### \[AI-' || echo 0)

  if [ "$OPEN_COUNT" -gt 0 ] || [ "$IN_PROGRESS_COUNT" -gt 0 ] || [ "$BLOCKED_COUNT" -gt 0 ]; then
    CONTEXT="${CONTEXT}\n\n--- ACTION ITEMS SUMMARY ---\nOpen: $OPEN_COUNT | In Progress: $IN_PROGRESS_COUNT | Blocked: $BLOCKED_COUNT | Critical: $CRITICAL_COUNT\nRead context/ACTION-ITEMS.md for full details."
  fi
fi

# --- MEMPALACE STATUS ---
# Check if MemPalace is installed and has data for this project
if command -v mempalace &>/dev/null || python3 -c "import mempalace" &>/dev/null 2>&1; then
  CONTEXT="${CONTEXT}\n\n--- MEMORY SYSTEM ---\nMemPalace: INSTALLED. Query institutional memory with the MemPalace MCP tools (mempalace_search, mempalace_recall). Before making architectural decisions or revisiting past work, check memory first — it may contain relevant decisions, rejected approaches, or user preferences from prior sessions."
else
  CONTEXT="${CONTEXT}\n\n--- MEMORY SYSTEM ---\nMemPalace: NOT INSTALLED. Long-term memory is unavailable. To enable cross-session memory, run: pip install mempalace"
fi

# --- GRAPHIFY STATUS ---
# Check if the knowledge graph exists and report its state
if [ -f "$PROJECT_DIR/graphify-out/graph.json" ]; then
  GRAPH_MOD=$(stat -f '%Sm' -t '%Y-%m-%d %H:%M' "$PROJECT_DIR/graphify-out/graph.json" 2>/dev/null || stat -c '%y' "$PROJECT_DIR/graphify-out/graph.json" 2>/dev/null | cut -d'.' -f1)
  NODE_COUNT=""
  if command -v python3 &>/dev/null; then
    NODE_COUNT=$(python3 -c "import json; g=json.load(open('$PROJECT_DIR/graphify-out/graph.json')); print(len(g.get('nodes',[])))" 2>/dev/null)
  fi
  CONTEXT="${CONTEXT}\n\n--- KNOWLEDGE GRAPH ---\nGraphify: ACTIVE. Last rebuilt: $GRAPH_MOD. Nodes: ${NODE_COUNT:-unknown}.\nRead graphify-out/GRAPH_REPORT.md for god nodes, communities, and architecture map. Use Graphify MCP tools (query_graph, get_neighbors, shortest_path) for targeted code navigation."
elif command -v graphify &>/dev/null || python3 -c "import graphify" &>/dev/null 2>&1; then
  CONTEXT="${CONTEXT}\n\n--- KNOWLEDGE GRAPH ---\nGraphify: INSTALLED but no graph built yet. Run 'graphify $PROJECT_DIR' to build the initial knowledge graph."
else
  CONTEXT="${CONTEXT}\n\n--- KNOWLEDGE GRAPH ---\nGraphify: NOT INSTALLED. Codebase knowledge graph is unavailable. To enable graph-first navigation, run: pip install graphifyy[all]"
fi

if [ -n "$CONTEXT" ]; then
  ESCAPED=$(echo "$CONTEXT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")
  echo "{\"hookSpecificOutput\":{\"additionalContext\":$ESCAPED}}"
fi
