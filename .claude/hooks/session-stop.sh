#!/bin/bash
# Stop hook: save session metadata + trigger MemPalace conversation mining
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

# --- MEMPALACE CONVERSATION MINING ---
# Attempt to mine the current session's transcript to MemPalace.
# This runs in the background with a short timeout to avoid blocking session close.
# If MemPalace is not installed, this silently does nothing.
if command -v mempalace &>/dev/null || python3 -c "import mempalace" &>/dev/null 2>&1; then
    # Get the wing name from project config
    WING="project"
    if [ -f "$PROJECT_DIR/mempalace.yaml" ]; then
        WING=$(python3 -c "import yaml; print(yaml.safe_load(open('$PROJECT_DIR/mempalace.yaml')).get('wing','project'))" 2>/dev/null || echo "project")
    fi

    # Find the most recent Claude Code transcript for this project
    # Claude Code stores transcripts as JSONL in ~/.claude/projects/
    PROJECT_HASH=$(echo "$PROJECT_DIR" | python3 -c "import sys,hashlib; print(hashlib.md5(sys.stdin.read().strip().encode()).hexdigest()[:8])" 2>/dev/null)

    if [ -n "$PROJECT_HASH" ]; then
        # Mine the transcript directory — mempalace handles finding the right files
        # Run with timeout to avoid blocking session close
        timeout 10 python3 -c "
from mempalace.mcp_server import tool_mine_directory
import os, glob

# Find Claude transcript directory
claude_dir = os.path.expanduser('~/.claude/projects/')
if os.path.isdir(claude_dir):
    # Mine the most recent transcript files
    try:
        tool_mine_directory(claude_dir, wing='$WING')
    except Exception:
        pass  # Silent fail — don't block session close
" 2>/dev/null &
    fi

    echo "mempalace_mined: true" >> "$LAST_SESSION"
    echo "mempalace_mine_time: $(date '+%Y-%m-%d %H:%M')" >> "$LAST_SESSION"
fi
