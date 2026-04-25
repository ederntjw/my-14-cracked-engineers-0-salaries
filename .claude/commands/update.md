---
description: Save all session decisions, context, and progress to memory and STATUS.md. Use at the end of every session.
---

# /update — Save Everything, Update Yourselves

Also triggers when the user says: "update yourselves", "save this", "remember this for future reference", "don't forget", "we did good" (at end of session)

This command invokes the `/update` skill in `.claude/skills/update/SKILL.md`. Follow those instructions exactly.

In short:

1. **Review the conversation** for decisions, new context, action items, knowledge growth
2. **Update STATUS.md** with current project state, progress, and what's next
3. **Update ACTION-ITEMS.md** with open/completed tasks
4. **Log decisions** in context/decisions/ if significant decisions were made
5. **Save to MemPalace** (if installed) — explicitly save key decisions, preferences, and discoveries from this session using `mempalace_add_drawer`. Focus on: architectural decisions, user preferences, rejected approaches, stakeholder constraints, and anything that would be valuable for a future session to know. There is no auto-mining — this explicit save is the ONLY mechanism by which memory persists across sessions.
6. **Check Graphify** — if code was written this session, verify the graph rebuild ran. The Graphify git post-commit hook (installed once via `graphify hook install`) handles AST rebuilds automatically on every commit. If hooks are not installed, run `graphify hook install` from the project root.
7. **Process inbox** if any unprocessed files remain
8. **Confirm to the user** — brief summary of what was saved and what's next

## When to Trigger Automatically

Run this automatically (without the user asking) when:
- A significant decision point is reached
- New context from inbox has been processed
- A build phase or milestone is completed
- The session is clearly winding down

## Master Report Staleness Check

After completing all update steps, check if the master report needs attention:

1. Read `context/reports/milestones/` — find the most recent milestone file by number
2. Check its date against today's date
3. If the most recent milestone is **more than 7 days old**, append this reminder to the confirmation:
   > "Master report hasn't been updated in [X] days. Run `/milestone` when you're ready to report."
4. If no milestone files exist, append:
   > "No milestone reports yet. Run `/milestone` to create the first one."

## Integration
- This is the LAST command of every session
- Run `/review` and `/test` BEFORE `/update` if code was written
- After `/update`, the next session can pick up exactly where this one left off
