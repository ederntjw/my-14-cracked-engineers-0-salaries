#!/bin/bash
# PreToolUse hook for Bash: detect search commands (grep/find/rg/ag) that bypass
# the dedicated Glob|Grep tools, and inject the graph reminder so the agent
# considers the knowledge graph BEFORE doing blind file searches.
#
# Fires on every Bash call but only outputs when:
#   1. A graph exists (graphify-out/graph.json present)
#   2. The command looks like a code search

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

# Skip if no graph
[ -f "$PROJECT_DIR/graphify-out/graph.json" ] || exit 0

# Read tool input from stdin
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except:
    print('')
" 2>/dev/null)

# Heuristic: does the command start with (or pipe through) a search tool?
# Match: grep, egrep, fgrep, rg (ripgrep), ag (silver searcher), find ... -name
if echo "$COMMAND" | grep -qE '(^|[ \t|;&])((e|f)?grep|rg|ag)( |$)' \
   || echo "$COMMAND" | grep -qE '(^|[ \t|;&])find( |$).*-(name|path|regex)'; then
  cat <<'EOF'
{"hookSpecificOutput":{"suppressOutput":false,"message":"graphify: Knowledge graph available. Read graphify-out/GRAPH_REPORT.md for god nodes, communities, and module relationships before doing raw text searches. Use Graphify MCP tools (query_graph, get_neighbors, shortest_path) for targeted lookups — they are faster than grep/find on large codebases."}}
EOF
fi

exit 0
