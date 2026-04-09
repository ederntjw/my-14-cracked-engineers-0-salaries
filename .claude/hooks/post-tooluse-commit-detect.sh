#!/bin/bash
# PostToolUse hook: fires after Bash tool calls that match "git commit"
# Triggers Graphify AST rebuild and STATUS.md micro-checkpoint

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
STATUS_FILE="$PROJECT_DIR/context/STATUS.md"

# Read the tool use input from stdin
INPUT=$(cat)

# Extract the command that was run
COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except:
    print('')
" 2>/dev/null)

# Only proceed if this was a git commit command
if echo "$COMMAND" | grep -q "git commit"; then
    # --- GRAPHIFY AST REBUILD ---
    # If graphify is installed, rebuild the AST graph (free, no LLM cost)
    if command -v graphify &>/dev/null; then
        # Run AST-only rebuild in background to avoid blocking
        graphify "$PROJECT_DIR" --no-viz --update 2>/dev/null &
    fi

    # --- STATUS.MD MICRO-CHECKPOINT ---
    # Record the latest commit info in STATUS.md
    if [ -f "$STATUS_FILE" ]; then
        LATEST_COMMIT=$(cd "$PROJECT_DIR" && git log --oneline -1 2>/dev/null)
        COMMIT_TIME=$(date '+%Y-%m-%d %H:%M')

        if [ -n "$LATEST_COMMIT" ]; then
            # Inject context back to the agent about the commit
            echo "{\"hookSpecificOutput\":{\"message\":\"Commit detected: $LATEST_COMMIT. Graphify AST rebuilding in background. Remember: update STATUS.md with what was built before presenting results to the user (save-before-deliver pattern).\"}}"
        fi
    fi
fi
