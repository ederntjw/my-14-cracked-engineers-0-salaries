---
description: Sharpen a vague idea into something buildable before planning. Produces a focused scope with an explicit "Not Doing" list.
---

# /refine — What Exactly Are We Building?

Also triggers when: the user describes an idea that is vague, broad, or has multiple possible interpretations. Auto-triggers when `/plan` would struggle because the requirements aren't clear enough. Also when the user says things like "I'm thinking about...", "what if we...", "I have an idea", "I want to add something but I'm not sure exactly what", "can we do something like..."

**This command runs automatically when the team detects a vague idea.** The user never needs to type `/refine`. If someone says "I want to build a marketplace" — that's too vague to plan. Refine first.

---

## Who runs this

**Maya** (Head of Strategy) leads. She asks the questions and shapes the output. She may call **Sara** (Architect) for feasibility checks on specific ideas.

---

## When to trigger (auto-detection)

Run `/refine` automatically when ANY of these are true:
- The user describes something with no clear scope ("I want a dashboard")
- The request has multiple valid interpretations ("add user management")
- The user uses tentative language ("maybe we could...", "what if...", "something like...")
- The user describes an outcome without specifying what to build ("I want users to be able to pay")
- The user describes more than 3 features in a single breath (scope overload)

Do NOT run `/refine` when:
- The request is specific and clear ("add a logout button to the navbar")
- The user has already written a spec or detailed requirements
- A `/wrap` handoff already exists with clear build brief

---

## Process

### Step 1: Restate the idea

Restate what the user said in one sentence. This proves you understood. If you're not sure, ask one clarifying question — not five.

> "So the core idea is: [restatement]. Is that right, or am I missing something?"

### Step 2: Ask sharpening questions (3 max)

Ask the single most important question first. Wait for the answer. Then ask the next one. Never dump all questions at once.

Good sharpening questions:
- "Who is this for? You, your users, or both?"
- "What's the one thing this has to do on day one?"
- "Is there something similar you've seen that you want to be like?"
- "What would make you say 'this is done'?"
- "What's the simplest version of this that would be useful?"

Bad questions (don't ask these):
- "What tech stack do you want?" (team decides this)
- "Do you want authentication?" (team handles this based on requirements)
- "What database should we use?" (technical detail, not user's concern)

### Step 3: Define what we ARE building (MVP scope)

Based on the answers, define the minimum viable version. This is what gets built first. Not the dream version — the version that proves the concept works.

Write it as a plain English paragraph, then a bullet list of specific things it includes.

### Step 4: Define what we are NOT building (the "Not Doing" list)

This is the most valuable part. For every thing the user mentioned or implied that is NOT in the MVP scope, list it explicitly with a one-line reason.

Format:
```
## Not Doing (for now)
- [Feature/idea] — [why it's out of scope for now]
- [Feature/idea] — [why it's out of scope for now]
```

This prevents scope creep. If it's not on the "building" list, it goes on the "not building" list. Nothing stays in limbo.

### Step 5: Surface assumptions

List 3-5 assumptions the team is making. These are things that could change the plan if they turn out to be wrong.

Format:
```
## Assumptions (check these)
- We're assuming [X]. If that's wrong, [Y changes].
- We're assuming [X]. If that's wrong, [Y changes].
```

### Step 6: Confirm and hand off

Present the full output (Steps 3-5) to the user. Ask:

> "Does this match what you have in mind? Anything to add or cut?"

Once confirmed:
1. Save to `context/decisions/[date]-[topic]-scope.md`
2. Hand off to Jake and Sara for `/plan`
3. The plan reads the scope document automatically

---

## Output Format

```markdown
# [Idea Name] — Scope Definition

**Date:** YYYY-MM-DD
**Defined by:** Maya + [User name]

## What we're building (MVP)

[Plain English paragraph describing the simplest useful version]

**Includes:**
- [Specific thing 1]
- [Specific thing 2]
- [Specific thing 3]

## Not doing (for now)

- [Feature] — [reason it's out of MVP scope]
- [Feature] — [reason it's out of MVP scope]

## Assumptions

- [Assumption 1]. If wrong, [impact].
- [Assumption 2]. If wrong, [impact].

## Success criteria

How we'll know this works:
- [Observable outcome 1]
- [Observable outcome 2]

## Open questions

- [Question 1] (needs answer before planning)
- Or: "None — scope is clear."
```

---

## Rules

- **3 questions maximum.** If you need more than 3 questions, the idea isn't vague — you're overthinking it.
- **One question at a time.** Wait for the answer. Don't dump a list.
- **No technical jargon.** The user may not know what an "API endpoint" is. Describe features in terms of what the user or their customers experience.
- **The "Not Doing" list is mandatory.** Never skip it. Scope creep kills first-time builds.
- **Assumptions are mandatory.** Every plan has hidden assumptions. Surface them now, not during the build.
- **Don't over-scope.** If the user says "I want a social media platform," the MVP is not Instagram. It's a profile page with a feed. Start absurdly small and expand.
- **Auto-hand off to /plan when confirmed.** Don't make the user ask for the next step.

---

## Teaching moment (after refinement)

> "What I just did is called scope definition (deciding exactly what version 1 looks like before anyone writes a single line of code). The 'Not Doing' list is the most important part — it's how you prevent the project from growing out of control. Professional teams spend more time deciding what NOT to build than what to build. If a stakeholder asks what your plan is, you can point to this document. It answers both 'what are we building?' and 'what are we deliberately leaving out?'"

---

## Common Rationalizations (things the team might try to skip)

| Excuse | Reality |
|--------|---------|
| "The idea is clear enough, let's just start planning" | Vague ideas produce vague plans. Vague plans produce features nobody asked for. 10 minutes of refinement saves days of rework. |
| "We can figure out the scope as we go" | Scope creep is the #1 reason first-time builds fail. Define it now or fight it later. |
| "The user knows what they want" | The user knows the *outcome* they want. They rarely know the *smallest version* that achieves it. That's our job. |
| "The 'Not Doing' list is unnecessary" | Without it, every feature the user mentions becomes an implied requirement. The list makes boundaries explicit and prevents silent expectations. |
