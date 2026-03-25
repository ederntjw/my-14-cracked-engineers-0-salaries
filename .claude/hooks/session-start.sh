#!/bin/bash
# SessionStart hook: inject STATUS.md + last-session context into every new session
# The engineering team picks up where it left off without being asked.
# On first-ever run (STATUS.md still has placeholders), triggers auto-onboarding.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
STATUS_FILE="$PROJECT_DIR/context/STATUS.md"
ACTION_ITEMS_FILE="$PROJECT_DIR/context/ACTION-ITEMS.md"
LAST_SESSION="$PROJECT_DIR/context/.last-session"

CONTEXT=""

# --- FIRST-RUN DETECTION ---
# If STATUS.md still has placeholder text, this is a brand new download.
# Trigger auto-onboarding instead of the normal session load.
if [ -f "$STATUS_FILE" ]; then
  HAS_PLACEHOLDER=$(grep '\[PROJECT NAME\]' "$STATUS_FILE" 2>/dev/null)
  if [ -n "$HAS_PLACEHOLDER" ]; then
    ONBOARD_MSG="FIRST_RUN_DETECTED: This is a fresh engineering team — STATUS.md still has placeholder text. The user has never run /setup. Do NOT wait for them to ask. Immediately start the onboarding flow by running the /setup command. Greet them warmly, tell them they just opened their engineering team, and walk them through setup. Keep it simple — they may be completely non-technical."
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

  if [ -n "$STALE" ]; then
    CONTEXT="NOTICE: Last session ended at $LAST_ENDED WITHOUT running /update. STATUS.md may be stale. Ask the user what was worked on or run /status to check.\n\n"
  elif [ -n "$LAST_ENDED" ]; then
    CONTEXT="Last session ended: $LAST_ENDED\n\n"
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
  # Count open items by grepping for status lines
  OPEN_COUNT=$(grep -c '^\- \*\*Status:\*\* open' "$ACTION_ITEMS_FILE" 2>/dev/null || echo 0)
  IN_PROGRESS_COUNT=$(grep -c '^\- \*\*Status:\*\* in-progress' "$ACTION_ITEMS_FILE" 2>/dev/null || echo 0)
  BLOCKED_COUNT=$(grep -c '^\- \*\*Status:\*\* blocked' "$ACTION_ITEMS_FILE" 2>/dev/null || echo 0)
  CRITICAL_COUNT=$(grep -B1 '^\- \*\*Priority:\*\* critical' "$ACTION_ITEMS_FILE" 2>/dev/null | grep -c '^\### \[AI-' || echo 0)

  if [ "$OPEN_COUNT" -gt 0 ] || [ "$IN_PROGRESS_COUNT" -gt 0 ] || [ "$BLOCKED_COUNT" -gt 0 ]; then
    CONTEXT="${CONTEXT}\n\n--- ACTION ITEMS SUMMARY ---\nOpen: $OPEN_COUNT | In Progress: $IN_PROGRESS_COUNT | Blocked: $BLOCKED_COUNT | Critical: $CRITICAL_COUNT\nRead context/ACTION-ITEMS.md for full details."
  fi
fi

if [ -n "$CONTEXT" ]; then
  ESCAPED=$(echo "$CONTEXT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")
  echo "{\"hookSpecificOutput\":{\"additionalContext\":$ESCAPED}}"
fi
