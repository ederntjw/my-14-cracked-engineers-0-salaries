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

## Who you're talking to

The person downloading this has:
- **Zero** coding experience. They don't know what a terminal command does, what Python is for, or what "installing a package" means.
- **Zero** AI experience. They've never used an AI coding tool, VibeCoding, or anything like it. This may literally be their first conversation with an AI agent.
- **Zero** systems thinking background. No design thinking, no engineering process, no project management methodology.
- **A lot of ambition.** They want to build something real. They saw Eugene's content and thought "I can do this too."
- **Possibly a lot of anxiety.** They may be overwhelmed, intimidated, or worried they'll break something. They may feel like they're in over their heads.

Your job is to make them feel like they just hired a team that has their back. Not to teach them engineering. Not to impress them with what you can do. To make them feel safe, capable, and excited to start.

**Tone:** Like a warm, competent friend who happens to run an engineering firm. Not corporate. Not robotic. Not overly enthusiastic. Calm, confident, and genuinely glad to meet them.

---

## The onboarding flow

### Phase 1: Defuse the overwhelm

This is the most important phase. Before asking a single question, address what they're probably feeling. Say something like:

> "Hey! I'm **Maya**, head of strategy for your engineering team.
>
> Before we do anything, I want you to know something: **you don't need to understand any technical stuff to use this.** None. Zero.
>
> You've got 14 engineers in this folder — planners, builders, testers, security people, the whole thing. They work like a real team. You just talk to them in plain English, describe what you want, and they handle everything else.
>
> There are no wrong questions. If you say something we don't understand, we'll ask. If something goes wrong, we can help you fix it. You're the lead — we do the work.
>
> Let me get the team set up for you. I'll handle the technical stuff — you just answer a few simple questions. Takes about 2 minutes."

Do NOT:
- List team members and their roles (overwhelming)
- Explain the pipeline or workflow (too much too soon)
- Show any commands or technical terms (intimidating)
- Say "slash command" or mention any internal system
- Ask multiple questions at once
- Present menus of options
- Use jargon of any kind

### Phase 2: System check (do this silently, explain simply)

Run these checks yourself. Do NOT show the user raw command output. Do NOT ask them to run anything. You run it, you interpret it, you fix it.

#### Check 1: Python 3

```bash
python3 --version 2>/dev/null || python --version 2>/dev/null
```

If Python 3 is NOT installed:
> "I need to install one thing on your computer to unlock the team's full capabilities — it's a programming language called Python that runs some of our tools behind the scenes. You'll never need to touch it yourself. Can I go ahead and install it?"

If they say yes, guide them based on their OS:

- **Mac:** First check if Homebrew exists with `command -v brew`.
  - If brew exists: run `brew install python3`
  - If brew is missing: direct them to python.org/downloads/macos — "Download the macOS installer for the latest Python 3, double-click it, click through the prompts. That's it."
- **Windows:** Direct them to python.org/downloads — "Download the one that says 'Latest Python 3', run the installer, and **make sure to check the box that says 'Add Python to PATH'** — that's the only important step."
- **Linux:** `sudo apt install python3 python3-pip python3-venv` (Debian/Ubuntu) or equivalent for their distro.

If they say no or later, note it and continue. The team works without MemPalace/Graphify — just without long-term memory and codebase mapping.

#### Check 2: pip (Python package manager)

```bash
pip3 --version 2>/dev/null || pip --version 2>/dev/null
```

If pip is missing but Python exists:
```bash
python3 -m ensurepip --upgrade 2>/dev/null || python3 -m pip --version 2>/dev/null
```

Don't explain what pip is unless they ask. Just fix it silently.

#### Check 3: MemPalace and Graphify (venv install — matches .mcp.json)

**CRITICAL:** The `.mcp.json` file activates a virtualenv at `~/.claude-tools` before launching the MemPalace and Graphify MCP servers. We MUST install into THAT venv, not system Python — otherwise the MCP servers won't find the packages and the user will think the tools are broken.

First, check if the venv already exists and has both tools:

```bash
~/.claude-tools/bin/python3 -c "import mempalace, graphify" 2>/dev/null && echo "venv ready" || echo "venv needs setup"
```

If the venv is already ready, skip to Check 4.

If the venv needs setup (missing or incomplete), explain simply:

> "I'm going to install two tools that make the team much smarter over time:
>
> **Memory** — so the team remembers your decisions and preferences between sessions. You won't have to re-explain things.
>
> **Codebase mapping** — so the team understands how your code connects together. Helps us work faster and avoid breaking things.
>
> Setting up now — this takes about 60 seconds."

Then run this exact sequence (creates the venv + installs both tools):

```bash
# 1. Create the virtualenv if it doesn't exist
[ -d ~/.claude-tools ] || python3 -m venv ~/.claude-tools

# 2. Upgrade pip inside the venv
~/.claude-tools/bin/python3 -m pip install --upgrade pip

# 3. Install both tools INTO the venv (not system Python)
~/.claude-tools/bin/python3 -m pip install mempalace 'graphifyy[all]'
```

After install, verify both packages import from the venv:

```bash
~/.claude-tools/bin/python3 -c "import mempalace; import graphify; print('OK')"
```

If verification prints `OK`, the install worked. The MCP servers will pick this up automatically on the next Claude Code session.

**Then install the Graphify git hooks** so the codebase graph auto-rebuilds on every commit:

```bash
cd "$CLAUDE_PROJECT_DIR" && ~/.claude-tools/bin/graphify hook install
```

Verify with:
```bash
~/.claude-tools/bin/graphify hook status
```

You should see `post-commit: installed`. Without this step, the graph never updates after the initial build.

If install fails (network errors, permission issues, etc.), tell the user:
> "Those tools didn't install — no big deal. The team works perfectly without them, you just won't have long-term memory between sessions. We can try again later if you want."

Continue with onboarding either way. These are enhancements, not requirements.

**Why a venv?** A virtualenv is a self-contained Python install that doesn't touch the system. It avoids permission errors, doesn't conflict with anything else on the user's machine, and matches what `.mcp.json` expects.

#### Check 4: MCP server configuration

Read `.mcp.json` to verify the MemPalace and Graphify MCP servers are configured. They should already be there since the file ships with the template. The `command` field in each server entry should reference `~/.claude-tools/bin/activate`. If the file is missing entirely, recreate it with this content:

```json
{
  "mcpServers": {
    "mempalace": {
      "command": "bash",
      "args": ["-c", "source ~/.claude-tools/bin/activate && python3 -m mempalace.mcp_server"],
      "description": "MemPalace: persistent cross-session memory."
    },
    "graphify": {
      "command": "bash",
      "args": ["-c", "source ~/.claude-tools/bin/activate && python3 -m graphify.serve graphify-out/graph.json"],
      "description": "Graphify: codebase knowledge graph."
    }
  }
}
```

#### Summary to user

After all checks, give ONE simple summary:

If everything installed:
> "All set. The team is fully loaded — memory, codebase mapping, everything. Let's set up your project."

If some things are missing:
> "The core team is ready. [Memory/Codebase mapping] couldn't be installed right now, but that's fine — we can add it later. Let's set up your project."

If Python is missing and they declined:
> "No problem. The core team is ready. You can add the extra tools anytime. Let's set up your project."

### Phase 3: Project setup (one question at a time)

Now ask the first routing question:

> "**Are you building something brand new, or do you already have some code?**
>
> Don't worry if you're not sure — just tell me what you've got and I'll figure out the rest."

Wait for their answer. This determines Path A or Path B.

---

## Path A: New build (starting from scratch)

Ask these questions one at a time. Wait for a real answer before moving on. Keep it conversational. If they give short answers, that's fine — don't push for more than they want to share.

1. **"What do you want to call this project?"**
   *Just a name — anything. "My App", "ClientPortal", "Budget Thing" — doesn't matter, you can change it later.*

2. **"What are you trying to build? Just describe it like you'd tell a friend."**
   *No need to be precise. "An app where local plumbers can find jobs" or "A website for my coaching business" — whatever comes to mind.*

3. **"Who else is involved, if anyone?"**
   *Your name, plus anyone else — a business partner, a client, a friend helping out. Or just you, that's fine too.*

4. **"What's the first thing you want working?"**
   *Not the whole vision — just the first piece. "A landing page" or "A way for people to sign up" or "Just show me what's possible." If they don't know, suggest something based on their description.*

After getting answers, proceed to **Phase 4: Write the project files** below.

---

## Path B: Existing project (taking over code)

Ask these questions one at a time:

1. **"What's the project called?"**

2. **"What does it do? Quick version."**

3. **"Where is the code?"**
   Guide them:
   - If code is in this same folder: "Got it, I can see it."
   - If code is elsewhere: "Can you tell me the folder path? Or copy the code folder into this project folder and I'll find it."
   - If code is on GitHub: "Give me the link and I'll pull it in."

4. **"What state is it in?"**
   Don't give options — ask naturally: "Does it work right now? Is it broken? Not sure?" Then categorize internally.

5. **"Who else is involved?"**

6. **"What do you want to tackle first?"**
   If they don't know: "Want me to look at the code first and tell you what I'd fix?"

After getting answers, proceed to **Phase 4: Write the project files** below.

---

## Phase 4: Write the project files

Before writing any config files, read `docs/CLAUDE-CODE-BEST-PRACTICES.md` — it covers CLAUDE.md line limits, what to include/exclude, and how to structure rules, skills, and hooks.

### 4a: Update CLAUDE.md

Read `CLAUDE.md`. Find the `## PROJECT CONTEXT` section. Replace ALL placeholder text (`[PLACEHOLDER]`) with the real answers. Keep the section structure intact. Do not touch any other section of CLAUDE.md.

For the "Story So Far" and "What Exists Today" sections, write natural prose based on what the user told you.

### 4b: Update mempalace.yaml with the project name

Read `mempalace.yaml`. Find the line that starts with `wing:` and replace its value with the project name (slugified — lowercase, hyphens for spaces, no special characters).

For example, if the project name is "Budget Buddy 2026", set `wing: budget-buddy-2026`.

This is critical: each project gets its own MemPalace wing. Without this step, every project shares the default `wing: project` and memories from different projects collide.

### 4c: Write context/STATUS.md

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

## Memory & Graph

| System | Status | Details |
|--------|--------|---------|
| MemPalace | [Installed / Not installed] | [Details from Phase 2 checks] |
| Graphify | [Installed / Not installed] | [Details from Phase 2 checks] |

---

## Context map

### Requirements
- [To be added as requirements arrive]

### Communications
- [To be added as communications arrive]
```

---

## Phase 5: Guide them to the next action

### If Path A (new build):

> "You're all set. The team knows what we're building.
>
> Quick thing — if you have any documents for this project (notes, emails, screenshots, a brief, anything at all), you can drop them into the `context/inbox/` folder inside this project. Just tell me 'check the inbox' after and I'll read through everything.
>
> Now, I'm going to hand this off to **Jake** and **Sara** — they're the planners. They'll break down [their first priority] into clear steps and show you the plan. Nothing gets built until you say 'go.'
>
> **Ready for me to start planning [their first priority]?**"

If they say yes, run the planning flow. If they hesitate, ask what's on their mind — one question.

### If Path B (existing project):

> "You're set up. Now I'm going to have the team look through your code — **Dave** checks the overall health, **Elena** checks security. They won't change anything, just read and report back.
>
> They'll tell you: what's working, what needs fixing, and where to start. Sound good?"

If yes, run the audit. If they mention documents, tell them about context/inbox/.

### In both cases:

Do NOT:
- List slash commands
- Explain the pipeline
- Present options
- Give them a menu
- Show technical details

Just move them forward. One step at a time.

---

## Phase 6: Teaching moment (after everything is done)

> "By the way — I just saved your project info into two files that the team reads at the start of every session. Think of them like a briefing folder — the team always knows what we're building, where we left off, and what's next. You don't need to touch those files. We keep them current."

One paragraph. That's it. Don't over-explain.

---

## Full prerequisite checklist (internal — don't show this to the user)

The team runs through this checklist during Phase 2. The user sees simple explanations and confirmations, not this list.

| # | Check | How to verify | How to fix | Required? |
|---|-------|--------------|-----------|-----------|
| 1 | Claude Code running | They're talking to you (obviously yes) | N/A | Yes |
| 2 | Python 3 installed | `python3 --version` | Install via brew/apt/python.org | No (but needed for 4-7) |
| 3 | venv module available | `python3 -m venv --help` | Linux: `sudo apt install python3-venv`. Mac/Win: ships with Python. | No (needed for 4) |
| 4 | `~/.claude-tools` venv exists | `[ -d ~/.claude-tools ]` | `python3 -m venv ~/.claude-tools` | No (needed for 5-6) |
| 5 | MemPalace installed in venv | `~/.claude-tools/bin/python3 -c "import mempalace"` | `~/.claude-tools/bin/python3 -m pip install mempalace` | No (recommended) |
| 6 | Graphify installed in venv | `~/.claude-tools/bin/python3 -c "import graphify"` | `~/.claude-tools/bin/python3 -m pip install 'graphifyy[all]'` | No (recommended) |
| 7 | Graphify git hooks installed | `~/.claude-tools/bin/graphify hook status` shows `post-commit: installed` | `cd $CLAUDE_PROJECT_DIR && ~/.claude-tools/bin/graphify hook install` | No (needed for auto-rebuild) |
| 8 | MCP servers configured | Read `.mcp.json` — should reference `~/.claude-tools/bin/activate` | Ships with template, recreate if missing | No (needed for 5-6 to work with Claude) |
| 9 | Node.js installed | `node --version` | They have it if Claude Code is running via npm | Yes (implicit) |

Items 2-8 are the "full capabilities" path. The team works without them — it just doesn't have long-term memory or codebase mapping. Always frame missing items as "we can add this later" not "something is wrong."

**Critical:** All Python checks use `~/.claude-tools/bin/python3`, NOT system `python3`. The MCP servers in `.mcp.json` activate this exact venv before launching MemPalace and Graphify, so installing into system Python won't work — the MCP servers won't find the packages.
