#!/bin/bash
# Shared helper: find the Python interpreter that has MemPalace/Graphify installed.
# This MUST match the interpreter used in .mcp.json — otherwise the hooks lie about
# install state and the team gets stale/wrong info about the memory + graph tools.
#
# Resolution order:
#   1. ~/.claude-tools/bin/python3   (matches .mcp.json venv activation)
#   2. system python3                (fallback)
#   3. system python                 (last resort)

# Returns the path to the Python interpreter that has mempalace installed,
# or empty string if none found.
find_python_with() {
  local pkg="$1"
  local candidates=(
    "$HOME/.claude-tools/bin/python3"
    "python3"
    "python"
  )
  for py in "${candidates[@]}"; do
    if command -v "$py" &>/dev/null && "$py" -c "import $pkg" &>/dev/null; then
      echo "$py"
      return 0
    fi
  done
  return 1
}

# Returns the path to a CLI tool from the venv if present, else system PATH.
find_cli() {
  local tool="$1"
  local venv_path="$HOME/.claude-tools/bin/$tool"
  if [ -x "$venv_path" ]; then
    echo "$venv_path"
    return 0
  fi
  if command -v "$tool" &>/dev/null; then
    command -v "$tool"
    return 0
  fi
  return 1
}

# Returns "yes" if MemPalace can be imported (in venv or system), else "no".
mempalace_available() {
  if find_python_with mempalace &>/dev/null; then
    echo "yes"
  else
    echo "no"
  fi
}

# Returns "yes" if Graphify can be imported (in venv or system), else "no".
graphify_available() {
  if find_python_with graphify &>/dev/null; then
    echo "yes"
  else
    echo "no"
  fi
}
