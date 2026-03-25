---
description: Explain what just happened in plain English. Use after any significant change, build, or when confused.
---

# /explain — What the Hell Is This?

Also triggers when you say: "what the hell is [X]?", "explain like I'm 12", "can you explain that in a simpler fashion?", "I don't understand what you mean", "what does that mean?", "I want to learn too, teach me this"

When this command is invoked, look at what was just done in this session and explain it in plain English.

## Process

1. **Review recent actions** — what files were changed, what commands were run, what was built
2. **Identify the key changes** — what's different now vs before
3. **Explain in plain English** using this structure:

## Output Format

### What Changed
- List each significant change in one sentence
- Use everyday language, not technical jargon
- If jargon is unavoidable, define it in parentheses

### Why It Matters
- How does this move the project forward?
- What can be done now that couldn't be done before?
- What risk was reduced or eliminated?

### What It Means Technically (Learning Moment)
- Pick ONE concept from what just happened
- Explain it using an analogy anyone would understand
- Connect it to something already known

### What's Next
- What should be done after this change?
- Any follow-up tasks or testing needed?

## Rules
- Never assume the user knows technical terms — define everything
- Use analogies: "Think of it like..." or "It's similar to..."
- Keep it under 2 minutes of reading time
- If multiple complex things happened, focus on the most important one and briefly list the rest
- Don't be condescending — teach, don't lecture
