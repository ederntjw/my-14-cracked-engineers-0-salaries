---
topic: team-upgrade-osmani-agent-skills
date: 2026-04-08
time: 00:00
status: ready
imported_at: null
---

## What This Session Was About

Eugene explored Addy Osmani's agent-skills repo (github.com/addyosmani/agent-skills) to identify upgrade opportunities for the engineering team. The goal: make the team more proactive, more disciplined, and more production-grade — without requiring the user to remember slash commands or follow any specific workflow themselves. White-glove service. World-class quality. The team handles the discipline so the user doesn't have to.

## What Was Decided

### ADOPT
1. **Anti-rationalization tables** — Add to evidence-protocol, testing, development-workflow, security, and code-reviewer. Prevents the team from talking itself into shortcuts.
2. **Idea refinement phase (`/refine`)** — New command between /setup and /plan. Maya leads. Sharpens vague ideas into buildable scope with a "Not Doing" list. Auto-triggers when user's idea is vague.
3. **Structured debugging protocol** — New rule. Six-step triage (Reproduce, Localize, Reduce, Fix Root Cause, Guard, Verify). Stop-the-Line rule. Tom references it.
4. **100-line incremental implementation rule** — Never write 100+ lines without testing. Build vertical slices. Add to development-workflow and Max's agent.

### ADAPT
5. **Strengthen /plan** — Add explicit "Assumptions" section. Change "Boundaries (DO NOT CHANGE)" to three tiers: Always do / Ask first / Never do.
6. **Code simplification for Yuki** — Add Chesterton's Fence rule, pattern tables for structural complexity, naming, redundancy. Extends beyond dead-code removal into making existing code simpler.
7. **Architecture Decision Records** — Create context/decisions/ with ADR template. Sara writes ADRs for structural decisions. Simple format, not full lifecycle.
8. **Pre-launch safety net for /deploy** — Beef up with real pre-launch checklist (security headers, env vars, health endpoints, no debug mode) and rollback plan. Skip staged rollouts/canary/feature flags.
9. **Clean removal discipline** — Yuki: when something gets replaced, old version gets fully deleted. Nina: code review checks for zombie code left behind.

### SKIP
10. Context engineering — We already do this better with STATUS.md + hooks + auto-detection.
11. Security hardening — Elena + security.md already covers OWASP Top 10.
12. Browser DevTools testing — Adds dependency, Aisha has Playwright.

### CRITICAL META-UPGRADE: White-Glove Auto-Routing
- The user should NEVER need to remember slash commands
- Every discipline (refine, plan, TDD, review, QA, deploy) should auto-trigger based on conversation context
- Update CLAUDE.md casual routing to include all new triggers
- Update agents.md auto-activation rules
- Create/update docs/START-HERE.md as a simple instruction manual for users

## Build Brief

1. Create `.claude/commands/refine.md` — idea refinement command
2. Create `.claude/rules/debugging-protocol.md` — six-step triage + stop-the-line
3. Create `context/decisions/TEMPLATE.md` — ADR template
4. Add anti-rationalization tables to: evidence-protocol.md, testing.md, development-workflow.md, security.md, agents/code-reviewer.md
5. Add incremental implementation rule to: development-workflow.md, agents/tdd-guide.md
6. Add simplification methodology to: agents/refactor-cleaner.md
7. Add Chesterton's Fence + pattern tables to: agents/refactor-cleaner.md
8. Strengthen /plan: assumptions section + 3-tier boundaries in .claude/commands/plan.md
9. Strengthen /deploy: pre-launch checklist + rollback plan in .claude/commands/deploy.md
10. Add clean removal discipline to: agents/refactor-cleaner.md, agents/code-reviewer.md
11. Update CLAUDE.md: pipeline includes /refine, casual routing includes all new auto-triggers
12. Update .claude/rules/agents.md: auto-trigger rules for all disciplines
13. Create/update docs/START-HERE.md: simple instruction manual, no slash commands mentioned

## Constraints and Boundaries

- Do NOT add complexity visible to the user. The user talks, the team handles everything.
- Do NOT create new agents. Strengthen existing ones.
- Do NOT add new dependencies or tools.
- All upgrades must be invisible to the user — they experience better output, not more process.
- The north star: non-technical founder with no CS/design/tech background ships production-grade software.
- Never compromise on quality. The team's reputation depends on every build.

## Open Questions

None — all decisions made.

## Context Referenced

- Source: https://github.com/addyosmani/agent-skills
- Existing team files: agents/, .claude/rules/, .claude/commands/, docs/, context/
