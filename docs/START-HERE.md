# Start Here

You just got a 14-person engineering team. This guide explains what you have and how to use it. Read it once. After that, just talk — the team handles the rest.

---

## What is this?

Think of this folder like hiring a full engineering team that lives inside your computer. You have specialists: strategists, planners, architects, builders, testers, security experts, and more.

You don't manage them. You don't give them technical instructions. You don't need to know any programming language, design tool, or engineering process.

**You talk. They build.**

The team plans before building, tests everything, reviews its own code, checks security, and proves things work with actual evidence — not just "it should work." If something breaks, they fix it themselves. If they need your input, they ask one clear question.

---

## Dependencies (optional but recommended)

The team works out of the box with just Claude Code. For long-term memory and codebase understanding, the team uses two Python tools.

**You don't install these yourself.** The first-run `/setup` flow handles it for you — creating an isolated virtualenv at `~/.claude-tools` (so it doesn't touch your system Python) and installing both tools into that venv to match `.mcp.json`.

- **MemPalace** — remembers decisions, preferences, and institutional knowledge across sessions. So the team never asks you the same question twice.
- **Graphify** — builds a map of your codebase so the team understands how everything connects. New sessions start with full architectural awareness instead of exploring from scratch.

Both are optional. The team handles setup during onboarding. If you want to install manually, this is what `/setup` runs:

```bash
python3 -m venv ~/.claude-tools
~/.claude-tools/bin/python3 -m pip install --upgrade pip
~/.claude-tools/bin/python3 -m pip install mempalace 'graphifyy[all]'
cd path/to/this/folder && ~/.claude-tools/bin/graphify hook install
```

---

## How to start

### Step 1: Open the folder

If using the terminal:
```
cd path/to/this/folder
claude
```

If using VS Code or Cursor: open this folder, then open the Claude Code panel.

### Step 2: Say hello

That's it. Type anything. "Hey" works. The team detects it's a new project and walks you through setup — name, what you're building, who's involved. Takes about 2 minutes.

After that, you're building.

---

## How to talk to the team

Just say what you want in plain English. Here are real examples:

| What you say | What happens |
|-------------|-------------|
| "I want to build a marketplace for local services" | Maya (strategy) helps you sharpen the idea. What's version 1? What's NOT in version 1? Then Jake (planner) breaks it into steps. |
| "Build me a landing page" | Liam (frontend) designs and builds it. |
| "This is broken" + paste an error | Tom (DevOps) diagnoses it using a structured process and fixes it. |
| "Is this ready to ship?" | The team runs a full pre-launch checklist — security, performance, tests, everything. |
| "I had a call with my investor, they want X by Friday" | The team adjusts priorities. Maya captures the context. Jake replans if needed. |
| "Check out this GitHub repo, can we learn from it?" | Maya reads it and walks you through what's worth adopting. |
| "Clean this up" | Yuki simplifies the code — understands it first, then makes it cleaner. |
| "What just happened?" | Whoever just worked explains what they did in plain English. |

**You never need to type a command.** The team figures out what's needed based on what you say.

---

## What the team does automatically

You don't need to ask for any of this. It just happens:

- **Detects your tech stack** — figures out what languages, frameworks, and tools the project uses
- **Sharpens vague ideas** — if you say something broad like "I want a dashboard," Maya helps you define exactly what version 1 looks like before anyone writes code
- **Plans before building** — Jake and Sara break work into steps with checklists. Nothing gets built until you approve the plan.
- **Tests everything** — Max writes tests first, then builds the feature. This proves things work, not just that they look right.
- **Reviews its own code** — Nina checks every change for bugs, security issues, and quality problems
- **Checks security** — Elena scans for vulnerabilities before anything ships
- **Self-heals** — when something breaks, the team fixes it internally (up to 3 attempts) before asking you
- **Proves things work** — every claim ("tests pass," "build succeeds") comes with actual output as evidence
- **Catches itself taking shortcuts** — every critical workflow has built-in checks that prevent the team from skipping steps
- **Documents decisions** — architectural choices get recorded so no one has to re-explain why something was built a certain way
- **Saves progress** — the team checkpoints automatically so the next session picks up exactly where this one left off
- **Remembers everything** — decisions, preferences, and institutional knowledge persist across sessions via MemPalace (if installed)
- **Maps the codebase** — module relationships, core abstractions, and architecture are mapped via Graphify (if installed). New sessions start with full understanding instead of exploring from scratch
- **Recovers from crashes** — if a session dies unexpectedly, the next session automatically recovers any unmined context

---

## The two types of sessions

**Thinking sessions** — explore ideas, make decisions, brainstorm. No code gets written. At the end, the team saves your decisions so they can be loaded into a build session later.

**Build sessions** — execute. The team follows a pipeline: plan, build, test, review, verify. You approve the plan, they build it, and they prove it works.

You don't need to tell the team which type of session you're in. They figure it out based on what you say.

---

## Giving the team context

You don't need to write formal documents. Talk naturally:

- "My partner said we should focus on mobile first."
- "Here's an email from the client — they want login by next week."
- "I saw a competitor that does X, I want something like that but simpler."

The team captures everything. If you have files (PDFs, emails, screenshots, specs), drop them in the `context/inbox/` folder and say "check the inbox." The team reads them, briefs you, and files them.

---

## For an existing codebase

If you already have code (from another AI tool, a developer, or yourself):

1. Open the folder and say hello
2. Tell the team you have existing code
3. The team reads everything, runs a health check, and gives you a clear report: what works, what's broken, what to fix first
4. Drop any documents into `context/inbox/`
5. Start building from there

The team doesn't judge how the code was written. It reads it, understands it, and helps you make it production-ready.

---

## How to know things are working

The team shows you proof, not promises. After every build:

- **Test results** — "14 passing, 0 failing" with actual output
- **Build status** — "Build succeeded" with actual output
- **Security check** — "No vulnerabilities found" with actual scan results
- **Quality review** — specific findings with severity levels
- **Acceptance criteria** — each requirement checked off with evidence

If something fails, the team explains what went wrong, fixes it, and re-verifies. You see the whole process.

---

## Tips

1. **Just talk.** Don't try to give technical instructions. Describe what you want your users to experience, and the team translates that into code.
2. **Start small.** "I want a simple page that shows X" is better than "I want a full platform with 20 features." The team will help you scope it down if needed.
3. **Drop files, don't explain them.** Put a client email in the inbox and say "check the inbox." The team reads it and briefs you.
4. **Nothing ships without your approval.** The team shows you the plan and waits. You're always in control.
5. **Don't worry about "doing it wrong."** There's no wrong way to talk to the team. If something is unclear, they ask.
6. **If something looks off, say so.** "That doesn't look right" or "I expected something different" is enough. The team investigates.

---

## What makes this different from regular AI coding

Most AI coding tools generate code when you ask. This team operates like a real engineering organization:

- **Planning before building** — so you don't build the wrong thing
- **Tests before code** — so bugs get caught during development, not after launch
- **Code review** — so quality issues get fixed before they become problems
- **Security review** — so vulnerabilities get caught before your users are at risk
- **Evidence-based verification** — so "it works" means "here's proof it works"
- **Self-healing** — so you don't have to debug errors yourself
- **Structured debugging** — so bugs get fixed at the root cause, not patched over
- **Scope discipline** — so your project doesn't balloon into something unfinishable
- **Clean removal** — so replaced code gets fully deleted, not left as dead weight
- **Progress saving** — so every session picks up exactly where the last one left off
- **Institutional memory** — so decisions, preferences, and context survive across sessions, weeks, and months
- **Codebase awareness** — so the team understands the full architecture before making changes

The result: production-grade software built as if your livelihood, income, and reputation depend on it. Because for many founders, they do.
