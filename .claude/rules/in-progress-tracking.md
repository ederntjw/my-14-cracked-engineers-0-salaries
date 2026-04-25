# In-Progress Tracking — Crash Recovery

## The Rule

Any agent that begins a multi-step task (3+ tool uses expected, or any task likely to span more than a couple of minutes) MUST write a one-line marker to `context/.in-progress` when starting, and MUST clear it when finishing.

This is the team's crash recovery mechanism. If a session dies mid-task, the next session reads `.in-progress` and recovers context without forcing the user to re-explain.

## Format

`context/.in-progress` is a single-line file (overwrite, don't append):

```
agent: <name> | task: <one-sentence summary> | started: YYYY-MM-DD HH:MM
```

Example:
```
agent: Tom | task: Fixing TypeScript error in auth.ts middleware | started: 2026-04-26 14:22
```

## When to Write

- Before starting a multi-step build wave
- Before starting an audit
- Before starting a refactor
- Before starting any task you expect to take >2 minutes or >3 tool uses
- Before delegating to a sub-agent (write on the orchestrator's behalf)

## When to Clear

- Immediately after the task completes (success OR failure)
- When `/update` runs (it always clears `.in-progress`)
- When switching to a different task — clear and rewrite for the new task

## What Session-Start Does With It

The session-start hook checks `.in-progress` against `context/STATUS.md`:
- If STATUS.md was modified more recently → `/update` ran since, ignore `.in-progress`
- If `.in-progress` is newer than STATUS.md → previous session likely crashed mid-task. The hook injects a notice and the agent should ask the user what they were working on.

## What Stop Hook Does With It

Nothing. The stop hook leaves `.in-progress` alone — that's the whole point of crash recovery. The file persists across the session boundary so the next session can read it.

## What `/update` Does With It

Always clears it. `/update` means "everything is saved" — there is no in-progress work left to recover.

## Cost

Negligible: one Write per task start, one Bash `rm` per task end. Cheaper than re-explaining context after a crash.

## Common Rationalizations (DO NOT fall for these)

| Excuse | Reality |
|--------|---------|
| "This task is small enough, I'll skip it" | The crash that loses your progress always happens on the task you didn't track. 5 seconds of writing a marker beats 30 minutes of re-explaining. |
| "I'll write it after the first tool call" | If the first tool call crashes Claude Code, you have no marker. Write it BEFORE the first tool call. |
| "Sub-agents handle their own .in-progress" | They might, but only the orchestrator knows the high-level intent. Write at the orchestrator level so the recovery context is meaningful, not just "Nina was reviewing something." |
