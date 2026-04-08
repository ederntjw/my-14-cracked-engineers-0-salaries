---
description: "Development workflow: plan-first, TDD, code review, verification before shipping"
---
# Development Workflow

> This file extends [common/git-workflow.md](./git-workflow.md) with the full feature development process that happens before git operations.

The Feature Implementation Workflow describes the development pipeline: research, planning, TDD, code review, and then committing to git.

## Feature Implementation Workflow

0. **Research & Reuse** _(mandatory before any new implementation)_
   - **GitHub code search first:** Run `gh search repos` and `gh search code` to find existing implementations, templates, and patterns before writing anything new.
   - **Library docs second:** Use Context7 or primary vendor docs to confirm API behavior, package usage, and version-specific details before implementing.
   - **Exa only when the first two are insufficient:** Use Exa for broader web research or discovery after GitHub search and primary docs.
   - **Check package registries:** Search npm, PyPI, crates.io, and other registries before writing utility code. Prefer battle-tested libraries over hand-rolled solutions.
   - **Search for adaptable implementations:** Look for open-source projects that solve 80%+ of the problem and can be forked, ported, or wrapped.
   - Prefer adopting or porting a proven approach over writing net-new code when it meets the requirement.

1. **Plan First**
   - Use **planner** agent to create implementation plan
   - Generate planning docs before coding: PRD, architecture, system_design, tech_doc, task_list
   - Identify dependencies and risks
   - Break down into phases

2. **Incremental Implementation (the 100-line rule)**
   - Never write more than ~100 lines of code without running tests and verifying
   - Build in **vertical slices** — complete end-to-end functionality (DB → API → UI for one feature), not horizontal layers (all DB, then all API, then all UI)
   - Each increment must leave the system in a working, testable state
   - If you're about to write a large batch of code, stop and ask: "What's the smallest piece I can build, test, and verify right now?"
   - **Red flags:** writing 100+ lines without testing, building all backend before touching frontend, mixing unrelated changes in one increment

3. **TDD Approach**
   - Use **tdd-guide** agent
   - Write tests first (RED)
   - Implement to pass tests (GREEN)
   - Refactor (IMPROVE)
   - Verify 80%+ coverage

4. **Code Review**
   - Use **code-reviewer** agent immediately after writing code
   - Address CRITICAL and HIGH issues
   - Fix MEDIUM issues when possible

5. **Verify Loop (Persistent — do not exit until clean)**
   - After implementation, enter a verify loop:
     ```
     BUILD → VERIFY → issues found? → FIX → VERIFY again → repeat until CLEAN
     ```
   - Each verify pass checks: build succeeds, tests pass, no type errors, no lint errors
   - Each check requires **actual command output** as evidence (see evidence-protocol.md)
   - If a fix introduces a new issue, that counts as a new cycle
   - Maximum 3 self-healing cycles per issue before escalating to the user
   - Only exit the loop when ALL checks produce clean evidence
   - This is what separates "I think it works" from "here's proof it works"

## Common Rationalizations (DO NOT fall for these)

| Excuse | Reality |
|--------|---------|
| "I'll write the tests after" | Then you'll write tests that confirm your code instead of challenging it. TDD catches design problems. Tests-after confirms assumptions. |
| "This is a quick fix, no need for the full workflow" | Quick fixes that skip review and testing are the #1 source of production bugs. The workflow exists because quick fixes have burned us before. |
| "I know this code, I don't need to research first" | You know *your* version of this problem. A 2-minute search might find a battle-tested library that handles edge cases you haven't thought of. |
| "The plan is in my head, I don't need to write it down" | Plans in your head can't be reviewed, challenged, or resumed in a fresh session. Write it down or it doesn't exist. |
| "Code review is a formality for code this simple" | Simple code with subtle bugs passes without review. Complex code with obvious bugs gets caught by tests. Review catches the middle ground that neither testing nor the author's eyes will find. |

6. **Commit & Push**
   - Only after the verify loop exits clean
   - Detailed commit messages
   - Follow conventional commits format
   - See [git-workflow.md](./git-workflow.md) for commit message format and PR process
