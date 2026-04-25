#!/bin/bash
# PostToolUse hook: fires after Bash tool calls that match "git commit".
#
# Graphify rebuild model: Graphify provides a `graphify hook install` command
# that installs git post-commit hooks which auto-rebuild the graph after every
# commit. This script does NOT try to call graphify directly (the CLI doesn't
# have a `--update` flag). Instead it:
#   1. Confirms the commit happened
#   2. Notes whether the graphify git hooks are installed (one-time setup)
#   3. Reminds the agent to update STATUS.md (save-before-deliver pattern)

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
STATUS_FILE="$PROJECT_DIR/context/STATUS.md"

# Source shared Python detection (matches .mcp.json venv).
HOOK_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=lib-python.sh
source "$HOOK_DIR/lib-python.sh"

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
    if [ ! -f "$STATUS_FILE" ]; then
        exit 0
    fi

    LATEST_COMMIT=$(cd "$PROJECT_DIR" && git log --oneline -1 2>/dev/null)
    if [ -z "$LATEST_COMMIT" ]; then
        exit 0
    fi

    # Check graphify git hook status — if installed, the rebuild already ran via post-commit hook
    GRAPHIFY_BIN=$(find_cli graphify 2>/dev/null)
    GRAPH_NOTE=""
    if [ -n "$GRAPHIFY_BIN" ]; then
        HOOK_STATUS=$(cd "$PROJECT_DIR" && "$GRAPHIFY_BIN" hook status 2>&1)
        if echo "$HOOK_STATUS" | grep -q "post-commit: installed"; then
            GRAPH_NOTE=" Graphify post-commit hook ran the AST rebuild automatically."
        else
            GRAPH_NOTE=" Graphify is available but its git hooks are not installed — run 'graphify hook install' from $PROJECT_DIR to enable auto-rebuild on commit."
        fi
    fi

    MSG="Commit detected: $LATEST_COMMIT.${GRAPH_NOTE} Remember: update STATUS.md with what was built before presenting results to the user (save-before-deliver pattern)."
    # Use python3 to safely escape the message into JSON
    echo "$MSG" | python3 -c "
import sys, json
msg = sys.stdin.read().strip()
print(json.dumps({'hookSpecificOutput': {'message': msg}}))
"
fi
