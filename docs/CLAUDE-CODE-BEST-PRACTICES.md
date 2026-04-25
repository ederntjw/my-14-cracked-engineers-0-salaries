# Claude Code Best Practices

A complete reference for building Claude Code setups. Covers CLAUDE.md, skills, hooks, rules, project structure, MCP servers, and settings. Written for AI agents tasked with building or improving a Claude Code configuration.

---

## Table of Contents

1. [Project Structure](#project-structure)
2. [CLAUDE.md](#claudemd)
3. [Rules (.claude/rules/)](#rules)
4. [Skills (.claude/skills/)](#skills)
5. [Hooks (.claude/hooks/)](#hooks)
6. [Settings (.claude/settings.json)](#settings)
7. [MCP Servers (.mcp.json)](#mcp-servers)
8. [Commands (.claude/commands/)](#commands)
9. [The Pruning Test](#the-pruning-test)

---

## Project Structure

A well-organized Claude Code project looks like this:

```
project-root/
├── CLAUDE.md                    # Primary instructions (keep lean — see below)
├── CLAUDE.local.md              # Personal overrides (gitignored)
├── .mcp.json                    # MCP server config (gitignored if it has credentials)
│
├── .claude/
│   ├── settings.json            # Permissions, hooks, model config
│   ├── settings.local.json      # Local permission overrides (gitignored)
│   ├── rules/                   # Behavioral rules (auto-load at startup)
│   │   ├── coding-style.md
│   │   ├── security.md
│   │   ├── testing.md
│   │   └── [topic].md
│   ├── skills/                  # On-demand capabilities
│   │   └── [skill-name]/
│   │       └── SKILL.md
│   ├── hooks/                   # Shell scripts for lifecycle events
│   │   ├── session-start.sh
│   │   └── session-stop.sh
│   └── commands/                # Slash command definitions
│       └── [command].md
│
├── agents/                      # Agent playbooks (if using multi-agent)
├── docs/                        # Human + AI reference docs (not auto-loaded)
└── context/                     # Project memory (STATUS.md, decisions, builds)
```

**Loading order (lowest → highest priority):**
1. System-wide CLAUDE.md (`/Library/Application Support/ClaudeCode/CLAUDE.md`)
2. User-level `~/.claude/CLAUDE.md`
3. User-level `~/.claude/rules/*.md`
4. Project `CLAUDE.md`
5. Project `.claude/rules/*.md`
6. `CLAUDE.local.md` (personal, appended last — overrides project instructions)

---

## CLAUDE.md

### What it is

The primary instruction file loaded into every session. Think of it as Claude's standing orders for this project — always loaded, always active.

### Line limit

**Target: under 100 lines. Hard cap: 200 lines.**

Every line costs tokens on every session. Bloated CLAUDE.md = rules get buried = Claude ignores them. When Claude keeps making the same mistake despite a rule in CLAUDE.md, the file is too long — not the rule too weak.

### What belongs in CLAUDE.md

Include only what Claude cannot infer from reading the code:

| Include | Exclude |
|---------|---------|
| Build and test commands (`npm run build`, `pytest`) | Standard practices Claude already knows |
| Repo-specific quirks and gotchas | File-by-file descriptions of the codebase |
| Architectural decisions that aren't obvious from code | Long explanations and tutorials |
| Code style rules that deviate from language defaults | Information Claude can discover by reading files |
| First-run detection logic | API documentation (link to it instead) |
| Routing rules for multi-agent setups | Anything self-evident ("write clean code") |
| References to rules/skills/docs for deep dives | Content that changes frequently |

### Structure

```markdown
# Project Name

One-line description of what this is.

## Quick Start
- Build: `npm run build`
- Test: `npm test`
- Lint: `npm run lint`

## First Run / New User Detection
[Short rule — if X condition, read Y file or run Z command]

## Routing / Who Does What
[How to handle different types of requests]

## Core Rules
[3-5 non-negotiable rules specific to THIS project]

## New Session Checklist
[What to do at the start of every session — 4-5 lines max]

## References
[One-liners pointing to rules/, docs/, agents/]
```

### Conditional content

CLAUDE.md is always loaded — you can't do true conditional imports. The pattern for "new user vs returning user" is:

```markdown
## First Run
If `context/STATUS.md` contains `[PLACEHOLDER]`: run `/setup` immediately.
Read `docs/ONBOARDING.md` for the full new-user guide. This fires on any first message.
```

This tells Claude to read the onboarding doc only when needed. `docs/` files don't auto-load — Claude reads them on demand per instructions.

### @import syntax

```markdown
# CLAUDE.md can reference other files inline
See @docs/architecture.md for system design decisions.
Build commands are documented in @package.json.
```

**Key facts:**
- Imported files load at session start — same as if the content were inline
- No context savings from imports — they expand fully into context
- Use imports for **organization**, not for reducing token cost
- Max recursion depth: 5 hops
- HTML comments in CLAUDE.md are stripped and do NOT consume tokens: `<!-- maintainer note -->`

### Anti-patterns

```markdown
# BAD — Claude already knows this
- Write readable, well-structured code
- Use meaningful variable names
- Handle errors properly
- Test your changes before committing

# BAD — Claude can read this from the files
- API handlers are in src/api/
- Database queries live in src/db/
- Components are in src/components/

# GOOD — Claude cannot infer this
- Run `npm run migrate` before any test that touches the database schema
- The session service requires REDIS_URL or it silently fails
- Never import from barrel files in test files — it causes circular dependency errors
```

---

## Rules

Rules live in `.claude/rules/`. They are markdown files that load automatically alongside CLAUDE.md.

### Two types

**1. Global rules** (no frontmatter) — load on every session, every file:
```markdown
# .claude/rules/security.md
Never hardcode secrets. Always use environment variables.
All SQL queries must use parameterized statements...
```

**2. Path-scoped rules** (with `paths` frontmatter) — load ONLY when Claude reads matching files. This is the primary tool for reducing unnecessary context:
```markdown
---
paths:
  - "src/api/**/*.ts"
  - "src/handlers/**/*.ts"
---
# API Rules
All endpoints must validate input with zod.
Use the standard error response format from src/lib/errors.ts.
```

### When to use path-scoped rules

Use path-scoped rules whenever a rule only applies in certain contexts:
- Database rules → scope to `src/db/**`, `migrations/**`
- Frontend rules → scope to `src/components/**`, `src/pages/**`
- Test rules → scope to `**/*.test.ts`, `**/*.spec.ts`
- Security rules for API → scope to `src/api/**`

Path-scoped rules are the most powerful tool for keeping context lean without losing coverage.

### Supported glob patterns

```
**/*.ts          — all TypeScript files anywhere
src/**/*         — all files under src/
*.md             — markdown files in root only
src/**/*.{ts,tsx} — multiple extensions
src/api/*.ts     — specific directory, one level deep
```

### Rule file anatomy

```markdown
# Rule Title

## The Rule (one sentence)

## Why
[One sentence explaining the reasoning — helps Claude apply it to edge cases]

## How to Apply
[When this rule kicks in. Specific examples.]

## Anti-patterns (DO NOT do these)
| Wrong | Right |
|-------|-------|
| ... | ... |
```

Always include the "why." A rule without reasoning gets blindly followed or blindly ignored. A rule with reasoning gets applied intelligently to situations the author didn't anticipate.

---

## Skills

Skills live in `.claude/skills/[skill-name]/SKILL.md`. They are on-demand capabilities — Claude loads and executes them when triggered.

### When to use a skill vs a rule

| Use a rule | Use a skill |
|-----------|-------------|
| Always-on behavior | Triggered on-demand |
| Single constraint | Multi-step procedure |
| "Always do X when Y" | "When asked to do Z, follow these steps" |
| Affects all work | Affects a specific workflow |

### SKILL.md anatomy

```markdown
# Skill Name — One-line description

## Trigger
Exact phrases or conditions that activate this skill:
- "Do X", "start X", "I want to X"
- `/skill-name` slash command
- AUTO-FIRE when [condition] is detected

## What This Does
2-3 sentences explaining what the skill accomplishes and why it exists.

## Procedure
Step-by-step instructions Claude follows when this skill runs:

1. [First action]
2. [Second action — include what to read, what to check]
3. [Decision point — if X do Y, else do Z]
4. [Output or result]

## Rules
- Constraints specific to this skill
- What Claude must NOT do during this skill
- How to handle edge cases

## Output
What the user sees when this skill completes.
```

### Trigger design

Be specific. Vague triggers cause skills to fire when they shouldn't, or miss when they should fire.

```markdown
# BAD — too vague
## Trigger
When the user wants to do something related to code.

# GOOD — specific
## Trigger
- "Review this", "is this good?", "check my code"
- After any significant code change (AUTO-FIRE)
- When a PR description asks for review
```

### Skill file size

Skills can be as long as they need to be — they only load when triggered, not at session start. A 200-line skill that runs once a week is better than cramming its logic into CLAUDE.md where it loads every session.

### Common skill patterns

**Onboarding skill** — runs once, guides new users, writes state to disk:
```markdown
## Trigger
`/onboard`, first session detection, or when user profile is empty.

## State
Writes progress to `.onboard-state.json`. Resumes if interrupted.
```

**Planning skill** — interactive, requires approval before proceeding:
```markdown
## Procedure
1. Ask clarifying questions (one at a time)
2. Draft the plan
3. Present to user — **STOP. Wait for explicit approval.**
4. Only proceed to build after "yes", "approved", "looks good"
```

**Audit skill** — read-only investigation, produces a report:
```markdown
## Procedure
1. Read all relevant files (never write during audit)
2. Build findings list
3. Present report with severity levels
4. Ask user what to address first
```

---

## Hooks

Hooks are shell scripts that execute automatically in response to lifecycle events. They run outside Claude's context — they cannot read or write the conversation.

### Hook types

| Type | When it fires | Use for |
|------|--------------|---------|
| `SessionStart` | When a new session begins | Inject context, load memory, check state |
| `Stop` | When the session ends | Save state, mine to memory, run cleanup |
| `PreToolUse` | Before Claude calls a specific tool | Validation, blocking dangerous operations |
| `PostToolUse` | After Claude calls a specific tool | Auto-format, trigger side effects, update indexes |

### Hook output format

Hooks communicate with Claude via stdout JSON:

```bash
# Inject context at session start
echo '{"hookSpecificOutput":{"additionalContext":"Last session ended at 2026-04-25 14:30. Snapshot is fresh."}}'

# Block a tool call (PreToolUse)
echo '{"decision":"block","reason":"Cannot delete files in the migrations/ directory."}'

# Allow a tool call
echo '{"decision":"allow"}'
```

### Session start hook pattern

```bash
#!/bin/bash
# .claude/hooks/session-start.sh

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
CONTEXT=""

# Load session state
if [ -f "$PROJECT_DIR/context/.last-session" ]; then
  LAST=$(cat "$PROJECT_DIR/context/.last-session")
  CONTEXT="Last session: $LAST\n\n"
fi

# Load snapshot/status
if [ -f "$PROJECT_DIR/context/STATUS.md" ]; then
  STATUS=$(head -50 "$PROJECT_DIR/context/STATUS.md")
  CONTEXT="${CONTEXT}${STATUS}"
fi

# Output to Claude
if [ -n "$CONTEXT" ]; then
  ESCAPED=$(echo "$CONTEXT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")
  echo "{\"hookSpecificOutput\":{\"additionalContext\":$ESCAPED}}"
fi
```

### Session stop hook pattern

```bash
#!/bin/bash
# .claude/hooks/session-stop.sh

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
INPUT=$(cat)
STOP_REASON=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('stop_hook_reason','unknown'))" 2>/dev/null || echo "unknown")

# Write session end marker
echo "ended: $(date '+%Y-%m-%d %H:%M'), reason: $STOP_REASON" > "$PROJECT_DIR/context/.last-session"

# Check if STATUS.md was updated (staleness warning for next session)
STATUS="$PROJECT_DIR/context/STATUS.md"
if [ -f "$STATUS" ]; then
  MOD=$(stat -f %m "$STATUS" 2>/dev/null || stat -c %Y "$STATUS" 2>/dev/null || echo 0)
  NOW=$(date +%s)
  if [ $((NOW - MOD)) -gt 10800 ]; then
    echo "stale: true" >> "$PROJECT_DIR/context/.last-session"
  fi
fi
```

### PreToolUse hook pattern (protection)

```bash
#!/bin/bash
# Blocks destructive bash commands in production directories

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null)

if echo "$COMMAND" | grep -qE "rm -rf|DROP TABLE|DELETE FROM .* WHERE 1"; then
  echo '{"decision":"block","reason":"Destructive command requires manual confirmation."}'
else
  echo '{"decision":"allow"}'
fi
```

### Hook rules

- Hooks must exit within their timeout (default 60s for SessionStart/Stop, 10s for Pre/PostToolUse)
- Hooks that fail or time out are skipped silently — they never crash Claude
- Never put business logic in hooks. Hooks inject context and save state. Claude handles logic.
- Test hooks standalone before wiring them up: `echo '{}' | bash .claude/hooks/session-stop.sh`

---

## Settings

`.claude/settings.json` controls permissions, hooks, and model behavior.

### Full structure

```json
{
  "model": "claude-opus-4-7",
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(git *)",
      "Read(**/*)",
      "Write(src/**/*)",
      "Edit(src/**/*)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)"
    ]
  },
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/session-start.sh\"",
            "timeout": 10
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/session-stop.sh\"",
            "timeout": 30
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash(git commit*)",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/post-commit.sh\""
          }
        ]
      }
    ]
  }
}
```

### Permission rules

Use the most specific permission that covers your use case. Broad permissions (`Bash(**)`) are dangerous — they let Claude run anything.

```json
// BAD — too broad
"allow": ["Bash(**)"]

// GOOD — scoped to what's actually needed
"allow": [
  "Bash(npm *)",
  "Bash(git status)",
  "Bash(git diff *)",
  "Bash(git add *)",
  "Bash(git commit *)"
]
```

`settings.local.json` (gitignored) is for personal permission overrides — useful for developers who want to allow more in their local environment without affecting the team.

---

## MCP Servers

MCP (Model Context Protocol) servers extend Claude with external tool access. Config lives in `.mcp.json`.

### Structure

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@package/mcp-server"],
      "env": {
        "API_KEY": "your-key-here"
      }
    },
    "local-server": {
      "command": "node",
      "args": ["scripts/my-mcp-server.js"]
    },
    "python-server": {
      "command": "python3",
      "args": ["-m", "my_mcp_package"]
    }
  }
}
```

### Rules

- **Gitignore `.mcp.json` if it contains credentials.** Use a `.mcp.json.template` with placeholders for the repo.
- MCP tools are available to Claude via `mcp__[server-name]__[tool-name]` — add these to `allowedTools` in settings or agent code.
- MCP servers run as subprocesses — they start when Claude Code starts and must be available on PATH.
- If an MCP server is optional (graceful degradation), document this in CLAUDE.md so Claude knows what to do if it's missing.

### Common MCP servers

| Server | Package | Use |
|--------|---------|-----|
| MemPalace | `mempalace-mcp` | Long-term memory, knowledge graph |
| Google Calendar | `@cocal/google-calendar-mcp` | Calendar read/write |
| Gmail | `@gongrzhe/server-gmail-autoauth-mcp` | Email read/write |
| Notion | `@notionhq/notion-mcp-server` | Notion databases |
| Filesystem | `@modelcontextprotocol/server-filesystem` | File access outside project |
| GitHub | `@modelcontextprotocol/server-github` | GitHub API |

---

## Commands

Commands live in `.claude/commands/[name].md`. They define what happens when someone types `/name`.

### Anatomy

```markdown
# Command Name

Brief description of what this command does.

## When to Use
- Specific scenarios where this command is the right choice

## Procedure
1. Step one
2. Step two
3. Step three — always end with a clear output or next-step suggestion

## Output
What the user sees when this command completes.
```

### Rules

- Commands are just markdown — they're instructions Claude reads, not code that executes
- Keep commands short — they get loaded when triggered, not at startup
- The command file defines the behavior; the hook (if any) handles side effects
- Never tell the user "type /command-name" — they shouldn't need to learn commands. Use natural language triggers in CLAUDE.md's routing section.

---

## The Pruning Test

Run every line of your CLAUDE.md, rules, and skill files through this test before shipping:

**For each rule or instruction, ask:**

1. **Would Claude break without this?** → Keep it
2. **Can Claude infer this from reading the code?** → Delete it
3. **Is this standard practice for this language/framework?** → Delete it (Claude already knows)
4. **Have I corrected Claude on this twice without this rule?** → Keep it
5. **Does this apply to every session, or only sometimes?** → Sometimes → move to a path-scoped rule or skill

**Red flags that a rule should be cut:**
- It starts with "Always" followed by something obvious
- It describes the project structure Claude can read for itself
- It has never actually prevented Claude from making a mistake
- It's longer than 3 lines and could be replaced by a link to a doc

**Red flags that CLAUDE.md is too long:**
- Claude keeps making a mistake despite a rule against it (rule is buried)
- You find yourself adding `IMPORTANT:` or `CRITICAL:` prefixes to get attention
- The file takes more than 60 seconds to read top-to-bottom
- You can't remember what's in it without re-reading it

**The benchmark:** A well-tuned CLAUDE.md should read in under 60 seconds and contain nothing surprising — only things you'd say on the first day of a new job if someone asked "what do I need to know about this project that I can't figure out from reading the code?"

---

## Summary: Where Everything Goes

| Content | Where |
|---------|-------|
| Always-on project rules | `CLAUDE.md` (lean) |
| Topic-specific always-on rules | `.claude/rules/[topic].md` |
| Rules that only apply to certain files | `.claude/rules/[topic].md` with `paths:` frontmatter |
| Multi-step workflows and procedures | `.claude/skills/[name]/SKILL.md` |
| Session lifecycle automation | `.claude/hooks/[event].sh` |
| Permissions and hook wiring | `.claude/settings.json` |
| Personal permission overrides | `.claude/settings.local.json` (gitignored) |
| External tool integrations | `.mcp.json` (gitignore if credentials) |
| Slash command definitions | `.claude/commands/[name].md` |
| New-user onboarding content | `docs/ONBOARDING.md` (Claude reads on demand) |
| Deep reference docs | `docs/` (Claude reads on demand, not at startup) |
| Personal CLAUDE.md overrides | `CLAUDE.local.md` (gitignored, highest priority) |
