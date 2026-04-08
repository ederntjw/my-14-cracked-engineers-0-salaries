---
description: "Evidence-based verification: 7-check protocol requiring actual command output as proof before any SHIP verdict"
---
# Evidence Protocol

## The Rule

No verification claim without proof. Claim nothing without evidence. Evidence means actual command output from the current session, run after the most recent code change. Not descriptions. Not summaries. Real output.

This is what separates "I think it works" from "here's proof it works." For a founder shipping to paying customers, the difference is everything.

## The 7-Check Verification Protocol

Every build must pass ALL 7 checks before it can SHIP. Each check is named, sequenced, and requires specific evidence.

### Check 1: BUILD
**What:** The project compiles and builds without errors.
**Command:** `npm run build` (or equivalent detected build command)
**Evidence required:** Build command output showing successful completion with exit code 0.
**Failure action:** Route to Tom (build-fixer). Self-heal.

### Check 2: TEST
**What:** All tests pass.
**Command:** `npm test` (or equivalent detected test command)
**Evidence required:** Full test runner output showing pass/fail counts. Zero failures.
**Failure action:** Route to Max (tdd-guide). Self-heal.

### Check 3: LINT
**What:** No linting or type errors.
**Commands:** `npx tsc --noEmit` + linter (if configured)
**Evidence required:** Type checker output showing 0 errors. Linter output showing 0 errors.
**Failure action:** Fix directly (type annotations, import fixes). Self-heal.

### Check 4: FUNCTIONALITY
**What:** The code does what the plan says it should do.
**Evidence required:** For each acceptance criterion in the PLAN file:
- Specific code reference (file:line) proving implementation
- Test output proving the behavior works
- If no automated test exists, describe manual verification steps
**Failure action:** Identify gap, implement missing functionality. Self-heal.

### Check 5: ARCHITECT
**What:** No architectural drift, no unplanned structural changes.
**Evidence required:** Compare actual changes against the PLAN. For each file changed:
- Was this file in the plan? If not, justify why it was touched.
- Does the change match the planned approach? If it diverges, document why.
**Failure action:** If drift is minor and justified, document it. If major, escalate to user.

### Check 6: TODO
**What:** No unfinished work left behind.
**Evidence required:** Grep output showing no `TODO`, `FIXME`, `HACK`, or placeholder comments in changed files. If any exist, they must reference a tracked issue number.
**Failure action:** Either complete the TODO or create a tracked issue for it.

### Check 7: ERROR_FREE
**What:** No runtime errors, no console errors, no unhandled edge cases.
**Evidence required:** If the project has a dev server, start it and verify no console errors. If not, verify error handling exists on all new code paths (try-catch, error boundaries, null checks).
**Failure action:** Add error handling. Self-heal.

## Evidence Freshness

Evidence expires the moment code changes. If you fix something after Check 2, re-run Checks 1-3 minimum. The checks that passed before the fix may no longer pass after it.

**Rule:** Evidence must be from commands run AFTER the most recent code change. If any code changed since the last run, the evidence is stale. Re-run.

## Verification Report Format

Every QA verdict includes this report:

```
## 7-Check Verification

| # | Check | Status | Evidence |
|---|-------|--------|----------|
| 1 | BUILD | PASS/FAIL | [build output summary] |
| 2 | TEST | PASS/FAIL | [test counts: X passing, Y failing] |
| 3 | LINT | PASS/FAIL | [tsc output: 0 errors / N errors] |
| 4 | FUNCTIONALITY | PASS/FAIL | [criteria checked: X/Y met] |
| 5 | ARCHITECT | PASS/FAIL | [drift: none / minor justified / major] |
| 6 | TODO | PASS/FAIL | [open TODOs: 0 / N with issue refs] |
| 7 | ERROR_FREE | PASS/FAIL | [runtime check summary] |

Self-healing cycles: [0-3]
Issues fixed internally: [list or "none"]
```

## When Evidence Is Impossible

Some checks (ARCHITECT, parts of FUNCTIONALITY) require judgment, not command output. For these, state your reasoning explicitly so another engineer could verify your claim from what you wrote.

**Good judgment evidence:**
> "ARCHITECT: PASS. All changes confined to files listed in the plan. One additional file touched (utils/format-date.ts) — extracted from a 60-line function in dashboard.tsx per the plan's 'keep functions under 50 lines' criterion."

**Bad judgment evidence:**
> "ARCHITECT: PASS. Looks good."

## The Standard

Could someone else verify every claim in the report from the evidence provided? If yes, the report passes. If no, add more detail until it does.

## Common Rationalizations (DO NOT fall for these)

| Excuse | Reality |
|--------|---------|
| "This change is too small to need all 7 checks" | Small changes cause production outages. A one-line typo can break a build. The checks take seconds. The debugging takes hours. |
| "I already know it works, I just wrote it" | You know what you *intended*. The checks verify what *actually happened*. Your confidence is not evidence. |
| "The tests passed last time, I only changed one thing" | Evidence expires the moment code changes. A fix to one file can break another. Re-run. |
| "I'll verify after I finish the next task" | Stale evidence compounds. If this task introduced a bug, the next task builds on it. Verify now. |
| "This is just a refactor, behavior didn't change" | Prove it. If behavior didn't change, the checks will pass in seconds. If they don't, you just caught a regression. |

## Teaching Moment

> Evidence-based verification is like an audit trail (a record that proves something actually happened, not just that someone said it happened). Think of it like a building inspection — the inspector doesn't just say "the wiring looks fine," they test each circuit and write down the readings. If a client or investor asks "how do you know this works?" you point to the 7-check report with actual test results. That's the difference between "trust me" and "here's the proof."
