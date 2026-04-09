---
description: First-run setup. Asks a few simple questions and gets the engineering team ready to build. Runs automatically on first message if STATUS.md has placeholder text.
---

# /setup — Welcome to Your Engineering Team

Also triggers when: the session-start hook detects placeholder text in STATUS.md (first-ever run), or the user says "set up the project", "initialize", "configure the team", "first time setup", "what do I do first?", "how does this work?"

---

## Before anything else

Read `context/STATUS.md`. If it contains real project content (not `[PROJECT NAME]` placeholder text), tell the user:

> "This project is already set up. Run `/status` to see where things stand."

If STATUS.md has placeholder text (or doesn't exist), proceed with onboarding below.

---

## The onboarding flow

Keep the tone warm, simple, and direct. The user may have zero technical background. No jargon. No assumptions. Talk like you're explaining something to a smart friend who's never coded before.

### Step 1: Welcome and explain

Say something like:

> "Hey! Welcome. I'm **Maya**, head of strategy for your engineering team.
>
> Here's all you need to know: you talk, we build. You've got 14 engineers here — planners, builders, testers, security, the works. You don't need to know their names, learn any commands, or understand any technical stuff. Just describe what you want in plain English, and we handle everything else.
>
> Let me ask you a few quick questions so the team knows what we're building. Takes about 2 minutes."

### Step 2: Ask the first question

> "First question: **are you building something new, or do you have an existing project you want us to work on?**"
>
> - **New** — starting from scratch, no code yet
> - **Existing** — you already have code (from VibeCoding, another AI tool, a developer, or yourself)

Wait for their answer. This determines the path.

---

## Path A: New build (starting from scratch)

Ask these questions one at a time. Wait for a real answer before moving on. Keep it conversational.

1. **"What's the project called?"**
   *Just a name. "TaskFlow", "BudgetBuddy", "ClientPortal" — whatever you want to call it.*

2. **"What are you trying to build? Describe it like you'd explain it to a friend."**
   *2-3 sentences. What does it do? Who uses it? What problem does it solve?*

3. **"Who's involved?"**
   *Your name and role. Anyone else working on this — a partner, a client, a co-founder. Just names and what they do.*

4. **"What do you want to build first?"**
   *List 3-5 things in rough order. The first thing you want working, then the next, then the next.*

After getting answers, proceed to **Step 3: Write the project files** below.

---

## Path B: Existing project (taking over code)

Ask these questions one at a time:

1. **"What's the project called?"**

2. **"What does it do? Give me the quick version."**

3. **"Where is the code?"**
   *Guide them:*
   - If code is in this same folder: "Got it, I can see it."
   - If code is elsewhere: "Copy this folder into the project, or tell me the path and I'll look at it."
   - If code is on GitHub: "Give me the repo link and I'll clone it."

4. **"What state is it in? Pick the closest:"**
   - It works but needs improvement (MVP, needs polish)
   - It's broken and I need help fixing it
   - It works and I want to add new features
   - I'm not sure — I need you to look at it and tell me

5. **"Who's involved?"**
   *Your name and anyone else.*

6. **"What do you want to tackle first?"**
   *List 3-5 priorities.*

After getting answers, proceed to **Step 3: Write the project files** below.

---

## Step 2b: Check dependencies

Before writing project files, check if the memory and graph tools are installed:

```bash
python3 -c "import mempalace" 2>/dev/null && echo "MemPalace: installed" || echo "MemPalace: not installed"
python3 -c "import graphify" 2>/dev/null && echo "Graphify: installed" || echo "Graphify: not installed"
```

If either is missing, tell the user:

> "Quick thing — your team has two optional upgrades that make it much smarter over time:
>
> **MemPalace** remembers decisions and preferences across sessions (so you never re-explain things).
> **Graphify** maps your codebase so the team understands how everything connects.
>
> Want me to install them? It's one command: `pip install graphifyy[all] mempalace`"

If they say yes, run the install. If they say no or later, proceed — both tools are optional. The team works without them.

If both are installed AND this is Path B (existing project), also offer to build the initial knowledge graph:

> "Since you have existing code, I can build a map of how everything connects. Takes about a minute. Want me to run it?"

If yes, run `graphify $PROJECT_DIR`.

---

## Step 3: Write the project files

### 3a: Update CLAUDE.md

Read `CLAUDE.md`. Find the `## PROJECT CONTEXT` section. Replace ALL placeholder text (`[PLACEHOLDER]`) with the real answers. Keep the section structure intact. Do not touch any other section of CLAUDE.md.

For the "Story So Far" and "What Exists Today" sections, write natural prose based on what the user told you.

### 3b: Write context/STATUS.md

Write `context/STATUS.md` with this structure:

```markdown
# [PROJECT NAME] — Project Status

**Last updated:** [today's date]
**Updated by:** Engineering team (setup)

---

## What is [PROJECT NAME]

[2-3 sentence description from their answers]

---

## Who is involved

| Person | Role | Context |
|--------|------|---------|
[Rows from their answers]

---

## Current status

**Phase:** [Greenfield / MVP / Taking over existing code]

[1-2 sentences about where things stand right now]

---

## What comes next

[Numbered list from their priorities]

---

## App build status

| Component | Status | Notes |
|-----------|--------|-------|
| [To be filled as the build progresses] | | |

---

## Known issues

[None yet — will be tracked as the build progresses]

---

## Context map

### Requirements
- [To be added as requirements arrive]

### Communications
- [To be added as communications arrive]
```

---

## Step 4: Guide them to the next action

### If Path A (new build):

> "You're all set! Your team knows what it's building.
>
> Before we jump in — do you have any documents for this project? A brief, notes, screenshots, emails, anything at all. If you do, drop them into the `context/inbox/` folder and tell me. If not, no worries.
>
> Either way, I'm going to hand you off to **Jake** (our planner) and **Sara** (our architect). They'll break your first milestone into steps and show you the plan. Nothing gets built until you say go."

Then immediately ask: **"Ready for me to start planning [their first milestone from Step 2 question 4]?"**

Do NOT list commands. Do NOT explain the pipeline. Do NOT give them options. Just move them forward. If they say yes, run the planning flow. If they hesitate, ask what's on their mind.

### If Path B (existing project):

> "You're set up. Now I'm going to bring in **Dave** (our codebase auditor) and **Elena** (security lead) to look at what you've got. They'll read through everything and give you a clear report: what's working, what's broken, and what to fix first. They won't change anything — just read and report."

Then immediately ask: **"Want me to run the health check now?"**

If yes, run the audit. If they also mention documents, tell them to drop files in `context/inbox/` and let you know.

Do NOT list commands. Do NOT explain the pipeline. Just move them forward.

---

## Teaching moment (after setup)

Briefly explain what just happened:

> "Quick explanation of what I just did: I saved your project info into two files.
>
> **CLAUDE.md** is like a briefing document — every time a new session starts, I read it first so I know what we're building.
>
> **STATUS.md** is the living source of truth — it gets updated every session with what was built, what changed, and what's next. Think of it as a project dashboard that never goes stale.
>
> You don't need to edit these files yourself. The team keeps them current."
