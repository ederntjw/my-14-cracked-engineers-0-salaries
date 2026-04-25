# Build Pipeline — Full Reference

The pipeline runs in this order. The team handles transitions automatically.

```
/status → /inbox → /pull → /refine (if vague) → /plan → BUILD → VERIFY LOOP → [Aisha: QA] → /update
```

## Steps

1. **`/status`** — Read `context/STATUS.md`. Auto-detect tech stack if first contact with codebase.
2. **`/inbox`** — Process any new documents in `context/inbox/`.
3. **`/pull`** — Load brainstorm handoff from `context/sessions/` if one exists.
4. **`/refine`** (Maya) — Auto-triggers when the idea is vague. Sharpens into a clear scope with a "Not Doing" list. Skipped when requirements are already specific.
5. **`/plan`** (Jake + Sara) — Break work into tasks with assumptions and 3-tier boundaries. No code before approval. Auto-checkpoint after approval.
6. **Build** (Max + Liam) — Tests first, then code. Never 100+ lines without testing. Build in vertical slices. Verify loop: build → verify → fix → verify → until clean. All checks require actual command output as evidence.
7. **QA** (Aisha — automatic, self-healing) — Runs immediately after build. Full chain: tests → investigation → code review → plan verification → human check → SHIP or HOLD. If HOLD, Aisha self-heals (up to 3 cycles). Only escalates when a human decision is genuinely needed.
8. **`/deploy`** — Pre-launch safety checklist + rollback plan. Only when shipping to production.
9. **`/update`** — Save everything to STATUS.md, ACTION-ITEMS.md, ADRs, and explicitly persist key decisions to MemPalace via `mempalace_add_drawer`. There is no auto-mining — this step is the only memory persistence mechanism. Never skip.

## What Happens Automatically

The user never needs to ask for any of these:

- Tech stack detection on first contact
- Idea refinement when request is vague (before planning)
- Model routing (cheaper models for simple tasks, expensive for complex)
- Structured debugging when errors occur (six-step triage, not guesswork)
- Auto-recovery when builds/tests fail (team handles internally, escalates only when stuck)
- Auto-checkpointing at every major milestone (save-before-deliver pattern)
- Progress narration (team tells user who's doing what)
- Evidence collection (every "it works" claim has actual command output attached)
- Anti-rationalization checks (team catches itself before taking shortcuts)
- Clean removal (no zombie code left behind after replacements)
- Architecture decisions documented to `context/decisions/`
- Codebase knowledge graph rebuilt on every git commit (Graphify post-commit hook, no LLM cost)
- Graph-first navigation (agents consult GRAPH_REPORT.md before grepping)
- Memory-informed decisions (agents check MemPalace before repeating past mistakes)
- Stop hook flags whether `/update` ran — next session warns the user if memory was likely not saved

## Periodic Commands

Run these on a cadence, not every session:

| Command | When |
|---------|------|
| `/audit` | When taking over existing code, or monthly health check |
| `/pipeline` | When data pipeline needs to run |
| `/deploy` | Before any production release |
| `/milestone` | End of each major phase |
