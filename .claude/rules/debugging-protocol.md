---
description: "Structured debugging: six-step triage with Stop-the-Line rule. Auto-triggers when any error is encountered."
---
# Debugging Protocol

## The Stop-the-Line Rule

When a bug or error is found, STOP new work. Do not push forward hoping it resolves itself. Do not start the next task while something is broken. Errors compound — a bug in Step 3 that goes unfixed makes Steps 4-10 wrong.

**Sequence:** Halt → Preserve evidence → Diagnose → Fix → Guard → Resume.

This rule applies to ALL team members, not just Tom. If Max finds a test failure, he stops and triages. If Aisha finds a QA failure, she stops and triages. The protocol is universal.

## The Six-Step Triage

### Step 1: Reproduce

Establish reliable failure reproduction. Can you make it fail consistently?

- Run the exact command that triggered the error
- Note whether it's deterministic (fails every time) or flaky (sometimes fails)
- If flaky: check for timing dependencies, state dependencies, or environment dependencies
- Record the exact error output — screenshots, terminal output, stack traces

**If you can't reproduce it, you can't fix it.** Don't guess. Reproduce first.

### Step 2: Localize

Identify which layer is failing. Don't start fixing until you know WHERE the bug lives.

| Layer | Symptoms | How to check |
|-------|----------|-------------|
| Build/compile | Red terminal, type errors | `npm run build` or `npx tsc --noEmit` |
| Test | Test runner shows failures | `npm test` — read the assertion error |
| Runtime | App crashes, console errors | Start dev server, check browser console |
| Database | Query errors, missing data | Check migration status, query logs |
| External service | Timeout, auth errors | Check API keys, service status |
| Configuration | "Module not found", env errors | Check .env, tsconfig, package.json |

For regressions (it worked before, now it doesn't): use `git bisect` to find the exact commit that broke it.

### Step 3: Reduce

Create the minimal failing case. Strip away everything unrelated.

- Comment out code until the error disappears, then restore the last piece — that's your culprit
- If it's a complex interaction, isolate the two components that are clashing
- The goal: "this specific thing causes this specific error"

### Step 4: Fix Root Cause

Fix the underlying issue, not the symptom.

- Ask "why" iteratively: Why did it fail? Because X. Why did X happen? Because Y. Keep going until you hit the root cause.
- A root cause fix means the bug can't come back. A symptom fix means it can.
- If the root cause is in a different module than where the error appeared, fix the source — don't patch the symptom.

**Bad fix:** Adding a null check to suppress an error that happens because data isn't being fetched correctly.
**Good fix:** Fixing the data fetch so it returns the expected shape.

### Step 5: Guard Against Recurrence

Write a regression test that:
1. Fails WITHOUT your fix (proves the test catches the bug)
2. Passes WITH your fix (proves the fix works)

This is non-negotiable. Every bug fix gets a test. The test is proof that this specific bug can never come back silently.

### Step 6: Verify End-to-End

After the fix + test:
1. Run the specific test that covers the fix
2. Run the full test suite (the fix might have broken something else)
3. Run the build
4. If it's a runtime bug, verify in the running app

Evidence required for all four. See evidence-protocol.md.

## Auto-Trigger

This protocol activates automatically when:
- A build command fails
- A test fails
- An error is pasted into the conversation
- The user says anything like "it's broken", "there's a bug", "this isn't working"
- An agent encounters an unexpected error during work

The team does not ask the user "should we debug this?" — it starts triaging immediately.

## Common Rationalizations (DO NOT fall for these)

| Excuse | Reality |
|--------|---------|
| "I know what the bug is, I don't need to reproduce" | You know what you *think* the bug is. Reproduction confirms it. Skipping reproduction leads to fixing the wrong thing. |
| "It's faster to just try a fix" | It's faster to try a fix, fail, try another, fail, and spend 30 minutes guessing. The protocol takes 5 minutes and fixes it right the first time. |
| "The regression test is overkill for this bug" | This exact bug already happened once. Without a test, it will happen again. The test takes 60 seconds. |
| "It works on my machine" | Then the bug is in the environment, not the code. That's still a bug. Localize which environment difference causes it. |
| "I'll add the test later" | You won't. The fix gets committed, the test gets forgotten, and the bug comes back in 3 weeks. Write it now. |

## Teaching Moment

> What I just did is called a triage (a structured way to diagnose and fix a problem, borrowed from emergency medicine). In hospitals, triage means figuring out what's wrong and how severe it is before treating anyone. In software, it means: reproduce the bug, find where it lives, isolate it, fix the root cause, and write a test so it can never come back. If someone asks about your team's debugging process, you'd say: "We follow a six-step triage — reproduce, localize, reduce, fix root cause, guard with a test, and verify end-to-end."
