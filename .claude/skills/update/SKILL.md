---
name: update
description: Save all session decisions, conclusions, and context to memory and STATUS.md so the team stays current across instances. Use when you say /update, "save this", "update yourselves", or at the end of any significant session.
user-invocable: true
---

# /update — Team State Sync

When this skill is triggered, perform ALL of the following steps:

## Step 1: Review the conversation

Scan the current conversation for:
- **Decisions made** (technical, architectural, scope, business)
- **New context learned** (from documents, verbal context, or Q&A)
- **Action items** identified (including casual mentions like "we should also fix X", "don't forget to Y", "we'll need to Z eventually")
- **User's knowledge growth** (new concepts now understood)
- **Open questions** that still need answers
- **Changes to project direction or priorities**
- **Completed work** that may resolve existing action items

## Step 2: Update memory files

For each relevant memory file in the memory directory:
- Read the current content
- Update with new information from this session
- If a new memory is needed (new topic not covered by existing files), create it
- Update MEMORY.md index if new files were created

Memory types to check:
- `user_[name]_profile.md` — Did the user demonstrate new knowledge or preferences?
- `project_[name]_status.md` — Did the project status, phase, or timeline change?
- `project_[stakeholder]_context.md` — Did we learn anything new about a key stakeholder or their expectations?
- `project_technical_decisions_[phase].md` — Were any technical decisions made or refined?
- `feedback_*.md` — Did the user give any feedback on how the team should operate?

## Step 3: Update ACTION-ITEMS.md

Read `context/ACTION-ITEMS.md` and perform ALL of the following:

### 3a: Capture new action items
Scan the conversation for anything that implies work to be done. This includes:
- Explicit requests ("we need to build X")
- Casual mentions ("we should also fix Y", "don't forget Z", "eventually we'll want W")
- Open questions that need follow-up ("need to check with [person] about X")
- Bugs discovered during the session
- Technical debt identified
- Follow-ups from code review or testing

For each new item, assign the next available ID from the `next_id` counter, increment the counter, and add it to the **Open** section using the standard format:
```
### [AI-NNN] Title
- **Status:** open
- **Priority:** critical | high | medium | low
- **Category:** feature | bug | debt | ops | research | docs
- **Source:** [Session date, inbox file name, verbal context, plan file, casual mention, etc.]
- **Created:** YYYY-MM-DD
- **Updated:** YYYY-MM-DD
- **Notes:** [Context about what this is and why it matters]
```

Priority guidelines:
- **critical:** Blocks other work or affects production
- **high:** Important for current phase, should be done soon
- **medium:** Should be done but not urgent
- **low:** Nice to have, do when convenient

### 3b: Update existing items
- Move items that were **worked on this session** to "In Progress" (or "Done" if completed)
- For completed items: set `Status: done`, add `Completed: YYYY-MM-DD`, move to "Done (Recent)"
- Update the `Updated` date on any item that was discussed or modified
- If an item is now blocked, move to "Blocked" and fill in `Blocked by`

### 3c: Staleness check
- Flag any open items with `Updated` date older than 30 days → move to "Stale Review Queue"
- Trim "Done (Recent)" — move items completed more than 3 sessions ago to "Archive"
- Prune Archive items older than 90 days (unless they have historical significance noted)

### 3d: Deduplication
- Check for duplicate or overlapping items. If found, merge them (keep the lower ID, note the merge)

## Step 4: Update STATUS.md

Read `context/STATUS.md` and update:
- **Last updated** date
- **Current Status** section if phase or timeline changed
- **App Build Status** table if any development work was done
- **Engineering Team Decisions** section if new decisions were made
- **What's Coming Next** section if priorities shifted
- Add any new sections needed

## Step 5: Process inbox (if applicable)

Check `context/inbox/` for unprocessed files. If any exist:
- Read and analyze each file
- Brief on contents
- Move to appropriate folder (requirements/, communications/, archive/*, etc.)
- Update STATUS.md with new information
- Extract any action items and add to ACTION-ITEMS.md (per Step 3a)

## Step 6: Log decisions

If significant decisions were made this session, create or update files in `context/decisions/` with:
- The decision
- Why it was made
- Who was involved
- Date
- Impact on the build

## Step 7: Save to MemPalace (REQUIRED if installed)

There is no auto-mining — explicit calls during `/update` are the ONLY way memories persist across sessions. Skipping this step means the next session starts blind to anything important from this one.

First check availability: call `mempalace_status`. If it returns an error or "not configured", skip this step. If it returns OK, proceed:

For each significant item from this session, call `mempalace_add_drawer` with the appropriate room:

| Type of memory | Room |
|---|---|
| Architectural decision (chose X over Y) | `decisions` |
| User preference ("I always want X", "never do Y") | `preferences` |
| Stakeholder constraint (deadline, requirement, scope limit) | `stakeholders` |
| Bug discovered + root cause | `bugs` |
| Feature scope decision (in/out, MVP cut) | `features` |
| Performance optimization or bottleneck found | `performance` |
| Security decision or compliance requirement | `security` |
| Deployment / hosting / CI choice | `deployment` |
| Database / pipeline / migration choice | `data` |
| Anything else worth remembering | `architecture` (catch-all) |

For each call:
- `agent_name`: which team member is saving (e.g., "Sara", "Maya", "Jake")
- `entry`: 2-3 sentences capturing the WHAT and WHY (not the how — that's in the code)
- `room`: from the table above

Then for any structured fact-relationships worth indexing (e.g., "AuthMiddleware depends on JWT", "BillingService uses Stripe"), call `mempalace_kg_add` with subject/predicate/object.

Do NOT save: code snippets, command output, transient state, or anything already captured in STATUS.md or ADRs. MemPalace is for the "why" and "what was rejected" — not the "what is".

## Step 8: Confirm

After updating, provide a brief summary:
- What was saved/updated
- **Action items:** N new, N updated, N completed, N total open
- Any open items that need attention next session
- Current project state in one sentence

## When to trigger automatically

This skill should also run automatically (without being asked) when:
- A significant decision point is reached
- New context from inbox has been processed
- A build phase or milestone is completed
- The session is clearly winding down
- User says anything like "save this", "remember this", "update yourselves", "don't forget"
