#!/bin/bash
# Stop hook: save session metadata so the next session knows what happened
# Writes to .last-session which SessionStart picks up

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
LAST_SESSION="$PROJECT_DIR/context/.last-session"
STATUS_FILE="$PROJECT_DIR/context/STATUS.md"

# Read stop hook input from stdin
INPUT=$(cat)
STOP_REASON=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('stop_hook_reason','unknown'))" 2>/dev/null || echo "unknown")

# Write session end marker
cat > "$LAST_SESSION" << EOF
last_ended: $(date '+%Y-%m-%d %H:%M')
stop_reason: $STOP_REASON
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
