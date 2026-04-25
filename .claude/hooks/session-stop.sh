#!/bin/bash
# Stop hook: save session metadata so the next SessionStart can pick up cleanly.
# Writes to context/.last-session.
#
# Note: We do NOT auto-mine the conversation transcript. The MemPalace public
# API does not expose a transcript-mining function — memory persistence happens
# through explicit `mempalace_add_drawer` / `mempalace_kg_add` calls during the
# /update slash command. This hook just flags whether /update appears to have
# run, so the next session can warn the user if memory wasn't saved.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
LAST_SESSION="$PROJECT_DIR/context/.last-session"
STATUS_FILE="$PROJECT_DIR/context/STATUS.md"
SESSION_COUNT="$PROJECT_DIR/context/.session-count"

# Source shared Python detection (matches .mcp.json venv).
HOOK_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=lib-python.sh
source "$HOOK_DIR/lib-python.sh"

# Read stop hook input from stdin
INPUT=$(cat)
PY_FOR_PARSE=$(find_python_with json 2>/dev/null || echo "python3")
STOP_REASON=$(echo "$INPUT" | "$PY_FOR_PARSE" -c "import sys,json; d=json.load(sys.stdin); print(d.get('stop_hook_reason','unknown'))" 2>/dev/null || echo "unknown")

# Write session end marker
cat > "$LAST_SESSION" << EOF
last_ended: $(date '+%Y-%m-%d %H:%M')
stop_reason: $STOP_REASON
clean_close: true
EOF

# Check if STATUS.md was updated during this session (within last 3 hours)
if [ -f "$STATUS_FILE" ]; then
    STATUS_MOD=$(stat -f %m "$STATUS_FILE" 2>/dev/null || stat -c %Y "$STATUS_FILE" 2>/dev/null || echo 0)
    NOW=$(date +%s)
    DIFF=$((NOW - STATUS_MOD))

    if [ "$DIFF" -gt 10800 ]; then
        echo "status_stale: true" >> "$LAST_SESSION"
    else
        echo "status_stale: false" >> "$LAST_SESSION"
    fi
fi

# --- SESSION COUNTER (for /audit suggestions every N sessions) ---
# Increment the counter. session-start checks this and suggests /audit when threshold hit.
# /audit resets the counter to 0.
CURRENT_COUNT=$(cat "$SESSION_COUNT" 2>/dev/null | tr -d '[:space:]')
case "$CURRENT_COUNT" in
  ''|*[!0-9]*) CURRENT_COUNT=0 ;;
esac
echo $((CURRENT_COUNT + 1)) > "$SESSION_COUNT"

# --- MEMPALACE: NOTE WHETHER /update RAN ---
# We do NOT auto-mine on session stop. The MemPalace API doesn't expose a
# transcript-mining function — memory persistence happens through explicit
# `mempalace_add_drawer` / `mempalace_kg_add` calls during /update.
#
# Here we just record whether STATUS.md was recently touched (a proxy for
# whether /update ran). The next session uses this to decide if it should
# nag the user about lost context.
if [ "$(mempalace_available)" = "yes" ]; then
    if [ -f "$STATUS_FILE" ] && [ "$DIFF" -lt 1800 ]; then
        # STATUS.md updated in last 30 min — likely /update ran cleanly
        echo "memory_saved: likely" >> "$LAST_SESSION"
    else
        # STATUS.md is stale — /update probably didn't run, memory may be lost
        echo "memory_saved: unlikely" >> "$LAST_SESSION"
        echo "memory_warning: /update did not appear to run this session — institutional memory may not have been saved to MemPalace" >> "$LAST_SESSION"
    fi
fi
